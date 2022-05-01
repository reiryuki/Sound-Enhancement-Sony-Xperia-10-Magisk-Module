mount /data
mount -o rw,remount /data
MODPATH=${0%/*}
AML=/data/adb/modules/aml
ACDB=/data/adb/modules/acdb

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

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
if [ -d $AML ] && [ ! -f $AML/disable ]\
&& [ -d $ACDB ] && [ ! -f $ACDB/disable ]; then
  touch $ACDB/disable
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

# audio files
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
rm -f `find $MODPATH/system -type f -name $NAME`
A=`find $ETC -maxdepth 1 -type f -name $NAME`
VA=`find $VETC -maxdepth 1 -type f -name $NAME`
VOA=`find $VOETC -maxdepth 1 -type f -name $NAME`
VAA=`find $VETC/audio -maxdepth 1 -type f -name $NAME`
VBA=`find $VETC/audio/"$PROP" -maxdepth 1 -type f -name $NAME`
if [ "$A" ]; then
  cp -f $A $MODETC
fi
if [ "$VA" ]; then
  cp -f $VA $MODVETC
fi
if [ "$VOA" ]; then
  cp -f $VOA $MODVOETC
fi
if [ "$VAA" ]; then
  cp -f $VAA $MODVOETC/audio
fi
if [ "$VBA" ]; then
  cp -f $VBA $MODVETC/audio/"$PROP"
fi
if [ "$SKU" ]; then
  for SKUS in $SKU; do
    VSA=`find $VETC/audio/$SKUS -maxdepth 1 -type f -name $NAME`
    if [ "$VSA" ]; then
      cp -f $VSA $MODVETC/audio/$SKUS
    fi
  done
fi

# media codecs
NAME=media_codecs.xml
rm -f $MODVETC/$NAME
DIR=$AML/system/vendor/etc
if [ -d $AML ] && [ ! -f $AML/disable ]; then
  if [ ! -d $DIR ]; then
    mkdir -p $DIR
  fi
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
  sh $FILE
  rm -f $FILE
fi

# function
dolby_manifest() {
NAME=vendor.dolby.hardware.dms@1.0.xml
FILE=`find $MAGISKTMP/mirror/*/etc/vintf\
           $MAGISKTMP/mirror/*/*/etc/vintf\
           /*/etc/vintf /*/*/etc/vintf -type f -name *.xml`
if ! grep -A2 vendor.dolby.hardware.dms $FILE | grep 1.0; then
  mv -f $MODETC/unused $MODETC/vintf
  mount -o bind $MODETC/vintf/manifest/$NAME /system/etc/vintf/manifest/$NAME
  killall hwservicemanager
else
  mv -f $MODETC/vintf $MODETC/unused
fi
}

# manifest
#ddolby_manifest


