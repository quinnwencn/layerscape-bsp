## Flexbuild Usage

```
$ cd flexbuild
$ source setup.env
$ flex-builder -h
```

```
Usage: flex-builder -c <component> [-a <arch>] [-f <config-file>]
   or: flex-builder -i <instruction> [-m <machine>] [-a <arch>] [-r <distro_type>:<distro_scale>] [-f <cfg>]
```

Most used example with automated build:
```
  flex-builder -m ls1043ardb                  # automatically build all firmware, linux, apps components and ubuntu-based rootfs for single ls1043ardb
  flex-builder -i auto                        # automatically build all firmware, linux, apps components and ubuntu-based rootfs for all arm64 machines
```

Most used example with separate command:
```
 flex-builder -i mkfw -m <machine>           # generate composite firmware (contains atf, u-boot, peripheral firmware, kernel, dtb, tinylinux rootfs, etc)
 flex-builder -i mkallfw                     # generate composite firmware for all arm64 machines
 flex-builder -i mkrfs                       # generate Ubuntu main arm64 userland, equivalent to "-i mkrfs -r ubuntu:main -a arm64" by default
 flex-builder -i mkrfs -r ubuntu:desktop     # generate Ubuntu desktop arm64 userland
 flex-builder -i mkrfs -r ubuntu:lite        # generate Ubuntu lite arm64 userland
 flex-builder -i mkrfs -r yocto:tiny         # generate Yocto-based arm64 tiny userland
 flex-builder -i mkrfs -r buildroot:tiny     # generate Buildroot-based arm64 tiny userland
 flex-builder -i mkrfs -r centos             # generate CentOS arm64 userland
 flex-builder -i mkitb -r yocto:tiny         # generate lsdk_yocto_tiny_LS_arm64.itb including rootfs_<sdk_version>_yocto_tiny_arm64.cpio.gz
 flex-builder -c <component>                 # compile <component> or <subsystem> (e.g. dpdk,weston,linux,networking,graphics,security,etc)
 flex-builder -c linux                       # compile linux kernel for all arm64 machines, equivalent to "-i compile -c linux -a arm64" by default
 flex-builder -c atf -m ls1046ardb -b sd     # compile atf image for SD boot on LS1046ardb
 flex-builder -i mkboot                      # generate boot partition tarball (contains kernel, dtb, modules, distro boot script, etc) for deployment
 flex-builder -i merge-component             # merge component packages into target arm64 userland
 flex-builder -i packrfs                     # pack and compress target rootfs as rootfs_<sdk_version>_ubuntu_main_arm64.tgz
 flex-builder -i packapp                     # pack and compress target app components as app_components_LS_arm64.tgz
 flex-builder -i download -m ls1043ardb      # download prebuilt distro images for specific machine
 flex-builder -i repo-fetch                  # fetch all git repositories of components from remote repos if not exist locally
 flex-builder -i repo-update                 # update all components to the latest TOP commmits of current branches
 flex-builder -i mkdistroscr                 # generate distro boot script
 flex-builder docker                         # create or attach Ubuntu docker container to run flex-builder in docker
 flex-builder clean                          # clean all obsolete firmware/linux/apps image except distro rootfs
 flex-builder clean-rfs                      # clean distro rootfs, '-r ubuntu:main -a arm64' by default
 flex-builder clean-firmware                 # clean obsolete firmware image
 flex-builder clean-apps                     # clean obsolete apps component binary image
 flex-builder clean-linux                    # clean obsolete linux image
```

