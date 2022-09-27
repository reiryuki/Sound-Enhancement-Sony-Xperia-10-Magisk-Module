MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml

# debug
exec 2>$MODPATH/debug.log
set -x

# property
resetprop ro.semc.product.model I4113
resetprop ro.semc.ms_type_id PM-1181-BV
resetprop ro.semc.version.fs GENERIC
resetprop ro.semc.product.name "Xperia 10"
resetprop ro.semc.product.device I41
#resetprop ro.boot.hardware.sku I4113
resetprop audio.sony.effect.use.proxy true
resetprop vendor.audio.sony.effect.use.proxy true
resetprop vendor.audio.sony.effect.custom.sp_bundle 0x122
resetprop vendor.audio.sony.effect.custom.caplus_hs 0x298
resetprop vendor.audio.sony.effect.custom.caplus_sp 0x2B8
resetprop ro.somc.dseehx.supported true
resetprop -p --delete persist.sony.effect.ahc
resetprop -n persist.sony.effect.ahc true
resetprop -p --delete persist.sony.mono_speaker
resetprop -n persist.sony.mono_speaker false
resetprop -p --delete persist.sony.effect.dolby_atmos
resetprop -n persist.sony.effect.dolby_atmos false
resetprop -p --delete persist.sony.enable.dolby_auto_mode
resetprop -n persist.sony.enable.dolby_auto_mode true
resetprop -p --delete persist.sony.effect.clear_audio_plus
resetprop -n persist.sony.effect.clear_audio_plus true
resetprop vendor.audio.use.sw.alac.decoder true
#dresetprop ro.odm.build.SomcCntrl.manufacture Sony
#dresetprop ro.odm.build.SomcCntrl.Brand Sony
#dresetprop ro.odm.build.SomcCntrl.Model Pdx203
#dresetprop ro.odm.build.SomcCntrl.device pdx203
#dresetprop ro.product.manufacturer Sony
#dresetprop vendor.audio.dolby.ds2.enabled false
#dresetprop vendor.audio.dolby.ds2.hardbypass false
#resetprop -p --delete persist.vendor.dolby.loglevel
#resetprop -n persist.vendor.dolby.loglevel 0
#resetprop vendor.dolby.dap.param.tee false
#resetprop vendor.dolby.mi.metadata.log false

# wait
sleep 20

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR
fi

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml"
#pNAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system/vendor
else
  DIR=$AML/system/vendor
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ "`realpath /odm/etc`" == /odm/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="/odm$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi
if [ -d /my_product/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="/my_product$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi

# restart
killall audioserver

# function
stop_service() {
for NAMES in $NAME; do
  if getprop | grep "init.svc.$NAMES\]: \[running"; then
    stop $NAMES
  fi
done
}
run_service() {
for FILES in $FILE; do
  killall $FILES
  $FILES &
  PID=`pidof $FILES`
done
}

# stop
#dNAME="dms-hal-1-0 dms-hal-2-0 dms-v36-hal-2-0"
#dstop_service

# run
#dFILE=`realpath /vendor`/bin/hw/vendor.dolby.hardware.dms@1.0-service
#drun_service

# unused
#FILE=idds
#NAME=vendor.semc.system.idd-1-0
#FILE=`realpath /vendor`/bin/hw/vendor.semc.system.idd@1.0-service
#FILE=`realpath /vendor`/bin/idd-logreader

# restart
#dkillall com.dolby.daxservice
#dVIBRATOR=`realpath /*/bin/hw/vendor.qti.hardware.vibrator.service*`
#d[ "$VIBRATOR" ] && killall $VIBRATOR
#dPOWER=`realpath /*/bin/hw/vendor.mediatek.hardware.mtkpower@*-service`
#d[ "$POWER" ] && killall $POWER
#dkillall android.hardware.usb@1.0-service
#dkillall android.hardware.usb@1.0-service.basic
#dkillall android.hardware.sensors@2.0-service-mediatek
#dkillall android.hardware.light-service.mt6768
#dkillall android.hardware.lights-service.xiaomi_mithorium
#dCAMERA=`realpath /*/bin/hw/android.hardware.camera.provider@*-service_64`
#d[ "$CAMERA" ] && killall $CAMERA

# wait
sleep 40

# grant
PKG=com.sonyericsson.soundenhancement
pm grant $PKG android.permission.RECORD_AUDIO
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# allow
PKG=com.dolby.daxappui
if pm list packages | grep $PKG ; then
  if [ "$API" -ge 30 ]; then
    appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
  fi
fi

# allow
PKG=com.dolby.daxservice
if pm list packages | grep $PKG ; then
  if [ "$API" -ge 30 ]; then
    appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
  fi
fi

# special file
FILE=/dev/sony_hweffect_params
if [ ! -e $FILE ]; then
  mknod $FILE c 10 51
  chmod 0660 $FILE
  chown 1000.1005 $FILE
  chcon u:object_r:audio_hweffect_device:s0 $FILE
fi

# file
DIR=/data/vendor/audio/acdbdata/delta
if [ ! -d $DIR ]; then
  mkdir -p $DIR
fi
NAME="Sony_ganges_Bluetooth_cal.acdbdelta
      Sony_ganges_General_cal.acdbdelta
      Sony_ganges_Global_cal.acdbdelta
      Sony_ganges_Handset_cal.acdbdelta
      Sony_ganges_Hdmi_cal.acdbdelta
      Sony_ganges_Headset_cal.acdbdelta
      Sony_ganges_Speaker_cal.acdbdelta"
for NAMES in $NAME; do
  if [ ! -f $DIR/$NAMES ]; then
    touch $DIR/$NAMES
    chmod 0600 $DIR/$NAMES
    chown 1041.1005 $DIR/$NAMES
  fi
done


