#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

tar -xjpf "${STAGE}" -C /mnt/gentoo
