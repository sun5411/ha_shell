#!/bin/bash

mqHome="/home/work/alibaba-rocketmq"

cids=`cat lists`
num=`cat lists |wc -l`
count=0
time=`date +%Y%m%d-%H%M%S`
half=$(($num/2))

add_topic()
{
cd $mqHome
for cid in $cids;do
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
		sh bin/mqadmin topicList -n 10.10.1.174:9876 -c|grep $cid
		if [[ $? -ne 0 ]];then
			echo "sh bin/mqadmin updateTopic -b 10.10.1.174:10911 -t $cid -r 1 -w 1"
			echo "sh bin/mqadmin updateSubGroup -b 10.10.1.174:10911 -g $cid -m true -d false"
			sh bin/mqadmin updateTopic -b 10.10.1.174:10911 -t $cid -r 1 -w 1
			sh bin/mqadmin updateSubGroup -b 10.10.1.174:10911 -g $cid -m true -d false
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


add_topic |tee -a addTopic_${time}.log
