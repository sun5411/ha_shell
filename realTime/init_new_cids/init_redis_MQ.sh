#!/bin/bash

#/home/cache/redis-3.2.1/tools/set_redis.sh init_cid 12345678
#/home/cache/redis-3.2.1/tools/set_redis.sh set_cid_hostIP 192.168.1.1 12345678
redis_server="10.10.1.173"
set_redis="/home/cache/redis-3.2.1/tools/set_redis.sh"

mq_server="10.10.1.173"
mq_home="/home/work/alibaba-rocketmq/"

###########################
## $0 $cmd
## login redis server
###########################
#set_redis()
#{
#expect -f - <<EOF
#set timeout -1
#spawn ssh -o StrictHostKeyChecking=no cache@$redis_server;
#expect {
#    "assword:" 			{ send "nbcache\r"; exp_continue }
#    "cache@localhost ~]$ "      { send "${set_redis} ${1} ${2} ${3}; exit\r"; exp_continue }
#	eof                     { send_user "eof" }
#}
#wait
#EOF
#}

##########################
# $0 $cmd
# login to MQ server 
##########################
set_redis()
{
expect -f - <<EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no cache@$mq_server;
expect {
    "assword:" 			{ send "nbcache\r"; exp_continue }
    "cache@localhost ~]$ "      { send "${set_redis} ${1} ${2} ${3}; exit\r"; exp_continue }
	eof                     { send_user "eof" }
}
wait
EOF
}


cids=`cat lists`
serverIP="10.10.1.169"
for cid in $cids;do
	set_redis init_cid $cid
	set_redis set_cid_hostIP $serverIP $cid
done
