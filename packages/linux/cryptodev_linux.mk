# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


.PHONY: cryptodev_linux
cryptodev_linux:
ifeq ($(CONFIG_KERL_CRYPTODEV_LINUX), "y")
	@[ "$(BUILDARG)" = custom ] && exit || \
	 $(call fetch-git-tree,cryptodev_linux,linux) && \
	 $(call fetch-git-tree,linux,linux) && \
	 cd $(PACKAGES_PATH)/linux && \
	 if [ ! -d $(FBOUTDIR)/linux/kernel/$(DESTARCH)/$(SOCFAMILY) ]; then \
	     flex-builder -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && \
	 cd $(PACKAGES_PATH)/linux/cryptodev_linux && \
	 $(call fbprint_b,"CRYPTODEV_LINUX") && \
	 export KERNEL_MAKE_OPTS="-lcrypto -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 $(MAKE) KERNEL_DIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) install KERNEL_DIR=$(KERNEL_PATH) O=$$opdir INSTALL_MOD_PATH=$$opdir/tmp && \
	 $(call fbprint_d,"CRYPTODEV_LINUX")
endif
