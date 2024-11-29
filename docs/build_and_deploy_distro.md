## Build and Deploy Various Distro

flex-builder supports generating various distro in different scale, including rich OS (Ubuntu-based, Debian-based, CentOS-based)
and embedded OS(Yocto-based and Buildroot-based distro). Users can choose an appropriate distro according to demand as below:

```
Usage: flex-builder -i mkrfs [ -r <distro_type>:<distro_scale> ] [ -a <arch> ]
$ flex-builder -i mkrfs -r ubuntu:main          # generate ubuntu-based main userland for as per extra_main_packages_list for networking
$ flex-builder -i mkrfs -r ubuntu:desktop       # generate Ubuntu-based desktop userland with main packages and gnome desktop for multimedia
$ flex-builder -i mkrfs -r ubuntu:devel         # generate Ubuntu-based devel userland with more main and universe packages for development
$ flex-builder -i mkrfs -r ubuntu:lite          # generate Ubuntu-based lite userland with base packages
$ flex-builder -i mkrfs -r debian:main          # generate Debian-based main userland with main packages
$ flex-builder -i mkrfs -r centos               # generate CentOS-based arm64 userland
$ flex-builder -i mkrfs -r yocto:tiny           # generate Yocto-based tiny arm64 userland
$ flex-builder -i mkrfs -r yocto:devel          # generate Yocto-based devel arm64 userland
$ flex-builder -i mkrfs -r buildroot:tiny       # generate Buildroot-based tiny arm64 userland
$ flex-builder -i mkrfs -r buildroot:devel      # generate Buildroot-based devel arm64 userland
```
To quickly install a new apt package to target Ubuntu-based arm64 userland on host machine, run the command as below
```
$ sudo chroot build/rfs/rootfs_<sdk_version>_ubuntu_main_arm64 apt install <package>
```


Example: Build and deploy ubuntu-based main distro
```
$ flex-builder -i mkrfs                # generate ubuntu-based main userland, '-r ubuntu:main -a arm64' by default if unspecified
$ flex-builder -i mkboot               # genrate boot_LS_arm64_lts_5.10.tgz
$ flex-builder -c apps                 # build all apps components
$ flex-builder -i merge-component      # merge app components into target userland
$ flex-builder -i packrfs              # pack and compress target userland as .tgz
$ flex-builder -i mkfw -m ls1046ardb   # generate composite firmware_ls1046ardb_<boottype>.img
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_ubuntu_main_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -d /dev/sdx
or
$ flex-installer -r rootfs_<sdk_version>_ubuntu_main_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/sdx
```
Note: The '-f <firmware> option is used for SD boot only'.



Example: Build and deploy Ubuntu-based desktop distro for graphics scenario
```
$ flex-builder -i mkrfs -r ubuntu:desktop
$ flex-builder -c apps -r ubuntu:desktop
$ flex-builder -i mkboot  ('-p LS' for Layerscapes by default, specify '-p IMX' for iMX platforms)
$ flex-builder -i merge-component -r ubuntu:desktop
$ flex-builder -i packrfs -r ubuntu:desktop
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_ubuntu_desktop_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -d /dev/sdx
```


Example: Build and deploy Ubuntu lite distro
```
$ flex-builder -i mkrfs -r ubuntu:lite
$ flex-builder -i mkboot
$ flex-builder -i merge-component -r ubuntu:lite
$ flex-builder -i packrfs -r ubuntu:lite
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_ubuntu_lite_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -d /dev/sdx
```
You can modify the default extra_lite_packages_list in configs/ubuntu/extra_packages_list to customize packages.



Example: Build and deploy Yocto-based distro
```
Usage: flex-builder -i mkrfs -r yocto:<distro_scale> [ -a <arch> ]
The <distro_scale> can be tiny, devel,   <arch> can be arm32, arm64
$ flex-builder -i mkrfs -r yocto:tiny
$ flex-builder -i mkfw -m ls1046ardb
$ flex-builder -i mkboot
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_yocto_tiny_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/sdx
```
You can customize extra packages to IMAGE_INSTALL_append in configs/yocto/local_arm64_<distro_scale>.conf, if you want to install
more packages(e.g. dpdk, etc) in yocto userland, you can choose devel instead of tiny. Additionally, you can add yocto
recipes for customizing package in packages/rfs/misc/yocto/recipes-support directory, or you can add your own app component in 
packages/apps/<category>/<component>.mk to integrate the new component into target Yocto-based rootfs.



Example: Build and deploy Buildroot-based distro
```
Usage: flex-builder -i mkrfs -r buildroot:<distro_scale> -a <arch>
The <distro_scale> can be tiny, devel, imaevm,  <arch> can be arm32, arm64
$ flex-builder -i mkrfs -r buildroot:devel:custom      # customize buildroot .config in interactive menu for arm64 arch
$ flex-builder -i mkrfs -r buildroot:devel             # generate buildroot userland
$ flex-builder -i mkrfs -r buildroot:tiny              # generate arm64 rootfs as per arm64_tiny_defconfig
$ flex-builder -i mkrfs -r buildroot:devel -a arm32    # generate arm32 rootfs as per arm32_devel_defconfig
$ flex-builder -i mkrfs -r buildroot:imaevm            # generate arm64 rootfs as per arm64_imaevm_defconfig
$ flex-builder -i mkfw -m ls1046ardb -b sd
$ flex-builder -i mkboot
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_buildroot_tiny_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0
```
You can modify configs/buildroot/qoriq_<arch>_<distro_scale>_defconfig to customize various packages



Example: Build and deploy CentOS-based distro
```
Usage:   flex-builder -i mkrfs -r centos [ -a <arch> ]
$ flex-builder -i mkrfs -r centos
$ flex-builder -i mkboot
$ flex-builder -i merge-component -r centos
$ flex-builder -i packrfs -r centos
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_centos_7.9.2009_arm64.tgz -b boot_LS_arm64_lts_5.10.tgz -d /dev/sdx
```
