#!/bin/bash

set -e

cd `dirname "${0}"`
source builder.cfg

tar xpf "${STAGE}" --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
