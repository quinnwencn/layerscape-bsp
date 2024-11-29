Linux SDK can be built with flex-builder and be deployed with flex-installer.


## How to build Linux SDK from scratch with flex-builder
```
Usage:  flex-builder -m <machine>
The supported Layserscape <machine>:
    ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy, ls1088ardb_pb, ls2088ardb, ls2160ardb_rev2, lx2162aqds.

The supported iMX <machine>:
    imx6qpsabresd, imx6qsabresd, imx6sllevk, imx7ulpevk, imx8mmevk, imx8mnevk, imx8mpevk, imx8mqevk, imx8qmmek, imx8qxpmek

Example:
$ cd flexbuild
$ source setup.env
$ flex-builder -m ls1046ardb  # automatically build all images (bootloader, linux, app components, distro userland, etc) for ls1046ardb
$ flex-builder -m imx8mpevk   # automatically build all images (bootloader, linux, app components, distro userland, etc) for imx8mpevk
```
Please refer to docs/flexbuild_usage.md and docs/build_and_deploy_distro.md for detailed usages.



## How to deploy LSDK with flex-installer
Examples:
- To automatically deploy LSDK distro onto storage device
```
$ flex-installer -i auto -m ls1046ardb -d /dev/mmcblk0          # install rootfs_lsdk2108_ubuntu_main.tgz and boot_LS_arm64_lts_5.10.tgz
$ flex-installer -i auto -m lx2160ardb -d /dev/sdx -b boot_LS_arm64_lts_5.10.tgz   # specify different kernel version for bootpartition
$ flex-installer -i auto -m ls2088ardb -d /dev/sdx -e dtb       # '-e dtb' option is used for UEFI in DTB way, no need for U-Boot case
$ flex-installer -i auto -m lx2160ardb -d /dev/sdx -e acpi      # '-e acpi' option is used for UEFI in ACPI way, no need for U-Boot case
```

- To install local distro images instead of automation for single distro
```
$ flex-installer -i pf -d /dev/sdx   (partition and format the target storage device)
$ flex-installer -b boot_LS_arm64_lts_5.10.tgz -r rootfs_lsdk2108_ubuntu_main_arm64.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/sdx
$ flex-installer -b boot_IMX_arm64_lts_5.10.tgz -r rootfs_lsdk2108_ubuntu_desktop_arm64.tgz -f firmware_imx8mpevk_sdboot.img -d /dev/sdx -o 32k
```

- To install local distro images instead of automation for dual distros
```
$ flex-installer -b <boot> -r rootfs_lsdk2108_ubuntu_main_arm64.tgz -R rootfs_lsdk2108_yocto_devel_arm64.tgz -f <firmware> -d /dev/sdx
(run 'setenv devpart_root 3;boot' in U-Boot to boot the second distro from partition-3)
```

- On ARM board running the TinyLinux, first partition target disk, then download local distro images onto board and install as below
```
$ flex-installer -i pf -d /dev/mmcblk0 (or /dev/sdx)
$ cd /mnt/mmcblk0p3 and download your customized distro images to this partition via wget or scp
$ flex-installer -b <bootpartition> -r <rootfs> -f <firmware> -d <device>
```

- To only download distro images without installation
```
$ flex-installer -i download -m ls1046ardb
```

- To only install composite firmware
```
$ flex-installer -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0 (or /dev/sdx)
(Note: '-f' option is only for sdboot, no need for non sdboot)
```


## How to build composite firmware with non default RCW
Besides modifying RCW settings in configs/board/<machine>/manifest, users also can set
environment variable 'rcw_bin' to override the default RCW as below, for example:
```
$ export rcw_bin=lx2160ardb_rev2/XGGFF_PP_HHHH_RR_19_5_2/rcw_2200_700_3200_19_5_2.bin
$ flex-builder -i clean-firmware
$ flex-builder -i mkfw -m lx2160ardb_rev2
$ unset rcw_bin (unset to avoid impact on subsequent build)
```



## How to program LSDK composite firmware to SD/NOR/QSPI/XSPI flash device
- For SD/eMMC card
```
$ wget http://www.nxp.com/lgfiles/sdk/lsdk2108/firmware_<machine>_sdboot.img
=> tftp a0000000 firmware_<machine>_sdboot.img
or
=> load mmc 0:2 a0000000 firmware_<machine>_sdboot.img

Under U-Boot:
=> mmc write a0000000 8 1f000

Under Linux:
$ flex-installer -f firmware_<machine>_sdboot.img -d /dev/mmcblk0 (or /dev/sdx)
```

