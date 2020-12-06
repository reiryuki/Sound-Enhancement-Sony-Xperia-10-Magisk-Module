# Sony Xperia 10 Sound Enhancement

## Descriptions
- An equalizer ported from Sony Xperia 10 (I4113)
- Only working with apps that has EQ option
- Doesn't support ACDB because using effect proxy
- Not friendly with other audio mods
- DSEEHX toggle only appear through Audio Settings launcher
- Audio Settings launcher is need root access to work

## Requirements
- Android 10 or 11

## Tested
- Android 10 arm64 CrDroid ROM

## Installation Guide
- Don't use ACDB!
- Install the module via Magisk Manager only
- Reboot
- It will take about 3 minutes after device boot until the effect is started
- For devices that doesn't support "compress-offload-playback", it will take sometime to play an mp3 file until audio_route is changed to "low-latency-playback" automatically

## Troubleshootings
- DSEEHX toggle is fixed, but will buggy again sometimes. Then you need to enable it first if you want to disable it.
- Install Audio Compatibility Patch module if encounter processing problem
- Install Audio Modification Library module if you using other audio mods
- Delete /data/adb/modules/SoundEnhancement via recovery if facing bootloop and send copied and zipped /data/system/dropbox files for fix
- Open issues and send full logcats if this module is not working for your device

## Attention!
- Always make nandroid backup before install or updating version, these are just experiments!
- Don't report anything without logcats!
- Special thanks to all people that helped and tested my modules.

## Telegram
- https://t.me/audioryukimods
- https://t.me/joinchat/E-On6U9cxckhIlAnoPIYpw
- https://t.me/modsandco

## Donate
- https://www.paypal.me/reiryuki

## Download
- Link bellow at "Releases".
