#!/usr/bin/env bash

clear

STR=$'\n\n\tConnect device to PC using the PC device USB cable and then press [ENTER]:'

echo "$STR"

read result

adb uninstall org.baobabhealth.myusb.myusb

adb install app-release.apk

clear

adb shell pm enable com.android.systemui

clear

STR=$'\n\n\tDisconnect the PC-device USB cable and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tConnect USB printer to device and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tOn the popup that shows up on the device screen, check the option "Use by default for this USB device" and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tClick the OK button on the device and then press [ENTER]:'

echo "$STR"

read result

clear

clear

STR=$'\n\n\tWhen running the application, point it to the specific target application\n\t\tserver path whether Order entry for wards:\n\n\t\te.g. "{PROTOCOL}://{IP ADDRESS}:{PORT}/"\n\n\t\tor Lab for laboratories\n\n\t\te.g. "{PROTOCOL}://{IP ADDRESS}:{PORT}/lab"\n\n\t\twhere:\n\n\t\tPROTOCOL: 	is http / https\n\t\tIP ADDRESS: is server IP address e.g. 127.0.0.1\n\t\tPORT:				is server port e.g. 3000\n\n\t and then press [ENTER]:'

echo "$STR"

read result

clear 

STR=$'\n\n\tReconnect the PC-device USB cable and then press [ENTER]:'

echo "$STR"

read result

clear

adb kill-server

adb start-server

adb devices

sleep 1

adb shell pm disable com.android.systemui

adb shell pm disable com.google.android.apps.maps

# adb tcpip 5555

adb shell pm disable com.android.launcher

adb shell reboot

clear

STR=$'\n\n\tDone!'

echo "$STR"