- For IFC-NOR flash
```
On LS1043ARDB, LS1021ATWR
=> load mmc 0:2 a0000000 firmware_<machine>_uboot_norboot.img
or tftp a0000000 firmware_<machine>_uboot_norboot.img
To program alternate bank:
=> protect off 64000000 +$filesize && erase 64000000 +$filesize && cp.b a0000000 64000000 $filesize
To program current bank
=> protect off 60000000 +$filesize && erase 60000000 +$filesize && cp.b a0000000 60000000 $filesize

On LS2088ARDB:
=> load mmc 0:2 a0000000 firmware_ls2088ardb_uboot_norboot.img
or tftp a0000000 firmware_ls2088ardb_uboot_norboot.img
To program alternate bank:
=> protect off 584000000 +$filesize && erase 584000000 +$filesize && cp.b a0000000 584000000 $filesize
To program current bank:
=> protect off 580000000 +$filesize && erase 580000000 +$filesize && cp.b a0000000 580000000 $filesize
```

- For QSPI-NOR/FlexSPI-NOR flash
```
On LS1012ARDB, LS1028ARDB, LS1046ARDB, LS1088ARDB-PB, LX2160ARDB
=> load mmc 0:2 a0000000 firmware_<machine>_qspiboot.img
or
=> load mmc 0:2 a0000000 firmware_lx2160ardb_xspiboot.img
or tftp a0000000 firmware_<machine>_qspiboot.img
=> sf probe 0:1
=> sf erase 0 +$filesize && sf write 0xa0000000 0 $filesize
```




## How to upgrade the existing LSDK distro with Flexbuild on host
As some LSDK components are updated quickly after a formal LSDK release, users can upgrade existing LSDK with
the steps below to simplify the procedure of building and deploying the new changes against existing LSDK.

Step 1: Download the latest flexbuild tarball and extract it against the existing flexbuild work directory
```
$ tar xvzf flexbuild_<version_update_xx>.tgz --strip-components 1 -C <path_to_existing_flexbuild>
$ cd <path_to_existing_flexbuild>
$ source setup.env
$ flex-builder -i repo-fetch (fetch repos of LSDK components)
$ flex-builder -i repo-tag   (switch to new tags of components)
```

Step 2: Rebuild LSDK image with the update of components
Examples:
To rebuild all images for specific machine:
```
$ flex-builder clean
$ flex-builder -m <machine>
```

To rebuild all apps components:
```
$ flex-builder -i clean-apps
$ flex-builder -c apps
```

To rebuild specific component:
```
$ flex-builder -i clean-apps
$ flex-builder -c <component>
```

To rebuild linux kernel:
```
$ flex-builder -i clean-linux
$ flex-builder -c linux                     (use the default kernel repo and tag/branch)
or
$ flex-builder -c linux:<repo>:<tag|branch> -a <arch> (specify kernel repo and tag/branch)
```

To rebuild composite firmware:
```
$ flex-builder -i clean-firmware
$ flex-builder -i mkfw -m <machine>
```

Step 3: Push the newly generated image on host to target board
Once boot the existing LSDK distro on target board and configure IP address, run commands below on host to
push the images generated in Step 2 to target board.
Examples:
To push kernel and modules to target board:
```
$ flex-builder connect <IP_address>
$ flex-builder push kernel <IP_address>
$ flex-builder disconnect <IP_address>
```

To push single or multiple apps components to target board:
```
$ flex-builder connect <IP_address>
$ flex-builder push apps <IP_address>
$ flex-builder disconnect <IP_address>
```
Reboot the target board to boot distro with the updated images.

To upgrade composite firmware, you can program the firmware generated in Step 2 into SD card or flash device under U-Boot.
Addtionally, for SD boot, you can program firmware by the command below in Linux environment:
```
$ flex-installer -f <firmware> -d /dev/sdx [ -o <offset> ]
or
$ sudo dd if=<firmware> of=/dev/sdX bs=1k seek=<offset>
  The <offset> is 4k for Layscape boards, 1k/32k/33k for iMX boards
```




