#!/usr/bin/env bash

adb kill-server

adb start-server

adb devices

adb remount /system/etc/permissions/handheld_core_hardware.xml rw

adb push handheld_core_hardware.xml /system/etc/permissions/handheld_core_hardware.xml

adb shell pm disable com.android.launcher

adb shell pm disable com.android.systemui

adb shell pm disable com.android.browser

adb shell pm disable com.android.calculator2

adb shell pm disable com.android.calendar

adb shell pm disable com.android.deskclock

adb shell pm disable com.android.providers.downloads.ui

adb shell pm disable com.android.email

adb shell pm disable net.micode.fileexplorer

adb shell pm disable com.android.gallery3d

adb shell pm disable com.android.soundrecorder

adb shell pm disable com.google.android.gm

adb shell pm disable com.google.android.gms

adb shell pm disable com.google.android.apps.maps

adb shell pm disable com.android.music

adb shell pm disable com.mxtech.videoplayer.ad

adb shell pm disable com.android.notepad

adb shell pm disable com.android.vending

adb shell pm disable com.android.fmradio

adb uninstall org.baobabhealth.myusb.myusb

adb install app-release.apk

