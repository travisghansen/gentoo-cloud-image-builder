#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

chroot_exec() {
    local args="${@}"
    chroot "${R}" /bin/bash -c "${args}"
}

R="/mnt/gentoo"
K="/usr/src/linux"

echo "creating partitions and formatting disk"
./disk_prep.sh

echo "mounting root filesystem"
./mount_root.sh

echo "extracting basa system"
./extract_stage.sh

echo "mounting binds"
./mount_binds.sh

echo "extracting portage"
./extract_portage.sh

cp -f /etc/resolv.conf ${R}/etc

# install standard packages
echo "installing packages"
chroot_exec "emerge --jobs=2 --keep-going ${EMERGE_BASE_PACKAGES} ${EMERGE_EXTRA_PACKAGES}"

# build and install kernel/initrd
mkdir -p ${R}/etc/kernels/
if [ -f kernel-config ];then
    cp -f kernel-config ${R}/etc/kernels/kernel-config-cloud
fi

# copy config in place
cp -f ${R}/etc/kernels/kernel-config-cloud ${R}/usr/src/linux/.config

echo "building and installing kernel"
if [ "x${KERNEL_CONFIGURE}" = "x1" ];then
    chroot_exec "cd ${K}; make nconfig;"
fi

chroot_exec "cd ${K}; make ${KERNEL_MAKE_OPTS}; make modules_install; make install;"

# in case any adjustments are made via menuconfig etc
cp -f ${R}/${K}/.config ${R}/etc/kernels/kernel-config-cloud

# keep the original around for safe keeping
cp -f ${R}/etc/kernels/kernel-config-cloud ${R}/etc/kernels/kernel-config-cloud-original

# install grub to the MBR
chroot_exec "grub2-install ${DEV}"

# copy /etc/default/grub
cp -f grub ${R}/etc/default/grub
chmod 644 ${R}/etc/default/grub

# generate grub.cfg
chroot_exec "grub2-mkconfig -o /boot/grub/grub.cfg"

# enable serial console
sed -i 's/^#s0:/s0:/g' ${R}/etc/inittab
sed -i 's/^#s1:/s1:/g' ${R}/etc/inittab

# create init script for net.eth0
chroot_exec "cd /etc/init.d/; ln -sf net.lo net.eth0"

# enable default services
for service in acpid syslog-ng cronie net.eth0 sshd cloud-init-local cloud-init cloud-config cloud-final;do
    chroot_exec "rc-update add ${service} default"
done

for service in base gentoo;do
    chroot_exec "eselect bashcomp enable --global ${service}"
done

# ensure eth0 style nic naming
chroot_exec "ln -sf /dev/null /etc/udev/rules.d/70-persistent-net.rules"
chroot_exec "ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules"

# generate fstab
FS_UUID=$(blkid "${PART}" | cut -d " " -f2)
cat > ${R}/etc/fstab << EOF
${FS_UUID}      /       ext4        defaults,noatime,user_xattr 0 1
EOF

# copy fs/partition grow
cp -f resize_root.start ${R}/etc/local.d
chmod 755 ${R}/etc/local.d/resize_root.start

# copy cloud-init config into place
cp -f cloud.cfg ${R}/etc/cloud/
chmod 644 ${R}/etc/cloud/cloud.cfg

# TODO: cleanup
echo "final cleanup"
chroot_exec "eselect news read &>/dev/null"
rm -rf ${R}/usr/portage/distfiles/*
rm -rf ${R}/etc/resolv.conf
