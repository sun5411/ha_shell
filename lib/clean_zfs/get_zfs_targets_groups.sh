#!/bin/bash

zfs_server="slce39sn01.us.oracle.com"
usr="root"
passwd="welcome1"
cmd1="configuration san iscsi targets show"
cmd2="configuration san iscsi targets groups show"
log_dir="tmp"
rm -rf $log_dir
mkdir $log_dir

function exec_on_zfs()
{
    #expect is a software suite for automating interactive tools
expect -f - <<EOF
set timeout 6000
spawn ssh $usr@$zfs_server
expect {
    "Are you sure you want to continue connecting (yes/no)?" { send "yes\r" ; exp_continue }
    "assword:" { send "$passwd\r"; exp_continue }
    "slce39sn01:>"         { send "$1\n exit\n" }
}
expect eof
EOF
}

### get the targets and groups
key="storagePoolAutomation"
exec_on_zfs "$cmd1" |tee -a $log_dir/target_results
exec_on_zfs "$cmd2" |tee -a $log_dir/group_results
cat $log_dir/target_results|grep -A 3 $key |grep iqn > $log_dir/targets
cat $log_dir/group_results |grep -A 3 $key |grep iqn > $log_dir/groups

####clean targets
#while read string;do
#    echo "###### Will destroy targets: $string "
#    exec_on_zfs "confirm configuration san iscsi targets destroy $string"
#done < $log_dir/targets
#
####clean groups
#while read string;do
#    echo "###### Will destroy groups: $string "
#    exec_on_zfs "confirm configuration san iscsi targets groups destroy $string"
#done < $log_dir/groups
