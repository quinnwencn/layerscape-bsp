# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: crconf
crconf:
ifeq ($(CONFIG_APP_CRCONF), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"crconf") && \
	 $(call fetch-git-tree,crconf,apps/security) && \
	 sed -i -e 's/CC =/CC ?=/' -e 's/DESTDIR=/DESTDIR?=/' $(SECDIR)/crconf/Makefile && \
	 cd $(SECDIR)/crconf && \
	 export CC=$(CROSS_COMPILE)gcc && \
	 export DESTDIR=${DESTDIR}/usr/local && \
	 $(MAKE) clean && \
	 $(MAKE) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"crconf")
endif
endif
