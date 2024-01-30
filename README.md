# Sound Enhancement & Dolby Atmos Sony Xperia 10 Magisk Module

## DISCLAIMER
- Dolby & Sony apps and blobs are owned by Dolby™ and Sony™.
- The MIT license specified here is for the Magisk Module only, not for Dolby nor Sony apps and blobs.

## Descriptions
- Equalizers soundfx ported from Sony Xperia 10 (I4113) and integrated as a Magisk Module for all supported and rooted devices with Magisk
- Global type soundfx
- Dolby Atmos changes/spoofs ro.product.manufacturer to Sony which may break some system apps and features functionality
- Dolby Atmos conflicted with `vendor.dolby.hardware.dms@2.0-service`
- Sound Enhancement doesn't support ACDB Magisk Module because using effect proxy

## Sources
- https://dumps.tadiphone.dev/dumps/sony/i4113 kirin_dsds-user-10-53.1.A.2.2-053001A00020000200894138764-release-keys
- libhscomp_jni.so & libhscomp.so: https://dumps.tadiphone.dev/dumps/sony/akari akari-user-9-TAMA2-2.0.1-191021-1837-1-dev-keys
- system_dolby: https://dumps.tadiphone.dev/dumps/sony/xq-at51 qssi-user-10-58.0.A.3.31-058000A003003102854466984-release-keys
- system_support: CrDroid ROM Android 13

## Screenshots
- https://t.me/androidryukimodsdiscussions/144433

## Requirements
- Sound Enhancement:
  - 32 bit architecture or 64 bit architecture with 32 bit library support
  - Android 10 and up
  - Magisk or KernelSU installed
- Dolby Atmos:
  - 64 bit architecture
  - Android 10 and up
  - Magisk or KernelSU installed (Recommended to use Magisk Delta/Kitsune Mask for systemless early init mount manifest.xml if your ROM is Read-Only https://t.me/androidryukimodsdiscussions/100091)

## WARNING!!!
- Possibility of bootloop or even softbrick or a service failure on Read-Only ROM with the Dolby Atmos if you don't use Magisk Delta/Kitsune Mask.

## Installation Guide & Download Link
- Recommended to use Magisk Delta/Kitsune Mask if Dolby Atmos is activated https://t.me/androidryukimodsdiscussions/100091
- Don't use ACDB Magisk Module!
- Remove any other else Dolby Magisk module with different name (no need to remove if it's the same name) if Dolby Atmos is activated
- Reboot
- If you have Dolby in-built in your ROM, then you need to activate data.cleanup=1 at the first time install (READ Optionals bellow!)
- Install this module https://www.pling.com/p/1531791/ via Magisk app or KernelSU app or Recovery if Magisk installed
- Install AML Magisk Module https://t.me/androidryukimodsdiscussions/29836 only if using any other else audio mod module
- Disable the "No active profiles" notification and ignore it it's nothing
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package-dolby.txt (and your home launcher app also) (enable show system apps) and reboot after
- If you are using SUList, you need to allow list manually your home launcher app (enable show system apps) and reboot after
- Play a music with any app that uses external EQ like Xperia Music, YouTube Music, or Spotify first, otherwise Sound Enhancement will not work with player that doesn't use external EQ like YouTube and SoundCloud (this trick can't be working if you are activating music stream mode optional)

## Optionals & Troubleshootings
- https://t.me/androidryukimodsdiscussions/25187
- Global: https://t.me/androidryukimodsdiscussions/29836
- Global: https://t.me/androidryukimodsdiscussions/60861
- Stream: https://t.me/androidryukimodsdiscussions/26764

## Support & Bug Report
- https://t.me/androidryukimodsdiscussions/2618
- If you don't do above, issues will be closed immediately

## Tested on
- Android 10 CrDroid ROM
- Android 11 DotOS ROM
- Android 12 AncientOS ROM
- Android 12.1 Nusantara ROM
- Android 13 AOSP ROM, CrDroid ROM, & AlphaDroid ROM
- Android 14 LineageOS ROM (Sound Enhancement only)

## Known Issue
- Dolby Atmos is unsupported in some Android 14 ROMs

## Credits and contributors
- https://t.me/viperatmos
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Thanks for Donations
This Magisk Module is always will be free but you can however show us that you are care by making a donations:
- https://ko-fi.com/reiryuki
- https://www.paypal.me/reiryuki
- https://t.me/androidryukimodsdiscussions/2619


