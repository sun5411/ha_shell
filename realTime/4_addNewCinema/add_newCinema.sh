#!/bin/bash

cids=`cat lists`
time=`date +%Y%m%d-%H%M%S`
RTSYNC_HOME=`echo $RTSYNC_HOME`

#nohup sh bin/rtsyncSvc -c "10000002:mysql-bin.000248:-1;10000003:mysql-bin.000248:-1" -f true
sample=":mysql-bin.000000:-1"
str=""

active_newCids()
{
	for cid in $cids;do
		if [ x$str = x ];then
			str="${cid}${sample}"
		else
			str="${str};${cid}${sample}"
		fi
	done
	
	cmd="nohup sh bin/rtsyncSvc -c \"$str\" -f true"
	echo $cmd
	cd $RTSYNC_HOME && sh bin/rtsyncshutdown && $cmd
	ps -ef |grep ConsumerStartService
	if [[ $? -eq 0 ]] ;then
		echo "start ConsumerStartService successfully!!!"
	else
		echo "*** start ConsumerStartService failed!!!"
	fi
}


active_newCids |tee -a active_newCids_${time}.log
