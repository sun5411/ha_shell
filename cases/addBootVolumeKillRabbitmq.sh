#!/bin/bash
pwd=${0%%addBootVolumeKillRabbitmq*}
libpath="${pwd}../lib"
pypath="${pwd}../py"
. $libpath/common_func.sh
#cd ${pwd}.. && . ./config &&cd -
cd $libpath && . ./function.sh && cd $libpath/../cases

run create_storage_env

for ((i=0;i<10;i++));do
    run create_boot_storage_volume ${stVolume}_boot_${i}
done
$pypath/getpid_kill_service.py rabbitmq_1 &

for ((i=0;i<10;i++));do
    run check_storage_volume_online ${stVolume}_boot_${i}
done


#### Clean up test ENV ###
#delete bootVolume 
for ((i=0;i<10;i++));do
    run delete_storage_volume ${stVolume}_boot_${i}
done

#check if bootVolumes are deleted
for ((i=0;i<10;i++));do
    run check_storage_volume_delete_status ${stVolume}_boot_${i}
done

run clean_storage_env

