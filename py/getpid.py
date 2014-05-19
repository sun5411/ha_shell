#!/usr/bin/python
import os,sys,time
import paramiko
import string
import operation
import pdb

#service="rabbitmq_1"
service=sys.argv[1]

def getPid_node():
    ssh=paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=operation.host,username=operation.user,password=operation.passwd)
    node = operation.getNode(service)
    print "Node info : %s"%node
    pid = operation.getPid(node,service)
    ssh.close()
    return (node,pid)

(node_before,pid_before) = getPid_node()
print "%s pid is %s"%(service,operation.ingreen(pid_before))
