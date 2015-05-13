#!/bin/bash

for i in proc dev sys
do
    mount --rbind /$i /mnt/gentoo/$i
done
