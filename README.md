## Scrcpy Multi-Device USB scripts

Simple utilities for managing and controlling multiple Android devices over USB using scrcpy and ADB.

Contents

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
Make sure the following are installed:

scrcpy
Android Debug Bridge
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
