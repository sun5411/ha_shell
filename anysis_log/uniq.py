#!/usr/bin/env  python
#coding=utf-8

import os
import time
from datetime import datetime, timedelta, tzinfo
#from pytz import timezone
import pytz
import argparse
from simhash import Simhash

class LogHandler():

    def __init__(self):
        self.filen = None
        self.lines = ()
        self.logdict = {}
        self.sortedlog = []
        self.shrinklogs = []

    def loadfile(self, filen):
        self.filen = os.path.abspath(filen)
        if os.path.isfile(self.filen) and os.access(self.filen, os.R_OK):
            with open(self.filen) as f:
                self.sortedlog = f.readlines()

    def _extract_content(self, content):
        cnt = content.split('@ ')

        if not cnt and len(cnt) > 2:
            ret = cnt[1]
        else:
            ret = content

        return ret

    def shrinkdup(self):
        pkv = Simhash('')
        shdist = 10

        for content in self.sortedlog:
            if not content or content.strip() == '':
                continue
            try:
                ret = self._extract_content(content)
                hv = Simhash(ret)
                if pkv.distance(hv) > shdist:
                    self.shrinklogs.append(content)
                    pkv = hv
            except Exception as e:
                print content
                print e

        if len(self.shrinklogs) > 0:
            filen = self.filen + '-shrunk'
            with open(filen, 'w') as f:
                for v in self.shrinklogs:
                    f.write('%s' % (v))


if __name__ == '__main__':

    parse = argparse.ArgumentParser()
    parse.add_argument("-i", "--iuniq", help="pass a instance related log file")
    #opts= vars(parse.parse_args())
    #print opts['instid']
    opts = parse.parse_args()

    lg = LogHandler()
    lg.loadfile(opts.iuniq)
    lg.shrinkdup()
