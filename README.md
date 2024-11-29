# Overview 
This is a repository download from https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/pex/5500/1/flexbuild_lsdk2108.tgz. The original sdk.yml contains invalid link for dependencies and I fix it here. Feel free to use it under original license from NXP.

## Flexbuild Overview
Flexbuild is a component-oriented build framework and integration platform
with capabilities of flexible, ease-to-use, scalable system build and
distro deployment.

With flex-builder, users can easily build linux, u-boot, atf and miscellaneous
userspace applications (e.g. networking, graphics, multimedia, security, AI/ML)
and customizable distro root filesystem to streamline the system build with
efficient CI/CD.

With flex-installer, users can easily install various distro to target storage
device (SD/eMMC card or USB/SATA disk) on target board or on host machine.


## Build Environment
- Cross-build on x86 host machine running Ubuntu
- Native-build on ARM board running Ubuntu
- Build in Docker container hosted on any machine running any distro


## Supported distros for target arm64/arm32
- Ubuntu-based userland   (main, desktop, devel, lite)
- Debian-based userland   (main, desktop, devel, lite)
- CentOS-based userland   (7.9.2009)
- Yocto-based userland    (tiny, devel)
- Buildroot-based userland (tiny, devel)


## Supported platforms
Layerscape: ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb,
            ls1046afrwy, ls1088ardb_pb, ls2088ardb, ls2160ardb_rev2, lx2162aqds.

iMX:        imx6qpsabresd, imx6qsabresd, imx6sllevk, imx7ulpevk, imx8mmevk, imx8mnevk,
            imx8mpevk, imx8mqevk, imx8qmmek, imx8qxpmek


## More info
See docs/flexbuild_usage.md, docs/build_and_deploy_distro.md, docs/lsdk_build_install.md for detailed information.
