#!/bin/bash

. ./function.sh

all="17011 17012 17013 17014 17015 17016 17017 17018 18611 18612 18613"

for port in $all;do
    echo_blue "\n### On Port $port"
    ssh_node_action 10.247.59.2  $port "pkill -9 perl"
done

