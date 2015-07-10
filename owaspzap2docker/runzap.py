#!/usr/bin/env python

import os
import subprocess
import time
import urllib
from pprint import pprint
from zapv2 import ZAPv2
import sys

print 'Starting ZAP ...'
subprocess.Popen(["zap.sh","-daemon","-port 8090","-host 0.0.0.0"],stdout=open(os.devnull,'w'))
print 'Waiting for ZAP to load, 10 seconds ...'
time.sleep(10)

target = sys.argv[1]
print target
#zap = ZAPv2(proxies={'http': 'http://localhost:8090', 'https': 'http://localhost:8090'})
zap = ZAPv2()

print 'Accessing target %s' % target
zap.urlopen(target)
time.sleep(2)

print 'Spidering target %s' % target
zap.spider.scan(target)
time.sleep(2)
while (int(zap.spider.status) < 100):
    print 'Spider progress %: ' + zap.spider.status
    time.sleep(2)

print 'Spider completed'
time.sleep(5)

print 'Scanning target %s' % target
zap.ascan.scan(target)
while (int(zap.ascan.status) < 100):
    print 'Scan progress %: ' + zap.ascan.status
    time.sleep(5)

print 'Scan completed'

#print 'Hosts: ' + ', '.join(zap.core.hosts)
#print 'Alerts: '
#pprint (zap.core.alerts())

#urllib.urlretrieve ("http://localhost:8090/OTHER/core/other/xmlreport", "xmlreport") 

with open("/zap/ZAP_2.4.0/report.xml", "w") as f:
	f.write(zap.core.xmlreport)
	f.close()

zap.core.shutdown()
