# Intro
gentoo-cloud-image-builder can be used to easily create openstack-compatible imaages

# Use
gentoo-cloud-image-builder is meant to be run from a qemu compatible host.  The high-level process includes booting a vm (using qemu) to the gentoo install cd/environment and subsequently automating a complete install.

In order to build an image you simply need to clone the repo and ensure you have a few standard deps on your host machine including:

 * qemu / kvm
 * curl
 * mkisofs
 * internet connectivity (all required files are downloaded for you)

On the host:

```./launch.sh -t build```

On the vm after booting the gentoo installer:

```
mkdir -p /mnt/builder
mount /dev/disk/by-label/builder /mnt/builder
/mnt/builder/full_install.sh
```

At this point kick back and relax.  Your image will be ready shortly.  Once everything is done you can halt the vm and test it out by running:

```./launch.sh -t test```

# Upload to Openstack
Once you have a valid image you can upload to openstack:

```glance image-create --name 'gentoo (20150507) x86_64' --disk-format qcow2 --container-format bare --is-public true --file gentoo.img --progress```

# TODO
 * disable root user / set random password / etc
 * more configurability to qemu options (memory, smp, etc)
 * grub serial device output?
 * app-emulation/openstack-guest-agents-unix?
 * make set/update hostname of cloud-init work with gentoo properly
 * kill hostname changes via dhcpcd
 * make use of growpart/growfs to do image growing (https://launchpad.net/cloud-utils)
