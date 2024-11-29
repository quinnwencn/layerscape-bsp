# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: aquantia_firmware_utility
aquantia_firmware_utility:
ifeq ($(CONFIG_APP_AQUANTIA_FIRMWARE_UTILITY), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = desktop ] && exit || \
	 $(call fbprint_b,"aquantia_firmware_utility") && \
	 $(call fetch-git-tree,aquantia_firmware_utility,apps/networking) && \
	 cd $(NETDIR)/aquantia_firmware_utility && \
	 $(MAKE) -j$(JOBS) && \
	 cp -f aq-firmware-tool $(DESTDIR)/usr/local/bin && \
	 $(call fbprint_d,"aquantia_firmware_utility")
endif
endif
