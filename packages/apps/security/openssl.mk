# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




.PHONY: openssl
openssl:
ifeq ($(CONFIG_APP_OPENSSL), "y")
	@[ $(DISTROTYPE) != ubuntu -a $(DISTROTYPE) != yocto -o \
	   $(DISTROSCALE) = lite -o $(DISTROSCALE) = tiny ] && exit || \
	 if [ $(DESTARCH) = arm64 ]; then \
	     archopt=linux-aarch64; \
	 elif [ $(DESTARCH) = arm32 ]; then \
	     archopt=linux-armv4; \
	 else \
	     $(call fbprint_e,"$(DESTARCH) is not supported for openssl"); exit; \
	 fi && \
	 $(call fbprint_b,"OpenSSL") && \
	 $(call fetch-git-tree,openssl,apps/security) && \
	 if [ ! -d $(DESTDIR)/usr/local/include/crypto ]; then \
	     flex-builder -c cryptodev_linux -a $(DESTARCH) -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cd $(SECDIR)/openssl && \
	 ./Configure enable-devcryptoeng $$archopt shared \
		     -I$(DESTDIR)/usr/local/include \
		     --prefix=/usr/local \
		     --openssldir=lib/ssl && \
	 $(MAKE) clean 2>/dev/null && \
	 $(MAKE) depend && \
	 $(MAKE) 1>/dev/null && \
	 $(MAKE) install DESTDIR=$(DESTDIR) 1>/dev/null && \
	 rm -fr $(DESTDIR)/usr/local/lib/ssl/{certs,openssl.cnf,private} && \
	 ln -s /etc/ssl/certs/ $(DESTDIR)/usr/local/lib/ssl/ && \
	 ln -s /etc/ssl/private/ $(DESTDIR)/usr/local/lib/ssl/ && \
	 ln -s /etc/ssl/openssl.cnf $(DESTDIR)/usr/local/lib/ssl/ && \
	 $(call fbprint_d,"OpenSSL")
endif
