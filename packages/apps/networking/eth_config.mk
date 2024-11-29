# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: eth_config
eth_config:
ifeq ($(CONFIG_APP_ETH_CONFIG), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROSCALE) = desktop -o $(DISTROTYPE) = centos -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"eth_config") && \
	 $(call fetch-git-tree,eth_config,apps/networking) && \
	 mkdir -p $(DESTDIR)/etc/fmc/config && \
	 cd $(NETDIR)/eth_config && \
	 cp -rf private $(DESTDIR)/etc/fmc/config && \
	 cp -rf shared_mac $(DESTDIR)/etc/fmc/config && \
	 $(call fbprint_d,"eth_config")
endif
endif
