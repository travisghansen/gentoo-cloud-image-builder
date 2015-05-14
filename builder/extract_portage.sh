#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

tar -xjpf "${PORTAGE}" -C /mnt/gentoo/usr/
