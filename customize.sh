ui_print " "

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi

# optionals
OPTIONALS=/sdcard/optionals.prop

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
ui_print " MagiskVersion=$MAGISK_VER"
ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
ui_print " "

# sdk
NUM=29
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API. You have to upgrade your"
  ui_print "  Android version at least SDK API $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# bit
if [ "$IS64BIT" == true ]; then
  ui_print "- 64 bit"
  ui_print " "
  if [ "`grep_prop se.dolby $OPTIONALS`" == 1 ]; then
    ui_print "- Activating Dolby Atmos..."
    DOLBY=true
    MODNAME2='Sound Enhancement Xperia 10 and Dolby Atmos Xperia 1 II'
    sed -i "s/$MODNAME/$MODNAME2/g" $MODPATH/module.prop
    MODNAME=$MODNAME2
    ui_print " "
  else
    DOLBY=false
  fi
else
  ui_print "- 32 bit"
  rm -rf `find $MODPATH/system -type d -name *64`
  DOLBY=false
  if [ "`grep_prop se.dolby $OPTIONALS`" == 1 ]; then
    ui_print "  ! Unsupported Dolby Atmos."
  fi
  ui_print " "
fi

# mount
if [ "$BOOTMODE" != true ]; then
  mount -o rw -t auto /dev/block/bootdevice/by-name/cust /vendor
  mount -o rw -t auto /dev/block/bootdevice/by-name/vendor /vendor
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi

# sepolicy.rule
FILE=$MODPATH/sepolicy.sh
DES=$MODPATH/sepolicy.rule
if [ -f $FILE ] && [ "`grep_prop sepolicy.sh $OPTIONALS`" != 1 ]; then
  mv -f $FILE $DES
  sed -i 's/magiskpolicy --live "//g' $DES
  sed -i 's/"//g' $DES
fi

# .aml.sh
mv -f $MODPATH/aml.sh $MODPATH/.aml.sh

# mod ui
if [ "`grep_prop mod.ui $OPTIONALS`" == 1 ]; then
  APP=SoundEnhancement
  FILE=/sdcard/$APP.apk
  DIR=`find $MODPATH/system -type d -name $APP`
  ui_print "- Using modified UI apk..."
  if [ -f $FILE ]; then
    cp -f $FILE $DIR
    chmod 0644 $DIR/$APP.apk
    ui_print "  Applied"
  else
    ui_print "  ! There is no $FILE file."
    ui_print "    Please place the apk to your internal storage first"
    ui_print "    and reflash!"
  fi
  ui_print " "
fi

# cleaning
ui_print "- Cleaning..."
PKG="com.sonyericsson.soundenhancement
     com.soundenhancement.launcher
     com.sonymobile.audioutil"
if [ "$BOOTMODE" == true ]; then
  for PKGS in $PKG; do
    RES=`pm uninstall $PKGS`
  done
fi
rm -rf $MODPATH/unused
rm -rf /metadata/magisk/$MODID
rm -rf /mnt/vendor/persist/magisk/$MODID
rm -rf /persist/magisk/$MODID
rm -rf /data/unencrypted/magisk/$MODID
rm -rf /cache/magisk/$MODID
ui_print " "

# function
conflict() {
for NAMES in $NAME; do
  DIR=/data/adb/modules_update/$NAMES
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAMES
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAMES/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAMES
  rm -rf /mnt/vendor/persist/magisk/$NAMES
  rm -rf /persist/magisk/$NAMES
  rm -rf /data/unencrypted/magisk/$NAMES
  rm -rf /cache/magisk/$NAMES
done
}

# conflict
if [ $DOLBY == true ]; then
  NAME="dolbyatmos
        DolbyAudio
        DolbyAtmos
        MotoDolby
        dsplus
        Dolby"
  conflict
  NAME=MiSound
  FILE=/data/adb/modules/$NAME/module.prop
  if grep -Eq 'Mi Sound and Dolby Atmos' $FILE; then
    conflict
  fi
fi

# function
cleanup() {
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
DIR=/data/adb/modules_update/$MODID
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
}

# cleanup
DIR=/data/adb/modules/$MODID
FILE=$DIR/module.prop
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's/^data.cleanup=1/data.cleanup=0/' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
elif [ -d $DIR ] && ! grep -Eq "$MODNAME" $FILE; then
  ui_print "- Different version detected"
  ui_print "  Cleaning-up $MODID data..."
  cleanup
  ui_print " "
fi

# check
NAME=_ZN7android8hardware23getOrCreateCachedBinderEPNS_4hidl4base4V1_05IBaseE
if [ "$BOOTMODE" == true ]; then
  DIR=`realpath $MAGISKTMP/mirror/system`
else
  DIR=`realpath /system`
fi
if [ $DOLBY == true ]; then
  ui_print "- Checking"
  ui_print "$NAME"
  ui_print "  function"
  ui_print "  Please wait..."
  if ! grep -Eq $NAME `find $DIR/lib64 -type f -name *audio*.so`; then
    ui_print "  ! Function not found."
    ui_print "  Unsupported Dolby Atmos."
    DOLBY=false
  fi
  ui_print " "
fi

