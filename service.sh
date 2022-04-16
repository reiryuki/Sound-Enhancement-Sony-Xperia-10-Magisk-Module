(

MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml

# debug
exec 2>$MODPATH/debug.log
set -x

# prevent soft reboot
echo 0 > /proc/sys/kernel/panic
echo 0 > /proc/sys/kernel/panic_on_oops
echo 0 > /proc/sys/kernel/panic_on_rcu_stall
echo 0 > /proc/sys/kernel/panic_on_warn
echo 0 > /proc/sys/vm/panic_on_oom

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

# restart
killall audioserver

# stop
NAME=dms-hal-2-0
if getprop | grep "init.svc.$NAME\]: \[running"; then
  stop $NAME
fi

# function
run_service() {
if getprop | grep "init.svc.$NAME\]: \[stopped"; then
  start $NAME
fi
PID=`pidof $SERV`
if [ ! "$PID" ]; then
  $FILE &
  PID=`pidof $SERV`
fi
resetprop init.svc.$NAME running
resetprop init.svc_debug_pid.$NAME "$PID"
}

# run
NAME=dms-hal-1-0
SERV=vendor.dolby.hardware.dms@1.0-service
FILE=/vendor/bin/hw/$SERV
#drun_service

# unused
NAME=idds
SERV=$NAME
FILE=$SERV
#run_service
NAME=vendor.semc.system.idd-1-0
SERV=vendor.semc.system.idd@1.0-service
FILE=/vendor/bin/hw/$SERV
#run_service
NAME=idd-logreader
SERV=$NAME
FILE=/vendor/bin/$SERV
#run_service

# wait
sleep 20

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system/vendor
else
  DIR=$AML/system/vendor
fi
FILE=`find $DIR/odm/etc -maxdepth 1 -type f -name $NAME`
if [ "`realpath /odm/etc`" != /vendor/odm/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="$(echo $i | sed "s|$DIR||")"
    umount $j
    mount -o bind $i $j
  done
  killall audioserver
fi
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system
else
  DIR=$AML/system
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ -d /my_product/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="$(echo $i | sed "s|$DIR||")"
    umount /my_product$j
    mount -o bind $i /my_product$j
  done
  killall audioserver
fi

# run
NAME=dms-hal-1-0
SERV=vendor.dolby.hardware.dms@1.0-service
FILE=/vendor/bin/hw/$SERV
#drun_service

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
  PID=`pidof $PKG`
  if [ $PID ]; then
    echo -17 > /proc/$PID/oom_adj
    echo -1000 > /proc/$PID/oom_score_adj
  fi
fi

# special file
FILE=/dev/sony_hweffect_params
magiskpolicy --live "type audio_hweffect_device"
magiskpolicy --live "dontaudit audio_hweffect_device tmpfs filesystem associate"
magiskpolicy --live "allow     audio_hweffect_device tmpfs filesystem associate"
magiskpolicy --live "dontaudit init audio_hweffect_device file relabelfrom"
magiskpolicy --live "allow     init audio_hweffect_device file relabelfrom"
magiskpolicy --live "dontaudit init audio_hweffect_device dir relabelfrom"
magiskpolicy --live "allow     init audio_hweffect_device dir relabelfrom"
if [ ! -e $FILE ]; then
  mknod $FILE c 10 51
  chmod 0660 $FILE
  chown 1000.1005 $FILE
  chcon u:object_r:audio_hweffect_device:s0 $FILE
fi

# file
DIR=/data/vendor/audio/acdbdata/delta
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

) 2>/dev/null


