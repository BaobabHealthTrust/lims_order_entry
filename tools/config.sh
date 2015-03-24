#!/usr/bin/env bash

adb kill-server

adb start-server

adb devices

adb remount /system/etc/permissions/handheld_core_hardware.xml rw

adb push handheld_core_hardware.xml /system/etc/permissions/handheld_core_hardware.xml

adb uninstall org.baobabhealth.myusb.myusb

adb install app-release.apk