The supported options:
```
  -m, --machine         target machine, supports ls1012afrwy,ls1021atwr,ls1028ardb,ls1043ardb,ls1046ardb,ls2088ardb,lx2160ardb_rev2,lx2162aqds,imx8mnevk,imx8mpevk,etc
  -a, --arch            target architect, valid argument: arm64, arm64:be, arm32, arm32:be, ppc64, ppc32, arm64 as default if unspecified
  -b, --boottype        type of boot media, valid argument: sd, emmc, qspi, xspi, nor, nand, default all types if unspecified
  -c, --component       compile the specified subsystem or component, e.g. firmware, apps, linux, networking, graphics, security, atf, rcw, uboot, dpdk,
                        ovs_dpdk, vpp, fmc, tsntool, weston, xserser, armnn, tflite, etc
  -i, --instruction     instruction to do for dedicated purpose, valid argument as below:
      mkfw              generate composite firmware (contains atf, u-boot, peripheral firmware, kernel, dtb, tinylinux rootfs, etc)
      mkallfw           generate composite firmware for all platforms
      mkitb             generate <sdk_version>_<distro_type>_<distro_scale>_<portfolio>_<arch>.itb
      mkboot            generate boot partition tarball (contains kernel, modules, dtb, distro boot script, secure boot header, etc)
      mkrfs             generate target rootfs, associated with -r, -a and -p options for different distro type and architecture
      mkdistroscr       generate distro autoboot script for all or single machine
      mkflashscr        generate U-Boot script of flashing images for all machines
      signimg           sign various images and generate secure boot header for the specified machine
      merge-component   merge custom component packages and kernel modules into target distro rootfs
      auto              automatically build all firmware, kernel, apps components and distro userland
      clean             clean all the obsolete images except distro rootfs
      clean-firmware    clean obsolete firmware images generated in build/firmware directory
      clean-linux       clean obsolete linux images generated in build/linux directory
      clean-apps        clean obsolete apps images
      clean-rfs         clean target rootfs
      packrfs           pack and compress distro rootfs as .tgz
      packapps          pack and compress apps components as .tgz
      repo-fetch        fetch single or all git repositories if not exist locally
      repo-branch       set single or all git repositories to specified branch
      repo-update       update single or all git repositories to latest HEAD
      repo-commit       set single or all git repositories to specified commit
      repo-tag          set single or all git repositories to specified tag
      rfsraw2ext        convert raw rootfs to ext4 rootfs
      list              list enabled config, machines and components
  -p, --portfolio       specify portfolio of SoC, valid argument: LS or IMX, default LS if unspecified
  -f, --cfgfile         specify config file, configs/sdk.yml is used by default if only the file exists
  -B, --buildarg        secondary argument for various build commands
  -r, --rootfs          specify flavor of target rootfs, valid argument: ubuntu|debian|centos|yocto|buildroot:main|desktop|devel|lite|tiny
  -j, --jobs            number of parallel build jobs, default 16 jobs if unspecified
  -s, --secure          enable security feature in case of secure boot without IMA/EVM
  -t, --ima-evm         enable IMA/EVM feature in case of secure boot with IMA/EVM
  -T, --cot             specify COT (Chain of Trust) type for secure boot, valid argument: arm-cot, arm-cot-with-verified-boot, nxp-cot
  -e, --encapsulation   enable encapsulation and decapsulation feature for chain of trust with confidentiality in case secure boot
  -v, --version         print the version of flexbuild
  -h, --help            print help info
```



## How to build composite firmware
The composite firmware consists of RCW/PBL, ATF BL2, ATF BL31, BL32 OPTEE, BL33 U-Boot/UEFI, bootloader environment variables,
secure boot headers, Ethernet firmware, dtb, kernel and tiny initrd rootfs, etc, this composite firmware can be programmed at
offset 0x0 in NOR/QSPI/FlexSPI flash device or at offset 4k (LS) or 1k/32k/33k (I.MX) in SD/eMMC card.
```
Usage: flex-builder -i mkfw -m <machine> [-b <boottype>]
Example:
$ flex-builder -i mkfw -m ls1046ardb        # generate all boot types composite firmware_ls1046ardb_<boottype>.img
$ flex-builder -i mkfw -m ls1046ardb -b sd  # generate specified boot type composite firmware_ls1046ardb_sdboot.img
$ flex-builder -i mkfw -m imx6qsabresd      # generate composite firmware_imx6qsabresd_sdboot.img
$ flex-builder -i mkfw -m imx8mpevk         # generate composite firmware_imx8mpevk_sdboot.img
```


## How to build boot partition tarball
```
Usage: flex-builder -i <instruction> [ -p <portfolio> ] [ -a <arch> ]
Examples:
$ flex-builder -i mkboot                   # generate boot_LS_arm64_lts_5.10.tgz for arm64 Layerscape platforms
$ flex-builder -i mkboot -a arm32          # generate boot_LS_arm32_lts_5.10.tgz for arm32 Layerscape platforms
$ flex-builder -i mkboot -p IMX            # generate boot_IMX_arm64_lts_5.10.tgz for arm64 iMX platforms
$ flex-builder -i mkboot -p IMX -a arm32   # generate boot_IMX_arm32_lts_5.10.tgz for arm32 iMX platforms
```


