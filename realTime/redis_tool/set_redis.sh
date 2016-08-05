#!/bin/bash

logDir="/home/cache/redis-3.2.1/tools/logs"
log=$logDir/setRedis.log
r_cli="/home/cache/redis-3.2.1/src/redis-cli"
db_lists="10.10.1.163,10.10.1.168,10.10.1.170,10.10.1.172,10.10.1.169"
db_user="pyuser"
db_pass="yhzdatacenter"
if [ ! -d $logDir ] ; then 
        mkdir -p $logDir
fi

###########################################
# $0 $cid
# initial cid in redis
###########################################
init_cid()
{
	echo "start init_cid ..." >> $log
	if [ $# -ne 1 ];then
		echo "### parameters incorrect !!!" >> $log
		exit
	fi
	
	echo $1||grep "^[1-9][0-9]\{7\}$"
	if [ $? -ne 0 ];then
		echo "### parameters is not required number !!!" >> $log
		exit
	fi
	
	$r_cli get ser_${1}|grep filename
	if [ $? -ne 0 ];then 
		$r_cli set ser_${1} '{"filename":"mysql_log_bin.000001","lastFilename":"mysql_log_bin.000001","lastPosition":"1","position":"1"}'
		echo "$r_cli set ser_${1} '{\"filename\":\"mysql_log_bin.000001\",\"lastFilename\":\"mysql_log_bin.000001\",\"lastPosition\":\"1\",\"position\":\"1\"}'" >> $log
	else
		echo "### ser_${1} already existed!!!" >> $log
	fi
}

###########################################
# $0 $serverIp $cid
# set the correspondence with cid and DB host ip
###########################################
set_cid_hostIP()
{
	echo "start set_cid_hostIP ..." $log
	if [ $# -ne 2 ];then
		echo "### parameters incorrect !!!" >> $log
		exit
	fi
	
	echo $1|grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"
	if [ $? -ne 0 ];then
		echo "### IP is not correct format !!!" >> $log
		exit
	fi
	
	echo $2|grep "^[1-9][0-9]\{7\}$"
	if [ $? -ne 0 ];then
		echo "### parameters is not required number !!!" >> $log
		exit
	fi
	
	$r_cli SMEMBERS rtSync:dbins |grep $1
	if [ $? -ne 0 ];then 
		echo "init db server ..." >> $log
		$r_cli sadd rtSync:dbins ${1}
		$r_cli hmset ${1} url "jdbc:mysql://${1}:3306/mysql" username ${db_user} password ${db_pass}
		echo "$r_cli sadd rtSync:dbins ${1}" >> $log
		echo "$r_cli hmset ${1} url "jdbc:mysql://${1}:3306/mysql" username ${db_user} password ${db_pass}" >> $log
	fi

	$r_cli SISMEMBER rtSync:dbname:${1} ${2}|grep 1
	if [ $? -ne 0 ];then 
		$r_cli sadd rtSync:dbname:${1} ${2}
		echo "$r_cli sadd rtSync:dbname:${1} ${2}" >> $log
	else
		echo "### rtSync:dbname:${1} ${2}  aleady existed!!!" >> $log
	fi
}

main()
{
	time=`date +%Y%m%d-%H%M%S`
	echo "############# $time start to set redis... ##############" >> $log
	$*
	time=`date +%Y%m%d-%H%M%S`
	echo "############# $time set redis done!!! ##############" >> $log
}

echo $*|grep -E 'init_cid|set_cid_hostIP'
if [ $? -ne 0 ];then
	echo "### Invalid usage , plese use 'init_cid | set_cid_hostIP' to set redis"
	echo "Such as :"
	echo "$0 init_cid 12345678"
	echo "$0 set_cid_hostIP 192.168.1.1 12345678"
elif [ $# -lt 2 ];then
	echo "### Wrong parameter!"
else 
	main $*
fi
