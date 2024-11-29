# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


.PHONY: wayland
wayland:
ifeq ($(CONFIG_APP_WAYLAND), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"wayland") && $(call fetch-git-tree,wayland,apps/graphics) && \
	 if [ $(DISTROTYPE) != ubuntu ]; then echo wayland is not supported on $(DISTROTYPE) yet; exit; fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && cd $(GRAPHICSDIR)/wayland && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu --disable-documentation --with-host-scanner && \
	 $(MAKE) && $(MAKE) install && $(call fbprint_d,"wayland")
endif
endif


.PHONY: wayland_protocols
wayland_protocols:
ifeq ($(CONFIG_APP_WAYLAND_PROTOCOLS), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"wayland_protocols") && $(call fetch-git-tree,wayland_protocols,apps/graphics) && \
	 cd $(GRAPHICSDIR)/wayland_protocols && ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 $(MAKE) && $(MAKE) install && $(call fbprint_d,"wayland_protocols")
endif
endif