## How to build linux itb FIT image
```
$ flex-builder -i mkitb -r yocto:tiny          # generate yocto-based tiny <sdk_version>_yocto_tiny_LS_arm64.itb
$ flex-builder -i mkitb -r yocto:tiny -a arm32 # generate yocto-based tiny <sdk_version>_yocto_tiny_LS_arm32.itb
$ flex-builder -i mkitb -r ubuntu:lite         # generate Ubuntu-based lite <sdk_version>_ubuntu_lite_LS_arm64.itb
$ flex-builder -i mkitb -r yocto:tiny -p IMX   # generate yocto-based tiny <sdk_version>_yocto_tiny_IMX_arm64.itb
$ flex-builder -i mkitb -r ubuntu:lite -p IMX  # generate ubuntu-based lite <sdk_version>_ubuntu_lite_IMX_arm64.itb
```


## How to build Linux kernel and modules
To build linux with default repo and current branch according to default config
```
Usage: flex-builder -c linux [ -a <arch> ] [ -p <portfolio> ]
Examples:
$ flex-builder -c linux                         # for arm64 Layerscape platforms by default
$ flex-builder -c linux -a arm32                # for arm32 Layerscape platform
$ flex-builder -c linux -a arm64 -p IMX         # for arm64 i.MX platforms
$ flex-builder -c linux -a arm32 -p IMX         # for arm32 i.MX platforms
```

To build linux with the specified kernel repo and branch/tag according to default kernel config
```
Usage: flex-builder -c linux:<kernel_repo>:<branch|tag|commit> [ -a <arch> ]
Examples:
$ flex-builder -c linux:linux-lts-nxp:lf-5.10.y
$ flex-builder -c linux:linux:LSDK-21.08
```

To customize kernel options with the default repo and current branch in interactive menu
```
$ flex-builder -c linux:custom                 # generate a customized .config
$ flex-builder -c linux                        # compile kernel and modules according to the generated .config above
```

To build custom linux with the specified kernel repo and branch/tag according to default config and the appended fragment config
```
Usage: flex-builder -c linux [ :<kernel_repo>:<tag|branch> ] -B fragment:<xx.config> [ -a <arch> ]
Examples:
$ flex-builder -c linux -B fragment:ima_evm_arm64.config
$ flex-builder -c linux -B fragment:"ima_evm_arm64.config lttng.config"
$ flex-builder -c linux:linux:LSDK-21.08 -B fragment:lttng.config
```




## How to build ATF (TF-A)
```
Usage: flex-builder -c atf [ -m <machine> ] [ -b <boottype> ] [ -s ] [ -B bootloader ]
Examples:
$ flex-builder -c atf -m ls1028ardb -b sd             # build U-Boot based ATF image for SD boot on ls1028ardb
$ flex-builder -c atf -m ls1046ardb -b qspi           # build U-Boot based ATF image for QSPI boot on ls1046ardb
$ flex-builder -c atf -m ls2088ardb -b nor -s         # build U-Boot based ATF image for secure IFC-NOR boot on ls2088ardb
$ flex-builder -c atf -m lx2160ardb -b xspi -B uefi   # build UEFI based ATF image for FlexSPI-NOR boot on lx2160ardb
```
flex-builder can automatically build the dependent RCW, U-Boot/UEFI, OPTEE and CST before building ATF to generate target images.
Note 1: If you want to specify different RCW configuration instead of the default one, first modify variable rcw_<boottype> in
        configs/board/<machine>/manifest, then run 'flex-builder -c rcw -m <machine>' to generate new RCW image.
Note 2: The '-s' option is used for secure boot, FUSE_PROVISIONING are not enabled by default, you can change
        CONFIG_FUSE_PROVISIONING:n to y in configs/sdk.yml to enable it if needed.



## How to build U-Boot
```
Usage:   flex-builder -c uboot -m <machine>
Examples:
$ flex-builder -c uboot -m ls2088ardb                 # build U-Boot image for ls2088ardb
$ flex-builder -c uboot -m imx6qsabresd               # build U-Boot image for imx6qsabresd
$ flex-builder -c uboot -m imx8mpevk                  # build U-Boot image for imx8mpevk
```



