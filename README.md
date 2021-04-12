# Sound Enhancement Sony Xperia 10 Magisk Module

## Descriptions
- An equalizer ported from Sony Xperia 10 (I4113).
- Post process type FX.
- FX can only be applied with Music apps that has external EQ option such as [Sony Music](https://github.com/reiryuki/Xperia-Libraries-Magisk-Module), Youtube Music, and Spotify. Not working with SoundCloud or Youtube app.
- Doesn't support ACDB module because using effect proxy.
- This FX will deactivates other non post process type FX while turned on.
- Will take about 3 minutes after device boot until the FX is started.
- DSEEHX is only works with audio output 24 bit. Use [this](https://github.com/reiryuki/Hi-Res-Audio-24-Bit-Enabler-Magisk-Module) if your device not enabled output 24 bit yet

## Requirements
- Android 10 or 11
- Magisk installed

## Tested
- Android 10 arm64 CrDroid ROM

## Installation Guide
- Don't use ACDB module!
- Install the module via Magisk Manager or Recovery
- Reboot

## Optional
- You can edit xloud strength and clear audio coefisions at /data/adb/modules_update/SoundEnhancement/system/vendor/etc/sony_effect/effect_params.data

## Troubleshootings
- DSEEHX and Clear Phase will be turning off itself every time song is stopped or changed. That's normal, you can turn it on again.
- Install Audio Modification Library module if you using other audio mods

## Bug Report
- https://t.me/audioryukimods/2618
- Otherwise, it will be closed immediately.

## Credits
- @guitardedhero
- @aip_x
- @aquahol

## Thanks for Donations
- https://t.me/audioryukimods/2619
- https://www.paypal.me/reiryuki

## Download
- Tap "Releases"
