FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_+= " \
    file://0001-net-tftp-Fix-incorrect-tftp_next_ack-on-no-OACK.patch \
"

SRC_URI_append_spider = " \
    file://0001-ufs-flush-invalidate-command-buffer.patch \
    file://0001-arm-dts-r8a779f0-Add-Renesas-UFS-HCD-support.patch \
    file://0002-ufs-port-linux-driver-for-rcar-ufshcd.patch \
    file://ufs.cfg \
"
