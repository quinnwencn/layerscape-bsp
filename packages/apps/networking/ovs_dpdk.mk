# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


.PHONY: ovs_dpdk
ovs_dpdk:
ifeq ($(CONFIG_APP_OVS_DPDK), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != main ] && exit || \
	 $(call fbprint_b,"ovs_dpdk") && \
	 $(call fetch-git-tree,ovs_dpdk,apps/networking) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     flex-builder -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/local/dpdk ]; then \
	     flex-builder -c dpdk -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
         if [ ! -f $(RFSDIR)/usr/local/include/rte_config.h ]; then \
	     sudo cp -af $(DESTDIR)/usr/local/include/rte_*.h $(RFSDIR)/usr/local/include/ && \
             sudo cp -rf $(DESTDIR)/usr/local/include/generic $(RFSDIR)/usr/local/include/; \
         fi && \
	 cd $(NETDIR)/ovs_dpdk && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export LDFLAGS="-L$(RFSDIR)/lib/aarch64-linux-gnu -L$(RFSDIR)/lib -L$(RFSDIR)/usr/lib -L$(DESTDIR)/usr/local/lib/" && \
	 export LIBS="$(shell PKG_CONFIG_PATH=$(DESTDIR)/usr/local/lib/pkgconfig $(CROSS)pkg-config --libs libdpdk)" && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/local/lib/pkgconfig && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 ./boot.sh && \
	 ./configure --prefix=/usr/local --host=aarch64-linux-gnu --with-dpdk=static --disable-ssl --disable-libcapng && \
	 $(MAKE) -j$(JOBS) 'CFLAGS=-g -Ofast' install && \
	 $(call fbprint_d,"ovs_dpdk")
endif
endif
