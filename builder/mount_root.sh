#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

mount "${PART}" /mnt/gentoo
