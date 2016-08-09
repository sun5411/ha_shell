#!/bin/bash

mqHome="/home/work/alibaba-rocketmq"
time=`date +%Y%m%d-%H%M%S`
curDir=`pwd`
logDir="${curDir}/logs"
log="$logDir/addTopic_${time}.log"
cids=`cat lists`
num=`cat lists |wc -l`
count=0
half=$(($num/2))
if [ ! -d $logDir ] ; then 
        mkdir -p $logDir
fi

add_topic()
{
cd $mqHome
for cid in $cids;do
	echo $cid
	if [ $count -lt $half ];then
		count=$(($count + 1))
		sh bin/mqadmin topicList -n 10.10.1.173:9876 -c|grep $cid
		if [[ $? -ne 0 ]];then
			echo "sh bin/mqadmin updateTopic -b 10.10.1.173:10911 -t $cid -r 1 -w 1"
			echo "sh bin/mqadmin updateSubGroup -b 10.10.1.173:10911 -g $cid -m true -d false"
			sh bin/mqadmin updateTopic -b 10.10.1.173:10911 -t $cid -r 1 -w 1
			sh bin/mqadmin updateSubGroup -b 10.10.1.173:10911 -g $cid -m true -d false
			echo "### number : $count"
		else
			echo "### TOPIC $cid already existed!!!"
		fi
		sh bin/mqadmin topicList -n 10.10.1.173:9876 -c|grep $cid
		if [[ $? -eq 0 ]];then
			echo "### TOPIC $cid add successed!!!"
		else
			echo "*** TOPIC $cid add failed!!!"
		fi
	else
		count=$(($count + 1))
		sh bin/mqadmin topicList -n 10.10.1.174:9876 -c|grep $cid
		if [[ $? -ne 0 ]];then
			echo "sh bin/mqadmin updateTopic -b 10.10.1.174:10911 -t $cid -r 1 -w 1"
			echo "sh bin/mqadmin updateSubGroup -b 10.10.1.174:10911 -g $cid -m true -d false"
			sh bin/mqadmin updateTopic -b 10.10.1.174:10911 -t $cid -r 1 -w 1
			sh bin/mqadmin updateSubGroup -b 10.10.1.174:10911 -g $cid -m true -d false
			echo "### number : $count"
		else
			echo "### TOPIC $cid already existed!!!"
		fi
		sh bin/mqadmin topicList -n 10.10.1.174:9876 -c|grep $cid
		if [[ $? -eq 0 ]];then
			echo "### TOPIC $cid add successed!!!"
		else
			echo "*** TOPIC $cid add failed!!!"
		fi
	fi
done
}


add_topic |tee -a $log
