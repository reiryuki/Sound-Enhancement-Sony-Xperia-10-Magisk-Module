MODPATH=${0%/*}

# destination
LIBPATH="\/vendor\/lib\/soundfx"
MODAEC=`find $MODPATH/system -type f -name *audio*effects*.conf`
MODAEX=`find $MODPATH/system -type f -name *audio*effects*.xml`
MODAP=`find $MODPATH/system -type f -name *policy*.conf -o -name *policy*.xml`
MODAPX=`find $MODPATH/system -type f -name *policy*.xml`
MODMC=$MODPATH/system/vendor/etc/media_codecs.xml

# function
remove_conf() {
for RMVS in $RMV; do
  sed -i "s/$RMVS/removed/g" $MODAEC
done
sed -i 's/path \/vendor\/lib\/soundfx\/removed//g' $MODAEC
sed -i 's/path \/system\/lib\/soundfx\/removed//g' $MODAEC
sed -i 's/path \/vendor\/lib\/removed//g' $MODAEC
sed -i 's/path \/system\/lib\/removed//g' $MODAEC
sed -i 's/library removed//g' $MODAEC
sed -i 's/uuid removed//g' $MODAEC
sed -i "/^        removed {/ {;N s/        removed {\n        }//}" $MODAEC
}
remove_xml() {
for RMVS in $RMV; do
  sed -i "s/\"$RMVS\"/\"removed\"/g" $MODAEX
done
sed -i 's/<library name="removed" path="removed"\/>//g' $MODAEX
sed -i 's/<library name="proxy" path="removed"\/>//g' $MODAEX
sed -i 's/<effect name="removed" library="removed" uuid="removed"\/>//g' $MODAEX
sed -i 's/<effect name="removed" uuid="removed" library="removed"\/>//g' $MODAEX
sed -i 's/<libsw library="removed" uuid="removed"\/>//g' $MODAEX
sed -i 's/<libhw library="removed" uuid="removed"\/>//g' $MODAEX
sed -i 's/<apply effect="removed"\/>//g' $MODAEX
sed -i 's/<library name="removed" path="removed" \/>//g' $MODAEX
sed -i 's/<library name="proxy" path="removed" \/>//g' $MODAEX
sed -i 's/<effect name="removed" library="removed" uuid="removed" \/>//g' $MODAEX
sed -i 's/<effect name="removed" uuid="removed" library="removed" \/>//g' $MODAEX
sed -i 's/<libsw library="removed" uuid="removed" \/>//g' $MODAEX
sed -i 's/<libhw library="removed" uuid="removed" \/>//g' $MODAEX
sed -i 's/<apply effect="removed" \/>//g' $MODAEX
}

# store
RMV="ring_helper alarm_helper music_helper voice_helper
     notification_helper ma_ring_helper ma_alarm_helper
     ma_music_helper ma_voice_helper ma_system_helper
     ma_notification_helper sa3d fens lmfv dirac dtsaudio
     dlb_music_listener dlb_ring_listener dlb_alarm_listener
     dlb_system_listener dlb_notification_listener"

# setup audio effects conf
if [ "$MODAEC" ]; then
  for RMVS in $RMV; do
    sed -i "/^        $RMVS {/ {;N s/        $RMVS {\n        }//}" $MODAEC
    sed -i "s/$RMVS { }//g" $MODAEC
    sed -i "s/$RMVS {}//g" $MODAEC
  done
  if ! grep -Eq '^output_session_processing {' $MODAEC; then
    sed -i -e '$a\
output_session_processing {\
    music {\
    }\
    ring {\
    }\
    alarm {\
    }\
    system {\
    }\
    voice_call {\
    }\
    notification {\
    }\
}\' $MODAEC
  else
    if ! grep -Eq '^    notification {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    notification {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    voice_call {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    voice_call {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    system {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    system {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    alarm {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    alarm {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    ring {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    ring {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    music {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    music {\n    }" $MODAEC
    fi
  fi
fi

# setup audio effects xml
if [ "$MODAEX" ]; then
  for RMVS in $RMV; do
    sed -i "s/<apply effect=\"$RMVS\"\/>//g" $MODAEX
    sed -i "s/<apply effect=\"$RMVS\" \/>//g" $MODAEX
  done
  if ! grep -Eq '<postprocess>' $MODAEX\
  || grep -Eq '<!-- Audio post processor' $MODAEX; then
    sed -i '/<\/effects>/a\
    <postprocess>\
        <stream type="music">\
        <\/stream>\
        <stream type="ring">\
        <\/stream>\
        <stream type="alarm">\
        <\/stream>\
        <stream type="system">\
        <\/stream>\
        <stream type="voice_call">\
        <\/stream>\
        <stream type="notification">\
        <\/stream>\
    <\/postprocess>' $MODAEX
  else
    if ! grep -Eq '<stream type="notification">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"notification\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="voice_call">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"voice_call\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="system">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"system\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="alarm">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"alarm\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="ring">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"ring\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="music">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"music\">\n        <\/stream>" $MODAEX
    fi
  fi
fi

# store
LIB=libsonysweffect.so
LIBHW=libsonypostprocbundle.so
LIBNAME=sonyeffect_sw
LIBNAMEHW=sonyeffect_hw
NAME=sonyeffect
UUID=50786e95-da76-4557-976b-7981bdf6feb9
UUIDHW=f9ed8ae0-1b9c-11e4-8900-0002a5d5c51b
UUIDPROXY=af8da7e0-2ca1-11e3-b71d-0002a5d5c51b
RMV="$LIB $LIBHW $LIBNAME $LIBNAMEHW $NAME $UUID
     $UUIDHW $UUIDPROXY libeffectproxy.so"

# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  proxy {\n    path $LIBPATH\/libeffectproxy.so\n  }" $MODAEC
  sed -i "/^libraries {/a\  $LIBNAMEHW {\n    path $LIBPATH\/$LIBHW\n  }" $MODAEC
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
fi

# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"proxy\" path=\"libeffectproxy.so\"\/>" $MODAEX
  sed -i "/<libraries>/a\        <library name=\"$LIBNAMEHW\" path=\"$LIBHW\"\/>" $MODAEX
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
  sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
  sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
fi

# patch audio policy
if [ "$MODAP" ]; then
  sed -i 's/COMPRESS_OFFLOAD/NONE/g' $MODAP
  sed -i 's/,compressed_offload//g' $MODAP
#u  sed -i 's/RAW/NONE/g' $MODAP
#u  sed -i 's/,raw//g' $MODAP
fi

# patch audio policy xml
if [ "$MODAPX" ]; then
  if ! grep -Eq 'format="AUDIO_FORMAT_ALAC"' $MODAPX; then
        sed -i '/AUDIO_FORMAT_MP3/i\
                    <profile name="" format="AUDIO_FORMAT_ALAC"\
                             samplingRates="8000,11025,12000,16000,22050,24000,32000,44100,48000,64000,88200,96000,128000,176400,192000"\
                             channelMasks="AUDIO_CHANNEL_OUT_MONO,AUDIO_CHANNEL_OUT_STEREO,AUDIO_CHANNEL_OUT_2POINT1,AUDIO_CHANNEL_OUT_QUAD,AUDIO_CHANNEL_OUT_PENTA,AUDIO_CHANNEL_OUT_5POINT1,AUDIO_CHANNEL_OUT_6POINT1,AUDIO_CHANNEL_OUT_7POINT1"/>' $MODAPX
  fi
fi

# patch media codecs
if [ -f $MODMC ]; then
  sed -i '/<MediaCodecs>/a\
    <Include href="media_codecs_somc.xml"/>' $MODMC
fi

# function
dolby_atmos() {
# store
LIB=libswdap.so
LIBNAME=dap
NAME=dap
UUID=9d4921da-8225-4f29-aefa-39537a04bcaa
RMV="$LIB $LIBNAME $NAME $UUID"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
#m  sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r  sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a  sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s  sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v  sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n  sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
fi
# patch effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
#m  sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r  sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a  sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s  sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v  sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n  sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
fi
# patch media codecs
if [ -f $MODMC ]; then
  sed -i '/<MediaCodecs>/a\
    <Include href="media_codecs_dolby_audio.xml"/>' $MODMC
fi
}

# dolby atmos
#ddolby_atmos








