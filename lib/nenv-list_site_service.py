#!/usr/bin/python
import paramiko
import pdb
import json
import sys

#host="10.247.51.59"
#host="10.247.51.8"
#host="10.247.51.3"
#host="10.247.51.9"
host="10.89.1.149"
#host="192.6.80.11"
#host=sys.argv[1]
user="nimbulaadmin"
passwd="OracleCloud9"
command = "curl -ks https://master:5000 |python -m json.tool"
command_getsite = "host site"
sum=0


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

ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#ssh.connect(hostname=host,username=user,password=passwd)
ssh.connect(hostname=host,username=user,password=passwd)
stdin,stdout,stderr = ssh.exec_command("%s\n" %command)
results=stdout.read()
resultsConf=json.loads(results)

def listAll(list):
    all=""
    for l in list:
        if all != "":
            all = all + ' , ' + l
        else:
            all = l
    return all

for (k,v) in resultsConf.items():
    if k == "services":
        for (i,j) in v.iteritems():
            sum += 1
            print("%s : [ %s ]" %(ingreen(i),listAll(j)))

print_bold("###### Total have %d services ######"%sum)

stdin,stdout,stderr = ssh.exec_command("%s\n" %command_getsite)
siteInfo=stdout.read()

print_bold("Site Info : %s"%(inred(siteInfo)))
