#!/bin/bash

cd `dirname "${0}"`
source builder.cfg

R="/mnt/gentoo"

./disk_prep.sh
./mount_root.sh
./extract_stage.sh
./mount_binds.sh
./extract_portage.sh

cp -f /etc/resolv.conf ${R}/etc

# install standard packages
chroot "${R}" /bin/bash -c 'emerge --jobs=2 --keep-going genkernel acpid syslog-ng cronie dhcpcd mlocate xfsprogs dosfstools grub sudo postfix cloud-init vim gentoo-sources linux-firmware parted portage-utils gentoolkit'


# build and install kernel/initrd
# TODO: get a better (more lean) kernel config
# TODO: add --virtio to genkernel if it ever starts working
mkdir -p ${R}/etc/kernels/
if [ -f kernel-config ];then
    cp -f kernel-config ${R}/etc/kernels/kernel-config-cloud
else
    cp -f /etc/kernels/kernel-config-* ${R}/etc/kernels/kernel-config-cloud
fi

cp -f ${R}/etc/kernels/kernel-config-cloud ${R}/etc/kernels/kernel-config-cloud-original

chroot /mnt/gentoo /bin/bash -c "genkernel --install --all-ramdisk-modules --e2fsprogs --disklabel --no-mountboot --kernel-config=/etc/kernels/kernel-config-cloud all"

# install grub to the MBR
chroot /mnt/gentoo /bin/bash -c "grub2-install ${DEV}"

# copy /etc/default/grub
# TODO: send grub to serial console?
cp -f grub ${R}/etc/default/grub
chmod 644 ${R}/etc/default/grub

# generate grub.cfg
chroot /mnt/gentoo /bin/bash -c "grub2-mkconfig -o /boot/grub/grub.cfg"

# enable serial console
sed -i 's/^#s0:/s0:/g' ${R}/etc/inittab
sed -i 's/^#s1:/s1:/g' ${R}/etc/inittab

# create init script for net.eth0
chroot /mnt/gentoo /bin/bash -c "cd /etc/init.d/; ln -sf net.lo net.eth0"

# enable standard services
for service in acpid syslog-ng cronie net.eth0 sshd cloud-init-local cloud-init cloud-config cloud-final;do
    chroot /mnt/gentoo /bin/bash -c "rc-update add ${service} default"
done

# ensure eth0 style nic naming
chroot /mnt/gentoo /bin/bash -c "ln -sf /dev/null /etc/udev/rules.d/70-persistent-net.rules"
chroot /mnt/gentoo /bin/bash -c "ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules"

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

# TODO: any passwd etc changes for root user

# create a genkernel script for updating to new kernels manually
cp -f genkernel-cloud ${R}/usr/bin/
chmod 755 ${R}/usr/bin/genkernel-cloud

cp -f rebuild-grub ${R}/etc/kernel/postinst.d/
chmod 755 ${R}/etc/kernel/postinst.d/rebuild-grub

# TODO: cleanup
rm -rf ${R}/usr/portage/distfiles/*
rm -rf ${R}/etc/resolv.conf
