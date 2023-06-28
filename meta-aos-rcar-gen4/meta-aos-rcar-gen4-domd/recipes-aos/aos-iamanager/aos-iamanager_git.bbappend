FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://aos-vis-service.conf \
"

AOS_IAM_IDENT_MODULES = " \
    identhandler/modules/visidentifier \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/aos-iamanager.service.d/ \
"

RDEPENDS_${PN} += " \
    aos-setupdisk \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/aos-iamanager.service.d
    install -m 0644 ${WORKDIR}/aos-vis-service.conf ${D}${sysconfdir}/systemd/system/aos-iamanager.service.d/10-aos-vis-service.conf
}
