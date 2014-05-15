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
print "Before kill, %s pid is %s"%(service,operation.ingreen(pid_before))
operation.killSer(node_before,pid_before)

time.sleep(50)

(node_after,pid_after) = getPid_node()

print "Before killed : %s, %s "%(node_before,pid_before)
print "After killed : %s, %s"%(node_after,pid_after)
if node_before == node_after:
    print "Service %s on the same node %s!"%(service,node_after)
elif pid_before == pid_after:
    print "Error Service have not be killed !"
