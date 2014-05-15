#!/usr/bin/python

import paramiko
import sys
#import config
host=sys.argv[1]
user="nimbulaadmin"
passwd="OracleCloud9"
ser=sys.argv[2]

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(hostname=host,username=user,password=passwd)
#stdin,stdout,stderr = ssh.exec_command("%s\n" %command)
#results=stdout.read()
#resultsConf=json.loads(results)

def getPid(host,service):
    ssh.connect(hostname=host,username=user,password=passwd)
    if service in ('gluster_server'):
        service="glusterfsd"
        cmd="ps -ef | grep -i %s | grep nimbula"%(service)
    elif service in ('zookeeper_base'):
        service="zookeeper"
        cmd="ps -ef | grep -i %s"%(service)
    elif service in ('bevent'):
        cmd="ps -ef | grep -i bevent.pid | grep nimbula"
    elif service in ('bstoragemanager_1'):
        cmd="ps -ef | grep -i bstoragemanager_1.pid | grep nimbula"
    elif service in ('bstorageworker_nfs_1'):
        service="bStorageWorker_1"
        cmd="ps -ef | grep -i %s.pid | grep nimbula"%(service)
    elif service in ('bstorageworker_nfs_2'):
        service="bStorageWorker_2"
        cmd="ps -ef | grep -i %s.pid | grep nimbula"%(service)
    elif service in ('rabbitmq_1'):
        service="rabbit1"
        cmd="ps -ef | grep -i %s | grep rabbitmq"%(service)
    elif service in ('bnode'):
        cmd="ps -ef | grep -i bnode.pid | grep nimbula"
    elif service in ('nosql_replica'):
        cmd="ps aux | grep nosql| grep RepNode | grep nimbula"
    else:
        cmd="ps -ef | grep -i %s.pid | grep nimbula"%(service)

    stdin,stdout,stderr = ssh.exec_command("%s\n" %cmd)
    pid=stdout.read()
    if pid == '':
        print "Can't get %s pid !"%service
        sys.exit()
    print "Get %s pid : %s"%(service,pid)
    return pid

def killSer(pid):
    cmd="echo %s|sudo -S kill -9 %s"%(passwd,pid)
    stdin,stdout,stderr = ssh.exec_command("%s\n" %cmd)
    if stderr != '':
        print stderr
        sys.exit()

if __name__ == '__main__':
    pid = getPid(ser)
    print "Service %s Pid is : %s"%(ser,pid)
    print "Will delete %s service"%(ser)
    #killSer(pid)
    ssh.close()
