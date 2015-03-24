#!/usr/bin/env bash

adb kill-server

adb start-server

adb devices

sleep 1

adb shell pm disable com.google.android.apps.maps

adb shell pm disable com.android.systemui

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

