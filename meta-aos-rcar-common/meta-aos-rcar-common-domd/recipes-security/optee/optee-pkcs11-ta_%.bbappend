
#do_deploy[noexec] = ""

TA_UUID = "fd02c9da-306c-48c7-a49c-bbd827ae86ee"

do_deploy() {
    bbwarn "Deploing PKCS11 TA"
    # install pkcs11 TA

    # Create deploy folder
    install -d ${DEPLOYDIR}/ta

    # Copy pkcs11 TA to the deploy dir
    install -m 0644 ${S}/out/arm-plat-${PLATFORM}/ta/pkcs11/${TA_UUID}.ta ${DEPLOYDIR}/ta
}

addtask deploy before do_build after do_compile
