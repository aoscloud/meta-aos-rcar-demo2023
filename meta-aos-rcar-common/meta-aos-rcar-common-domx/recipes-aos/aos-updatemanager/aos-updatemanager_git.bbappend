FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://optee-identity.conf \
    file://reboot-on-failure.conf \
    file://aos-reboot.service \
"

AOS_UM_UPDATE_MODULES = " \
    updatemodules/overlayxenstore \
    updatemodules/ubootdualpart \
"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
"

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-reboot.service ${D}${systemd_system_unitdir}/aos-reboot.service

    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-optee-identity.conf
    install -m 0644 ${WORKDIR}/reboot-on-failure.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/20-reboot-on-failure.conf
}
