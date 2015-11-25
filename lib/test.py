#!/usr/bin/python

import re
import os,sys

f = open("./bbb")
results = f.readlines()
#print results

#print string.find(results,r'ERROR')
#print re.findall(r'(ERROR:.*)',results)
print re.findall(r"(ERROR.*?...)$",results)
