# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




.PHONY: iperf
iperf:
ifeq ($(CONFIG_APP_IPERF), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"iperf") && \
	 $(call fetch-git-tree,iperf,apps/generic) && \
	 cd $(GENDIR)/iperf && \
	 export CC=aarch64-linux-gnu-gcc && \
	 export CXX=aarch64-linux-gnu-g++ && \
	 ./configure --host=aarch64 && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install DESTDIR=$(DESTDIR) && \
	 $(call fbprint_d,"iperf")
endif
endif
