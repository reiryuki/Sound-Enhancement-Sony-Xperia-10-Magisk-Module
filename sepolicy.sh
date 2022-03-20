# type
magiskpolicy --live "type system_lib_file"
magiskpolicy --live "type vendor_file"
magiskpolicy --live "type vendor_configs_file"
magiskpolicy --live "type vendor_data_file"
magiskpolicy --live "type vendor_media_data_file"
magiskpolicy --live "type hal_dms_default_exec"

# hwservice_manager
magiskpolicy --live "allow { system_app priv_app platform_app untrusted_app_29 untrusted_app hal_audio_default mtk_hal_audio audioserver } { default_android_hwservice hal_dms_hwservice } hwservice_manager find"

# binder
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } hal_dms_default binder call"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } hal_dms_default binder call"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } { hal_dms_default_exec vendor_displayfeature_prop } file getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } { hal_dms_default_exec vendor_displayfeature_prop } file getattr"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } bluetooth_prop file map"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } bluetooth_prop file map"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } vendor_default_prop file { read open getattr }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } vendor_default_prop file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } system_file file { read open getattr execute }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } system_file file { read open getattr execute }"
magiskpolicy --live "dontaudit zygote device file write"
magiskpolicy --live "allow     zygote device file write"

# chr_file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } device chr_file { read write open getattr ioctl }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } device chr_file { read write open getattr ioctl }"

# dir
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } migt_file dir search"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } migt_file dir search"

# additional
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } default_prop file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } default_prop file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } mnt_vendor_file file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } mnt_vendor_file file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } system_prop file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } system_prop file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } boottime_prop file { read open getattr map }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } boottime_prop file { read open getattr map }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } sysfs_wake_lock file { write open }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } sysfs_wake_lock file { write open }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app } { hal_audio_default_exec mtk_hal_audio_exec audioserver_exec } file getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app } { hal_audio_default_exec mtk_hal_audio_exec audioserver_exec } file getattr"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { diag_device vendor_diag_device } chr_file { read write open ioctl getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { diag_device vendor_diag_device } chr_file { read write open ioctl getattr }"
magiskpolicy --live "dontaudit hal_audio_default hal_audio_default capability2 block_suspend"
magiskpolicy --live "allow     hal_audio_default hal_audio_default capability2 block_suspend"
magiskpolicy --live "dontaudit mtk_hal_audio mtk_hal_audio capability2 block_suspend"
magiskpolicy --live "allow     mtk_hal_audio mtk_hal_audio capability2 block_suspend"
magiskpolicy --live "dontaudit audioserver audioserver capability2 block_suspend"
magiskpolicy --live "allow     audioserver audioserver capability2 block_suspend"


