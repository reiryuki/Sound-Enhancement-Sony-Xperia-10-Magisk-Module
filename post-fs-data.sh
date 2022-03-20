(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
fi

# etc
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi
ETC=$MAGISKTMP/mirror/system/etc
VETC=$MAGISKTMP/mirror/system/vendor/etc
VOETC=$MAGISKTMP/mirror/system/vendor/odm/etc
MODETC=$MODPATH/system/etc
MODVETC=$MODPATH/system/vendor/etc
MODVOETC=$MODPATH/system/vendor/odm/etc

# conflict
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb
if [ -d $AML ] && [ -d $ACDB ]; then
  rm -rf $ACDB
fi

# directory
SKU=`ls $VETC/audio | grep sku_`
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    mkdir -p $MODVETC/audio/$SKUS
  done
fi
PROP=`getprop ro.build.product`
if [ -d $VETC/audio/"$PROP" ]; then
  mkdir -p $MODVETC/audio/"$PROP"
fi

# audio effects
NAME=*audio*effects*
rm -f `find $MODPATH/system -type f -name $NAME.conf -o -name $NAME.xml`
AE=`find $ETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VAE=`find $VETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VOAE=`find $VOETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
cp -f $AE $MODETC
cp -f $VAE $MODVETC
cp -f $VOAE $MODVOETC
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    VSAE=`find $VETC/audio/$SKUS -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
    cp -f $VSAE $MODVETC/audio/$SKUS
  done
fi
if [ -d $VETC/audio/"$PROP" ]; then
  VBAE=`find $VETC/audio/"$PROP" -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
  cp -f $VBAE $MODVETC/audio/"$PROP"
fi

# audio policy
NAME=*policy*
rm -f `find $MODPATH/system -type f -name $NAME.conf -o -name $NAME.xml`
AP=`find $ETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VAP=`find $VETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VAAP=`find $VETC/audio -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
VOAP=`find $VOETC -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
cp -f $AP $MODETC
cp -f $VAP $MODVETC
cp -f $VAAP $MODVETC/audio
cp -f $VOAP $MODVOETC
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    VSAP=`find $VETC/audio/$SKUS -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
    cp -f $VSAP $MODVETC/audio/$SKUS
  done
fi
if [ -d $VETC/audio/"$PROP" ]; then
  VBAP=`find $VETC/audio/"$PROP" -maxdepth 1 -type f -name $NAME.conf -o -name $NAME.xml`
  cp -f $VBAP $MODVETC/audio/"$PROP"
fi

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ "$VOAE" ] || [ "$VOAP" ]; then
  if [ -d $AML ] && [ ! -d $DIR ]; then
    mkdir -p $DIR
    cp -f $VOAE $DIR
    cp -f $VOAP $DIR
  fi
fi
magiskpolicy "dontaudit vendor_configs_file labeledfs filesystem associate"
magiskpolicy "allow     vendor_configs_file labeledfs filesystem associate"
magiskpolicy "dontaudit init vendor_configs_file dir relabelfrom"
magiskpolicy "allow     init vendor_configs_file dir relabelfrom"
magiskpolicy "dontaudit init vendor_configs_file file relabelfrom"
magiskpolicy "allow     init vendor_configs_file file relabelfrom"
chcon -R u:object_r:vendor_configs_file:s0 $DIR

# media codecs
NAME=media_codecs.xml
rm -f $MODVETC/$NAME
DIR=$AML/system/vendor/etc
FILE=$AML/disable
if [ -d $DIR ] && [ ! -f $FILE ]; then
  cp -f $VETC/$NAME $DIR
else
  cp -f $VETC/$NAME $MODVETC
fi

# run
sh $MODPATH/.aml.sh

# directory
DIR=/data/mediaserver
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi

# directory
#dDIR=/data/vendor/dolby
#dif [ ! -d $DIR ]; then
#d  mkdir -p $DIR
#dfi
#dchmod 0770 $DIR
#dchown 1013.1013 $DIR

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi

# function
dolby_manifest() {
CHECK=@1.0::IDms/default
if ! grep -rEq "$CHECK" $MAGISKTMP/mirror/*/etc/vintf\
&& ! grep -rEq "$CHECK" $MAGISKTMP/mirror/system/*/etc/vintf\
&& ! grep -rEq "$CHECK" $MAGISKTMP/mirror/system_root/*/etc/vintf; then
  mv -f $MODETC/unused $MODETC/vintf
  mount -o bind $MODETC/vintf/manifest/vendor.dolby.hardware.dms@1.0.xml /system/etc/vintf/manifest/vendor.dolby.hardware.dms@1.0.xml
  killall hwservicemanager
else
  mv -f $MODETC/vintf $MODETC/unused
fi
}

# manifest
#ddolby_manifest

) 2>/dev/null


