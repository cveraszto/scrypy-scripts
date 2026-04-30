# Requires PowerShell 7+ (pwsh)
# Works on Windows, Linux, macOS

Write-Host "Starting script.."

$ADB = "./adb"
$SCRCPY = "./scrcpy"

# --- Get only valid "device" entries (strict filtering like bash) ---
$devices = & $ADB devices |
    Select-Object -Skip 1 |
    Where-Object { $_ -match "\tdevice$" } |
    ForEach-Object { ($_ -split "\t")[0] }

if (-not $devices) {
    Write-Host "No USB devices found"
    exit 1
}

# --- Cleanup handler ---
$cleanup = {
    Write-Host "`nStopping all SCRYPY sessions..."

    Get-Process scrcpy -ErrorAction SilentlyContinue | Stop-Process -Force

    foreach ($serial in $devices) {
        & $ADB -s $serial shell svc power stayon false | Out-Null
    }

    exit 0
}

# Ctrl+C handling (cross-platform)
[Console]::CancelKeyPress += {
    $_.Cancel = $true
    & $cleanup
}

$processes = @()

foreach ($serial in $devices) {
    Write-Host "Starting SCRYPY for $serial"

    # Prevent sleep + max brightness
    & $ADB -s $serial shell svc power stayon true | Out-Null
    & $ADB -s $serial shell settings put system screen_brightness 255 | Out-Null

    # --- Get resolution ---
    $sizeRaw = & $ADB -s $serial shell wm size

    if ($sizeRaw -match "(\d+)x(\d+)") {
        $width = [int]$matches[1]
        $height = [int]$matches[2]
    } else {
        Write-Host "  Could not determine resolution, fallback to fullscreen"
        $width = 0
        $height = 0
    }

    # --- Crop config ---
    $CROP_W = 700
    $CROP_H = 700
    $CROP_X = 490
    $CROP_Y = 610

    $args = @("--serial", $serial,
              "--max-size", "700",
              "--max-fps", "30",
              "--video-bit-rate", "2M",
              "--no-control")

    if (($CROP_X + $CROP_W -le $width) -and ($CROP_Y + $CROP_H -le $height)) {
        Write-Host "  Using crop"
        $args += @("--crop", "$CROP_W`:$CROP_H`:$CROP_X`:$CROP_Y")
    } else {
        Write-Host "  Fallback to full screen"
    }

    # --- Start process and track it ---
    $proc = Start-Process -FilePath $SCRCPY -ArgumentList $args -PassThru
    $processes += $proc
}

Write-Host "`nAll SCRYPY sessions started. Press Ctrl+C to stop."

# --- Wait for all scrcpy processes (like bash `wait`) ---
foreach ($p in $processes) {
    $p.WaitForExit()
}

& $cleanup