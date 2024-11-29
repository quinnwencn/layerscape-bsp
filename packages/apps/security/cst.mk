# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: cst
cst:
ifeq ($(CONFIG_APP_CST), "y")
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o $(DISTROSCALE) = tiny ] && exit || \
	 $(call fbprint_b,"CST") && \
	 $(call fetch-git-tree,cst,apps/security) && \
	 cd $(SECDIR)/cst && \
	 $(MAKE) -j$(JOBS) && \
	 if [ -n "$(SECURE_PRI_KEY)" ]; then \
	     echo Using specified $(SECURE_PRI_KEY) and $(SECURE_PUB_KEY) ... ; \
	     cp -f $(SECURE_PRI_KEY) $(SECDIR)/cst/srk.pri; \
	     cp -f $(SECURE_PUB_KEY) $(SECDIR)/cst/srk.pub; \
	 elif [ ! -f srk.pri -o ! -f srk.pub ]; then \
	     ./gen_keys 1024 && echo "Generated new keys!"; \
	 else \
	     echo "Using default keys srk.pri and srk.pub"; \
	 fi && \
	 $(call fbprint_d,"CST")
endif
