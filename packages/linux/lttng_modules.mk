# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


.PHONY: lttng_modules
lttng_modules:
	@$(call fetch-git-tree,lttng_modules,linux) && \
	 $(call fetch-git-tree,$(KERNEL_TREE),linux) && \
	 curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir && \
	 if ! grep CONFIG_STACKTRACE=y $$opdir/.config 1>/dev/null 2>&1; then \
	     flex-builder -c linux -B fragment:lttng.config -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 cd $(PACKAGES_PATH)/linux/lttng_modules && \
	 $(call fbprint_b,"LTTng modules") && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) KERNELDIR=$(KERNEL_PATH) O=$$opdir modules_install && \
	 $(call fbprint_d,"LTTng modules")
