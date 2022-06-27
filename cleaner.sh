# function
cleanup() {
  for PKGS in $PKG; do
    rm -rf /data/user/*/$PKGS/cache/*
  done
}

# cleaning
MODPATH=${0%/*}
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
for APPS in $APP; do
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APPS*.apk`
done
PKG="com.sonyericsson.soundenhancement
     com.sonymobile.audioutil"
cleanup
rm -rf /data/user/*/com.reiryuki.soundenhancement.launcher/*
#dPKG="com.dolby.daxappui com.dolby.daxservice"
#dcleanup


