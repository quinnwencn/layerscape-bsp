# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


.PHONY: flib
flib:
ifeq ($(CONFIG_APP_FLIB), "y")
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"flib") && \
	 $(call fetch-git-tree,flib,apps/networking) && \
	 $(MAKE) -C $(NETDIR)/flib install && \
	 $(call fbprint_d,"flib")
endif
endif
