require recipes-core/images/aos-image.inc

IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
    block \
    iputils \
"

IMAGE_INSTALL += "iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += "kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += "kernel-module-ixgbe"

IMAGE_INSTALL += "e2fsprogs"

# System components
IMAGE_INSTALL += " \
    openssh \
"

# Aos components
IMAGE_INSTALL += " \
    ${@bb.utils.contains('GEN4_DOM0_OS', 'zephyr', 'aos-messageproxy ', '', d)} \
"

AOS_ROOTFS_IMAGE_VERSION = "${AOS_DOMD_IMAGE_VERSION}"
