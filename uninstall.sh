mount -o rw,remount /data
[ -z $MODPATH ] && MODPATH=${0%/*}
[ -z $MODID ] && MODID=`basename "$MODPATH"`

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
rm -rf /metadata/magisk/"$MODID"
rm -rf /mnt/vendor/persist/magisk/"$MODID"
rm -rf /persist/magisk/"$MODID"
rm -rf /data/unencrypted/magisk/"$MODID"
rm -rf /cache/magisk/"$MODID"
#drm -f /data/vendor/dolby/dax_sqlite3.db
#dresetprop -p --delete persist.vendor.dolby.loglevel
resetprop -p --delete persist.sony.effect.ahc
resetprop -p --delete persist.sony.mono_speaker
resetprop -p --delete persist.sony.effect.dolby_atmos
resetprop -p --delete persist.sony.enable.dolby_auto_mode
resetprop -p --delete persist.sony.effect.clear_audio_plus

# function
get_device() {
PAR="$1"
DEV="`cat /proc/self/mountinfo | awk '{ if ( $5 == "'$PAR'" ) print $3 }' | head -1 | sed 's/:/ /g'`"
}
mount_mirror() {
SRC="$1"
DES="$2"
RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
while [ -e /dev/$RAN ]; do
  RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
done
mknod /dev/$RAN b `get_device "$SRC"; echo $DEV`
if mount -t ext4 -o ro /dev/$RAN "$DES"\
|| mount -t erofs -o ro /dev/$RAN "$DES"\
|| mount -t f2fs -o ro /dev/$RAN "$DES"\
|| mount -t ubifs -o ro /dev/$RAN "$DES"; then
  blockdev --setrw /dev/$RAN
  rm -f /dev/$RAN
  return 0
fi
rm -f /dev/$RAN
return 1
}
unmount_mirror() {
DIRS="$MIRROR/system_root $MIRROR/system $MIRROR/vendor
      $MIRROR/system_ext $MIRROR"
for DIR in $DIRS; do
  umount $DIR
done
}
mount_partitions_to_mirror() {
unmount_mirror
# mount system
if [ "$SYSTEM_ROOT" == true ]; then
  DIR=/system_root
  mkdir -p $MIRROR$DIR
  if mount_mirror / $MIRROR$DIR; then
    rm -rf $MIRROR/system
    ln -sf $MIRROR$DIR/system $MIRROR
  else
    rm -rf $MIRROR$DIR
  fi
else
  DIR=/system
  mkdir -p $MIRROR$DIR
  if ! mount_mirror $DIR $MIRROR$DIR; then
    rm -rf $MIRROR$DIR
  fi
fi
# mount vendor
DIR=/vendor
mkdir -p $MIRROR$DIR
if ! mount_mirror $DIR $MIRROR$DIR; then
  rm -rf $MIRROR$DIR
  ln -sf $MIRROR/system$DIR $MIRROR
fi
# mount system_ext
DIR=/system_ext
mkdir -p $MIRROR$DIR
if ! mount_mirror $DIR $MIRROR$DIR; then
  rm -rf $MIRROR$DIR
  if [ -d $MIRROR/system$DIR ]; then
    ln -sf $MIRROR/system$DIR $MIRROR
  fi
fi
}
grep_cmdline() {
REGEX="s/^$1=//p"
cat /proc/cmdline | tr '[:space:]' '\n' | sed -n "$REGEX"
}
set_read_write() {
for NAME in $NAMES; do
  if [ -e $DIR$NAME ]; then
    blockdev --setrw $DIR$NAME
  fi
done
}
restore() {
for FILE in $FILES; do
  if [ -f $FILE.orig ]; then
    mv -f $FILE.orig $FILE
  fi
  if [ -f $FILE.bak ]; then
    mv -f $FILE.bak $FILE
  fi
done
}
remove_dolby() {
# boot mode
[ -z $BOOTMODE ] && ps | grep zygote | grep -qv grep && BOOTMODE=true
[ -z $BOOTMODE ] && ps -A | grep zygote | grep -qv grep && BOOTMODE=true
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
# cleaning
if [ "$BOOTMODE" != true ]; then
  rm -f `find /metadata/early-mount.d /persist/early-mount.d\
              /mnt/vendor/persist/early-mount.d /cache/early-mount.d\
              /data/unencrypted/early-mount.d /data/adb/early-mount.d\
              -type f -name manifest.xml`
fi
# magisk
MAGISKPATH=`magisk --path`
if [ "$BOOTMODE" == true ]; then
  if [ "$MAGISKPATH" ]; then
    mount -o rw,remount $MAGISKPATH
    MAGISKTMP=$MAGISKPATH/.magisk
    MIRROR=$MAGISKTMP/mirror
  else
    MAGISKTMP=/mnt
    mount -o rw,remount $MAGISKTMP
    MIRROR=$MAGISKTMP/mirror
    mount_partitions_to_mirror
  fi
fi
# slot
SLOT=`grep_cmdline androidboot.slot_suffix`
if [ -z $SLOT ]; then
  SLOT=`grep_cmdline androidboot.slot`
  [ -z $SLOT ] || SLOT=_${SLOT}
fi
# remount
DIR=/dev/block/bootdevice/by-name
NAMES="/vendor$SLOT /cust$SLOT /system$SLOT /system_ext$SLOT"
set_read_write
DIR=/dev/block/mapper
set_read_write
DIR=$MAGISKTMP/block
NAMES="/vendor /system_root /system /system_ext"
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
# unmount
if [ "$BOOTMODE" == true ] && [ ! "$MAGISKPATH" ]; then
  unmount_mirror
fi
}

# remove dolby
#dremove_dolby






















