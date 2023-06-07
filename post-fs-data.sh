mount -o rw,remount /data
MODPATH=${0%/*}

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.pfsd
if [ -f $FILE ]; then
  magiskpolicy --live --apply $FILE
fi

# list
(
PKGS=`cat $MODPATH/package.txt`
#dPKGS=`cat $MODPATH/package-dolby.txt`
for PKG in $PKGS; do
  magisk --denylist rm $PKG
  magisk --sulist add $PKG
done
FILE=$MODPATH/tmp_file
magisk --hide sulist 2>$FILE
if [ "`cat $FILE`" == 'SuList is enforced' ]; then
  for PKG in $PKGS; do
    magisk --hide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk --hide rm $PKG
  done
fi
rm -f $FILE
) 2>/dev/null

# run
. $MODPATH/copy.sh
. $MODPATH/.aml.sh

# directory
DIR=/data/mediaserver
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi

# function
dolby_data() {
DIR=/data/vendor/dolby
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi
chmod 0770 $DIR
chown 1013.1013 $DIR
chcon u:object_r:vendor_data_file:s0 $DIR
}

# directory
#ddolby_data

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  rm -f $FILE
fi

# permission
chmod 0751 $MODPATH/system/bin
FILES=`find $MODPATH/system/bin\
            $MODPATH/vendor/bin\
            $MODPATH/vendor/odm/bin\
            $MODPATH/system/vendor/bin\
            $MODPATH/system/vendor/odm/bin -type f`
for FILE in $FILES; do
  chmod 0755 $FILE
done
chown -R 0.2000 $MODPATH/system/bin
DIRS=`find $MODPATH/vendor\
           $MODPATH/system/vendor -type d`
for DIR in $DIRS; do
  chown 0.2000 $DIR
done
FILES=`find $MODPATH/vendor/bin\
            $MODPATH/vendor/odm/bin\
            $MODPATH/system/vendor/bin\
            $MODPATH/system/vendor/odm/bin -type f`
for FILE in $FILES; do
  chown 0.2000 $FILE
done
chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  chmod 0751 $MODPATH/vendor/bin
  chmod 0751 $MODPATH/vendor/bin/hw
  chmod 0755 $MODPATH/vendor/odm/bin
  chmod 0755 $MODPATH/vendor/odm/bin/hw
  chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/odm/etc
  #dchcon u:object_r:hal_dms_default_exec:s0 $MODPATH/vendor/bin/hw/vendor.dolby.hardware.dms@*-service
  #dchcon u:object_r:hal_dms_default_exec:s0 $MODPATH/vendor/odm/bin/hw/vendor.dolby_v3_6.hardware.dms360@2.0-service
else
  chmod 0751 $MODPATH/system/vendor/bin
  chmod 0751 $MODPATH/system/vendor/bin/hw
  chmod 0755 $MODPATH/system/vendor/odm/bin
  chmod 0755 $MODPATH/system/vendor/odm/bin/hw
  chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc
  #dchcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/bin/hw/vendor.dolby.hardware.dms@*-service
  #dchcon u:object_r:hal_dms_default_exec:s0 $MODPATH/system/vendor/odm/bin/hw/vendor.dolby_v3_6.hardware.dms360@2.0-service
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
if ! grep delta /data/adb/magisk/util_functions.sh; then
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
        <version>1.0</version>\
        <interface>\
            <name>IDms</name>\
            <instance>default</instance>\
        </interface>\
        <fqname>@1.0::IDms/default</fqname>\
    </hal>' $MODPATH$M
    mount -o bind $MODPATH$M $M
    killall hwservicemanager
  fi
fi
}

# manifest
#ddolby_manifest














