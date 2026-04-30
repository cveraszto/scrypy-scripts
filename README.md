## Scrcpy Multi-Device USB scripts

Simple scripts for managing scrypy window of devices (phones, tablets) over USB.
Cropping is optimised for ichessone App running to just show the board. Scaling should be unticked in the App to avoid the jumping of the board. 

## Contents

This repository includes one script for 3 environments: # scrypy-scripts
```bash
scrcpy_multi_usb_devices_crossplatform.ps1
```
```bash
scrcpy_multi_usb_devices_win.ps1
```
```bash
scrcpy_multi_usb_devices_linux.sh
```

### Requirements
Make sure your devices have developer mode activated. 
Make sure the following are installed:

scrcpy
Python 3.8+

### Setup
Enable USB Debugging on all Android devices
Connect devices via USB
Verify detection:
adb devices

You should see a list of connected devices.

### Usage

Enable script with chmod +x if necessary.
Run scripts. 

### Description

The scripts all do the same: 
- They loop through all connected devices 
    - They will keep the devices from sleeping while the script is active, and will adjust screen brightness to 255.
    - They check for device resolution and and start a cropped scrypy window or fall back to full screen. 
    - FPS 30 and no-control, so you can only observe.
- You can stop the script and all scrypy connection with the kill switch CTRL + C. 


### Project Structure
```bash
.
├── README.md
├── scrcpy_multi_usb_devices_crossplatform.ps1
├── scrcpy_multi_usb_devices_win.ps1
├── scrcpy_multi_usb_devices_linux.sh
```

### Troubleshooting

Device not showing:

adb kill-server
adb start-server
adb devices

### Author

cveraszto
