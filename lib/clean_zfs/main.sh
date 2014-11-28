#!/bin/bash

./get_zfs_targets_groups.sh
python ./destroy_targets_groups.py
