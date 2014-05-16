#!/bin/bash
sys_path=$(pwd)
case_path=${0%%addBootVolumeKillRabbitmq*}
libpath="${sys_path}/${case_path}../lib"
pypath="${sys_path}/${case_path}../py"
. $libpath/common_func.sh
cd $libpath && . ./function.sh

run create_storage_env

echo_yellow "$(date +%Y%m%d-%H%M%S) , Start to add Boot storage_volume..."
for ((i=0;i<10;i++));do
    create_boot_storage_volume ${stVolume}_boot_${i}
done
echo_yellow "$(date +%Y%m%d-%H%M%S) , Add Boot storage_volume requests done !"

run $pypath/getpid_kill_service.py rabbitmq_1 &

for ((i=0;i<10;i++));do
    echo_yellow "$(date +%Y%m%d-%H%M%S) , checking volume ${stVolume}_boot_${i}"
    check_storage_volume_online ${stVolume}_boot_${i}
done


#### Clean up test ENV ###
#delete bootVolume 
for ((i=0;i<10;i++));do
    delete_storage_volume ${stVolume}_boot_${i}
done

#check if bootVolumes are deleted
for ((i=0;i<10;i++));do
    check_storage_volume_delete_status ${stVolume}_boot_${i}
done

run clean_storage_env
