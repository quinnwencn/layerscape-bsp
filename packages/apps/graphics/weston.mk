# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



.PHONY: weston
weston:
ifeq ($(CONFIG_APP_WESTON), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"weston") && \
	 $(call fetch-git-tree,weston,apps/graphics) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     flex-builder -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/libdrm ]; then \
	     flex-builder -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/wayland-client.h ]; then \
	     flex-builder -c wayland -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/share/wayland-protocols ]; then \
	     flex-builder -c wayland_protocols -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/EGL ]; then \
	     flex-builder -c gpulib -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 cd $(GRAPHICSDIR)/weston && \
	 rm -rf arm64_build && mkdir arm64_build && \
	 sudo cp -Prf --preserve=mode,timestamps $(DESTDIR)/usr/* $(RFSDIR)/usr/ && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a72%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/packages/rfs/misc/meson/cross-compilation.conf > $(GRAPHICSDIR)/weston/arm64_build/cross-compilation.conf && \
	 \
	 PKG_CONFIG_LIBDIR=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig \
	 PYTHONNOUSERSITE=y PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 meson arm64_build  \
		--cross-file=arm64_build/cross-compilation.conf \
		--prefix=/usr --libdir=lib --default-library=shared --buildtype=release \
		-Ddoc=false -Dbackend-drm-screencast-vaapi=false -Dbackend-rdp=false -Dcolor-management-lcms=false \
		-Dcolor-management-colord=false -Dpipewire=false -Dbackend-drm=true -Dbackend-x11=false -Drenderer-g2d=false -Degl=true \
		-Dimage-jpeg=false  -Dimage-webp=false -Dweston-launch=false -Dlauncher-logind=false -Dremoting=false -Ddemo-clients=false \
		-Dsystemd=true -Dimxgpu=true -Dbackend-wayland=true -Dbackend-fbdev=false \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/local/include -I$(RFSDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -lgbm" && \
	 ninja install -j$(JOBS) -C arm64_build && \
	 echo OPTARGS=\" \" | sudo tee $(RFSDIR)/etc/default/weston && \
	 sudo install -d $(RFSDIR)/etc/xdg/weston && \
	 if [ $(SOCFAMILY) = IMX ]; then \
	     sudo sed -e 's%DP%HDMI-A%g' $(FBDIR)/packages/rfs/misc/weston/weston.ini > $(RFSDIR)/etc/xdg/weston/weston.ini; \
	 else \
	     sudo cp $(FBDIR)/packages/rfs/misc/weston/weston.ini $(RFSDIR)/etc/xdg/weston/weston.ini; \
	 fi && \
	 sudo install -m 755 $(FBDIR)/packages/rfs/misc/weston/weston.sh $(RFSDIR)/etc/profile.d/ && \
	 sudo install -m 644 $(FBDIR)/packages/rfs/misc/weston/weston.service $(RFSDIR)/lib/systemd/system/ && \
	 sudo ln -sf /lib/systemd/system/weston.service $(RFSDIR)/etc/systemd/system/multi-user.target.wants/weston.service && \
	 $(call fbprint_d,"weston")
endif
endif
