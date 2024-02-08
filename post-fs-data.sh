mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
ABI=`getprop ro.product.cpu.abi`

# function
permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if ! setenforce 0; then
    echo 0 > /sys/fs/selinux/enforce
  fi
fi
}
magisk_permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
	magiskpolicy --live "permissive *"
  else
	$MODPATH/$ABI/libmagiskpolicy.so --live "permissive *"
  fi
fi
}
sepolicy_sh() {
if [ -f $FILE ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
    magiskpolicy --live --apply $FILE 2>/dev/null
  else
    $MODPATH/$ABI/libmagiskpolicy.so --live --apply $FILE 2>/dev/null
  fi
fi
}

# selinux
SELINUX=`getenforce`
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#1permissive
#2magisk_permissive
#kFILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

# list
PKGS=`cat $MODPATH/package.txt`
#dPKGS=`cat $MODPATH/package-dolby.txt`
for PKG in $PKGS; do
  magisk --denylist rm $PKG 2>/dev/null
  magisk --sulist add $PKG 2>/dev/null
done
if magisk magiskhide sulist; then
  for PKG in $PKGS; do
    magisk magiskhide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk magiskhide rm $PKG
  done
fi

# run
. $MODPATH/copy.sh

# conflict
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb
if [ -d $ACDB ] && [ ! -f $ACDB/disable ]; then
  if [ ! -d $AML ] || [ -f $AML/disable ]; then
    rm -f `find $MODPATH/system/etc $MODPATH/vendor/etc\
     $MODPATH/system/vendor/etc -maxdepth 1 -type f -name\
     *audio*effects*.conf -o -name *audio*effects*.xml`
  fi
fi

# run
. $MODPATH/.aml.sh

# directory
DIR=/data/mediaserver
mkdir -p $DIR

# function
dolby_data() {
DIR=/data/vendor/dolby
mkdir -p $DIR
chmod 0770 $DIR
chown 1013.1013 $DIR
chcon u:object_r:vendor_data_file:s0 $DIR
}

# directory
#ddolby_data

# permission
chmod 0751 $MODPATH/system/bin
FILES=`find $MODPATH/system/bin -type f`
for FILE in $FILES; do
  chmod 0755 $FILE
done
chown -R 0.2000 $MODPATH/system/bin
DIRS=`find $MODPATH/vendor\
           $MODPATH/system/vendor -type d`
for DIR in $DIRS; do
  chown 0.2000 $DIR
done
chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  chmod 0751 $MODPATH/vendor/bin
  chmod 0751 $MODPATH/vendor/bin/hw
  chmod 0755 $MODPATH/vendor/odm/bin
  chmod 0755 $MODPATH/vendor/odm/bin/hw
  FILES=`find $MODPATH/vendor/bin\
              $MODPATH/vendor/odm/bin -type f`
  for FILE in $FILES; do
    chmod 0755 $FILE
    chown 0.2000 $FILE
  done
  chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/odm/etc
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/vendor/bin/hw/vendor.dolby*.hardware.dms*@*-service
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/vendor/odm/bin/hw/vendor.dolby*.hardware.dms*@*-service
else
  chmod 0751 $MODPATH/system/vendor/bin
  chmod 0751 $MODPATH/system/vendor/bin/hw
  chmod 0755 $MODPATH/system/vendor/odm/bin
  chmod 0755 $MODPATH/system/vendor/odm/bin/hw
  FILES=`find $MODPATH/system/vendor/bin\
              $MODPATH/system/vendor/odm/bin -type f`
  for FILE in $FILES; do
    chmod 0755 $FILE
    chown 0.2000 $FILE
  done
  chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/bin/hw/vendor.dolby*.hardware.dms*@*-service
#  chcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/odm/bin/hw/vendor.dolby*.hardware.dms*@*-service
fi

# function
mount_helper() {
if [ -d /odm ]\
&& [ "`realpath /odm/etc`" == /odm/etc ]; then
  DIR=$MODPATH/system/odm
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/odm`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
if [ -d /my_product ]; then
  DIR=$MODPATH/system/my_product
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/my_product`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
}

# mount
if ! grep -E 'delta|Delta|kitsune' /data/adb/magisk/util_functions.sh; then
  mount_helper
fi

# function
dolby_manifest() {
M=/system/etc/vintf/manifest.xml
rm -f $MODPATH$M
FILE="/*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml
      /*/etc/vintf/manifest/*.xml /*/*/etc/vintf/manifest/*.xml"
if ! grep -A2 vendor.dolby.hardware.dms $FILE | grep 1.0; then
  cp -af $M $MODPATH$M
  if [ -f $MODPATH$M ]; then
    sed -i '/<manifest/a\
    <hal format="hidl">\
        <name>vendor.dolby.hardware.dms</name>\
        <transport>hwbinder</transport>\
        <fqname>@1.0::IDms/default</fqname>\
    </hal>' $MODPATH$M
    umount $M
    mount -o bind $MODPATH$M $M
    killall hwservicemanager
  fi
fi
}

# manifest
#ddolby_manifest

# function
mount_bind_file() {
for FILE in $FILES; do
  umount $FILE
  mount -o bind $MODFILE $FILE
done
}
mount_bind_to_apex() {
for NAME in $NAMES; do
  MODFILE=$MODPATH/system/lib64/$NAME
  if [ -f $MODFILE ]; then
    FILES=`find /apex /system/apex -path *lib64/* -type f -name $NAME`
    mount_bind_file
  fi
  MODFILE=$MODPATH/system/lib/$NAME
  if [ -f $MODFILE ]; then
    FILES=`find /apex /system/apex -path *lib/* -type f -name $NAME`
    mount_bind_file
  fi
done
}

# mount
NAMES=libhidlbase.so
mount_bind_to_apex

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE.txt
fi