## How to add support for a new custom machine in flexbuild based on LSDK release
Assume adding a new custom machine named LS1046AXX based on LS1046A SoC, follow the steps below:
```
1. Run 'flex-builder -i repo-fetch' to fetch all git repositories of LSDK components for the first time

2. Add new machine support in U-Boot, take LSDK-21.08 for example
   $ cd components/firmware/uboot
   then add U-Boot patches for new LS1046AXX board
   Assume config file components/firmware/u-boot/configs/ls1046axx_tfa_defconfig is added for LS1046AXX,
   configure "LS1046AXX: y" under CONFIG_MACHINE in configs/sdk.yml
   $ cd components/firmware/atf
   $ git checkout LSDK-21.08 -b LSDK-21.08-LS1046AXX
   then add ATF patches for new LS1046AXX
   Run 'flex-builder -c atf -m ls1046axx -b sd' to build ATF image with u-boot for SD boot on LS1046AXX

3. Add new machine support in Linux kernel, take LSDK-21.08 for example
   $ cd components/linux/linux
   $ git checkout LSDK-21.08 -b LSDK-21.08-LS1046AXX
   then add kernel patches for new machine and commit all the patches in this branch and make a tag as below
   $ git tag LSDK-21.08-LS1046AXX
   Assume a new device tree file fsl-ls1046axx.dts is added in components/linux/linux/arch/arm64/boot/dts directory
   Run 'flex-builder -c linux:linux:LSDK-21.08-LS1046AXX' to build kernel image for new LS1046AXX board.

4. Add configs in flexbuild for new machine
   - Add ls1046axx node in configs/linux/linux_arm64_LS.its
   - Set linux new tag/branch to LSDK-21.08-LS1046AXX and set uboot new tag/branch to LSDK-21.08-LS1046AXX in configs/sdk.yml
   - optionally, user can use different memory layout from default settings by modifying it in configs/board/common/layerscape_memorylayout.cfg
   - Add manifest for new machine
     $ mkdir configs/board/ls1046axx
     $ cp configs/board/ls1046ardb/manifest configs/board/ls1046axx
     Update the settings in configs/board/ls1046axx/manifest on demand
     Note: generally, user can reuse the settings of rcw, fman, qe, eth-phy used for existing ls1046ardb if those components
           are same for new ls1046axx, otherwise user needs to add new RCW config support in components/firmware/rcw/ls1046axx.
   Run 'flex-builder -i mkitb -r yocto:tiny' to generate lsdk2108_yocto_tiny_LS_arm64.itb image
   Run 'flex-builder -c bin_firmware' to generate the shared fman/qe/eth-phy images for new ls1046axx
   Run 'flex-builder -i mkfw -m ls1046axx -b sd' to generate firmware_ls1046axx_sdboot.img
   user can boot the new lsdk2108_yocto_tiny_LS_arm64.itb from U-Boot prompt during debugging stage on LS1046AXX machine
   => tftp a0000000 lsdk2108_yocto_tiny_LS_arm64.itb
   => bootm a0000000#ls1046axx

5. Build all other images for new custom machine with lsdk userland if needed
   $ flex-builder -i mkrfs
   $ flex-builder -c apps
   $ flex-builder -i mkboot
   $ flex-builder -i merge-component
   $ flex-builder -i packrfs
   Finally, install boot_LS_arm64_lts_<version>.tgz and rootfs_lsdk_<version>_<arch>.tgz to
   SD/USB/SATA storage drive on LS1046AXX machine by flex-installer.
```



## How to program LSDK separate image to different bank of NOR/QSPI/FlexSPI flash device
If you need to flash different image (e.g. atf bl2, atf fip, dtb, kernel, etc) to current or other bank to evaluate
certain feature on Layerscape board, for example, to evaluate TDM feature with non-default RCW image on LS1043ARDB:
```
1. Replace the default rcw_1600.bin with rcw_1600_qetdm.bin (or other rcw you want) in configs/board/ls1043ardb/manifest
2. re-generate ATF image (RCW image is included in ATF BL2 image, RCW image can't be flashed separately)
     $ flex-builder -c atf -m ls1043ardb -b nor
3. copy the new BL2 image build/firmware/atf/ls1043ardb/bl2_nor.pbl to directory flash_images/ls1043ardb on the bootpartition of SD card
4. run the following commands under uboot prompt on ls1043ardb
=> setenv bd_type mmc
=> setenv bd_part 0:2
=> setenv bank other
=> ls $bd_type $bd_part flash_images/ls1043ardb
=> setenv img bl2
=> setenv bl2_img flash_images/ls1043ardb/bl2_nor.pbl
=> load $bd_type $bd_part $load_addr flash_images.scr
=> source $load_addr
- To flash single image, set u-boot env variable 'img' to one of following: bl2, fip, mcfw, mcdpc, mcdpl, fman, qe, pfe, phy, dtb or kernel
- To flash all images to current or other bank, set u-boot env variable 'img' to all by command 'setenv img all'
  You can override the default setting of variable bd_part, flash_type, bl2_img, fip_img, dtb_img, kernel_itb,
  qe_img, fman_img, phy_img, mcfw_img, mcdpl_img, mcdpc_img before running source $load_addr if necessary.
```
