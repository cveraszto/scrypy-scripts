#!/bin/bash

SCRCPY="./scrcpy"
ADB="./adb"

DEVICES=$($ADB devices | awk 'NR>1 && $2=="device" {print $1}')

if [ -z "$DEVICES" ]; then
    echo "No USB devices found"
    exit 1
fi

# --- cleanup function (if you press CTRL + C you stop all processes, kill switch) ---
cleanup() {
    echo ""
    echo "Stopping all scrcpy sessions..."

    pkill -f scrcpy 2>/dev/null

    # optional: disable stay-on again
    for SERIAL in $DEVICES; do
        $ADB -s "$SERIAL" shell svc power stayon false
    done

    exit 0
}

trap cleanup SIGINT SIGTERM

for SERIAL in $DEVICES; do
    echo "Starting scrcpy for $SERIAL"

    # prevent sleep
    $ADB -s "$SERIAL" shell svc power stayon true

    # max brightness
    $ADB -s "$SERIAL" shell settings put system screen_brightness 255

    # get device resolution to see device specs
    SIZE=$($ADB -s "$SERIAL" shell wm size | grep -oE "[0-9]+x[0-9]+")
    WIDTH=$(echo "$SIZE" | cut -d'x' -f1)
    HEIGHT=$(echo "$SIZE" | cut -d'x' -f2)

    # ichessone board crop dimensions --- when scaling is switched off ---
    CROP_W=700
    CROP_H=700
    CROP_X=490
    CROP_Y=610

    # check if crop fits
    if [ $((CROP_X + CROP_W)) -le "$WIDTH" ] && [ $((CROP_Y + CROP_H)) -le "$HEIGHT" ]; then
        echo "  Now using crop for ichessone's board dimensions"
        CROP_OPT="--crop ${CROP_W}:${CROP_H}:${CROP_X}:${CROP_Y}"
    else
        echo "  Now fallback to full screen"
        CROP_OPT=""
    fi

    "$SCRCPY" --serial "$SERIAL" \
        $CROP_OPT \
        --max-size 700 \
        --max-fps 30 \
        --video-bit-rate 2M \
        --no-control </dev/null &

done

wait