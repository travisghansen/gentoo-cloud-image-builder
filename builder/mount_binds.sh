#!/bin/bash

set -e

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

#test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
#mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
#chmod 1777 /dev/shm /run/shm

