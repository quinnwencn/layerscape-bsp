# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: fmlib
fmlib:
ifeq ($(CONFIG_APP_FMLIB), "y")
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"fmlib") && \
	 $(call fetch-git-tree,fmlib,apps/networking) && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then \
	     flex-builder -c linux -f $(CFGLISTYML); \
	 fi && \
	 cd $(NETDIR)/fmlib && \
	 export KERNEL_SRC=$(KERNEL_PATH) && \
	 $(MAKE) clean && $(MAKE) && \
	 $(MAKE) install-libfm-arm && \
	 $(call fbprint_d,"fmlib")
endif
endif
