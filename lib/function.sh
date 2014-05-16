#!/bin/bash
. ./config && . ./common_func.sh

auto_login_ssh () {
   expect -c "set timeout -1;
   spawn -noecho ssh -o StrictHostKeyChecking=no nimbulaadmin@$1 ${@:2};
   expect *assword:*;
   send -- OracleCloud9\r;
   interact;";
}

function create_storage_property()
{
    cmd="$apiClient -a $api -u $user -p $passFile add property storage $stProperty automation_added_prop -f json"
    echo "$cmd"
    eval $cmd
    r_val=$?
    check_cmd="$apiClient -a $api -u $user -p $passFile list property storage $stProperty"
    echo $check_cmd
    $check_cmd
    #[ $? -eq 0 ] || echo_red "Check storage property failed !"; exit
    [ $? -eq 0 ] || echo_red "Create storage property failed !"
}

function create_storage_server()
{
    cmd="$apiClient -a $api -u $user -p $passFile add storageserver $stServer $storage_address $storage_address nfs -f json"
    echo "$cmd"
    $cmd
    #[ $? -eq 0 ] || echo_red "Create storageserver failed !"; exit

    check_cmd="$apiClient -a $api -u $user -p $passFile list storageserver $stServer -Fname,status"
    value=1
    while [[ $value -ne 0 ]];do
            echo "$check_cmd"
            $check_cmd
            value=$?
            sleep 3
    done
    return $value
}

function delete_storage_server()
{
    cmd="$apiClient -a $api -u $user -p $passFile delete storageserver $stServer -f json"
    delete_property_cmd="$apiClient -a $api -u $user -p $passFile delete property storage $stProperty"
    echo "$delete_property_cmd"
    $delete_property_cmd
    value=0
    while [[ $value -eq 0 ]];do
            echo "$check_cmd | grep $stProperty"
            eval $check_cmd | grep $stProperty
            value=$?
            sleep 3
    done

    echo "$cmd"
    $cmd
    check_cmd="$apiClient -a $api -u $user -p $passFile list storageserver $stServer -Fname,status"
    value=0
    while [[ $value -eq 0 ]];do
            echo "$check_cmd | grep $stServer "
            eval $check_cmd | grep $stServer
            value=$?
            sleep 3
    done
}

function create_storage_pool()
{
    cmd="$apiClient -a $api -u $user -p $passFile add storagepool $stPool $stServer $stProperty \"nfs\" '{ \"nfs_share\":\"$nfs_share\" }' -fjson"
    echo "$cmd"
    eval $cmd
    #[ $? -eq 0 ] || echo_red "Create storagepool failed !"; exit

    check_cmd="$apiClient -a $api -u $user -p $passFile list storagepool $stPool -Fname,status"
    value=1
    while [[ $value -ne 0 ]];do
            echo "$check_cmd |grep Online"
            $check_cmd |grep Online
            value=$?
            sleep 3
    done
    return $value
}

# $0 volume_name
function create_storage_volume()
{
    [[ "$1" = "" ]] && echo_red "Please using : create_storage_volume volumes_name" && exit
    volume_name=$1
    cmd="$apiClient -a $api -u $user -p $passFile add storagevolume $volume_name 1G $stProperty --tags volumeTag1 -f json"
    echo "$cmd"
    $cmd &
}

# Use : $0 volume_name
function delete_storage_volume()
{
    [[ "$1" = "" ]] && echo_red "Please using : delete_storage_volume volumes_name" && exit
    volume_name=$1
    cmd="$apiClient -a $api -u $user -p $passFile delete storagevolume $volume_name --force"
    echo "$cmd"
    $cmd &
}

# $0 volume_number
function delete_created_storage_volumes()
{
    [[ "$1" = "" ]] && echo_red "Please using : delete_storage_volumes volumes_number" && exit
    volNum = $1
    for(( i=0;i<$volNum;i++ ));do
	    volume_name=${stVolume}_${i}
    	delete_storage_volume $volume_name
    done
}

# Use : $0 volume_name
function check_storage_volume_delete_status()
{
    volume_name=$1
    check_cmd="$apiClient -a $api -u $user -p $passFile list storagevolume $volume_name -Fname,status"
    value=0
    while [[ $value -eq 0 ]];do
            echo "$check_cmd |grep $volume_name"
            eval $check_cmd |grep $volume_name
            value=$?
            sleep 3
    done
    echo "Volume $volume_name deleted successed!"
    return 0
}

# $0 volume_number
function create_storage_volumes()
{
    [[ "$1" = "" ]] && echo_red "Please using : create_storage_volumes volumes_number" && exit
    for(( i=0;i<$1;i++ ));do
	volume_name=${stVolume}_${i}
	create_storage_volume $volume_name
    done
}

#Use : $0 volume_name
function create_boot_storage_volume()
{
    [[ "$1" = "" ]] && echo_red "Please using : create_boot_storage_volume volumes_name" && exit
    volume_name=$1
    cmd="$apiClient -a $api -u $user -p $passFile add storagevolume $volume_name 8G $stProperty --tags volumeTag1 -f json"
    echo "$cmd"
    $cmd &
}

# Use : $0 volumename
function check_storage_volume_online()
{
    check_cmd="$apiClient -a $api -u $user -p $passFile list storagevolume ${1} -Fname,status"
    value=1
    while [[ $value -ne 0 ]];do
            echo "$check_cmd |grep Online"
            eval $check_cmd |grep Online 
            value=$?
            sleep 3
    done
    return $value
}


#use $0 
function delete_storage_pool()
{
    cmd="$apiClient -a $api -u $user -p $passFile delete storagepool $stPool --force"
    echo "Will delete storagepool $stPool"
    echo "$cmd"
    eval $cmd

    check_cmd="$apiClient -a $api -u $user -p $passFile list storagepool $stPool -Fname,status"
    value=0
    while [[ $value -eq 0 ]];do
            echo "$check_cmd |grep $stPool"
            eval $check_cmd |grep $stPool
            value=$?
            sleep 3
    done
}

create_storage_env()
{
    create_storage_property &&
    create_storage_server &&
    create_storage_pool
}

#### Clean up test ENV ###
clean_storage_env()
{
    #Delete storage pool
    delete_storage_pool &&
    #Delete storage server && property
    delete_storage_server
}

delete_all_volumes()
{
    volumes=`$apiClient -a $api -u $user -p $passFile list storagevolume / -Fname,status |grep Online |awk '{print $1}'`
    if [ "$volumes" != "" ];then
        echo -e "Will delete Volumes :  \n $volumes"
        for volume in $volumes;do
            delete_storage_volume $volume
            check_storage_volume_delete_status $volume
        done
    fi
}
