# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX HANTRO VPU library

.PHONY: imxvpu

imxvpu:
ifeq ($(CONFIG_APP_IMXVPU), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop -o $(SOCFAMILY) != IMX ] && exit || true && \
	 mkdir -p $(MMDIR) && cd $(MMDIR) && \
	 if [ ! -d $(MMDIR)/imx-vpu-hantro ]; then \
	     wget -q $(repo_vpu_hantro_bin_url) -O vpu_hantro.bin && chmod +x vpu_hantro.bin && \
	     ./vpu_hantro.bin --auto-accept && \
	     mv imx-vpu-hantro-* imx-vpu-hantro && rm -f vpu_hantro.bin; \
	 fi && \
	 mkdir -p $(DESTDIR)/usr/include/imx/linux $(DESTDIR)/usr/include/linux && \
	 incdir=$(KERNEL_PATH)/usr/include/linux && \
	 cp -t $(DESTDIR)/usr/include/imx/linux $$incdir/hantrodec.h $$incdir/ipu.h $$incdir/dma-buf.h \
	    $$incdir/hx280enc.h $$incdir/isl29023.h $$incdir/imx_vpu.h $$incdir/mxc*.h \
	    $$incdir/pxp_device.h $$incdir/pxp_dma.h $$incdir/videodev2.h && \
	 cp $(KERNEL_PATH)/drivers/staging/android/uapi/ion.h $(DESTDIR)/usr/include/linux/ && \
	 cd imx-vpu-hantro && \
	 $(MAKE) clean && unset ARCH && \
	 $(MAKE) all SDKTARGETSYSROOT=$(DESTDIR) PLATFORM=IMX8MM CROSS=aarch64-linux-gnu- && \
	 $(MAKE) install DEST_DIR=$(DESTDIR) PLATFORM=IMX8MM libdir=/usr/lib; \
	 \
	 if [ ! -d $(MMDIR)/imx-vpu-hantro-vc ]; then \
	     mkdir -p $(MMDIR) && cd $(MMDIR) && \
	     wget -q $(repo_vpu_hantro_vc_bin_url) -O vpu_hantro_vc.bin && \
	     chmod +x vpu_hantro_vc.bin && \
	     ./vpu_hantro_vc.bin --auto-accept && \
	     mv imx-vpu-hantro-vc-* imx-vpu-hantro-vc && rm -f vpu_hantro_vc.bin; \
	 fi && \
	 mkdir -p $(DESTDIR)/opt && \
	 cp -rf $(MMDIR)/imx-vpu-hantro-vc/usr $(DESTDIR)/ && \
	 cp -rf $(MMDIR)/imx-vpu-hantro-vc/unit_tests $(DESTDIR) && \
	 $(call fbprint_d,"imxvpu")
endif
endif
