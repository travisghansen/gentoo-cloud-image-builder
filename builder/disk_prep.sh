#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

# http://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/
# http://honglus.blogspot.com/2013/06/script-to-automatically-partition-new.html
parted -s "${DEV}" mklabel msdos
parted -s "${DEV}" mkpart primary 2048s 100%
partprobe > /dev/null 2>&1

mkfs.ext4 -FF "${PART}"
