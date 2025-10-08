# Sound Enhancement & Dolby Atmos Sony Xperia 10 Magisk Module

## DISCLAIMER
- Dolby & Sony apps and blobs are owned by Dolby™ and Sony™.
- The MIT license specified here is for the Magisk Module only, not for Dolby nor Sony apps and blobs.

## Descriptions
- Equalizers sound effect ported from Sony Xperia 10 (I4113) and integrated as a Magisk Module for all supported and rooted devices with Magisk
- Global type sound effect
- Dolby Atmos changes/spoofs ro.product.manufacturer to Sony which may break some system apps and features functionality
- Dolby Atmos conflicted with `vendor.dolby.hardware.dms@2.0-service`
- Sound Enhancement doesn't support ACDB Magisk Module because using effect proxy

## Sources
- https://dumps.tadiphone.dev/dumps/sony/i4113 kirin_dsds-user-10-53.1.A.2.2-053001A00020000200894138764-release-keys
- libhscomp_jni.so & libhscomp.so: https://dumps.tadiphone.dev/dumps/sony/akari akari-user-9-TAMA2-2.0.1-191021-1837-1-dev-keys
- system_dolby: https://dumps.tadiphone.dev/dumps/sony/xq-at51 qssi-user-10-58.0.A.3.31-058000A003003102854466984-release-keys
- libhidlbase.so, libhidltransport.so, & libhwbinder.so: CrDroid ROM Android 13
- libutils.so: LineageOS 23 Android 16 BP2A.250605.031.A2 1758630651
- libmagiskpolicy.so: Kitsune Mask R6687BB53

## Screenshots
- https://t.me/androidryukimodsdiscussions/144433

## Requirements
- Sound Enhancement:
  - armeabi-v7a or arm64-v8a architecture
  - 32 bit audio service (this also can be found in 64 bit ROM with 32 bit support, not only 32 bit ROM)
  - Android 10 (SDK 29) and up
  - Magisk or KernelSU installed
- Dolby Atmos:
  - arm64-v8a architecture
  - Android 10 (SDK 29) and up
  - Magisk or KernelSU installed (Recommended to use Magisk Delta/Kitsune Mask for systemless early init mount manifest.xml if your ROM is Read-Only https://t.me/ryukinotes/49)

## WARNING!!!
- Possibility of bootloop or even softbrick or a service failure on Read-Only ROM with the Dolby Atmos if you don't use Magisk Delta/Kitsune Mask.

## Installation Guide & Download Link
- Recommended to use Magisk Delta/Kitsune Mask if Dolby Atmos is activated https://t.me/ryukinotes/49
- Remove any other else Dolby MAGISK MODULE with different name (no need to remove if it's the same name) if Dolby Atmos is activated
- Reboot
- If you have Dolby in-built in your ROM, then you need to activate data.cleanup=1 at the first time install (READ Optionals bellow!)
- Install this module https://www.pling.com/p/1531791/ via Magisk app or KernelSU app or Recovery if Magisk installed
- Install AML Magisk Module https://t.me/ryukinotes/34 only if using any other else audio mod module
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings
- Reboot
- Disable the "No active profiles" notification and ignore it it's nothing
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package-dolby.txt (and your home launcher app also) (enable show system apps) and reboot afterwards
- If you are using SUList, you need to allow list manually your home launcher app (enable show system apps) and reboot afterwards
- If you have sensors issue (fingerprint, proximity, gyroscope, etc), then READ Optionals bellow!
- If Sound Enhancement effect doesn't work, then type:

  `su`
  
  `sefx`
  
  at Terminal/Termux app while playing music

## Optionals
- https://t.me/ryukinotes/56
- Global: https://t.me/ryukinotes/35
- Stream: https://t.me/ryukinotes/52

## Troubleshootings
- https://t.me/ryukinotes/56
- Global: https://t.me/ryukinotes/34

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- @HuskyDG
- https://t.me/viperatmos
- https://t.me/androidryukimodsdiscussions
- @HELLBOY017
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
- https://t.me/ryukinotes/25


