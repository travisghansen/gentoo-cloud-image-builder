# Intro
Create gentoo openstack-compatible images

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
 * make set/update hostname of cloud-init work with gentoo properly
 * kill hostname changes via dhcpcd
 * app-emulation/openstack-guest-agents-unix?
 * make use of growpart/growfs to do image growing (https://launchpad.net/cloud-utils)
 * install/setup  bash completion

# Kernel
 * memory compaction/hotplug
 * namespaces/cgroups (for docker)
 * iptables/networking options
 * hugetlb?
 * ecrypt
 * mdraid
 * non-module virtio support
 * drbd
 * cirrus/hyper-v/qxl/etc graphics
 * disk hotplug: CONFIG_HOTPLUG=y CONFIG_ACPI_HOTPLUG_CPU=y CONFIG_HOTPLUG_PCI=y

# LINKS
 * http://terrarum.net/blog/creating-a-gentoo-cloud-image.html
 * http://blog.condi.me/base/
 * http://blog.david-jung.net/post/25402391612/testing-cloud-init-forcing-re-run-of-user
 * http://docs.openstack.org/image-guide/content/ch_openstack_images.html
 * https://wiki.ubuntu.com/QemuDiskHotplug
