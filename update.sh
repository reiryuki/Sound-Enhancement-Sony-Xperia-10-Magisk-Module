copy_library() {
DIR=`find /data/app -type d -name *$PKG*`
DES=$DIR/lib/$ARCH
if [ "$ARCH" ]; then
  if echo "$ABI" | grep 64; then
    if echo $DES | grep $PKG; then
      mkdir -p $DES
      for NAMES in $NAME; do
        if [ -f /system/lib64/$NAMES ]; then
          cp -f /system/lib64/$NAMES $DES
        else
          cp -f /system/apex/*/lib64/$NAMES $DES
          cp -f /apex/*/lib64/$NAMES $DES
        fi
      done
      chmod 0755 $DIR/*
      chown -R 1000.1000 $DIR/lib
    fi
  else
    if echo $DES | grep $PKG; then
      mkdir -p $DES
      for NAMES in $NAME; do
        if [ -f /system/lib/$NAMES ]; then
          cp -f /system/lib/$NAMES $DES
        else
          cp -f /system/apex/*/lib/$NAMES $DES
          cp -f /apex/*/lib/$NAMES $DES
        fi
      done
      chmod 0755 $DIR/*
      chown -R 1000.1000 $DIR/lib
    fi
  fi
fi
}

ABI=`getprop ro.product.cpu.abi`
if [ "$ABI" == arm64-v8a ]; then
  ARCH=arm64
elif [ "$ABI" == armeabi-v7a ] || [ "$ABI" == armeabi ]; then
  ARCH=arm
elif [ "$ABI" == x86_64 ]; then
  ARCH=x64
elif [ "$ABI" == x86 ]; then
  ARCH=x86
elif [ "$ABI" == mips64 ]; then
  ARCH=mips64
elif [ "$ABI" == mips ]; then
  ARCH=mips
fi
PKG=com.sonyericsson.soundenhancement
NAME="libhscomp_jni.so libhscomp.so"
copy_library




