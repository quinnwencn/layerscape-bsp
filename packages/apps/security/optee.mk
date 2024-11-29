# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



optee: optee_os optee_client optee_test


.PHONY: optee_os
optee_os:
ifeq ($(CONFIG_APP_OPTEE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_os") && \
	 $(call fetch-git-tree,optee_os,apps/security) && \
	 if ! `pip3 show -q pycryptodomex`; then \
	     pip3 install pycryptodomex; \
	 fi && \
	 if [ $(MACHINE) = all ]; then \
	    exit; \
	 else \
	     cd $(SECDIR)/optee_os && \
	     if [ $(SOCFAMILY) = LS ]; then \
		 if [ $(MACHINE) = ls1088ardb_pb ]; then \
		     brd=ls1088ardb; \
		 elif [ $(MACHINE) = lx2160ardb_rev2 ]; then \
		     brd=lx2160ardb; \
		 elif [ $(MACHINE) = lx2162aqds ]; then \
	             brd=lx2160aqds; \
		 elif [ $(MACHINE) = ls1046afrwy ]; then \
		     brd=ls1046ardb; \
		 else \
		     brd=$(MACHINE); \
		 fi && \
		 $(MAKE) CFG_ARM64_core=y PLATFORM=ls-$$brd ARCH=arm \
		         CFG_TEE_CORE_LOG_LEVEL=1 CFG_TEE_TA_LOG_LEVEL=0 && \
		 mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-ls/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/ && \
		 if [ $(MACHINE) = ls1012afrwy ]; then \
		     mv out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}_512mb.bin && \
		     $(MAKE) -j$(JOBS) CFG_ARM64_core=y PLATFORM=ls-ls1012afrwy ARCH=arm CFG_DRAM0_SIZE=0x40000000 && \
		     mv out/arm-plat-ls/core/tee-raw.bin out/arm-plat-ls/core/tee_$${MACHINE:0:10}.bin; \
		 fi; \
	     elif [ $(SOCFAMILY) = IMX ]; then \
		 brd=$${MACHINE:1} && \
		 $(MAKE) PLATFORM=imx PLATFORM_FLAVOR=$$brd ARCH=arm CFG_TEE_TA_LOG_LEVEL=0 CFG_TEE_CORE_LOG_LEVEL=0 && \
		 $(CROSS_COMPILE)objcopy -v -O binary out/arm-plat-imx/core/tee.elf out/arm-plat-imx/core/tee_$(MACHINE).bin && \
		 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
		 cp -f out/arm-plat-imx/export-ta_arm64/ta/*.ta $(DESTDIR)/usr/lib/optee_armtz/; \
	     fi; \
	fi && \
	$(call fbprint_d,"optee_os")
endif
else
	@$(call fbprint_w,INFO: OPTEE is not enabled by default)
endif




.PHONY: optee_client
optee_client:
ifeq ($(CONFIG_APP_OPTEE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_client") && \
	 $(call fetch-git-tree,optee_client,apps/security) && \
	 cd $(SECDIR)/optee_client && \
	 $(MAKE) -j$(JOBS) ARCH=arm64 && \
	 mkdir -p $(DESTDIR)/usr/local/lib && \
	 ln -sf $(DESTDIR)/lib/libteec.so $(DESTDIR)/usr/local/lib/libteec.so && \
	 $(call fbprint_d,"optee_client")
endif
else
	@$(call fbprint_w,INFO: OPTEE is not enabled by default)
endif




.PHONY: optee_test
optee_test:
ifeq ($(CONFIG_APP_OPTEE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = tiny -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"optee_test") && \
	 $(call fetch-git-tree,optee_test,apps/security) && \
	 if [ ! -f $(DESTDIR)/lib/libteec.so.1.0 ]; then \
	     flex-builder -c optee_client -m $(MACHINE); \
	 fi && \
	 if [ ! -d $(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 ]; then \
	     flex-builder -c optee_os -m ls1028ardb -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cd $(SECDIR)/optee_test && \
	 export CC=${CROSS_COMPILE}gcc && \
	 $(MAKE) CFG_ARM64=y OPTEE_CLIENT_EXPORT=$(DESTDIR)/usr \
	         TA_DEV_KIT_DIR=$(SECDIR)/optee_os/out/arm-plat-ls/export-ta_arm64 && \
	 mkdir -p $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/ta/*/*.ta $(DESTDIR)/usr/lib/optee_armtz && \
	 cp $(SECDIR)/optee_test/out/xtest/xtest $(DESTDIR)/usr/bin && \
	 mkdir -p $(DESTDIR)/usr/lib/tee-supplicant/plugins && \
	 cp $(SECDIR)/optee_test/out/supp_plugin/*.plugin $(DESTDIR)/usr/lib/tee-supplicant/plugins/ && \
	 $(call fbprint_d,"optee_test")
endif
else
	@$(call fbprint_w,INFO: OPTEE is not enabled by default)
endif
