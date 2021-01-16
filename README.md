# Sony Xperia 10 Sound Enhancement

## Descriptions
- An equalizer ported from Sony Xperia 10 (I4113).
- Post process bundle proxy type FX
- Effects only working with Music apps that has external EQ option such as [Sony Music](https://github.com/reiryuki/Xperia-Libraries-Magisk-Module), Youtube Music, and Spotify. Not working with SoundCloud or Youtube app.
- Doesn't support ACDB module because using effect proxy.
- Not friendly with other audio mods.
- Will take about 3 minutes after device boot until the effect is started.
- DSEEHX is only working with audio output 24 bit. Use [this](https://github.com/reiryuki/Hi-Res-Audio-24-Bit-Enabler-Magisk-Module) if your device not enabled output 24 bit yet
- S-Force Front Surround is actually for device with stereo speaker.

## Requirements
- Android 10 or 11
- Magisk Installed

## Tested
- Android 10 arm64 CrDroid ROM

## Installation Guide
- Don't use ACDB module!
- Using ACP is not recommended
- Install the module via Magisk Manager only
- Reboot

## Optional
- You can edit xloud strength and clear audio coefisions at /data/adb/modules_update/SoundEnhancement/system/vendor/etc/sony_effect/effect_params.data

## Troubleshootings
- Using ACP module is not recommended
- DSEEHX is turned off itself every time song is stopped or changed, that's normal, you have to turn it on again.
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
