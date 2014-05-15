#!/usr/bin/python
import os,sys
import paramiko
import string
import operation
import pdb

service="rabbitmq_1"

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(hostname=operation.host,username=operation.user,password=operation.passwd)
node = operation.getNode(service)

pid=operation.getPid(node,service)
print "Before kill, %s on %s pid is %s"%(service,node,operation.ingreen(pid))
operation.killSer(node,pid)

ssh.close()

#for (k,v) in resultsConf.items():
#    if k == "services":
#        for (i,j) in v.iteritems():
#            print("%s:%s" %(ingreen(i),listAll(j)))
