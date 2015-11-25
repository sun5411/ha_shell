#!/usr/bin/python
import paramiko
import pdb
import json
import sys
import re

#host="10.247.51.57"
#host="10.247.51.8"
#host="10.247.59.2"
#host="192.6.64.11"
#host=sys.argv[1]
host=sys.argv[1]
#nodeport=17011
#nodeport=17012
nodeport=17013
user="nimbulaadmin"
passwd="OracleCloud9"
command = "date"
ports = [17011,17012,17013,17014,17015,17016,17017,17018,18611,18612,18613]

def inred(str):
        return"%s[1;31m%s%s[0m"%(chr(27), str, chr(27))

def sshNode(port):
    ssh=paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    #ssh.connect(hostname=host,username=user,password=passwd)
    ssh.connect(hostname=host,port=port,username=user,password=passwd)
    print inred(host)
    print inred(port)
    print "### get date info..."
    stdin,stdout,stderr = ssh.exec_command("%s\n" %command)
    results=stdout.read()
    print results


for port in ports:
    sshNode(port)
