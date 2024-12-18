# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: fmc
fmc:
ifeq ($(CONFIG_APP_FMC), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) = centos -o $(DISTROSCALE) = desktop -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"fmc") && \
	 $(call fetch-git-tree,fmc,apps/networking) && \
	 if [ $(DISTROTYPE) = ubuntu -o $(DISTROTYPE) = yocto -o $(DISTROTYPE) = debian ]; then \
	     xmlhdr=$(RFSDIR)/usr/include/libxml2; \
	 elif [ $(DISTROTYPE) = buildroot ]; then \
	     xmlhdr=$(RFSDIR)/../host/include/libxml2; \
	 fi && \
	 if [ ! -d $(NETDIR)/fmlib/include/fmd/Peripherals -o ! -f $(DESTDIR)/lib/libfm-arm.a ]; then \
	     flex-builder -c fmlib -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $$xmlhdr/libxml/parser.h ]; then \
	     flex-builder -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(KERNEL_PATH)/include/uapi/linux/fmd ]; then \
	     flex-builder -c linux -a $(DESTARCH) -p $(SOCFAMILY) -f $(CFGLISTYML); \
	 fi && \
	 export LDFLAGS="-L$(RFSDIR)/usr/lib -Wl,-rpath=$(RFSDIR)/usr/lib:$(RFSDIR)/lib:$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 export CFLAGS="-I$(RFSDIR)/usr/include/aarch64-linux-gnu -I$(NETDIR)/fmlib/include/fmd \
		-I$(NETDIR)/fmlib/include/fmd/Peripherals -I$(NETDIR)/fmlib/include/fmd/integrations" && \
	 cd $(NETDIR)/fmc && \
	 $(MAKE) clean -C source && \
	 $(MAKE) FMD_USPACE_HEADER_PATH=$(KERNEL_PATH)/include/uapi/linux/fmd \
		 FMLIB_HEADER_PATH=$(NETDIR)/fmlib/include \
		 LIBXML2_HEADER_PATH=$$xmlhdr \
		 FMD_USPACE_LIB_PATH=$(DESTDIR)/lib TCLAP_HEADER_PATH=$(RFSDIR)/usr/include \
		 CXX=$(CROSS_COMPILE)g++ CC=$(CROSS_COMPILE)gcc -C source && \
	 install -d $(DESTDIR)/usr/local/bin && \
	 install -m 755 source/fmc $(DESTDIR)/usr/local/bin/fmc && \
	 install -d $(DESTDIR)/etc/fmc/config && \
	 install -m 644 etc/fmc/config/hxs_pdl_v3.xml $(DESTDIR)/etc/fmc/config && \
	 install -m 644 etc/fmc/config/netpcd.xsd $(DESTDIR)/etc/fmc/config && \
	 install -d $(DESTDIR)/usr/local/include/fmc && \
	 install source/fmc.h $(DESTDIR)/usr/local/include/fmc && \
	 install -d $(DESTDIR)/usr/local/lib/aarch64-linux-gnu && \
	 install source/libfmc.a $(DESTDIR)/usr/local/lib/aarch64-linux-gnu && \
	 install -d $(DESTDIR)/usr/local/fmc/ && \
	 install -m 755 $(FBDIR)/packages/rfs/misc/fmc/init-ls104xa $(DESTDIR)/usr/local/fmc && \
	 install -d $(DESTDIR)/lib/systemd/system/ && \
	 install -d $(DESTDIR)/etc/systemd/system/multi-user.target.wants/ && \
	 install -m 644 $(FBDIR)/packages/rfs/misc/fmc/fmc.service $(DESTDIR)/lib/systemd/system/ && \
	 ln -sf /lib/systemd/system/fmc.service $(DESTDIR)/etc/systemd/system/multi-user.target.wants/fmc.service && \
	 $(call fbprint_d,"fmc")
endif
endif
