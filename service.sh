MODPATH=${0%/*}

# log
LOGFILE=$MODPATH/debug.log
exec 2>$LOGFILE
set -x

# var
API=`getprop ro.build.version.sdk`

# function
dolby_prop() {
resetprop ro.odm.build.SomcCntrl.manufacture Sony
resetprop ro.odm.build.SomcCntrl.Brand Sony
resetprop ro.odm.build.SomcCntrl.Model Pdx203
resetprop ro.odm.build.SomcCntrl.device pdx203
resetprop ro.product.manufacturer Sony
resetprop ro.dolby.mod_uuid false
resetprop vendor.audio.dolby.ds2.enabled false
resetprop vendor.audio.dolby.ds2.hardbypass false
#resetprop -p --delete persist.vendor.dolby.loglevel
#resetprop -n persist.vendor.dolby.loglevel 0
#resetprop vendor.dolby.dap.param.tee false
#resetprop vendor.dolby.mi.metadata.log false
}

# property
resetprop ro.audio.ignore_effects false
#ddolby_prop
resetprop ro.sony.global.effect true
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
#resetprop vendor.audio.sony.effect.wait_ef_off_ms 500
#resetprop vendor.audio.sony.effect.wait_conv_on_ms 500
#resetprop vendor.audio.sony.effect.cpu_min_freq_little 600
#resetprop vendor.audio.sony.effect.cpu_min_freq_big 600
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

# special file
FILE=/dev/sony_hweffect_params
FILE2=/dev/msm_hweffects
if [ ! -e $FILE ]; then
  if [ -e $FILE2 ]; then
    MM=`stat -c "%t %T" $FILE2 | { read major minor; printf "%d %d\n" 0x$major 0x$minor; }`
  fi
  if [ "$MM" ]; then
    mknod $FILE c $MM
    chmod 0660 $FILE
    chown 1000.1005 $FILE
    chcon u:object_r:audio_hweffect_device:s0 $FILE
  fi
fi

# restart
if [ "$API" -ge 24 ]; then
  SERVER=audioserver
else
  SERVER=mediaserver
fi
PID=`pidof $SERVER`
if [ "$PID" ]; then
  killall $SERVER android.hardware.audio@4.0-service-mediatek
fi

# unused
#NAMES=vendor.semc.system.idd-1-0
#SERVICES="idds `realpath /vendor`/bin/idd-logreader
#          `realpath /vendor`/bin/hw/vendor.semc.system.idd@1.0-service"

# function
dolby_service() {
# stop
NAMES="dms-hal-1-0 dms-hal-2-0"
for NAME in $NAMES; do
  if [ "`getprop init.svc.$NAME`" == running ]\
  || [ "`getprop init.svc.$NAME`" == restarting ]; then
    stop $NAME
  fi
done
# mount
DIR=/odm/bin/hw
FILES=$DIR/vendor.dolby.hardware.dms@2.0-service
if [ "`realpath $DIR`" == $DIR ]; then
  for FILE in $FILES; do
    if [ -f $FILE ]; then
      if [ -L $MODPATH/system/vendor ]\
      && [ -d $MODPATH/vendor ]; then
        mount -o bind $MODPATH/vendor$FILE $FILE
      else
        mount -o bind $MODPATH/system/vendor$FILE $FILE
      fi
    fi
  done
fi
# run
SERVICES=`realpath /vendor`/bin/hw/vendor.dolby.hardware.dms@1.0-service
for SERVICE in $SERVICES; do
  killall $SERVICE
  $SERVICE &
  PID=`pidof $SERVICE`
done
# restart
killall vendor.qti.hardware.vibrator.service\
 vendor.qti.hardware.vibrator.service.oneplus9\
 android.hardware.camera.provider@2.4-service_64\
 vendor.mediatek.hardware.mtkpower@1.0-service\
 android.hardware.usb@1.0-service\
 android.hardware.usb@1.0-service.basic\
 android.hardware.light-service.mt6768\
 android.hardware.lights-service.xiaomi_mithorium\
 vendor.samsung.hardware.light-service\
 android.hardware.sensors@1.0-service\
 android.hardware.sensors@2.0-service\
 android.hardware.sensors@2.0-service-mediatek\
 android.hardware.sensors@2.0-service.multihal\
 android.hardware.health-service.qti
}

# dolby
#ddolby_service

# wait
sleep 20

# aml fix
AML=/data/adb/modules/aml
if [ -L $AML/system/vendor ]\
&& [ -d $AML/vendor ]; then
  DIR=$AML/vendor/odm/etc
else
  DIR=$AML/system/vendor/odm/etc
fi
if [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR
fi
AUD=`grep AUD= $MODPATH/copy.sh | sed -e 's|AUD=||g' -e 's|"||g'`
if [ -L $AML/system/vendor ]\
&& [ -d $AML/vendor ]; then
  DIR=$AML/vendor
else
  DIR=$AML/system/vendor
fi
FILES=`find $DIR -type f -name $AUD`
if [ -d $AML ] && [ ! -f $AML/disable ]\
&& find $DIR -type f -name $AUD; then
  if ! grep '/odm' $AML/post-fs-data.sh && [ -d /odm ]\
  && [ "`realpath /odm/etc`" == /odm/etc ]; then
    for FILE in $FILES; do
      DES=/odm`echo $FILE | sed "s|$DIR||g"`
      if [ -f $DES ]; then
        umount $DES
        mount -o bind $FILE $DES
      fi
    done
  fi
  if ! grep '/my_product' $AML/post-fs-data.sh\
  && [ -d /my_product ]; then
    for FILE in $FILES; do
      DES=/my_product`echo $FILE | sed "s|$DIR||g"`
      if [ -f $DES ]; then
        umount $DES
        mount -o bind $FILE $DES
      fi
    done
  fi
fi

# wait
until [ "`getprop sys.boot_completed`" == "1" ]; do
  sleep 10
done

# grant
PKG=com.sonyericsson.soundenhancement
pm grant $PKG android.permission.RECORD_AUDIO
if [ "$API" -ge 30 ]; then
  appops set $PKG SYSTEM_ALERT_WINDOW allow
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi
if [ "$API" -ge 33 ]; then
  appops set $PKG ACCESS_RESTRICTED_SETTINGS allow
fi
PKGOPS=`appops get $PKG`
UID=`dumpsys package $PKG 2>/dev/null | grep -m 1 userId= | sed 's|    userId=||g'`
if [ "$UID" ] && [ "$UID" -gt 9999 ]; then
  UIDOPS=`appops get --uid "$UID"`
fi

# allow
PKG=com.dolby.daxappui
if appops get $PKG > /dev/null 2>&1; then
  if [ "$API" -ge 30 ]; then
    appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
  fi
  PKGOPS=`appops get $PKG`
  UID=`dumpsys package $PKG 2>/dev/null | grep -m 1 userId= | sed 's|    userId=||g'`
  if [ "$UID" ] && [ "$UID" -gt 9999 ]; then
    UIDOPS=`appops get --uid "$UID"`
  fi
fi

# allow
PKG=com.dolby.daxservice
if appops get $PKG > /dev/null 2>&1; then
  if [ "$API" -ge 30 ]; then
    appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
  fi
  PKGOPS=`appops get $PKG`
  UID=`dumpsys package $PKG 2>/dev/null | grep -m 1 userId= | sed 's|    userId=||g'`
  if [ "$UID" ] && [ "$UID" -gt 9999 ]; then
    UIDOPS=`appops get --uid "$UID"`
  fi
fi

# function
stop_log() {
SIZE=`du $LOGFILE | sed "s|$LOGFILE||g"`
if [ "$LOG" != stopped ] && [ "$SIZE" -gt 50 ]; then
  exec 2>/dev/null
  set +x
  LOG=stopped
fi
}
check_audioserver() {
if [ "$NEXTPID" ]; then
  PID=$NEXTPID
else
  PID=`pidof $SERVER`
fi
sleep 15
stop_log
NEXTPID=`pidof $SERVER`
if [ "`getprop init.svc.$SERVER`" != stopped ]; then
  [ "$PID" != "$NEXTPID" ] && killall $PROC
else
  start $SERVER
fi
check_audioserver
}
check_service() {
for SERVICE in $SERVICES; do
  if ! pidof $SERVICE; then
    $SERVICE &
    PID=`pidof $SERVICE`
  fi
done
}

# check
#dcheck_service
PROC=com.sonyericsson.soundenhancement
#dPROC="com.sonyericsson.soundenhancement com.dolby.daxservice com.dolby.daxappui"
killall $PROC
check_audioserver










