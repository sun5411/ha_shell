#!/usr/bin/python
import paramiko
import pdb
import json
import os,sys
import string

getendpoint="nimbula-admin -u /root/root -p /tmp/nimbulaPasswdFile_root_root list node / -Fendpoint"
res=os.popen(getendpoint)
host=res.readlines()[1].strip()
user="nimbulaadmin"
passwd="OracleCloud9"
command = "curl -ks https://master:5000 |python -m json.tool"

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

def inred(str):
    return"%s[1;31m%s%s[0m"%(chr(27), str, chr(27))

def inblue(str):
    return"%s[1;34m%s%s[0m"%(chr(27), str, chr(27))

def ingreen(str):
    return"%s[1;32m%s%s[0m"%(chr(27), str, chr(27))

def inyellow(str):
    return"%s[1;33m%s%s[0m"%(chr(27), str, chr(27))

def inpink(str):
    return"%s[1;35m%s%s[0m"%(chr(27), str, chr(27))

def inbold(str):
    return"%s[1;38m%s%s[0m"%(chr(27), str, chr(27))

def print_red(str):
    print "%s[1;31m%s%s[0m"%(chr(27), str, chr(27))

def print_blue(str):
    print "%s[1;34m%s%s[0m"%(chr(27), str, chr(27))

def print_green(str):
    print "%s[1;32m%s%s[0m"%(chr(27), str, chr(27))

def print_yellow(str):
    print "%s[1;33m%s%s[0m"%(chr(27), str, chr(27))

def print_pink(str):
    print "%s[1;35m%s%s[0m"%(chr(27), str, chr(27))

def print_bold(str):
    print "%s[1;38m%s%s[0m"%(chr(27), str, chr(27))

def listAll(list):
    all=""
    for l in list:
        if all != "":
            all = all + ' , ' + l
        else:
            all = l
    return all

def getNode(service):
    ssh.connect(hostname=host,username=user,password=passwd)
    stdin,stdout,stderr = ssh.exec_command("%s\n" %command)
    results=stdout.read()

    resultsConf=json.loads(results)
    for (k,v) in resultsConf.items():
        if k == "services":
            for (i,j) in v.iteritems():
                if i == service:
                    return listAll(j)

def getPid(host,service):
    if service in ('gluster_server'):
        service="glusterfsd"
        cmd="ps -ef | grep -i %s | grep nimbula |grep -v grep |awk '{print $2}'"%(service)
    elif service in ('zookeeper_base'):
        service="zookeeper"
        cmd="ps -ef | grep -i %s|grep -v grep |awk '{print $2}'"%(service)
    elif service in ('bevent'):
        cmd="ps -ef | grep -i bevent.pid | grep nimbula|grep -v grep |awk '{print $2}'"
    elif service in ('bstoragemanager_1'):
        cmd="ps -ef | grep -i bstoragemanager_1.pid | grep nimbula|grep -v grep |awk '{print $2}'"
    elif service in ('bstorageworker_nfs_1'):
        service="bStorageWorker_1"
        cmd="ps -ef | grep -i %s.pid | grep nimbula |grep -v grep |awk '{print $2}'"%(service)
    elif service in ('bstorageworker_nfs_2'):
        service="bStorageWorker_2"
        cmd="ps -ef | grep -i %s.pid | grep nimbula |grep -v grep |awk '{print $2}'"%(service)
    elif service in ('rabbitmq_1'):
        service="rabbit1"
        cmd="ps -ef | grep -i %s | grep rabbitmq |grep -v grep |awk '{print $2}'"%(service)
    elif service in ('bnode'):
        cmd="ps -ef | grep -i bnode.pid | grep nimbula|grep -v grep |awk '{print $2}'"
    elif service in ('nosql_replica'):
        cmd="ps aux | grep nosql| grep RepNode | grep nimbula|grep -v grep |awk '{print $2}'"
    else:
        cmd="ps -ef | grep -i %s.pid | grep nimbula|grep -v grep |awk '{print $2}'"%(service)

    ssh.connect(hostname=host,username=user,password=passwd)
    stdin,stdout,stderr = ssh.exec_command("%s\n" %cmd)
    pid=stdout.read()
    if pid == '':
        print  "cmd : %s"%cmd
        print "Can't get %s pid !"%service
        sys.exit()
    print "Get %s pid : %s"%(service,pid)
    return pid

def killSer(host,pid):
    cmd="echo %s|sudo -S kill -9 %s"%(passwd,pid)
    ssh.connect(hostname=host,username=user,password=passwd)
    stdin,stdout,stderr = ssh.exec_command("%s\n" %cmd)
