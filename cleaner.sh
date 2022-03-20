cleanup() {
  for PKGS in $PKG; do
    rm -rf /data/user/*/$PKGS/cache/*
  done
}

PKG="com.sonyericsson.soundenhancement
     com.sonymobile.audioutil"
cleanup

rm -rf /data/user/*/com.reiryuki.soundenhancement.launcher/*

#dPKG="com.dolby.daxappui com.dolby.daxservice"
#dcleanup



