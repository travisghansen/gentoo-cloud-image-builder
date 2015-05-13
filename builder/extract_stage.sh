#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

tar -xvjpf "${STAGE}" -C /mnt/gentoo
