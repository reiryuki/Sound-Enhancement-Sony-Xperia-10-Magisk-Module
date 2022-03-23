MODPATH=${0%/*}

# destinations
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
  sed -i 's/    path \/vendor\/lib\/soundfx\/removed//g' $MODAEC
  sed -i 's/    path \/system\/lib\/soundfx\/removed//g' $MODAEC
  sed -i 's/    path \/vendor\/lib\/removed//g' $MODAEC
  sed -i 's/    path \/system\/lib\/removed//g' $MODAEC
  sed -i "/^        removed {/ {;N s/        removed {\n        }//}" $MODAEC
}
remove_xml() {
  for RMVS in $RMV; do
    sed -i "s/\"$RMVS\"/\"removed\"/g" $MODAEX
  done
  sed -i 's/<library name="removed" path="removed"\/>//g' $MODAEX
  sed -i 's/<effect name="removed" library="removed" uuid="removed"\/>//g' $MODAEX
  sed -i 's/<apply effect="removed"\/>//g' $MODAEX
}

# store
LIB=libznrwrapper.so
LIBNAME=znrwrapper
NAME=ZNR
UUID=b8a031e0-6bbf-11e5-b9ef-0002a5d5c51b
RMV="$LIB $LIBNAME $NAME $UUID"

# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
  if ! grep -Eq '^pre_processing {' $MODAEC; then
    sed -i -e '$a\
pre_processing {\
  mic {\
  }\
  camcorder {\
  }\
}\' $MODAEC
  else
    if ! grep -Eq '^  camcorder {' $MODAEC; then
      sed -i "/^pre_processing {/a\  camcorder {\n  }" $MODAEC
    fi
    if ! grep -Eq '^  mic {' $MODAEC; then
      sed -i "/^pre_processing {/a\  mic {\n  }" $MODAEC
    fi
  fi
#c  sed -i "/^  camcorder {/a\    $NAME {\n    }" $MODAEC
#c  sed -i "/^  mic {/a\    $NAME {\n    }" $MODAEC
fi

# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  if ! grep -Eq '<preprocess>' $MODAEX; then
    sed -i '/<\/effects>/a\
    <preprocess>\
        <stream type="mic">\
        <\/stream>\
        <stream type="camcorder">\
        <\/stream>\
    <\/preprocess>' $MODAEX
  else
    if ! grep -Eq '<stream type="camcorder">' $MODAEX; then
      sed -i "/<preprocess>/a\        <stream type=\"camcorder\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="mic">' $MODAEX; then
      sed -i "/<preprocess>/a\        <stream type=\"mic\">\n        <\/stream>" $MODAEX
    fi
  fi
#c  sed -i "/<stream type=\"camcorder\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c  sed -i "/<stream type=\"mic\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
fi

# store
LIBSW=libsonysweffect.so
LIBHW=libsonypostprocbundle.so
NAMESW=sonyeffect_sw
NAMEHW=sonyeffect_hw
NAME=sonyeffect
UUIDSW=50786e95-da76-4557-976b-7981bdf6feb9
UUIDHW=f9ed8ae0-1b9c-11e4-8900-0002a5d5c51b
UUID=af8da7e0-2ca1-11e3-b71d-0002a5d5c51b
RMV="$LIBSW $LIBHW $NAMESW $NAMEHW $NAME $UUIDSW $UUIDHW $UUID"
#2RMV2="libdiraceffect.so dirac_gef 3799D6D1-22C5-43C3-B3EC-D664CF8D2F0D
#2      libdirac.so dirac_controller dirac_music b437f4de-da28-449b-9673-667f8b964304 b437f4de-da28-449b-9673-667f8b9643fe
#2      dirac 1e069d9e0-8329-11df-9168-0002a5d5c51b"
#3RMV3="libmisoundfx.so misoundfx 5b8e36a5-144a-4c38-b1d7-0002a5d5c51b"

# patch audio effects conf
if [ "$MODAEC" ]; then
  #2for RMVS2 in $RMV2; do
  #2  sed -i "s/$RMVS2/removed/g" $MODAEC
  #2done
  #3for RMVS3 in $RMV3; do
  #3  sed -i "s/$RMVS3/removed/g" $MODAEC
  #3done
  remove_conf
  sed -i "/^libraries {/a\  proxy {\n    path $LIBPATH\/libeffectproxy.so\n  }" $MODAEC
  sed -i "/^libraries {/a\  $NAMEHW {\n    path $LIBPATH\/$LIBHW\n  }" $MODAEC
  sed -i "/^libraries {/a\  $NAMESW {\n    path $LIBPATH\/$LIBSW\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUID\n  }" $MODAEC
  sed -i "/^    uuid $UUID/a\    libhw {\n      library $NAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
  sed -i "/^    uuid $UUID/a\    libsw {\n      library $NAMESW\n      uuid $UUIDSW\n    }" $MODAEC
  sed -i "/^        ring_helper {/ {;N s/        ring_helper {\n        }//}" $MODAEC
  sed -i "/^        alarm_helper {/ {;N s/        alarm_helper {\n        }//}" $MODAEC
  sed -i "/^        music_helper {/ {;N s/        music_helper {\n        }//}" $MODAEC
  sed -i "/^        voice_helper {/ {;N s/        voice_helper {\n        }//}" $MODAEC
  sed -i "/^        notification_helper {/ {;N s/        notification_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_ring_helper {/ {;N s/        ma_ring_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_alarm_helper {/ {;N s/        ma_alarm_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_music_helper {/ {;N s/        ma_music_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_voice_helper {/ {;N s/        ma_voice_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_system_helper {/ {;N s/        ma_system_helper {\n        }//}" $MODAEC
  sed -i "/^        ma_notification_helper {/ {;N s/        ma_notification_helper {\n        }//}" $MODAEC
  sed -i "/^        sa3d {/ {;N s/        sa3d {\n        }//}" $MODAEC
  sed -i "/^        fens {/ {;N s/        fens {\n        }//}" $MODAEC
  sed -i "/^        lmfv {/ {;N s/        lmfv {\n        }//}" $MODAEC
  sed -i "/^        dirac {/ {;N s/        dirac {\n        }//}" $MODAEC
fi

# patch audio effects xml
if [ "$MODAEX" ]; then
  #2for RMVS2 in $RMV2; do
  #2  sed -i "s/\"$RMVS2\"/\"removed\"/g" $MODAEX
  #2done
  #3for RMVS3 in $RMV3; do
  #3  sed -i "s/\"$RMVS3\"/\"removed\"/g" $MODAEX
  #3done
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"proxy\" path=\"libeffectproxy.so\"\/>" $MODAEX
  sed -i "/<libraries>/a\        <library name=\"$NAMEHW\" path=\"$LIBHW\"\/>" $MODAEX
  sed -i "/<libraries>/a\        <library name=\"$NAMESW\" path=\"$LIBSW\"\/>" $MODAEX
  sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
  sed -i "/<effects>/a\            <libhw library=\"$NAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
  sed -i "/<effects>/a\            <libsw library=\"$NAMESW\" uuid=\"$UUIDSW\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUID\">" $MODAEX
  sed -i 's/<apply effect="ring_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="alarm_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="music_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="voice_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="notification_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_ring_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_alarm_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_music_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_voice_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_system_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="ma_notification_helper"\/>//g' $MODAEX
  sed -i 's/<apply effect="sa3d"\/>//g' $MODAEX
  sed -i 's/<apply effect="fens"\/>//g' $MODAEX
  sed -i 's/<apply effect="lmfv"\/>//g' $MODAEX
  sed -i 's/<apply effect="dirac"\/>//g' $MODAEX
fi

# patch audio policy
if [ "$MODAP" ]; then
  sed -i 's/COMPRESS_OFFLOAD/NONE/g' $MODAP
  sed -i 's/,compressed_offload//g' $MODAP
fi

# patch audio policy
#uif [ "$MODAP" ]; then
#u  sed -i 's/RAW/NONE/g' $MODAP
#u  sed -i 's/,raw//g' $MODAP
#ufi

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

# store
#dLIB=libswdap.so
#dNAME=dap
#dUUID=9d4921da-8225-4f29-aefa-39537a04bcaa
#dRMV="$LIB $NAME $UUID"

# patch audio effects conf
#dif [ "$MODAEC" ]; then
#d  remove_conf
#d  sed -i "/^libraries {/a\  $NAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
#d  sed -i "/^effects {/a\  $NAME {\n    library $NAME\n    uuid $UUID\n  }" $MODAEC
#d  if ! grep -Eq '^output_session_processing {' $MODAEC; then
#d    sed -i -e '$a\
#doutput_session_processing {\
#d    music {\
#d    }\
#d    ring {\
#d    }\
#d    alarm {\
#d    }\
#d    voice_call {\
#d    }\
#d    notification {\
#d    }\
#d}\' $MODAEC
#d  else
#d    if ! grep -Eq '^    notification {' $MODAEC; then
#d      sed -i "/^output_session_processing {/a\    notification {\n    }" $MODAEC
#d    fi
#d    if ! grep -Eq '^    voice_call {' $MODAEC; then
#d      sed -i "/^output_session_processing {/a\    voice_call {\n    }" $MODAEC
#d    fi
#d    if ! grep -Eq '^    alarm {' $MODAEC; then
#d      sed -i "/^output_session_processing {/a\    alarm {\n    }" $MODAEC
#d    fi
#d    if ! grep -Eq '^    ring {' $MODAEC; then
#d      sed -i "/^output_session_processing {/a\    ring {\n    }" $MODAEC
#d    fi
#d    if ! grep -Eq '^    music {' $MODAEC; then
#d      sed -i "/^output_session_processing {/a\    music {\n    }" $MODAEC
#d    fi
#d  fi
#d  #msed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#d  #rsed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#d  #ased -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#d  #vsed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#d  #nsed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#dfi

# patch effects xml
#dif [ "$MODAEX" ]; then
#d  remove_xml
#d  sed -i "/<libraries>/a\        <library name=\"$NAME\" path=\"$LIB\"\/>" $MODAEX
#d  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$NAME\" uuid=\"$UUID\"\/>" $MODAEX
#d  if ! grep -Eq '<postprocess>' $MODAEX || grep -Eq '<!-- Audio post processor' $MODAEX; then
#d    sed -i '/<\/effects>/a\
#d    <postprocess>\
#d        <stream type="music">\
#d        <\/stream>\
#d        <stream type="ring">\
#d        <\/stream>\
#d        <stream type="alarm">\
#d        <\/stream>\
#d        <stream type="voice_call">\
#d        <\/stream>\
#d        <stream type="notification">\
#d        <\/stream>\
#d    <\/postprocess>' $MODAEX
#d  else
#d    if ! grep -Eq '<stream type="notification">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
#d      sed -i "/<postprocess>/a\        <stream type=\"notification\">\n        <\/stream>" $MODAEX
#d    fi
#d    if ! grep -Eq '<stream type="voice_call">' $MODAEX; then
#d      sed -i "/<postprocess>/a\        <stream type=\"voice_call\">\n        <\/stream>" $MODAEX
#d    fi
#d    if ! grep -Eq '<stream type="alarm">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
#d      sed -i "/<postprocess>/a\        <stream type=\"alarm\">\n        <\/stream>" $MODAEX
#d    fi
#d    if ! grep -Eq '<stream type="ring">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
#d      sed -i "/<postprocess>/a\        <stream type=\"ring\">\n        <\/stream>" $MODAEX
#d    fi
#d    if ! grep -Eq '<stream type="music">' $MODAEX || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX; then
#d      sed -i "/<postprocess>/a\        <stream type=\"music\">\n        <\/stream>" $MODAEX
#d    fi
#d  fi
#d  #msed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#d  #rsed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#d  #ased -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#d  #vsed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#d  #nsed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#dfi

# patch media codecs
#dif [ -f $MODMC ]; then
#d  sed -i '/<MediaCodecs>/a\
#d    <Include href="media_codecs_dolby_audio.xml"/>' $MODMC
#dfi








