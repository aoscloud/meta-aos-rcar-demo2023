FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://optee-identity.conf \
    file://simple-service.conf \
"

FILES_${PN} += " \
    ${sysconfdir} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/10-optee-identity.conf
    install -m 0644 ${WORKDIR}/simple-service.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/10-simple-service.conf
}

python do_update_config() {
    import json

    file_name = oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "aos", "aos_messageproxy.cfg")

    with open(file_name) as f:
        data = json.load(f)

    host = d.getVar("HOST_NAME")+"."+d.getVar("DOMAIN_NAME")

    # Update IAM servers

    data["IAMPublicServerURL"] = host+":8090"

    # Update CM server

    data["CMServerURL"] = d.getVar("MAIN_NODE_ADDRESS")+":8093"

    with open(file_name, "w") as f:
        json.dump(data, f, indent=4)
}

addtask update_config after do_install before do_package
