#!/bin/bash -x

. /root/.bash_profile
curDir=`pwd`
date=`date +'%Y-%m-%d'`
dataDir="/data0/db_data/mysql"
targetDir="$curDir/${date}"
RTSYNC_HOME="/data0/rtsync-1.0.0"
cunsumeroffsetDir="${RTSYNC_HOME}/store"
logDir="$curDir/log/"
log="$curDir/log/${date}_backupLog"
redisCli="/home/cache/redis-3.2.1/src/redis-cli hget rtsync:dbs:offset "
redis_server="10.10.1.173"
ip=`ifconfig |grep -A 1 em1|grep 'inet addr' |awk '{print $2}'|awk -F: '{print $2}'`
cids=`mysql -ucaofei -pcaofei -D cinema_imp_record -h 10.10.1.19 -e "select cid from available_CID where db_host_ip='$ip' and cinema_flag=3" |grep -v cid`
echo "mysql -ucaofei -pcaofei -D cinema_imp_record -h 10.10.1.19 -e \"select cid from available_CID where db_host_ip='$ip' and cinema_flag=3\" |grep -v cid" >> $log
echo "Backup DB ip : $ip" >> $log
echo "Backup cids : $cids" >> $log
if [ x"$cids" = x ];then
	echo "Haven't found any cids, please check your manager db!!!" >> $log
	exit
fi
availableSize=`df -m ${curDir}/|grep /data0|awk '{print $4}'`
dbSize=`du -s --block-size=1024k ${dataDir}|awk '{print $1}'`
if [[ $availableSize -le $dbSize ]];then
        echo "### Available disk space is not enough!!!"
        exit
fi

which expect
if [ $? -ne 0 ];then
	echo "Please install expect!!!" >> $log
	exit
fi

if [ ! -d $targetDir ] ; then
        mkdir -p $targetDir
fi

if [ ! -d $logDir ] ; then
        mkdir -p $logDir
fi

#################################################################################
# Function:   remote_cmd 
# Description: check cid's offset
#################################################################################
function remote_cmd()
{
expect -f - <<EOF
spawn ssh cache@$redis_server "$redisCli $1"
expect {
            "Are you sure you want to continue connecting (yes/no)?"    { send "yes\r"; exp_continue }
            "*assword:"                                                 { send "nbcache\r";exp_continue }
                eof                                                     { send_user "eof" }
                            }
EOF
#return $?
}


################################
# $0 cid
# get cid redis offset, and backup it
################################
function backup_redisRecord()
{
	echo "$(date +'%Y-%m-%d %H:%M:%S'), check and record redis offset ..." >> $log
	for cid in $cids;do
		ret=`remote_cmd $cid|grep filename`
		if [[ $ret == "" ]];then
			echo "### Haven't found position for $cid" > $log
			#return 3
		fi
		echo "$cid $ret" >> $targetDir/cids_redis_record
		echo "$cid $ret" >> $log
	done
	echo "$(date +'%Y-%m-%d %H:%M:%S'), backup consumeroffset file ..." >> $log
	cp -ra $cunsumeroffsetDir $targetDir
	return $?
}

################################
# $0
# backup mysql database
################################
function backup_mysql()
{
	echo "$(date +'%Y-%m-%d %H:%M:%S'), Start to copy mysql databases ..." >> $log
	/etc/init.d/mysql stop &&
	cp -ra $dataDir ${targetDir}/ &&
	/etc/init.d/mysql start
	return $?
}

main()
{
        ### 1. stop rtsync
        cd $RTSYNC_HOME && sh bin/rtsyncshutdown
        if [[ $? -ne 0 ]];then
                echo "ERROR: Stop rtsync failed..." >>  $log
                exit
        fi
        ### 2. backup redis redord and consumeroffset file
        backup_redisRecord
        if [[ $? -eq 0 ]];then
                echo "Redis and consumer backup done..." >>  $log
        else
                echo "ERROR: Redis and consumer backup failed..." >>  $log ; exit
                exit
        fi
        ### 3. backup mysql 
        backup_mysql
        if [[ $? -eq 0 ]];then
                echo "Mysql backup done..." >>  $log
        else
                echo "ERROR: mysql backup failed..." >>  $log
                exit
        fi
        ### 4. start rtsync
        cd $RTSYNC_HOME && nohup sh bin/rtsyncSvc -l true
        [[ $? -eq 0 ]] || echo "ERROR: Start rtsync failed..." >>  $log
        echo "$(date +'%Y-%m-%d %H:%M:%S'), backup ended!" >>  $log
}


main
