#!/bin/bash

#for i in {1..30};do
#    nimbula-api -u /root/root -p /home/sun/pass.txt add storagevolume testVolume${i} 1g /oracle/ha_storage_prop1_auto
#done
for i in {1..10};do
    nimbula-api -u /root/root -p /home/sun/pass.txt add storagevolume bootVolume${i} 6g /oracle/ha_storage_prop1_auto --bootable true --imagelist /oracle/public/oel6 -f json
done
