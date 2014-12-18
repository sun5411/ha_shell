#!/bin/bash

for i in {1..30};do
    nimbula-api -u /root/root -p /home/sun/pass.txt add storagevolume testVolume${i} 1g /oracle/ha_storage_prop1_auto
done
