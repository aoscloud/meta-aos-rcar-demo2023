require recipes-core/images/aos-image.inc

IMAGE_INSTALL += " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-network \
    dnsmasq \
    block \
"

# System components
IMAGE_INSTALL += " \
    openssh \
"

# Aos components
IMAGE_INSTALL += " \
    ${@bb.utils.contains('GEN3_DOM0_OS', 'zephyr', 'aos-messageproxy ', '', d)} \
"

AOS_ROOTFS_IMAGE_VERSION = "${AOS_DOMD_IMAGE_VERSION}"