## How to build various firmware components
```
Usage: flex-builder -c <component> [ -b <boottype> ]
Examples:
$ flex-builder -c rcw -m ls1046ardb                   # build RCW images for ls1046ardb
$ flex-builder -c mc_utils                            # build mc_utils image
$ flex-builder -c bin_firmware                        # build binary fm_ucode, qe_ucode, mc_bin, phy_cortina, pfe_bin, etc
```


## How to build APP components
The supported APP components: restool, tsntool, gpp_aioptool, dpdk, pktgen_dpdk, ovs_dpdk, flib, fmlib, fmc, spc, openssl, cst, aiopsl,
ceetm, qbman_userspace, eth_config, crconf, optee_os, optee_client, optee_test, libpkcs11, secure_obj, eiq, opencv, tflite, armcl,
flatbuffer, onnx, onnxruntime, etc.
```
Usage: flex-builder -c <component> [ -a <arch> ] [ -r <distro_type>:<distro_scale> ]
Examples:
$ flex-builder -c apps                                # build all apps components against arm64 Ubuntu main userland by default
$ flex-builder -c apps -r yocto:devel                 # build apps components against arm64 Yocto-based userland
$ flex-builder -c apps -r buildroot:devel             # build all apps components against arm64 buildroot-based userland
$ flex-builder -c fmc -a arm64                        # build FMC component against arm64 Ubuntu main userland
$ flex-builder -c fmc -a arm32                        # build FMC component against arm32 Ubuntu main userland
$ flex-builder -c dpdk -r ubuntu:main                 # build DPDK component against Ubuntu main userland
$ flex-builder -c dpdk -r yocto:devel                 # build DPDK component against Yocto devel userland
$ flex-builder -c weston -r ubuntu:desktop            # build weston component
$ flex-builder -c xserver -r ubuntu:desktop           # build xserver component
$ flex-builder -c optee_os                            # build optee_os component
$ flex-builder -c tflite                              # build tensorflow lite
  (note: '-r ubuntu:main -a arm64' is the default if unspecified)
```




## Manage git repositories of various components
```
Usage: flex-builder -i <instruction> [ -B <args> ]
Examples:
$ flex-builder -i repo-fetch                          # git clone source repositories of all components
$ flex-builder -i repo-fetch -c dpdk                  # git clone source repository for DPDK
$ flex-builder -i repo-branch                         # switch branches of all components to specified branches according to the config file
$ flex-builder -i repo-tag                            # switch tags of all components to specified tags according to default config
$ flex-builder -i repo-commit                         # set all components to the specified commmits of current branches
$ flex-builder -i repo-update                         # update all components to the latest HEAD commmit of current branches 
```



## How to use different build config instead of the default config
User can create a custom config file configs/custom.yml, flex-builder will preferentially select custom.yml, otherwise, if there
is a config file configs/sdk_internal.yml, it will be used. In case there is only configs/sdk.yml, it will be used.
If there are multiple config files in configs directory, user can specify the expected one by specifying '-f <cfg>' option.
Example:
```
$ flex-builder -m ls1043ardb -f custom.yml
$ flex-builder -m ls1028ardb -f test.yml
$ flex-builder -m imx8mpevk -f sdk.yml
```



## How to add new application component/package in Flexbuild
```
- Add a new "<app_name>: y" under CONFIG_APP and configure repo url/branch/tag in configs/sdk.yml,
  user can directly create the new component git repository in components/apps/<category> directory before the new git repo is ready.
- Add makefile object support for the new component in packages/apps/<category>/<component>.mk
- Run 'flex-builder -c <component> -r <distro_type:distro_scale> -a <arch>' to build new component against the target <arch> rootfs.
- Run 'flex-builder -i merge-component -r <distro_type:distro_scale> -a <arch>' to merger new component package into the target <arch> rootfs.
- Run 'flex-builder -i packrfs -r <distro_type:distro_scale> -a <arch>' to pack the target <arch> rootfs.
  (note: '-r ubuntu:main -a arm64' is the default if unspecified)
```




## How to configurate different packages/components path and images output path instead of the default path for sharing with multi-users
The default packages path is <flexbuild_dir>/packages, the default images output path is <flexbuild_dir>/build, there are two ways to
change the default path:
Way1: set PACKAGES_PATH and/or FBOUTDIR in environment variable as below:
```
$ export PACKAGES_PATH=<path>
$ export FBOUTDIR=<path>
```
Way2: modify DEFAULT_PACKAGES_PATH and/or DEFAULT_OUT_PATH in <flexbuild_dir>/configs/sdk.yml
