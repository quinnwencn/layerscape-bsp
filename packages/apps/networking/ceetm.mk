# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: ceetm
ceetm:
ifeq ($(CONFIG_APP_CEETM), "y")
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) = desktop -o $(DISTROSCALE) = lite ] && exit || \
	 $(call fbprint_b,"CEETM") && \
	 $(call fetch-git-tree,ceetm,apps/networking) && \
	 cd $(NETDIR)/ceetm && \
	 if [ ! -f iproute2-4.15.0/tc/tc_util.h ]; then \
	     wget --no-check-certificate $(repo_iproute2_src_url) && tar xzf iproute2-4.15.0.tar.gz; \
	 fi && \
	 export IPROUTE2_DIR=$(NETDIR)/ceetm/iproute2-4.15.0 && \
	 $(MAKE) clean && \
	 $(MAKE) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"CEETM")
endif
