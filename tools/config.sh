#!/usr/bin/env bash

clear

STR=$'\n\n\tConnect device to PC using the PC device USB cable and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tOn the device, select "Settings" and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tClick menu entry "{} Developer options" and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tMake sure option "USB debugging" is checked and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tClose menu and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tOn "Settings" menu, enable "WLAN" and select the menu and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tAdd device to network which can provide access to the target server instance and then press [ENTER]:'

echo "$STR"

read result

clear

STR=$'\n\n\tConfiguring device, Please Wait...\n\n\n'

echo "$STR"

adb kill-server

adb start-server

adb devices

sleep 1

adb shell pm disable com.google.android.apps.maps

adb shell pm disable com.android.browser

adb shell pm disable com.android.calculator2

adb shell pm disable com.android.calendar

adb shell pm disable com.android.camera

adb shell pm disable com.android.deskclock

adb shell pm disable com.android.providers.downloads.ui

adb shell pm disable com.android.email

adb shell pm disable net.micode.fileexplorer

adb shell pm disable com.android.gallery3d

adb shell pm disable com.android.soundrecorder

adb shell pm disable com.google.android.gm

adb shell pm disable com.google.android.gms

adb shell pm disable com.android.music

adb shell pm disable com.mxtech.videoplayer.ad

adb shell pm disable com.android.notepad

adb shell pm disable com.android.fmradio

adb shell am start -n org.baobabhealth.myusb.myusb/.RemoveShortcut

adb uninstall org.baobabhealth.myusb.myusb

adb install app-release.apk

adb shell pm disable com.android.vending

# adb shell pm clear com.android.launcher

# adb pull /system/app/MarketUpdater.apk
# adb pull /system/app/GooglePlay.apk .
# adb remount /system/app/GooglePlay.apk rw
# adb shell rm /system/app/GooglePlay.apk

sleep 1

adb shell am start -n org.baobabhealth.myusb.myusb/.shortcut

adb remount /system/etc/permissions/handheld_core_hardware.xml rw

adb push handheld_core_hardware.xml /system/etc/permissions/handheld_core_hardware.xml

adb shell reboot

clear

STR=$'\n\n\tWait for device to reboot and then press [ENTER]:'

echo "$STR"

read result

adb kill-server

adb start-server

adb devices

sleep 1

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

adb shell reboot

clear

STR=$'\n\n\tDone!'

echo "$STR"


