# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK Networking Components


.PHONY: dce
dce:
ifeq ($(CONFIG_APP_DCE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = desktop -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"dce") && \
	 $(call fetch-git-tree,dce,apps/networking) && \
	 cd $(NETDIR)/dce && \
	 if [ ! -f lib/qbman_userspace/Makefile ]; then \
	     git submodule update; \
	 fi && \
	 $(MAKE) ARCH=aarch64 && \
	 $(MAKE) install && \
	 $(call fbprint_d,"dce")
endif
endif
