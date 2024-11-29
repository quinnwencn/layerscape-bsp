# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: restool
restool:
ifeq ($(CONFIG_APP_RESTOOL), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = desktop ] && exit || \
	 $(call fbprint_b,"restool") && \
	 $(call fetch-git-tree,restool,apps/networking) && \
	 cd $(NETDIR)/restool && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) -j$(JOBS) install && \
	 $(call fbprint_d,"restool")
endif
endif
