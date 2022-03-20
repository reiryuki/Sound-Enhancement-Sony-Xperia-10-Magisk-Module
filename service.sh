(

MODPATH=${0%/*}

# properties
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
#resetprop -n persist.vendor.dolby.loglevel 1
#resetprop vendor.dolby.dap.param.tee true
#resetprop vendor.dolby.mi.metadata.log true

# restart
killall audioserver

# run
#dstop dms-hal-2-0
#dif ! getprop | grep -Eq init.svc.dms-hal-1-0; then
#d  /vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service &
#d  PID=`pidof /vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service`
#d  resetprop init.svc.dms-hal-1-0 running
#d  resetprop init.svc_debug_pid.dms-hal-1-0 $PID
#delse
#d  killall /vendor/bin/hw/vendor.dolby.hardware.dms@1.0-service
#dfi

# run
#if ! getprop | grep -Eq init.svc.idds; then
#  idds &
#  PID=`pidof idds`
#  resetprop init.svc.idds running
#  resetprop init.svc_debug_pid.idds $PID
#fi

# run
#if ! getprop | grep -Eq init.svc.vendor.semc.system.idd-1-0; then
#  /vendor/bin/hw/vendor.semc.system.idd@1.0-service &
#  PID=`pidof /vendor/bin/hw/vendor.semc.system.idd@1.0-service`
#  resetprop init.svc.vendor.semc.system.idd-1-0 running
#  resetprop init.svc_debug_pid.vendor.semc.system.idd-1-0 $PID
#fi

# run
#if ! getprop | grep -Eq init.svc.idd-logreader; then
#  /vendor/bin/idd-logreader &
#  PID=`pidof /vendor/bin/idd-logreader`
#  resetprop init.svc.idd-logreader running
#  resetprop init.svc_debug_pid.idd-logreader $PID
#fi

# wait
sleep 60

# grant
PROP=`getprop ro.build.version.sdk`
PKG=com.sonyericsson.soundenhancement
pm grant $PKG android.permission.RECORD_AUDIO
if [ $PROP -gt 29 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# pid
PKG=com.dolby.daxservice
if pm list packages | grep -Eq $PKG ; then
  PID=`pidof $PKG`
  if [ $PID ]; then
    echo -17 > /proc/$PID/oom_adj
    echo -1000 > /proc/$PID/oom_score_adj
  fi
fi

# special file
FILE=/dev/sony_hweffect_params
#magiskpolicy --live "dontaudit audio_hweffect_device tmpfs filesystem associate"
#magiskpolicy --live "allow     audio_hweffect_device tmpfs filesystem associate"
#magiskpolicy --live "dontaudit init audio_hweffect_device file relabelfrom"
#magiskpolicy --live "allow     init audio_hweffect_device file relabelfrom"
if [ ! -e $FILE ]; then
  mknod $FILE c 10 51
  chmod 0660 $FILE
  chown 1000.1005 $FILE
  #chcon u:object_r:audio_hweffect_device:s0 $FILE
fi
#magiskpolicy --live "type audio_hweffect_device"

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


