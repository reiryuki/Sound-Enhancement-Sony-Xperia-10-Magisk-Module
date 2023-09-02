mount -o rw,remount /data
[ -z $MODPATH ] && MODPATH=${0%/*}
[ -z $MODID ] && MODID=`basename "$MODPATH"`

# log
exec 2>/data/media/0/$MODID\_uninstall.log
set -x

# run
. $MODPATH/function.sh

# cleaning
APPS="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
for APP in $APPS; do
  rm -f `find /data/system/package_cache -type f -name *$APP*`
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APP*.apk`
done
PKGS=`cat $MODPATH/package.txt`
#dPKGS=`cat $MODPATH/package-dolby.txt`
for PKG in $PKGS; do
  rm -rf /data/user*/*/$PKG
done
remove_sepolicy_rule
#drm -f /data/vendor/dolby/dax_sqlite3.db
#dresetprop -p --delete persist.vendor.dolby.loglevel
resetprop -p --delete persist.sony.effect.ahc
resetprop -p --delete persist.sony.mono_speaker
resetprop -p --delete persist.sony.effect.dolby_atmos
resetprop -p --delete persist.sony.enable.dolby_auto_mode
resetprop -p --delete persist.sony.effect.clear_audio_plus

# function
grep_cmdline() {
  local REGEX="s/^$1=//p"
  { echo $(cat /proc/cmdline)$(sed -e 's/[^"]//g' -e 's/""//g' /proc/cmdline) | xargs -n 1; \
    sed -e 's/ = /=/g' -e 's/, /,/g' -e 's/"//g' /proc/bootconfig; \
  } 2>/dev/null | sed -n "$REGEX"
}
remove_dolby() {
# boot mode
[ -z $BOOTMODE ] && ps | grep zygote | grep -qv grep && BOOTMODE=true
[ -z $BOOTMODE ] && ps -A 2>/dev/null | grep zygote | grep -qv grep && BOOTMODE=true
[ -z $BOOTMODE ] && BOOTMODE=false
# system_root
if [ -z $SYSTEM_ROOT ]; then
  if [ -f /system/init -o -L /system/init ]; then
    SYSTEM_ROOT=true
  else
    SYSTEM_ROOT=false
    grep ' / ' /proc/mounts | grep -qv 'rootfs' || grep -q ' /system_root ' /proc/mounts && SYSTEM_ROOT=true
  fi
fi
# slot
SLOT=`grep_cmdline androidboot.slot_suffix`
if [ -z $SLOT ]; then
  SLOT=`grep_cmdline androidboot.slot`
  [ -z $SLOT ] || SLOT=_${SLOT}
fi
[ "$SLOT" = "normal" ] && unset SLOT
# recovery
mount_partitions_in_recovery
# cleaning
if [ "$BOOTMODE" != true ]; then
  rm -f `find /metadata/early-mount.d /persist/early-mount.d\
   /mnt/vendor/persist/early-mount.d /cache/early-mount.d\
   /data/unencrypted/early-mount.d /data/adb/early-mount.d\
   /cust/early-mount.d -type f -name manifest.xml`
fi
# magisk
magisk_setup
# remount
remount_rw
# restore
FILES="$MAGISKTMP/mirror/*/etc/vintf/manifest.xml
       $MAGISKTMP/mirror/*/*/etc/vintf/manifest.xml
       /*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml
       $MAGISKTMP/mirror/*/etc/selinux/*_hwservice_contexts
       $MAGISKTMP/mirror/*/*/etc/selinux/*_hwservice_contexts
       /*/etc/selinux/*_hwservice_contexts /*/*/etc/selinux/*_hwservice_contexts
       $MAGISKTMP/mirror/*/etc/selinux/*_file_contexts
       $MAGISKTMP/mirror/*/*/etc/selinux/*_file_contexts
       /*/etc/selinux/*_file_contexts /*/*/etc/selinux/*_file_contexts"
restore
# remount
remount_ro
# unmount
if [ "$BOOTMODE" == true ] && [ ! "$MAGISKPATH" ]; then
  unmount_mirror
fi
}

# remove dolby
#dremove_dolby














