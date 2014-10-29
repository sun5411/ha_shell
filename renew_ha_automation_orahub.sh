#!/bin/bash

basedir="/home/sun/working-dir/HA/my_compute-controlplane"
source ~/.bashrc
#git pull the latest code
echo "###### Git pull get the latest code ..."
cd $basedir
id=`git log|sed 1q|cut -d' ' -f2`
git reset --hard $id
git pull

#renew the framework
echo "###### Mvn renew the framework..."
cd $basedir/test/infra/colt
mvn install
cd $basedir/test/infra/test-framework
mvn install

#replace the config file
echo "###### Replace the config file..."
cd $basedir/test/ha/config
\cp ~/nimbula.properties .
\cp ~/ha.properties .
