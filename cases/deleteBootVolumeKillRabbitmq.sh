#!/bin/bash
sys_path=$(pwd)
case_path=${0%%deleteBootVolumeKillRabbitmq*}
libpath="${sys_path}/${case_path}../lib"
pypath="${sys_path}/${case_path}../py"
. $libpath/common_func.sh
cd $libpath && . ./function.sh

run create_storage_env
for ((i=0;i<10;i++));do
    create_boot_storage_volume ${stVolume}_boot_${i}
done

for ((i=0;i<10;i++));do
    check_storage_volume_online ${stVolume}_boot_${i}
done


#delete bootVolume 
echo_yellow "$(date +%Y%m%d-%H%M%S) , Start to delete Boot storage_volume..."
for ((i=0;i<10;i++));do
    delete_storage_volume ${stVolume}_boot_${i}
done
echo_yellow "$(date +%Y%m%d-%H%M%S) , delete Boot storage_volume requests done !"

run $pypath/getpid_kill_service.py rabbitmq_1 &

#check if bootVolumes are deleted
for ((i=0;i<10;i++));do
    check_storage_volume_delete_status ${stVolume}_boot_${i}
done

run clean_storage_env

