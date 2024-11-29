#
# Copyright 2018-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#


.PHONY: atf
atf:
ifeq ($(CONFIG_FW_ATF), "y")
	@$(call fetch-git-tree,atf,firmware) && \
	 $(call fetch-git-tree,mbedtls,firmware) && \
	 $(call fetch-git-tree,uboot,firmware) && \
	 if [ -z "$(BOOTTYPE)" ]; then $(call fbprint_w,"Please specify '-b <boottype>'") && exit 0; fi && \
	 cd $(FWDIR)/atf && \
	 curbrch=`git branch | grep ^* | cut -d' ' -f2` && \
	 $(call fbprint_n,"Building ATF $$curbrch" for $(MACHINE)) && \
	 $(MAKE) realclean && mkdir -p $(FBOUTDIR)/firmware/atf/$(MACHINE); \
	 if [ $(MACHINE) = ls1088ardb_pb -o $${MACHINE:0:7} = lx2160a ]; then \
	     platform=$${MACHINE:0:10}; \
	 else \
	     platform=$(MACHINE); \
	 fi; \
	 [ $${platform:0:6} = ls1012 -o $${platform:0:5} = ls104 ] && chassistype=ls104x_1012 || chassistype=ls2088_1088; \
	 if [ "$(SECURE)" = y -a "$(BL33TYPE)" = uboot ]; then \
	     if [ $$chassistype = ls104x_1012 ]; then \
		 rcwbin=`grep ^rcw_$(BOOTTYPE)_sec= $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d'"' -f2`; \
	     else \
		 rcwbin=`grep ^rcw_$(BOOTTYPE)= $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d'"' -f2`; \
	     fi; \
	     if [ ! -f $(PACKAGES_PATH)/firmware/atf/ddr4_pmu_train_dmem.bin ]; then \
		 flex-builder -c ddr_phy_bin -f $(CFGLISTYML); \
	     fi && \
	     if [ "$(COT)" = arm-cot -o "$(COT)" = arm-cot-with-verified-boot ]; then \
		 secureopt="TRUSTED_BOARD_BOOT=1 CST_DIR=$(PACKAGES_PATH)/apps/security/cst \
			    GENERATE_COT=1 MBEDTLS_DIR=$(PACKAGES_PATH)/firmware/mbedtls"; \
		 outputdir="arm-cot"; \
		 mkdir -p $$outputdir build/$$platform/release; \
		 [ -f $$outputdir/rot_key.pem ] && cp -f $$outputdir/*.pem build/$$platform/release/; \
		 if [ "$(COT)" = arm-cot-with-verified-boot ]; then \
		     if [ ! -f keys/dev.key ]; then \
			[ ! -f ~/.rnd ] && cd ~ && openssl rand -writerand .rnd && cd -; \
			mkdir -p keys; openssl genpkey -algorithm RSA -out keys/dev.key -pkeyopt \
					       rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:65537; \
			openssl req -batch -new -x509 -key keys/dev.key -out keys/dev.crt; \
		     fi; \
		     cp -rf keys/* $(FBOUTDIR)/firmware/atf/$$platform/; \
		     ubootcfg=$${platform}_tfa_verified_boot_defconfig; \
		     bl33=$(FBOUTDIR)/firmware/atf/$$platform/u-boot-combined-dtb.bin; \
		     secext=_sec_verified_boot; \
		 else \
		     ubootcfg=$${platform}_tfa_SECURE_BOOT_defconfig; \
		     bl33=$(FBOUTDIR)/firmware/u-boot/$${platform}/uboot_$${platform}_tfa_SECURE_BOOT.bin; \
		     secext=_sec; \
		 fi; \
		 ubootcfg=$(PACKAGES_PATH)/firmware/$(UBOOT_TREE)/configs/$$ubootcfg; \
	     else \
		 secureopt="TRUSTED_BOARD_BOOT=1 CST_DIR=$(PACKAGES_PATH)/apps/security/cst"; \
		 outputdir="nxp-cot" && mkdir -p $$outputdir; \
		 ubootcfg=$(PACKAGES_PATH)/firmware/$(UBOOT_TREE)/configs/$${platform}_tfa_SECURE_BOOT_defconfig; \
		 bl33=$(FBOUTDIR)/firmware/u-boot/$${platform}/uboot_$${platform}_tfa_SECURE_BOOT.bin; \
		 secext=_sec; \
	     fi; \
	     [ ! -f $(PACKAGES_PATH)/apps/security/cst/srk.pub ] && flex-builder -c cst -f $(CFGLISTYML); \
	     cp -f $(PACKAGES_PATH)/apps/security/cst/srk.* $(PACKAGES_PATH)/firmware/atf; \
	 else \
	     if [ $(BL33TYPE) = uboot -a $(SOCFAMILY) = LS ]; then \
		 ubootcfg=$(PACKAGES_PATH)/firmware/$(UBOOT_TREE)/configs/$${platform}_tfa_defconfig; \
		 bl33=$(FBOUTDIR)/firmware/u-boot/$${platform}/uboot_$${platform}_tfa.bin; \
	     elif [ $(BL33TYPE) = uefi -a $(SOCFAMILY) = LS ]; then \
		 bl33=`grep ^uefi_$(BOOTTYPE) $(FBDIR)/configs/board/$${MACHINE:0:10}/manifest | cut -d'"' -f2`; \
		 if [ -z "$$bl33" ]; then exit; fi; \
		 bl33=$(FBOUTDIR)/$$bl33; \
	     fi; \
	     rcwbin=`grep ^rcw_$(BOOTTYPE)= $(FBDIR)/configs/board/$(MACHINE)/manifest | cut -d'"' -f2`; \
	 fi && \
	 if [ -z "$$rcwbin" -a $(SOCFAMILY) = LS ]; then echo $(MACHINE) $(BOOTTYPE)boot$$secext is not supported && exit 0; fi && \
	 rcwbin=$(FBOUTDIR)/$$rcwbin && \
	 if [ -n "$(rcw_bin)" ]; then rcwbin=$(FBOUTDIR)/firmware/rcw/$(rcw_bin); fi && \
	 if [ $(SOCFAMILY) = LS ]; then \
	    if [ ! -f $$rcwbin ] || `cd $(FWDIR)/rcw && git status -s|grep -qiE 'M|A|D' && cd - 1>/dev/null`; then \
		echo building dependent rcw ...; \
		flex-builder -c rcw -m $(MACHINE) -f $(CFGLISTYML); \
		test -f $$rcwbin || { $(call fbprint_e,"$$rcwbin not exist"); exit;} \
	    fi; \
	 fi; \
	 if [ "$(CONFIG_FUSE_PROVISIONING)" = y ]; then \
	     fusefile=$(PACKAGES_PATH)/apps/security/cst/fuse_scr.bin && \
	     fuseopt="fip_fuse FUSE_PROG=1 FUSE_PROV_FILE=$$fusefile" && \
	     if [ ! -d $(PACKAGES_PATH)/packages/apps/security/cst ]; then flex-builder -c cst -f $(CFGLISTYML); fi && \
	     $(call fbprint_b,"dependent fuse_scr.bin") && \
	     cd $(PACKAGES_PATH)/apps/security/cst && ./gen_fusescr input_files/gen_fusescr/$$chassistype/input_fuse_file && cd -; \
	 fi; \
	 if [ "$(CONFIG_APP_OPTEE)" = y ]; then \
	     if [ $$platform = lx2162aqds ] || ! `echo $$platform|grep -q 'qds'`; then \
		[ $(SOCFAMILY) = LS ] && platsoc=arm-plat-ls || platsoc=arm-plat-imx; \
		bl32=$(PACKAGES_PATH)/apps/security/optee_os/out/$$platsoc/core/tee_$${MACHINE:0:10}.bin; \
		bl32opt="BL32=$$bl32" && spdopt="SPD=opteed"; \
		[ ! -f $$bl32 ] && flex-builder -c optee_os -m $$platform -f $(CFGLISTYML); \
	     fi; \
	 fi; \
	 if [ $(BL33TYPE) = uboot -a $(SOCFAMILY) = LS ]; then \
	    if [ ! -f $$bl33 ] || [[ `cd $(FWDIR)/$(UBOOT_TREE) && git status -s|grep -qiE 'M|A|D' && cd - 1>/dev/null` ]]; then \
		echo building dependent $$bl33 ...; \
		if [ ! -f $$ubootcfg ]; then \
		    $(call fbprint_e,Not found the dependent $$ubootcfg) && exit; \
		fi; \
		flex-builder -c uboot -m $$platform -b tfa -f $(CFGLISTYML); \
	    fi; \
	 elif [ $(BL33TYPE) = uefi ]; then \
	    [ ! -f $$bl33 ] && flex-builder -c uefi_bin -m $$platform -f $(CFGLISTYML); \
	 fi; \
	 if [ -z "$$bl32opt" ]; then echo BL32=NULL as OPTEE is not enabled; fi && \
	 if [ $(BOOTTYPE) = xspi ]; then bootmode=flexspi_nor; else bootmode=$(BOOTTYPE); fi && \
	 if [ $(SOCFAMILY) = LS ]; then \
	     echo $(MAKE) -j$(JOBS) fip pbl PLAT=$$platform BOOT_MODE=$$bootmode RCW=$$rcwbin \
		  BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt && \
	     $(MAKE) -j$(JOBS) fip pbl PLAT=$$platform BOOT_MODE=$$bootmode \
		     RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt && \
	     if [ $${MACHINE:0:5} = lx216 -a "$(SECURE)" = y ] && [ ! -f $$outputdir/ddr_fip_sec.bin ]; then \
		 $(MAKE) -j$(JOBS) fip_ddr PLAT=$$platform BOOT_MODE=$$bootmode $$secureopt \
		 $$fuseopt DDR_PHY_BIN_PATH=$(PACKAGES_PATH)/firmware/ddr_phy_bin/lx2160a; \
		 [ "$(COT)" = arm-cot -o "$(COT)" = arm-cot-with-verified-boot ] && cp -f build/$$platform/release/*.pem $$outputdir/; \
		 cp -f build/$$platform/release/ddr_fip_sec.bin $$outputdir/; \
	     fi && \
	     [ $${MACHINE:0:5} = lx216 -a "$(SECURE)" = y -a -f $$outputdir/ddr_fip_sec.bin ] && \
	     cp -f $$outputdir/ddr_fip_sec.bin $(FBOUTDIR)/firmware/atf/$(MACHINE)/fip_ddr_sec.bin; \
	     cp -f build/$$platform/release/bl2_$$bootmode*.pbl $(FBOUTDIR)/firmware/atf/$(MACHINE)/ && \
	     cp -f build/$$platform/release/fip.bin $(FBOUTDIR)/firmware/atf/$(MACHINE)/fip_$(BL33TYPE)$$secext.bin && \
	     if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		 cp -f build/$$platform/release/fuse_fip.bin $(FBOUTDIR)/firmware/atf/$(MACHINE)/fuse_fip$$secext.bin; \
	     fi && \
             if [ $(MACHINE) = ls1012afrwy ]; then \
		 bl32=$(PACKAGES_PATH)/apps/security/optee_os/out/arm-plat-ls/core/tee_ls1012afrw_512mb.bin && bl32opt="BL32=$$bl32" && \
		 $(MAKE) realclean && $(MAKE) all fip pbl PLAT=ls1012afrwy_512mb \
		 BOOT_MODE=$$bootmode RCW=$$rcwbin BL33=$$bl33 $$bl32opt $$spdopt $$secureopt $$fuseopt && \
		 mkdir -p $(FBOUTDIR)/firmware/atf/ls1012afrwy_512mb && \
		 cp -f build/ls1012afrwy_512mb/release/bl2_$$bootmode*.pbl $(FBOUTDIR)/firmware/atf/ls1012afrwy_512mb/ && \
		 cp -f build/ls1012afrwy_512mb/release/fip.bin $(FBOUTDIR)/firmware/atf/ls1012afrwy_512mb/fip_uboot$$secext.bin && \
		 if [ "$(CONFIG_FUSE_PROVISIONING)" = "y" ]; then \
		    cp -f build/ls1012afrwy_512mb/release/fuse_fip.bin $(FBOUTDIR)/firmware/atf/ls1012afrwy_512mb/fuse_fip$$secext.bin; \
		 fi; \
             fi && \
	     if [ "$(COT)" = arm-cot-with-verified-boot ]; then \
		 [ ! -f $(FBOUTDIR)/images/linux_LS_arm64_signature.itb ] && flex-builder -i mkitb -r yocto:tiny -f $(CFGLISTYML); \
		 ./mkimage -F $(FBOUTDIR)/images/linux_LS_arm64_signature.itb -k keys -K u-boot.dtb -c "Sign the FIT Image" -r; \
		 chmod 644 $(FBOUTDIR)/images/linux_LS_arm64_signature.itb; \
	     fi; \
	 elif [ $(SOCFAMILY) = IMX ]; then \
	    $(MAKE) -j$(JOBS) PLAT=$${MACHINE:0:6} bl31 && \
	    mkdir -p $(FBOUTDIR)/firmware/atf/$(MACHINE) && \
	    cp -f build/$${MACHINE:0:6}/release/bl31.bin $(FBOUTDIR)/firmware/atf/$(MACHINE)/; \
	 fi && \
	 ls -l $(FBOUTDIR)/firmware/atf/$(MACHINE)/* && \
	 $(call fbprint_d,"ATF for $(MACHINE) $${bootmode} boot")
endif
