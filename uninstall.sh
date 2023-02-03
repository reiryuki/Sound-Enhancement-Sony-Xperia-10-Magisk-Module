mount -o rw,remount /data
if [ ! "$MODPATH" ]; then
  MODPATH=${0%/*}
fi
if [ ! "$MODID" ]; then
  MODID=`echo "$MODPATH" | sed 's|/data/adb/modules/||' | sed 's|/data/adb/modules_update/||'`
fi

# boot mode
if [ ! "$BOOTMODE" ]; then
  [ -z $BOOTMODE ] && ps | grep zygote | grep -qv grep && BOOTMODE=true
  [ -z $BOOTMODE ] && ps -A | grep zygote | grep -qv grep && BOOTMODE=true
  [ -z $BOOTMODE ] && BOOTMODE=false
fi

# cleaning
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
for APPS in $APP; do
  rm -f `find /data/system/package_cache -type f -name *$APPS*`
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APPS*.apk`
done
PKG="com.sonyericsson.soundenhancement
     com.reiryuki.soundenhancementlauncher
     com.sonymobile.audioutil"
for PKGS in $PKG; do
  rm -rf /data/user*/*/$PKGS
done
rm -rf /metadata/magisk/"$MODID"
rm -rf /mnt/vendor/persist/magisk/"$MODID"
rm -rf /persist/magisk/"$MODID"
rm -rf /data/unencrypted/magisk/"$MODID"
rm -rf /cache/magisk/"$MODID"
resetprop -p --delete persist.sony.effect.ahc
resetprop -p --delete persist.sony.mono_speaker
resetprop -p --delete persist.sony.effect.dolby_atmos
resetprop -p --delete persist.sony.enable.dolby_auto_mode
resetprop -p --delete persist.sony.effect.clear_audio_plus

# function
cleaning() {
PKG="com.dolby.daxappui com.dolby.daxservice"
for PKGS in $PKG; do
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$PKGS*`
  rm -rf /data/user*/*/$PKGS
done
rm -f /data/vendor/dolby/dax_sqlite3.db
resetprop -p --delete persist.vendor.dolby.loglevel
if [ "$BOOTMODE" != true ]; then
  rm -rf `find /metadata/early-mount.d\
  /mnt/vendor/persist/early-mount.d /persist/early-mount.d\
  /data/unencrypted/early-mount.d /cache/early-mount.d\
  /data/adb/early-mount.d -type f -name manifest.xml\
  -o -name libhidlbase.so`
fi
}

# cleaning
#dcleaning

# magisk
if [ ! "$MAGISKTMP" ]; then
  if [ -d /sbin/.magisk ]; then
    MAGISKTMP=/sbin/.magisk
  else
    MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
  fi
fi

# function
grep_cmdline() {
REGEX="s/^$1=//p"
cat /proc/cmdline | tr '[:space:]' '\n' | sed -n "$REGEX"
}
set_read_write() {
for NAMES in $NAME; do
  blockdev --setrw $DIR$NAMES
done
}

# slot
if [ ! "$SLOT" ]; then
  SLOT=`grep_cmdline androidboot.slot_suffix`
  if [ -z $SLOT ]; then
    SLOT=`grep_cmdline androidboot.slot`
    [ -z $SLOT ] || SLOT=_${SLOT}
  fi
fi

# function
remount_rw() {
DIR=/dev/block/bootdevice/by-name
NAME="/vendor$SLOT /cust$SLOT /system$SLOT /system_ext$SLOT"
set_read_write
DIR=/dev/block/mapper
set_read_write
DIR=$MAGISKTMP/block
NAME="/vendor /system_root /system /system_ext"
set_read_write
mount -o rw,remount $MAGISKTMP/mirror/system
mount -o rw,remount $MAGISKTMP/mirror/system_root
mount -o rw,remount $MAGISKTMP/mirror/system_ext
mount -o rw,remount $MAGISKTMP/mirror/vendor
mount -o rw,remount /system
mount -o rw,remount /
mount -o rw,remount /system_root
mount -o rw,remount /system_ext
mount -o rw,remount /vendor
}

# remount
#dremount_rw

# function
restore() {
for FILES in $FILE; do
  if [ -f $FILES.orig ]; then
    mv -f $FILES.orig $FILES
  fi
  if [ -f $FILES.bak ]; then
    mv -f $FILES.bak $FILES
  fi
done
}

# restore
FILE="$MAGISKTMP/mirror/*/etc/vintf/manifest.xml
      $MAGISKTMP/mirror/*/*/etc/vintf/manifest.xml
      /*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml
      $MAGISKTMP/mirror/*/etc/selinux/*_hwservice_contexts
      $MAGISKTMP/mirror/*/*/etc/selinux/*_hwservice_contexts
      /*/etc/selinux/*_hwservice_contexts /*/*/etc/selinux/*_hwservice_contexts
      $MAGISKTMP/mirror/*/etc/selinux/*_file_contexts
      $MAGISKTMP/mirror/*/*/etc/selinux/*_file_contexts
      /*/etc/selinux/*_file_contexts /*/*/etc/selinux/*_file_contexts"
#drestore

# function
remount_ro() {
if [ "$BOOTMODE" == true ]; then
  mount -o ro,remount $MAGISKTMP/mirror/system
  mount -o ro,remount $MAGISKTMP/mirror/system_root
  mount -o ro,remount $MAGISKTMP/mirror/system_ext
  mount -o ro,remount $MAGISKTMP/mirror/vendor
  mount -o ro,remount /system
  mount -o ro,remount /
  mount -o ro,remount /system_root
  mount -o ro,remount /system_ext
  mount -o ro,remount /vendor
fi
}

# remount
#dremount_ro


