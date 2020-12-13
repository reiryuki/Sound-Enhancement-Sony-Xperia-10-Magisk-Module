# Sony Xperia 10 Sound Enhancement

## Descriptions
- An equalizer ported from Sony Xperia 10 (I4113)
- Effects only working with Music apps that has EQ option
- Doesn't support ACDB because using effect proxy
- Not friendly with other audio mods
- Will take about 3 minutes after device boot until the effect is started
- DSEEHX is not working properly yet (even the toggle is fixed) because it's need IDD HW service. Will add it later.

## Requirements
- Android 10 or 11

## Tested
- Android 10 arm64 CrDroid ROM

## Installation Guide
- Don't use ACDB!
- Install the module via Magisk Manager only
- Reboot

## Optional
- You can edit /data/adb/modules_update/SoundEnhancement/system/vendor/etc/sony_effect/effect_params.data to any value as you wish to get more xloud (dynamic normalizer) and clear audio effects. 

## Troubleshootings
- Install Audio Modification Library module if you using other audio mods
- Delete /data/adb/modules/SoundEnhancement via recovery if facing bootloop and send copied and zipped /data/system/dropbox files for fix
- Open issues and send full logcats if this module is not working for your device

## Attention!
- Always make nandroid backup before install or updating version, these are just experiments!
- Don't report anything without logcats!
- Special thanks to all people that helped and tested my modules.

## Telegram
- https://t.me/audioryukimods
- https://t.me/modsandco

## Donate
- https://www.paypal.me/reiryuki

## Download
- Tap "Releases"
