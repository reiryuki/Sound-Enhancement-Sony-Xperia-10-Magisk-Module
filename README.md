# Sound Enhancement & Dolby Atmos Sony Xperia 10 Magisk Module

## DISCLAIMER
- Dolby & Sony apps and blobs are owned by Dolby™ and Sony™.
- The MIT license specified here is for the Magisk Module only, not for Dolby nor Sony apps and blobs.

## Description
- Equalizers global type sound effects ported from Sony Xperia 10 (I4113) and integrated as a Magisk Module for all supported and rooted devices with Magisk
- Dolby Atmos changes/spoofs ro.product.manufacturer to Sony which may break some system apps and features functionality
- Dolby Atmos conflicted with `vendor.dolby.hardware.dms@2.0-service`
- Sound Enhancement doesn't support ACDB Magisk Module because using effect proxy

## Sources
- https://dumps.tadiphone.dev/dumps/sony/i4113 kirin_dsds-user-10-53.1.A.2.2-053001A00020000200894138764-release-keys
- libhscomp_jni.so & libhscomp.so: https://dumps.tadiphone.dev/dumps/sony/akari akari-user-9-TAMA2-2.0.1-191021-1837-1-dev-keys
- system_dolby: https://dumps.tadiphone.dev/dumps/sony/xq-at51 qssi-user-10-58.0.A.3.31-058000A003003102854466984-release-keys
- libhidlbase.so, libhidltransport.so, & libhwbinder.so: CrDroid ROM Android 13
- libutils.so: LineageOS 23 Android 16 BP2A.250605.031.A2 1758630651
- libmagiskpolicy.so: Magisk (debug) 31.0 (31000)

## Screenshots
https://t.me/androidryukimodsdiscussions/144433

## Requirements
- Android 10 (SDK 29) and up
- Magisk or Kitsune Mask or KernelSU or Apatch installed
- Sound Enhancement:
  - armeabi-v7a or arm64-v8a with armeabi-v7a support architecture
  - 32 bit HIDL audio service
- Dolby Atmos:
  - arm64-v8a architecture
  - HIDL audio service
  - Recommended to use Magisk Delta/Kitsune Mask for systemless early init mount manifest.xml if your ROM is Read-Only https://t.me/ryukinotes/49

## Download Links and Changelog

v1.2.5 https://github.com/reiryuki/Sound-Enhancement-Sony-Xperia-10-Magisk-Module
- Update libmagiskpolicy.so from Magisk (debug) 31.0 (31000)
- Prepare /storage/emulated/"$UID"/Android/data/$PKG/ directories
- Add a new optional dolby.mod_xml to let users to use any modified/custom dax-default.xml. Please read Optionals below.

v1.2.4 https://move2link.co/6af720e
- Dolby Atmos:
  - Fix manifest.xml detection bug in some ROMs
  - Fix sepolicy denial

v1.2.3
- AudioSettings.apk v1.8
  - Executes sefx command automatically via app launcher (if the root access is granted) so you don't need to run sefx via Termux/Terminal manually
  - Fix launch animation dark theme if battery saver is on in AOSP
- Dolby Atmos:
  - Check functions in mirror /apex files instead of mirror /system if exist
  - Remove hardware services conflict restart (Use this instead: https://github.com/reiryuki/Hardware-Services-Restarter-Magisk-Module)
  - Fix sepolicy denial

v1.2.2
- Dolby Atmos: Fix inaccessible libhwbinder.so in some ROMs
- AudioSettings.apk v1.7: Fix launch animation

v1.2.1
- AudioSettings.apk v1.6
- Support NoMount metamodule
- Resets module folders/files permissions at post-fs-data
- Move _uninstall.log to /data/adb/logs/
- Dolby Atmos: Hides in-built LunarisDolby.apk
- Removes conflicted weird modules

v1.2.0
- Update libmagiskpolicy.so from Magisk (stable) 30.7 (30700) (fixes sepolicy denials in KernelSU)
- Does not disable raw playback (You can use Audio Compatibility Patch Reborn Magisk Module instead)

v1.1.9
- Fix wrong target in latest KernelSU
- Improve detections

v1.1.8
- Dolby Atmos: Fix wrong manifest.xml location patch target in latest Magisk version

v1.1.7
- Using startService instead of startForegroundService to fix crash in KernelSU
- Tidy up aml.sh
- Exclude \*audio\*effects\*haptic\*.xml
- Fix wrong file permissions in some ROMs

v1.1.6
- Dolby Atmos:
  - Fix ZN7android8String16aSEOS0 function not found in some ROMs
  - Add libutils.so as system_support
  - Move DaxUI.apk 36dB to priv-app
- Abort if failed to mount mirror system at installation

## Download Tutorial
https://t.me/ryukinotes/97

## WARNING!!!
Possibility of bootloop or even softbrick or a service failure on Read-Only ROM with the Dolby Atmos if you don't use Magisk Delta/Kitsune Mask.

## Installation Guide
- Recommended to use Magisk Delta/Kitsune Mask if Dolby Atmos is activated https://t.me/ryukinotes/49
- Remove any other else Dolby MAGISK MODULE with different name (no need to remove if it's the same name) if Dolby Atmos is activated
- Reboot
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs or https://github.com/KernelSU-Modules-Repo/magic_mount_rs or https://github.com/KernelSU-Modules-Repo/hybrid_mount or https://github.com/maxsteeel/nomount first depending on ROM compatibility
- If you have Dolby in-built in your ROM, then you need to activate data.cleanup=1 at the first time install (READ Optionals below!)
- Install this module via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Install AML Magisk Module https://t.me/ryukinotes/34 only if using any other else audio mod module
- Reboot
- Disable the "No active profiles" notification and ignore it it's nothing
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package-dolby.txt (and your home launcher app also) (enable show system apps) and reboot afterwards
- If you are using SUList, you need to allow list manually your home launcher app (enable show system apps) and reboot afterwards
- If you have vibrator, camera, charging/USB, SIM card/RIL, display, brightness, WiFi, thermal, and sensors issues (fingerprint, proximity, gyroscope, etc.), then install https://github.com/reiryuki/Hardware-Services-Restarter-Magisk-Module also
- Play music and launch the Sound Enhancement app (grant the root access to execute sefx command automatically)
- You can also run sefx via Terminal/Termux app while playing music:

  `su`
  
  `sefx`

- If sefx command triggers integrity failure in your ROM then you can use Xperia Music instead: https://github.com/reiryuki/Xperia-Music-Magisk-Module and choose Sound effects in the app

## Optionals
- https://t.me/ryukinotes/56
- Global: https://t.me/ryukinotes/35
- Stream: https://t.me/ryukinotes/52

## Troubleshootings
- https://t.me/ryukinotes/56
- Global: https://t.me/ryukinotes/34

## Support and Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- @HuskyDG
- @HELLBOY017
- https://t.me/viperatmos
- https://t.me/androidryukimodsdiscussions
- https://t.me/androidappsportdevelopment

## Sponsors and Donation
https://t.me/ryukinotes/25


