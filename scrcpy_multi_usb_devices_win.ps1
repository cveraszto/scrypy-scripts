$SCRCPY = ".\scrcpy.exe"
$ADB = ".\adb.exe"

# --- get devices ---
$devices = & $ADB devices | Select-String "device" | ForEach-Object {
    ($_ -split "\s+")[0]
}

if (-not $devices) {
    Write-Host "No USB devices found"
    exit 1
}

# --- cleanup / kill switch ---
$script:jobs = @()

function Cleanup {
    Write-Host ""
    Write-Host "Stopping all scrcpy sessions..."

    # kill scrcpy processes
    Get-Process scrcpy -ErrorAction SilentlyContinue | Stop-Process -Force

    # disable stay-on
    foreach ($serial in $devices) {
        & $ADB -s $serial shell svc power stayon false | Out-Null
    }

    exit 0
}

# Ctrl+C handler
Register-EngineEvent ConsoleCancelKeyPress -Action {
    Cleanup
} | Out-Null

# --- launch loop ---
foreach ($serial in $devices) {

    Write-Host "Starting scrcpy for $serial"

    # prevent sleep
    & $ADB -s $serial shell svc power stayon true | Out-Null

    # max brightness
    & $ADB -s $serial shell settings put system screen_brightness 255 | Out-Null

    # get resolution
    $sizeRaw = & $ADB -s $serial shell wm size
    if ($sizeRaw -match "(\d+)x(\d+)") {
        $width = [int]$matches[1]
        $height = [int]$matches[2]
    } else {
        $width = 0
        $height = 0
    }

    # crop settings
    $cropW = 700
    $cropH = 700
    $cropX = 490
    $cropY = 610

    $cropOpt = ""

    if (($cropX + $cropW) -le $width -and ($cropY + $cropH) -le $height) {
        Write-Host "  Using crop for board"
        $cropOpt = "--crop 700:700:490:610"
    } else {
        Write-Host "  Fallback to full screen"
    }

    # start scrcpy in background
    Start-Process -NoNewWindow -FilePath $SCRCPY -ArgumentList @(
        "--serial", $serial,
        $cropOpt,
        "--max-size", "700",
        "--max-fps", "30",
        "--video-bit-rate", "2M",
        "--no-control"
    )
}

Write-Host "All scrcpy sessions started."
Write-Host "Press Ctrl+C to stop everything."

# keep script alive
while ($true) { Start-Sleep 1 }