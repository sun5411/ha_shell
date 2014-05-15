#!/usr/bin/python
import os
import string

cmd="nimbula-admin -u /root/root -p /tmp/nimbulaPasswdFile_root_root list node / -Fendpoint"
res=os.popen(cmd)
print res.readlines()[1].strip()
