## Dolby

# debug
magiskpolicy --live "dontaudit system_server system_file file write"
magiskpolicy --live "allow     system_server system_file file write"

# context
magiskpolicy --live "type system_lib_file"
magiskpolicy --live "type vendor_file"
magiskpolicy --live "type vendor_configs_file"
magiskpolicy --live "type hal_dms_default_exec"
magiskpolicy --live "type vendor_data_file"
magiskpolicy --live "type vendor_media_data_file"
magiskpolicy --live "dontaudit { system_lib_file vendor_file vendor_configs_file hal_dms_default_exec vendor_data_file vendor_media_data_file } labeledfs filesystem associate"
magiskpolicy --live "allow     { system_lib_file vendor_file vendor_configs_file hal_dms_default_exec vendor_data_file vendor_media_data_file } labeledfs filesystem associate"
magiskpolicy --live "dontaudit init { system_lib_file vendor_file vendor_configs_file vendor_data_file vendor_media_data_file } dir relabelfrom"
magiskpolicy --live "allow     init { system_lib_file vendor_file vendor_configs_file vendor_data_file vendor_media_data_file } dir relabelfrom"
magiskpolicy --live "dontaudit init { system_lib_file vendor_file vendor_configs_file hal_dms_default_exec vendor_data_file vendor_media_data_file } file relabelfrom"
magiskpolicy --live "allow     init { system_lib_file vendor_file vendor_configs_file hal_dms_default_exec vendor_data_file vendor_media_data_file } file relabelfrom"
magiskpolicy --live "type same_process_hal_file"

# hwservice_manager
magiskpolicy --live "allow { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app hal_audio_default mtk_hal_audio audioserver } { default_android_hwservice hal_dms_hwservice dms_hwservice } hwservice_manager find"

# service_manager
magiskpolicy --live "allow daxservice_app permission_checker_service service_manager find"

# binder
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } hal_dms_default binder call"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } hal_dms_default binder call"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { hal_dms_default_exec vendor_displayfeature_prop } file getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { hal_dms_default_exec vendor_displayfeature_prop } file getattr"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } bluetooth_prop file map"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } bluetooth_prop file map"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } vendor_default_prop file { read open getattr }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } vendor_default_prop file { read open getattr }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } debug_mtk_gpud_prop file { read open getattr map }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } debug_mtk_gpud_prop file { read open getattr map }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } system_file file { read open getattr execute }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } system_file file { read open getattr execute }"
magiskpolicy --live "dontaudit zygote { device unlabeled } file write"
magiskpolicy --live "allow     zygote { device unlabeled } file write"
magiskpolicy --live "dontaudit init system_file file mounton
magiskpolicy --live "allow     init system_file file mounton

# chr_file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } device chr_file { read write open getattr ioctl }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } device chr_file { read write open getattr ioctl }"

# dir
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } migt_file dir search"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } migt_file dir search"

# additional
magiskpolicy --live "allow { hal_audio_default mtk_hal_audio audioserver } system_suspend_hwservice hwservice_manager find"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { default_prop boottime_prop } file { read open getattr map }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { default_prop boottime_prop } file { read open getattr map }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { mnt_vendor_file system_prop } file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { mnt_vendor_file system_prop } file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } audio_prop file { read open getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } audio_prop file { read open getattr }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } sysfs_wake_lock file { write open }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } sysfs_wake_lock file { write open }"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } vendor_default_prop file open"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } vendor_default_prop file open"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { sysfs_net sysfs } dir read"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { sysfs_net sysfs } dir read"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } logd_socket sock_file write"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } logd_socket sock_file write"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } logd unix_stream_socket connectto"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } logd unix_stream_socket connectto"
magiskpolicy --live "dontaudit { hal_audio_default mtk_hal_audio audioserver } { diag_device vendor_diag_device } chr_file { read write open ioctl getattr }"
magiskpolicy --live "allow     { hal_audio_default mtk_hal_audio audioserver } { diag_device vendor_diag_device } chr_file { read write open ioctl getattr }"
magiskpolicy --live "dontaudit hal_audio_default hal_audio_default capability2 block_suspend"
magiskpolicy --live "allow     hal_audio_default hal_audio_default capability2 block_suspend"
magiskpolicy --live "dontaudit mtk_hal_audio mtk_hal_audio capability2 block_suspend"
magiskpolicy --live "allow     mtk_hal_audio mtk_hal_audio capability2 block_suspend"
magiskpolicy --live "dontaudit audioserver audioserver capability2 block_suspend"
magiskpolicy --live "allow     audioserver audioserver capability2 block_suspend"


## Sound Enhancement

# context
magiskpolicy --live "type audio_hweffect_device"
magiskpolicy --live "dontaudit audio_hweffect_device tmpfs filesystem associate"
magiskpolicy --live "allow     audio_hweffect_device tmpfs filesystem associate"
magiskpolicy --live "dontaudit init audio_hweffect_device file relabelfrom"
magiskpolicy --live "allow     init audio_hweffect_device file relabelfrom"
magiskpolicy --live "dontaudit init audio_hweffect_device dir relabelfrom"
magiskpolicy --live "allow     init audio_hweffect_device dir relabelfrom"


