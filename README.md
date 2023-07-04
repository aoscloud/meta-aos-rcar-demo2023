# meta-aos-rcar-demo2023

This is demo product. The aim of this product is to demonstrate Aos multi node capability. It produces images for two
Renesas R-Car device based nodes: R-Car-S4 device is the main node and one of R-Car Gen3 device is additional node.
Build for R-Car-S4 device is based on [meta-aos-rcar-gen4](https://github.com/aoscloud/meta-aos-rcar-gen4) while R-Car
Gen3 device is based on [meta-aos-rcar-gen3](https://github.com/aoscloud/meta-aos-rcar-gen3).

## Status

This is release 0.2.0. This release supports the following features:

* R-Car-S4 device:
  * dom0 with running unikernels as Aos services capability;
  * domd with running OCI containers as Aos services capability.
* R-Car Gen3 device:
  * dom0 with running unikernels as Aos services capability;
  * domd with running OCI containers as Aos services capability.
* FOTA is integrated and supported.

## Building

### Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto manual]
   (<https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages>).
3. You need `Moulin` of version 0.11 or newer installed in your PC. Recommended way is to install it for your user only:
   `pip3 install --user git+https://github.com/xen-troops/moulin`. Make sure that your `PATH` environment variable
    includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

### Fetching

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-rcar-demo2023.yaml`.
During the build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse,
we recommend to download only `aos-rcar-demo2023.yaml`:

```sh
# curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-rcar-demo2023/main/aos-rcar-demo2023.yaml
```

### Building

Moulin is used to generate Ninja build file: `aos-rcar-demo2023.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command line option:

```sh
usage: /home/oleksandr_grytsov/.local/bin/moulin aos-rcar-demo2023.yaml [--GEN3_DEVICE {enable,disable}]
                                                                        [--GEN3_MACHINE {h3ulcb-4x2g-ab,h3ulcb-4x2g,h3ulcb-4x2g-kf,m3ulcb,salvator-x-m3,salvator-xs-m3-2x4g,salvator-xs-h3,salvator-xs-h3-4x2g,salvator-x-h3-4x2g,salvator-x-h3}]
                                                                        [--DOM0 {linux,zephyr}] [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}]

Config file description: Aos virtual development machine

options:
  --GEN3_DEVICE {enable,disable}
                        Add RCAR Gen3-based device as Aos nodes
  --GEN3_MACHINE {h3ulcb-4x2g-ab,h3ulcb-4x2g,h3ulcb-4x2g-kf,m3ulcb,salvator-x-m3,salvator-xs-m3-2x4g,salvator-xs-h3,salvator-xs-h3-4x2g,salvator-x-h3-4x2g,salvator-x-h3}
                        RCAR Gen3-based machine
  --DOM0 {linux,zephyr}
                        Select Dom0
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        Specifies plugin for VIS automotive data

```

By default, build for two devices will be performed. It is possible to build standalone product only for R-Car-S4
device by disabling build for R-Car Gen3 device: `--GEN3_DEVICE=disable`. To build zephyr OS as Dom0 OS, `--DOM0=zephyr`
option should be specified.

Moulin will generate `build.ninja` file. After that run `ninja` to build the images. Issue the command
`ninja gen4_full.img` to generate full image for R-Car-S4 device and `ninja gen3_full.img` to generate full image for
R-Car Gen3 device.

### Deploying

To deploy the full image to R-Car-S4 device, see [meta-aos-rcar-gen4]
(<https://github.com/aoscloud/meta-aos-rcar-gen4/blob/main/README.md>).

To deploy the full image to R-Car Gen3 device, see [meta-aos-rcar-gen3]
(<https://github.com/aoscloud/meta-aos-rcar-gen3/blob/main/README.md>).

In the current release, if zephyr Dom0 OS is selected, internal mmc storage is allocated for Dom0 zephyr needs. Other
image partitions should be deployed to the different device storage.

The image should be flashed to SD card on Gen3 board:

```sh
dd if=/gen3_full.img of=/dev/mmcblk1 bs=32M status=progress oflag=direct
```

The image should be flashed to UFS on Gen4 board:

```sh
dd if=/gen4_full.img of=/dev/sda bs=32M
```

If you need to deploy Gen3 board over ethernet connected to Gen4 board, it is possible by enabling bridge on Gen4 baord:

```sh
brctl addbr br0
brctl addif br0 tsn0
brctl addif br0 tsn1
ifconfig br0 up
```

### U-Boot environment variables

Gen3 board:

```sh
setenv aos_boot1 'if test ${aos_boot1_ok} -eq 1; then setenv aos_boot1_ok 0; setenv aos_boot2_ok 1; setenv aos_boot_part 0; setenv aos_boot_slot 1; echo "==== Boot from part 1"; run aos_save_vars; run aos_boot_cmd; fi'
setenv 'aos_boot2=if test ${aos_boot2_ok} -eq 1; then setenv aos_boot2_ok 0; setenv aos_boot1_ok 1; setenv aos_boot_part 1; setenv aos_boot_slot 2; echo "==== Boot from part 2"; run aos_save_vars; run aos_boot_cmd; fi'
setenv aos_boot_cmd 'run aos_xen_load; run aos_dtb_load; run aos_zephyr_load; run aos_xenpolicy_load; bootm 0x48080000 - 0x48000000'
setenv aos_boot_device 'mmcblk1'
setenv aos_default_vars 'setenv aos_boot_main 0; setenv aos_boot1_ok 1; setenv aos_boot2_ok 1; setenv aos_boot_part 0'
setenv aos_device 'mmc 0'
setenv aos_dtb_load 'ext2load ${aos_device}:${aos_boot_slot} 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device ${aos_boot_device}'
setenv aos_load_vars 'run aos_default_vars; if load ${aos_device}:3 ${loadaddr} uboot.env; then env import -t ${loadaddr} ${filesize}; else run aos_save_vars; fi'
setenv aos_save_vars 'env export -t ${loadaddr} aos_boot_main aos_boot_part aos_boot1_ok aos_boot2_ok; fatwrite ${aos_device}:3 ${loadaddr} uboot.env 0x3E'
setenv aos_xen_load 'ext2load ${aos_device}:${aos_boot_slot} 0x48080000 xen'
setenv aos_xenpolicy_load 'ext2load ${aos_device}:${aos_boot_slot} 0x8e000000 xenpolicy'
setenv aos_zephyr_load 'ext2load ${aos_device}:${aos_boot_slot} 0x8a000000 zephyr.bin'
setenv bootcmd_aos 'run aos_load_vars; if test ${aos_boot_main} -eq 0; then run aos_boot1; run aos_boot2; else run aos_boot2; run aos_boot1; fi'
setenv bootcmd 'run bootcmd_aos'
```

Gen4 board:

```sh
setenv aos_boot1 'if test ${aos_boot1_ok} -eq 1; then setenv aos_boot1_ok 0; setenv aos_boot2_ok 1; setenv aos_boot_part 0; setenv aos_boot_slot 1; echo "==== Boot from part 1"; run aos_save_vars; run aos_boot_cmd; fi'
setenv 'aos_boot2=if test ${aos_boot2_ok} -eq 1; then setenv aos_boot2_ok 0; setenv aos_boot1_ok 1; setenv aos_boot_part 1; setenv aos_boot_slot 2; echo "==== Boot from part 2"; run aos_save_vars; run aos_boot_cmd; fi'
setenv aos_boot_cmd 'run aos_xen_load; run aos_dtb_load; run aos_zephyr_load; run aos_xenpolicy_load; bootm 0x48080000 - 0x48000000'
setenv aos_boot_device 'sda'
setenv aos_default_vars 'setenv aos_boot_main 0; setenv aos_boot1_ok 1; setenv aos_boot2_ok 1; setenv aos_boot_part 0'
setenv aos_device 'scsi 0'
setenv aos_dtb_load 'ext2load ${aos_device}:${aos_boot_slot} 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device ${aos_boot_device}'
setenv aos_load_vars 'run aos_default_vars; if load ${aos_device}:3 ${loadaddr} uboot.env; then env import -t ${loadaddr} ${filesize}; else run aos_save_vars; fi'
setenv aos_save_vars 'env export -t ${loadaddr} aos_boot_main aos_boot_part aos_boot1_ok aos_boot2_ok; fatwrite ${aos_device}:3 ${loadaddr} uboot.env 0x3E'
setenv aos_xen_load 'ext2load ${aos_device}:${aos_boot_slot} 0x48080000 xen'
setenv aos_xenpolicy_load 'ext2load ${aos_device}:${aos_boot_slot} 0x7e000000 xenpolicy'
setenv aos_zephyr_load 'ext2load ${aos_device}:${aos_boot_slot} 0x7a000000 zephyr.bin'
setenv bootcmd_aos 'run aos_load_vars; if test ${aos_boot_main} -eq 0; then run aos_boot1; run aos_boot2; else run aos_boot2; run aos_boot1; fi'
setenv bootcmd 'run set_pcie; run set_ufs; scsi scan; run bootcmd_aos'
setenv set_pcie 'i2c dev 0; i2c mw 0x6c 0x26 5; i2c mw 0x6c 0x254.2 0x1e; i2c mw 0x6c 0x258.2 0x1e; i2c mw 0x20 0x3.1 0xfe;'
setenv set_ufs 'i2c dev 0; i2c mw 0x6c 0x26 0x05; i2c olen 0x6c 2; i2c mw 0x6c 0x13a 0x86; i2c mw 0x6c 0x268 0x06; i2c mw 0x6c 0x269 0x00; i2c mw 0x6c 0x26a 0x3c; i2c mw 0x6c 0x26b 0x00; i2c mw 0x6c 0x26c 0x06; i2c mw 0x6c 0x26d 0x00; i2c mw 0x6c 0x26e 0x3f; i2c mw 0x6c 0x26f 0x00'
```
