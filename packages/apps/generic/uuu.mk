# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# UUU (Universal Update Utility), mfgtools

.PHONY: uuu
uuu:
ifeq ($(CONFIG_APP_UUU), "y")
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"UUU") && \
	 $(call fetch-git-tree,uuu,apps/generic) && \
	 cd $(GENDIR)/uuu && \
	 cmake -Wno-dev . && \
	 $(MAKE) && \
	 install uuu/uuu $(FBDIR)/tools && \
	 install uuu/uuu $(FBOUTDIR)/images && \
	 $(call fbprint_d,"UUU")
endif
