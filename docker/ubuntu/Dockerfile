FROM ubuntu:20.04
MAINTAINER Shengzhou Liu <shengzhou.liu@nxp.com>

ARG USER_ID=1002
ARG USER_NAME=builder

ARG http_proxy
ENV http_proxy $http_proxy
ARG https_proxy
ENV https_proxy $https_proxy
ARG no_proxy
ENV no_proxy $no_proxy
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN echo "Acquire::http::proxy \"$http_proxy\";" | tee -a /etc/apt/apt.conf && \
    echo "Acquire::https::proxy \"$https_proxy\";" | tee -a /etc/apt/apt.conf && \
    echo 'PS1="[\u@\h \W]\$ "' | tee -a /root/.bashrc 1>/dev/null
RUN rm -rf /var/lib/apt/lists/* && apt autoclean
RUN apt-get update --fix-missing && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && export LANG=en_US.utf8

RUN apt-get install -y \
        u-boot-tools device-tree-compiler autoconf automake dh-autoreconf libssl-dev zip \
        openssl curl flex bison bc git gcc vim ethtool wget ftp make makedev tclsh ccache \
        binfmt-support qemu-system-common qemu-user-static debootstrap sudo ncurses-dev  \
        gcc-arm-linux-gnueabihf crossbuild-essential-arm64 gcc-aarch64-linux-gnu file    \
        build-essential gdb u-boot-tools device-tree-compiler python3 python3-dev python3-pip \
        libxml2-dev libsensors4-dev libssl-dev libedit-dev liblzma-dev tree binutils-dev \
        libnuma-dev libpcap-dev libtool mtd-utils libncurses5-dev libelf-dev net-tools   \
        libcunit1-dev pkg-config autotools-dev crossbuild-essential-armhf openssh-server \
        openssh-client crossbuild-essential-armhf qemu-utils kmod g++-aarch64-linux-gnu  \
	cpp-arm-linux-gnueabihf dosfstools ruby iputils-ping cpio rsync libtclap-dev     \
	parted rpm2cpio lsb-release xutils-dev libwayland-bin cmake locales texinfo gawk \
	chrpath diffstat scons libgflags-dev libhdf5-serial-dev python3-numpy python3-wheel \
	python3-h5py

RUN ln -sf /usr/bin/python3 /usr/bin/python && pip3 install six

RUN echo "quinn ALL = NOPASSWD: /usr/bin/apt-get" >> /etc/sudoers
RUN groupadd -g $USER_ID builder
RUN useradd -m -s /bin/bash -u $USER_ID $USER_NAME && echo "${USER_NAME}:${USER_NAME}" | chpasswd
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
USER $USER_NAME
RUN echo "export LANG=en_US.UTF-8" >> ~/.bashrc
RUN echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
WORKDIR /home/$USER_NAME
RUN git config --global user.email "quinnwen.cn@gmail.com" && git config --global user.name "Quinn Wen"
