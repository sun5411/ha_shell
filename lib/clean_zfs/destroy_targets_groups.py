#!/usr/bin/python
import paramiko
import pdb
import json
import sys

#zfs_server="slce39sn02.us.oracle.com"
zfs_server="slce39sn01.us.oracle.com"
port=22
user="root"
passwd="welcome1"
target_cmd="confirm configuration san iscsi targets destroy "
group_cmd="confirm configuration san iscsi targets groups destroy "

def inred(str):
    return"%s[1;31m%s%s[0m"%(chr(27), str, chr(27))

targets_file = open("tmp/targets")
#groups_file = open("tmp/groups")

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#ssh.connect(hostname=host,username=user,password=passwd)
ssh.connect(hostname=zfs_server,port=port,username=user,password=passwd)


while 1:
    lines = targets_file.readlines(255)
    if not lines:
        break
    for line in lines:
        print "###### Start to destory targets %s" %line
        print "%s%s\n" %(target_cmd,line)
        stdin,stdout,stderr = ssh.exec_command("%s%s\n" %(target_cmd,line))

#while 1:
#    lines = groups_file.readlines(255)
#    if not lines:
#        break
#    for line in lines:
#        print "###### Start to destory groups %s\n" %line
#        print "%s%s\n" %(group_cmd,line)
#        stdin,stdout,stderr = ssh.exec_command("%s%s\n" %(group_cmd,line))
#        print "%s\n" %(inred(stdout.read()))
