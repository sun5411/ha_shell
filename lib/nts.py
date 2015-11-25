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
nodeport=17011
#nodeport=17012
#nodeport=17013
user="nimbulaadmin"
passwd="OracleCloud9"
command = "echo OracleCloud9 |sudo -S nimbula-test-services -p OracleCloud9"
command_getsite = "host site"

def inred(str):
        return"%s[1;31m%s%s[0m"%(chr(27), str, chr(27))

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#ssh.connect(hostname=host,username=user,password=passwd)
ssh.connect(hostname=host,port=nodeport,username=user,password=passwd)
print inred(host)
print "Start to get NTS log..."
stdin,stdout,stderr = ssh.exec_command("%s\n" %command)
results=stdout.read()
print results


#print ERROR info in red line
lists = re.findall(r"(ERROR.*?...)$",results,re.M)
for i in lists:
    print inred(i)

