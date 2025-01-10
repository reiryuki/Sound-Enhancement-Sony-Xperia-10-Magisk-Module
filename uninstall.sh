mount -o rw,remount /data
[ ! "$MODPATH" ] && MODPATH=${0%/*}
[ ! "$MODID" ] && MODID=`basename "$MODPATH"`
UID=`id -u`
[ ! "$UID" ] && UID=0

# log
exec 2>/data/adb/$MODID\_uninstall.log
set -x

# run
. $MODPATH/function.sh

# cleaning
remove_cache
PKGS=`cat $MODPATH/package.txt`
#dPKGS=`cat $MODPATH/package-dolby.txt`
for PKG in $PKGS; do
  rm -rf /data/user*/"$UID"/$PKG
done
remove_sepolicy_rule
#drm -f /data/vendor/dolby/dax_sqlite3.db
#dresetprop -p --delete persist.vendor.dolby.loglevel
resetprop -p --delete persist.sony.effect.ahc
resetprop -p --delete persist.sony.mono_speaker
resetprop -p --delete persist.sony.effect.dolby_atmos
resetprop -p --delete persist.sony.enable.dolby_auto_mode
resetprop -p --delete persist.sony.effect.clear_audio_plus