# function
permissive() {
SELINUX=`getenforce`
if [ "$SELINUX" == Enforcing ]; then
  setenforce 0
  SELINUX=`getenforce`
  if [ "$SELINUX" == Enforcing ]; then
    ui_print "  ! Your device can't be turned to Permissive state."
    if [ $DOLBY == true ]; then
      ui_print "    Unsupported Dolby Atmos."
      DOLBY=false
    fi
  fi
  setenforce 1
fi
sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  setenforce 0\
fi\' $MODPATH/post-fs-data.sh
}
set_read_write() {
for NAMES in $NAME; do
  blockdev --setrw $DIR$NAMES
done
}
backup() {
if [ ! -f $FILE.orig ] && [ ! -f $FILE.bak ]; then
  cp -f $FILE $FILE.orig
fi
}
patch_manifest() {
if [ -f $FILE ]; then
  backup
  if [ -f $FILE.orig ] || [ -f $FILE.bak ]; then
    ui_print "- Created"
    ui_print "$FILE.orig"
    ui_print " "
    ui_print "- Patching"
    ui_print "$FILE"
    ui_print "  directly..."
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
    </hal>' $FILE
    ui_print " "
  else
    ui_print "! Failed to create"
    ui_print "$FILE.orig"
    ui_print " "
  fi
fi
}
patch_hwservice() {
if [ -f $FILE ]; then
  backup
  if [ -f $FILE.orig ] || [ -f $FILE.bak ]; then
    ui_print "- Created"
    ui_print "$FILE.orig"
    ui_print " "
    ui_print "- Patching"
    ui_print "$FILE"
    ui_print "  directly..."
    sed -i '1i\
vendor.dolby.hardware.dms::IDms u:object_r:hal_dms_hwservice:s0' $FILE
    ui_print " "
  else
    ui_print "! Failed to create"
    ui_print "$FILE.orig"
    ui_print " "
  fi
fi
}
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
early_init_mount_dir() {
if echo $MAGISK_VER | grep -Eq delta; then
  EIM=true
  ACTIVEEIMDIR=$MAGISKTMP/mirror/early-mount
  if [ -L $ACTIVEEIMDIR ]; then
    EIMDIR=$(readlink $ACTIVEEIMDIR)
    [ "${EIMDIR:0:1}" != "/" ] && EIMDIR="$MAGISKTMP/mirror/$EIMDIR"
  elif ! $ISENCRYPTED\
  && [ -d $NVBASE/modules/early-mount.d ]; then
    EIMDIR=$NVBASE/modules/early-mount.d
  elif [ -d /data/unencrypted/early-mount.d ]\
  && ! grep ' /data ' /proc/mounts | grep -qE 'dm-|f2fs'; then
    EIMDIR=/data/unencrypted/early-mount.d
  elif grep ' /cache ' /proc/mounts | grep -q 'ext4'\
  && [ -d /cache/early-mount.d ]; then
    EIMDIR=/cache/early-mount.d
  elif grep ' /metadata ' /proc/mounts | grep -q 'ext4'\
  && [ -d /metadata/early-mount.d ]; then
    EIMDIR=/metadata/early-mount.d
  elif grep ' /persist ' /proc/mounts | grep -q 'ext4'\
  && [ -d /persist/early-mount.d ]; then
    EIMDIR=/persist/early-mount.d
  elif grep ' /mnt/vendor/persist ' /proc/mounts | grep -q 'ext4'\
  && [ -d /mnt/vendor/persist/early-mount.d ]; then
    EIMDIR=/mnt/vendor/persist/early-mount.d
  else
    EIM=false
    ui_print "- Unable to find early init mount directory"
  fi
  if [ -d ${EIMDIR%/early-mount.d} ]; then
    ui_print "- Your early init mount directory is"
    ui_print "  $EIMDIR"
    ui_print " "
    ui_print "  Any file stored to this directory will not be deleted even"
    ui_print "  you have uninstalled this module. You can delete it"
    ui_print "  manually using any root file manager."
  else
    EIM=false
    ui_print "- Unable to find early init mount directory ${EIMDIR%/early-mount.d}"
  fi
  ui_print " "
else
  EIM=false
fi
}
find_file() {
for NAMES in $NAME; do
  if [ "$SYSTEM_ROOT" == true ]; then
    if [ "$BOOTMODE" == true ]; then
      FILE=`find $MAGISKTMP/mirror/system_root\
                 $MAGISKTMP/mirror/system_ext\
                 $MAGISKTMP/mirror/vendor -type f -name $NAMES`
    else
      FILE=`find /system_root\
                 /system_ext\
                 /vendor -type f -name $NAMES`
    fi
  else
    if [ "$BOOTMODE" == true ]; then
      FILE=`find $MAGISKTMP/mirror/system\
                 $MAGISKTMP/mirror/system_ext\
                 $MAGISKTMP/mirror/vendor -type f -name $NAMES`
    else
      FILE=`find /system\
                 /system_ext\
                 /vendor -type f -name $NAMES`
    fi
  fi
  if [ ! "$FILE" ]; then
    if [ "`grep_prop install.hwlib $OPTIONALS`" == 1 ]; then
      sed -i 's/^install.hwlib=1/install.hwlib=0/' $OPTIONALS
      ui_print "- Installing $NAMES directly to /system and /vendor..."
      if [ "$BOOTMODE" == true ]; then
        cp $MODPATH/system_support/lib/$NAMES $MAGISKTMP/mirror/system/lib
        cp $MODPATH/system_support/lib64/$NAMES $MAGISKTMP/mirror/system/lib64
        cp $MODPATH/system_support/vendor/lib/$NAMES $MAGISKTMP/mirror/vendor/lib
        cp $MODPATH/system_support/vendor/lib64/$NAMES $MAGISKTMP/mirror/vendor/lib64
        DES=$MAGISKTMP/mirror/system/lib/$NAMES
        DES2=$MAGISKTMP/mirror/system/lib64/$NAMES
        DES3=$MAGISKTMP/mirror/system/vendor/lib/$NAMES
        DES4=$MAGISKTMP/mirror/system/vendor/lib64/$NAMES
      else
        cp $MODPATH/system_support/lib/$NAMES /system/lib
        cp $MODPATH/system_support/lib64/$NAMES /system/lib64
        cp $MODPATH/system_support/vendor/lib/$NAMES /vendor/lib
        cp $MODPATH/system_support/vendor/lib64/$NAMES /vendor/lib64
        DES=/system/lib/$NAMES
        DES2=/system/lib64/$NAMES
        DES3=/system/vendor/lib/$NAMES
        DES4=/system/vendor/lib64/$NAMES
      fi
      if [ -f $MODPATH/system_support/lib/$NAMES ]\
      && [ ! -f $DES ]; then
        ui_print "  ! $DES"
        ui_print "    installation failed."
      fi
      if [ -f $MODPATH/system_support/lib64/$NAMES ]\
      && [ ! -f $DES2 ]; then
        ui_print "  ! $DES2"
        ui_print "    installation failed."
      fi
      if [ -f $MODPATH/system_support/vendor/lib/$NAMES ]\
      && [ ! -f $DES3 ]; then
        ui_print "  ! $DES3"
        ui_print "    installation failed."
      fi
      if [ -f $MODPATH/system_support/vendor/lib64/$NAMES ]\
      && [ ! -f $DES4 ]; then
        ui_print "  ! $DES4"
        ui_print "    installation failed."
      fi
      ui_print " "
    else
      ui_print "! $NAMES not found."
      ui_print "  This module will not be working without $NAMES."
      ui_print "  You can type:"
      ui_print "  install.hwlib=1"
      ui_print "  inside $OPTIONALS"
      ui_print "  and reinstalling this module"
      ui_print "  to install $NAMES directly to this ROM."
      ui_print " "
    fi
  fi
done
}
patch_manifest_overlay_d() {
if [ "`grep_prop dolby.skip.early $OPTIONALS`" != 1 ]\
&& echo $MAGISK_VER | grep -Eq delta; then
  if [ "$BOOTMODE" == true ]; then
    SRC=$MAGISKTMP/mirror/system/etc/vintf/manifest.xml
  else
    SRC=/system/etc/vintf/manifest.xml
  fi
  if [ -f $SRC ]; then
    DIR=$EIMDIR/system/etc/vintf
    DES=$DIR/manifest.xml
    mkdir -p $DIR
    if [ ! -f $DES ]; then
      cp -f $SRC $DIR
    fi
    if ! grep -A2 vendor.dolby.hardware.dms $DES | grep -Eq 1.0; then
      ui_print "- Patching"
      ui_print "$SRC"
      ui_print "  systemlessly using early init mount..."
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
    </hal>' $DES
      ui_print " "
    fi
  else
    EIM=false
  fi
else
  EIM=false
fi
}
patch_hwservice_overlay_d() {
if [ "`grep_prop dolby.skip.early $OPTIONALS`" != 1 ]\
&& echo $MAGISK_VER | grep -Eq delta; then
  if [ "$BOOTMODE" == true ]; then
    SRC=$MAGISKTMP/mirror/system/etc/selinux/plat_hwservice_contexts
  else
    SRC=/system/etc/selinux/plat_hwservice_contexts
  fi
  if [ -f $SRC ]; then
    DIR=$EIMDIR/system/etc/selinux
    DES=$DIR/plat_hwservice_contexts
    mkdir -p $DIR
    if [ ! -f $DES ]; then
      cp -f $SRC $DIR
    fi
    if ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $DES; then
      ui_print "- Patching"
      ui_print "$SRC"
      ui_print "  systemlessly using early init mount..."
      sed -i '1i\
vendor.dolby.hardware.dms::IDms u:object_r:hal_dms_hwservice:s0' $DES
      ui_print " "
    fi
  else
    EIM=false
  fi
else
  EIM=false
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using permissive method"
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
fi

# dolby
if [ $DOLBY == true ]; then
  sed -i 's/#d//g' $MODPATH/.aml.sh
  sed -i 's/#d//g' $MODPATH/*.sh
  cp -rf $MODPATH/system_dolby/* $MODPATH/system
  PKG2="com.dolby.daxappui com.dolby.daxservice"
  if [ "$BOOTMODE" == true ]; then
    for PKGS2 in $PKG2; do
      RES=`pm uninstall $PKGS2`
    done
  fi
  rm -f /data/vendor/dolby/dax_sqlite3.db
else
  MODNAME2='Sound Enhancement Sony Xperia 10'
  sed -i "s/$MODNAME/$MODNAME2/g" $MODPATH/module.prop
fi
rm -rf $MODPATH/system_dolby

# mod ui
if [ $DOLBY == true ]\
&& [ "`grep_prop mod.ui $OPTIONALS`" == 1 ]; then
  APP=DaxUI
  FILE=/sdcard/$APP.apk
  DIR=`find $MODPATH/system -type d -name $APP`
  ui_print "- Using modified Dolby UI apk..."
  if [ -f $FILE ]; then
    cp -f $FILE $DIR
    chmod 0644 $DIR/$APP.apk
    ui_print "  Applied"
  else
    ui_print "  ! There is no $FILE file."
    ui_print "    Please place the apk to your internal storage first"
    ui_print "    and reflash!"
  fi
  ui_print " "
fi

# power save
FILE=$MODPATH/system/etc/sysconfig/*
if [ "`grep_prop power.save $OPTIONALS`" == 1 ]; then
  ui_print "- $MODNAME will not be allowed in power save."
  ui_print "  It may save your battery but decreasing $MODNAME performance."
  for PKGS in $PKG; do
    sed -i "s/<allow-in-power-save package=\"$PKGS\"\/>//g" $FILE
    sed -i "s/<allow-in-power-save package=\"$PKGS\" \/>//g" $FILE
  done
  ui_print " "
fi

# remount
if [ $DOLBY == true ]; then
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
fi

# early init mount dir
early_init_mount_dir

# find
chcon -R u:object_r:system_lib_file:s0 $MODPATH/system_support/lib*
chcon -R u:object_r:same_process_hal_file:s0 $MODPATH/system_support/vendor/lib*
NAME=`ls $MODPATH/system_support/vendor/lib`
if [ $DOLBY == true ]; then
  find_file
fi
rm -rf $MODPATH/system_support

# patch manifest.xml
if [ $DOLBY == true ]; then
  FILE="$MAGISKTMP/mirror/*/etc/vintf/manifest.xml
        $MAGISKTMP/mirror/*/*/etc/vintf/manifest.xml
        /*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml
        $MAGISKTMP/mirror/*/etc/vintf/manifest/*.xml
        $MAGISKTMP/mirror/*/*/etc/vintf/manifest/*.xml
        /*/etc/vintf/manifest/*.xml /*/*/etc/vintf/manifest/*.xml"
  if [ "`grep_prop dolby.skip.vendor $OPTIONALS`" != 1 ]\
  && ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    FILE=$MAGISKTMP/mirror/vendor/etc/vintf/manifest.xml
    patch_manifest
  fi
  if [ "`grep_prop dolby.skip.system $OPTIONALS`" != 1 ]\
  && ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    FILE=$MAGISKTMP/mirror/system/etc/vintf/manifest.xml
    patch_manifest
  fi
  if [ "`grep_prop dolby.skip.system_ext $OPTIONALS`" != 1 ]\
  && ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    FILE=$MAGISKTMP/mirror/system_ext/etc/vintf/manifest.xml
   patch_manifest
  fi
  if [ "`grep_prop dolby.skip.vendor $OPTIONALS`" != 1 ]\
  && ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    FILE=/vendor/etc/vintf/manifest.xml
    patch_manifest
  fi
  if [ "`grep_prop dolby.skip.system $OPTIONALS`" != 1 ]\
  && ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    FILE=/system/etc/vintf/manifest.xml
    patch_manifest
  fi
  if [ "`grep_prop dolby.skip.system_ext $OPTIONALS`" != 1 ]\
  && ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    FILE=/system/system_ext/etc/vintf/manifest.xml
    patch_manifest
  fi
  if ! grep -A2 vendor.dolby.hardware.dms $FILE | grep -Eq 1.0; then
    patch_manifest_overlay_d
    if [ $EIM == false ]; then
      ui_print "- Using systemless manifest.xml patch."
      ui_print "  On some ROMs, it's buggy or even makes bootloop"
      ui_print "  because not allowed to restart hwservicemanager."
      ui_print " "
    fi
    FILE="$MAGISKTMP/mirror/*/etc/vintf/manifest.xml
          $MAGISKTMP/mirror/*/*/etc/vintf/manifest.xml
          /*/etc/vintf/manifest.xml /*/*/etc/vintf/manifest.xml"
    restore
  fi
fi

# patch hwservice contexts
if [ $DOLBY == true ]; then
  FILE="$MAGISKTMP/mirror/*/etc/selinux/*_hwservice_contexts
        $MAGISKTMP/mirror/*/*/etc/selinux/*_hwservice_contexts
        /*/etc/selinux/*_hwservice_contexts
        /*/*/etc/selinux/*_hwservice_contexts"
  if [ "`grep_prop dolby.skip.vendor $OPTIONALS`" != 1 ]\
  && ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    FILE=$MAGISKTMP/mirror/vendor/etc/selinux/vendor_hwservice_contexts
    patch_hwservice
  fi
  if [ "`grep_prop dolby.skip.system $OPTIONALS`" != 1 ]\
  && ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    FILE=$MAGISKTMP/mirror/system/etc/selinux/plat_hwservice_contexts
    patch_hwservice
  fi
  if [ "`grep_prop dolby.skip.system_ext $OPTIONALS`" != 1 ]\
   && ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    FILE=$MAGISKTMP/mirror/system_ext/etc/selinux/system_ext_hwservice_contexts
    patch_hwservice
  fi
  if [ "`grep_prop dolby.skip.vendor $OPTIONALS`" != 1 ]\
  && ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    FILE=/vendor/etc/selinux/vendor_hwservice_contexts
    patch_hwservice
  fi
  if [ "`grep_prop dolby.skip.system $OPTIONALS`" != 1 ]\
  && ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    FILE=/system/etc/selinux/plat_hwservice_contexts
    patch_hwservice
  fi
  if [ "`grep_prop dolby.skip.system_ext $OPTIONALS`" != 1 ]\
  && ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    FILE=/system/system_ext/etc/selinux/system_ext_hwservice_contexts
    patch_hwservice
  fi
  if ! grep -Eq 'u:object_r:hal_dms_hwservice:s0|u:object_r:default_android_hwservice:s0' $FILE; then
    patch_hwservice_overlay_d
    if [ $EIM == false ]; then
      ui_print "! Failed to set hal_dms_hwservice context."
      ui_print " "
    fi
    FILE="$MAGISKTMP/mirror/*/etc/selinux/*_hwservice_contexts
          $MAGISKTMP/mirror/*/*/etc/selinux/*_hwservice_contexts
          /*/etc/selinux/*_hwservice_contexts
          /*/*/etc/selinux/*_hwservice_contexts"
    restore
  fi
fi

# remount
if [ "$BOOTMODE" == true ] && [ $DOLBY == true ]; then
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

# function
hide_oat() {
for APPS in $APP; do
  mkdir -p `find $MODPATH/system -type d -name $APPS`/oat
  touch `find $MODPATH/system -type d -name $APPS`/oat/.replace
done
}
replace_dir() {
if [ -d $DIR ]; then
  mkdir -p $MODDIR
  touch $MODDIR/.replace
fi
}
hide_app() {
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/system/app/$APPS
else
  DIR=/system/app/$APPS
fi
MODDIR=$MODPATH/system/app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/system/priv-app/$APPS
else
  DIR=/system/priv-app/$APPS
fi
MODDIR=$MODPATH/system/priv-app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/product/app/$APPS
else
  DIR=/product/app/$APPS
fi
MODDIR=$MODPATH/system/product/app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/product/priv-app/$APPS
else
  DIR=/product/priv-app/$APPS
fi
MODDIR=$MODPATH/system/product/priv-app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=/mnt/vendor/my_product/app/$APPS
else
  DIR=/my_product/app/$APPS
fi
MODDIR=$MODPATH/system/product/app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=/mnt/vendor/my_product/priv-app/$APPS
else
  DIR=/my_product/priv-app/$APPS
fi
MODDIR=$MODPATH/system/product/priv-app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/product/preinstall/$APPS
else
  DIR=/product/preinstall/$APPS
fi
MODDIR=$MODPATH/system/product/preinstall/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/system_ext/app/$APPS
else
  DIR=/system/system_ext/app/$APPS
fi
MODDIR=$MODPATH/system/system_ext/app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/system_ext/priv-app/$APPS
else
  DIR=/system/system_ext/priv-app/$APPS
fi
MODDIR=$MODPATH/system/system_ext/priv-app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/vendor/app/$APPS
else
  DIR=/vendor/app/$APPS
fi
MODDIR=$MODPATH/system/vendor/app/$APPS
replace_dir
if [ "$BOOTMODE" == true ]; then
  DIR=$MAGISKTMP/mirror/vendor/euclid/product/app/$APPS
else
  DIR=/vendor/euclid/product/app/$APPS
fi
MODDIR=$MODPATH/system/vendor/euclid/product/app/$APPS
replace_dir
}
check_app() {
if [ "$BOOTMODE" == true ]\
&& [ "`grep_prop hide.parts $OPTIONALS`" == 1 ]; then
  for APPS in $APP; do
    FILE=`find $MAGISKTMP/mirror/system_root/system\
               $MAGISKTMP/mirror/system_root/product\
               $MAGISKTMP/mirror/system_root/system_ext\
               $MAGISKTMP/mirror/system\
               $MAGISKTMP/mirror/product\
               $MAGISKTMP/mirror/system_ext\
               $MAGISKTMP/mirror/vendor -type f -name $APPS.apk`
    if [ "$FILE" ]; then
      ui_print "  Checking $APPS.apk"
      ui_print "  Please wait..."
      if grep -Eq $UUID $FILE; then
        ui_print "  Your $APPS.apk will be hidden"
        hide_app
      fi
    fi
  done
fi
}
detect_soundfx() {
if [ "$BOOTMODE" == true ]\
&& dumpsys media.audio_flinger | grep -Eq $UUID; then
  ui_print "- $NAME is detected."
  ui_print "  It may be conflicting with this module."
  ui_print "  You can type:"
  ui_print "  disable.dirac=1"
  ui_print "  inside $OPTIONALS"
  ui_print "  and reinstall this module if you want to disable it."
  ui_print " "
fi
}

# hide
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
hide_oat
APP="MusicFX AudioFX"
for APPS in $APP; do
  hide_app
done
if [ $DOLBY == true ]; then
  APP="MotoDolbyDax3 MotoDolbyV3 OPSoundTuner DolbyAtmos AudioEffectCenter"
  for APPS in $APP; do
    hide_app
  done
fi
if [ "`grep_prop disable.dirac $OPTIONALS`" != 0 ]\
&& [ "`grep_prop disable.misoundfx $OPTIONALS`" != 0 ]; then
  APP=MiSound
  for APPS in $APP; do
    hide_app
  done
fi
if [ "`grep_prop disable.dirac $OPTIONALS`" != 0 ]; then
  APP="Dirac DiracAudioControlService"
  for APPS in $APP; do
    hide_app
  done
fi

# dirac & misoundfx
FILE=$MODPATH/.aml.sh
APP="XiaomiParts ZenfoneParts ZenParts GalaxyParts
     KharaMeParts DeviceParts PocoParts"
NAME='dirac soundfx'
UUID=e069d9e0-8329-11df-9168-0002a5d5c51b
if [ "`grep_prop disable.dirac $OPTIONALS`" != 0 ]; then
  ui_print "- $NAME will be disabled"
  sed -i 's/#2//g' $FILE
  check_app
  ui_print " "
else
  detect_soundfx
fi
FILE=$MODPATH/.aml.sh
NAME=misoundfx
UUID=5b8e36a5-144a-4c38-b1d7-0002a5d5c51b
if [ "`grep_prop disable.misoundfx $OPTIONALS`" != 0 ]; then
  ui_print "- $NAME will be disabled"
  sed -i 's/#3//g' $FILE
  check_app
  ui_print " "
else
  if [ "$BOOTMODE" == true ]\
  && dumpsys media.audio_flinger | grep -Eq $UUID; then
    ui_print "- $NAME is detected."
    ui_print "  It may be conflicting with this module."
    ui_print "  You can type:"
    ui_print "  disable.misoundfx=1"
    ui_print "  inside $OPTIONALS"
    ui_print "  and reinstall this module if you want to disable it."
    ui_print " "
  fi
fi

# dirac_controller
FILE=$MODPATH/.aml.sh
NAME='dirac_controller soundfx'
UUID=b437f4de-da28-449b-9673-667f8b964304
if [ "`grep_prop disable.dirac $OPTIONALS`" != 0 ]; then
  ui_print "- $NAME will be disabled"
  ui_print " "
else
  detect_soundfx
fi

# dirac_music
FILE=$MODPATH/.aml.sh
NAME='dirac_music soundfx'
UUID=b437f4de-da28-449b-9673-667f8b9643fe
if [ "`grep_prop disable.dirac $OPTIONALS`" != 0 ]; then
  ui_print "- $NAME will be disabled"
  ui_print " "
else
  detect_soundfx
fi

# dirac_gef
FILE=$MODPATH/.aml.sh
NAME='dirac_gef soundfx'
UUID=3799D6D1-22C5-43C3-B3EC-D664CF8D2F0D
if [ "`grep_prop disable.dirac $OPTIONALS`" != 0 ]; then
  ui_print "- $NAME will be disabled"
  ui_print " "
else
  detect_soundfx
fi

# stream mode
FILE=$MODPATH/.aml.sh
PROP=`grep_prop stream.mode $OPTIONALS`
if [ $DOLBY == true ]; then
  if echo "$PROP" | grep -Eq m; then
    ui_print "- Activating Dolby music stream..."
    sed -i 's/#m//g' $FILE
    ui_print " "
  else
    ui_print "- Sound Enhancement post process effect is disabled"
    ui_print "  for Dolby Atmos global effect"
    sed -i 's/persist.sony.effect.dolby_atmos false/persist.sony.effect.dolby_atmos true/g' $MODPATH/service.sh
    sed -i 's/persist.sony.effect.ahc true/persist.sony.effect.ahc false/g' $MODPATH/service.sh
    ui_print " "
  fi
  if echo "$PROP" | grep -Eq r; then
    ui_print "- Activating Dolby ring stream..."
    sed -i 's/#r//g' $FILE
    ui_print " "
  fi
  if echo "$PROP" | grep -Eq a; then
    ui_print "- Activating Dolby alarm stream..."
    sed -i 's/#a//g' $FILE
    ui_print " "
  fi
  if echo "$PROP" | grep -Eq s; then
    ui_print "- Activating Dolby system stream..."
    sed -i 's/#s//g' $FILE
    ui_print " "
  fi
  if echo "$PROP" | grep -Eq v; then
    ui_print "- Activating Dolby voice_call stream..."
    sed -i 's/#v//g' $FILE
    ui_print " "
  fi
  if echo "$PROP" | grep -Eq n; then
    ui_print "- Activating Dolby notification stream..."
    sed -i 's/#n//g' $FILE
    ui_print " "
  fi
fi
if [ "`grep_prop se.znr $OPTIONALS`" == 1 ]; then
  ui_print "- Activating Sony Zoom Noise Reduction for camcorder, mic,"
  ui_print "  and voice recognition stream..."
  sed -i 's/#c//g' $FILE
  ui_print " "
fi

# settings
if [ $DOLBY == true ]; then
  FILE=$MODPATH/system/vendor/etc/dolby/dax-default.xml
  PROP=`grep_prop dolby.bass $OPTIONALS`
  if [ "$PROP" == def ]; then
    ui_print "- Using default settings for bass enhancer"
  elif [ "$PROP" == true ]; then
    ui_print "- Enable bass enhancer for all profiles"
    sed -i 's/bass-enhancer-enable value="false"/bass-enhancer-enable value="true"/g' $FILE
  elif [ "$PROP" ] && [ "$PROP" != false ] && [ "$PROP" -gt 0 ]; then
    ui_print "- Enable bass enhancer for all profiles"
    sed -i 's/bass-enhancer-enable value="false"/bass-enhancer-enable value="true"/g' $FILE
    ui_print "- Changing bass enhancer boost values to $PROP for all profiles"
    ROW=`grep bass-enhancer-boost $FILE | sed 's/<bass-enhancer-boost value="0"\/>//p'`
    echo $ROW > $TMPDIR/test
    sed -i 's/<bass-enhancer-boost value="//g' $TMPDIR/test
    sed -i 's/"\/>//g' $TMPDIR/test
    ROW=`cat $TMPDIR/test`
    ui_print "  (Default values: $ROW)"
    for ROWS in $ROW; do
      sed -i "s/bass-enhancer-boost value=\"$ROWS\"/bass-enhancer-boost value=\"$PROP\"/g" $FILE
    done
  else
    ui_print "- Disable bass enhancer for all profiles"
    sed -i 's/bass-enhancer-enable value="true"/bass-enhancer-enable value="false"/g' $FILE
  fi
  if [ "`grep_prop dolby.virtualizer $OPTIONALS`" == 1 ]; then
    ui_print "- Enable virtualizer for all profiles"
    sed -i 's/virtualizer-enable value="false"/virtualizer-enable value="true"/g' $FILE
  elif [ "`grep_prop dolby.virtualizer $OPTIONALS`" == 0 ]; then
    ui_print "- Disable virtualizer for all profiles"
    sed -i 's/virtualizer-enable value="true"/virtualizer-enable value="false"/g' $FILE
  fi
  if [ "`grep_prop dolby.volumeleveler $OPTIONALS`" == def ]; then
    ui_print "- Using default volume leveler settings"
  elif [ "`grep_prop dolby.volumeleveler $OPTIONALS`" == 1 ]; then
    ui_print "- Enable volume leveler for all profiles"
    sed -i 's/volume-leveler-enable value="false"/volume-leveler-enable value="true"/g' $FILE
  else
    ui_print "- Disable volume leveler for all profiles"
    sed -i 's/volume-leveler-enable value="true"/volume-leveler-enable value="false"/g' $FILE
  fi
  if [ "`grep_prop dolby.deepbass $OPTIONALS`" != 0 ]; then
    ui_print "- Using deeper bass GEQ frequency"
    sed -i 's/frequency="47"/frequency="0"/g' $FILE
    sed -i 's/frequency="141"/frequency="47"/g' $FILE
    sed -i 's/frequency="234"/frequency="141"/g' $FILE
    sed -i 's/frequency="328"/frequency="234"/g' $FILE
    sed -i 's/frequency="469"/frequency="328"/g' $FILE
    sed -i 's/frequency="656"/frequency="469"/g' $FILE
    sed -i 's/frequency="844"/frequency="656"/g' $FILE
    sed -i 's/frequency="1031"/frequency="844"/g' $FILE
    sed -i 's/frequency="1313"/frequency="1031"/g' $FILE
    sed -i 's/frequency="1688"/frequency="1313"/g' $FILE
    sed -i 's/frequency="2250"/frequency="1688"/g' $FILE
    sed -i 's/frequency="3000"/frequency="2250"/g' $FILE
    sed -i 's/frequency="3750"/frequency="3000"/g' $FILE
    sed -i 's/frequency="4688"/frequency="3750"/g' $FILE
    sed -i 's/frequency="5813"/frequency="4688"/g' $FILE
    sed -i 's/frequency="7125"/frequency="5813"/g' $FILE
    sed -i 's/frequency="9000"/frequency="7125"/g' $FILE
    sed -i 's/frequency="11250"/frequency="9000"/g' $FILE
    sed -i 's/frequency="13875"/frequency="11250"/g' $FILE
    sed -i 's/frequency="19688"/frequency="13875"/g' $FILE
  fi
  ui_print " "
fi

# check
NAME=libaudio-resampler.so
if [ "$BOOTMODE" == true ]; then
  FILE=$MAGISKTMP/mirror/system/lib/$NAME
  FILE2=$MAGISKTMP/mirror/system/lib64/$NAME
else
  FILE=/system/lib/$NAME
  FILE2=/system/lib64/$NAME
fi
if [ -f $FILE ] || [ -f $FILE2 ]; then
  rm -f `find $MODPATH -type f -name $NAME`
else
  ui_print "- Added $NAME"
  ui_print " "
fi

# function
file_check() {
  if [ "$BOOTMODE" == true ]; then
    FILE=$MAGISKTMP/mirror/vendor/lib/$NAME
    FILE2=$MAGISKTMP/mirror/vendor/lib64/$NAME
  else
    FILE=/vendor/lib/$NAME
    FILE2=/vendor/lib64/$NAME
  fi
  if [ -f $FILE ] || [ -f $FILE2 ]; then
    rm -f `find $MODPATH -type f -name $NAME`
  else
    ui_print "- Added $NAME"
    ui_print " "
  fi
}

# check
NAME=libAlacSwDec.so
file_check
NAME=libOmxAlacDec.so
file_check
NAME=libOmxAlacDecSw.so
file_check

# check
NAME=dsee_hx_state
if [ "$BOOTMODE" == true ]; then
  FILE=$MAGISKTMP/mirror/vendor/lib*/hw/audio.primary.*.so
else
  FILE=/vendor/lib*/hw/audio.primary.*.so
fi
if grep -Eq "$NAME" $FILE ; then
  ui_print "- Detected DSEEHX support in"
  ui_print "$FILE"
  sed -i 's/ro.somc.dseehx.supported true/ro.somc.dseehx.supported false/g' $MODPATH/service.sh
  ui_print " "
fi

# audio rotation
FILE=$MODPATH/service.sh
if [ "`grep_prop audio.rotation $OPTIONALS`" == 1 ]; then
  ui_print "- Activating ro.audio.monitorRotation=true"
  sed -i '1i\
resetprop ro.audio.monitorRotation true' $FILE
  ui_print " "
fi

# raw
FILE=$MODPATH/.aml.sh
if [ "`grep_prop disable.raw $OPTIONALS`" == 0 ]; then
  ui_print "- Not disabling Ultra Low Latency playback (RAW)"
  ui_print " "
else
  sed -i 's/#u//g' $FILE
fi

# other
FILE=$MODPATH/service.sh
if [ "`grep_prop other.etc $OPTIONALS`" == 1 ]; then
  ui_print "- Activating other etc files bind mount..."
  sed -i 's/#p//g' $FILE
  ui_print " "
fi

# function
file_check_vendor() {
for NAMES in $NAME; do
  if [ "$BOOTMODE" == true ]; then
    FILE64=$MAGISKTMP/mirror/vendor/lib64/$NAMES
    FILE=$MAGISKTMP/mirror/vendor/lib/$NAMES
  else
    FILE64=/vendor/lib64/$NAMES
    FILE=/vendor/lib/$NAMES
  fi
  FILE64_2=/odm/lib64/$NAMES
  FILE_2=/odm/lib/$NAMES
  if [ -f $FILE64 ] || [ -f $FILE64_2 ]; then
    ui_print "- Detected $NAMES 64 bit"
    rm -f $MODPATH/system/vendor/lib64/$NAMES
    ui_print " "
  fi
  if [ -f $FILE ] || [ -f $FILE_2 ]; then
    ui_print "- Detected $NAMES"
    rm -f $MODPATH/system/vendor/lib/$NAMES
    ui_print " "
  fi
done
}

# check
NAME="libstagefrightdolby.so
      libstagefright_soft_ddpdec.so
      libstagefright_soft_ac4dec.so"
if [ $DOLBY == true ]; then
  file_check_vendor
fi

# permission
ui_print "- Setting permission..."
FILE=`find $MODPATH/system/bin $MODPATH/system/vendor/bin $MODPATH/system/vendor/odm/bin -type f`
for FILES in $FILE; do
  chmod 0755 $FILES
done
chmod 0751 $MODPATH/system/bin
chmod 0751 $MODPATH/system/vendor/bin
chmod 0751 $MODPATH/system/vendor/bin/hw
chmod 0755 $MODPATH/system/vendor/odm/bin
chmod 0755 $MODPATH/system/vendor/odm/bin/hw
chown -R 0.2000 $MODPATH/system/bin
DIR=`find $MODPATH/system/vendor -type d`
for DIRS in $DIR; do
  chown 0.2000 $DIRS
done
FILE=`find $MODPATH/system/vendor/bin -type f`
for FILES in $FILE; do
  chown 0.2000 $FILES
done
ui_print " "

# vendor_overlay
if [ $DOLBY == true ]; then
  DIR=/product/vendor_overlay
  if [ -d $DIR ]; then
    ui_print "- Fixing $DIR mount..."
    cp -rf $DIR/*/* $MODPATH/system/vendor
    ui_print " "
  fi
fi

# uninstaller
NAME=DolbyUninstaller.zip
if [ $DOLBY == true ]; then
  cp -f $MODPATH/$NAME /sdcard
  ui_print "- Flash /sdcard/$NAME"
  ui_print "  via recovery if you got bootloop"
  ui_print " "
fi
rm -f $MODPATH/$NAME






