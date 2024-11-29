#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


include imx_mkimage.mk


.PHONY: u-boot
uboot u-boot:
ifeq ($(CONFIG_FW_UBOOT), "y")
	@$(call fetch-git-tree,uboot,firmware)
	@curbrch=`cd $(FWDIR)/$(UBOOT_TREE) && git branch | grep ^* | cut -d' ' -f2` && \
	 $(call fbprint_n,"Building u-boot $$curbrch for $(MACHINE)") && \
	 cd $(FWDIR) && \
	 if [ "$(BOOTTYPE)" = tfa -a "$(COT)" = arm-cot-with-verified-boot ]; then \
	     uboot_cfg=$(MACHINE)_tfa_verified_boot_defconfig; \
	 elif [ -n "$(UBOOT_CONFIG)" ]; then \
	     uboot_cfg="$(UBOOT_CONFIG)"; \
	 elif [ "$(BOOTTYPE)" = tfa -a "$(SECURE)" = y ]; then \
	     uboot_cfg=$(MACHINE)_tfa_SECURE_BOOT_defconfig; \
	 elif [ "$(BOOTTYPE)" = tfa ]; then \
	     uboot_cfg=$(MACHINE)_tfa_defconfig; \
	 fi; \
	 for cfg in $$uboot_cfg; do \
	     $(call build-uboot-target,$$cfg) \
	 done



define build-uboot-target
	if echo $1 | grep -qE 'ls1021a|^mx'; then \
	    export ARCH=arm && export CROSS_COMPILE=arm-linux-gnueabihf-; \
	else \
	    export ARCH=arm64 && export CROSS_COMPILE=aarch64-linux-gnu-; \
	fi && \
	if [ $(MACHINE) != all ]; then brd=$(MACHINE); fi && \
	if [ $$brd = ls1088ardb_pb ]; then brd=ls1088ardb; fi && \
	if [ $${brd:0:7} = lx2160a ]; then brd=$${brd:0:10}; fi && \
	opdir=$(FBOUTDIR)/firmware/u-boot/$$brd/output/$1 && mkdir -p $$opdir && \
	$(call fbprint_n,"config = $1") && \
	\
	$(MAKE) -C $(FWDIR)/$(UBOOT_TREE) -j$(JOBS) O=$$opdir $1 && \
	$(MAKE) -C $(FWDIR)/$(UBOOT_TREE) -j$(JOBS) O=$$opdir && \
	\
	if echo $1 | grep -iqE 'sdcard|nand'; then \
	   [ -f $$opdir/u-boot-with-spl-pbl.bin ] && srcbin=u-boot-with-spl-pbl.bin || srcbin=u-boot-with-spl.bin; \
	   if echo $1 | grep -iqE 'SECURE_BOOT'; then \
		if echo $1 | grep -iqE 'sdcard'; then \
		   cp $$opdir/spl/u-boot-spl.bin $(FBOUTDIR)/firmware/u-boot/$$brd/uboot_$${brd}_sdcard_spl.bin ; \
		   cp $$opdir/u-boot-dtb.bin $(FBOUTDIR)/firmware/u-boot/$$brd/uboot_$${brd}_sdcard_dtb.bin ; \
		elif echo $1 | grep -iqE 'nand'; then \
		   cp $$opdir/spl/u-boot-spl.bin $(FBOUTDIR)/firmware/u-boot/$$brd/uboot_$${brd}_nand_spl.bin ; \
		   cp $$opdir/u-boot-dtb.bin $(FBOUTDIR)/firmware/u-boot/$$brd/uboot_$${brd}_nand_dtb.bin ; \
		fi; \
	   fi; \
	   tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
	elif echo $1 | grep -iqE 'verified_boot'; then \
	    mkdir -p $(FBOUTDIR)/firmware/atf/$$brd; \
	    cat $$opdir/u-boot-nodtb.bin $$opdir/u-boot.dtb > $$opdir/u-boot-combined-dtb.bin; \
	    cp -f $$opdir/u-boot-nodtb.bin $$opdir/u-boot.dtb $$opdir/u-boot-combined-dtb.bin $(FBOUTDIR)/firmware/atf/$$brd/; \
	    cp -f $$opdir/u-boot.dtb $$opdir/tools/mkimage $(FWDIR)/atf/; \
	    srcbin=u-boot-combined-dtb.bin; \
	else \
	    srcbin=u-boot.bin; \
	    tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
	fi;  \
	\
	if echo $1 | grep -q ^ls1021a && [ ! -d $(FBOUTDIR)/firmware/rcw/$(MACHINE) ]; then \
	    flex-builder -c rcw -m $(MACHINE) -f $(CFGLISTYML); \
	fi && \
	if echo $1 | grep -qE ^imx8; then \
	    flex-builder -c atf -m $(MACHINE) -b sd -f $(CFGLISTYML) && \
	    $(call imx_mkimage_target, $1) \
	elif echo $1 | grep -qiE "mx6|mx7"; then \
	    cp $$opdir/u-boot-dtb.imx $(FBOUTDIR)/firmware/u-boot/$$brd/; \
	else \
	    cp $$opdir/$$srcbin $(FBOUTDIR)/firmware/u-boot/$$brd/$$tgtbin ; \
	fi && \
	$(call fbprint_d,"u-boot for $$brd in $(FBOUTDIR)/firmware/u-boot/$$brd");
endef

endif
