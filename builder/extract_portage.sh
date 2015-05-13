#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

tar -xvjpf "${PORTAGE}" -C /mnt/gentoo/usr/
