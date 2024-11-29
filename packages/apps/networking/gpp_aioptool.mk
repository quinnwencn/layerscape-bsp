# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: gpp_aioptool
gpp_aioptool:
ifeq ($(CONFIG_APP_GPP_AIOPTOOL), "y")
ifeq ($(DESTARCH),arm64)
	@$(call fbprint_b,"gpp_aioptool") && \
	 $(call fetch-git-tree,gpp_aioptool,apps/networking) && \
	 cd $(NETDIR)/gpp_aioptool && \
	 sed -i '/libio.h/d' flib/mc/fsl_mc_sys.h && \
	 $(MAKE) clean && \
	 $(MAKE) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"gpp_aioptool")
endif
endif
