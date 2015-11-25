#!/usr/bin/python
import paramiko
import pdb
import json
import sys
import re

host="10.247.59.2"
#host=sys.argv[1]
user="root"
passwd="welcome1"
command = "oc-service -a api.scalability.nimbula -u /root/root -p ~/pass.txt -n ~/pass.txt audit-site"
command_getsite = "host site"

def inred(str):
        return"%s[1;31m%s%s[0m"%(chr(27), str, chr(27))

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#ssh.connect(hostname=host,username=user,password=passwd)
ssh.connect(hostname=host,username=user,password=passwd)
print inred(host)
print "To write password file ..."
stdin,stdout,stderr = ssh.exec_command("echo OracleCloud9 > ~/pass.txt\n")
stdin,stdout,stderr = ssh.exec_command("chmod 600 ~/pass.txt\n")


print "Start to get audit-site log..."
print command 
stdin,stdout,stderr = ssh.exec_command("%s\n" %command)
results=stdout.read()
print results


#print ERROR info in red line
lists = re.findall(r"(ERROR.*?...)$",results,re.M)
for i in lists:
    print inred(i)

