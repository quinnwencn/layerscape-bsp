# Copyright 2020-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


define imx_mkimage_target
    if [ ! -d $(FWDIR)/imx_mkimage ]; then \
	$(call fetch-git-tree,imx_mkimage,firmware); \
    fi && \
    if [ ! -d $(FWDIR)/firmware-imx ]; then \
	cd $(FWDIR) && echo Downloading $(repo_firmware_imx_bin_url) && \
	wget -q $(repo_firmware_imx_bin_url) -O firmware_imx.bin && chmod +x firmware_imx.bin && \
	./firmware_imx.bin --auto-accept && mv firmware-imx* firmware-imx && rm -f firmware_imx.bin; \
    fi && \
    if [ ! -d $(FWDIR)/imx-seco/firmware/seco ]; then \
	cd $(FWDIR) && echo Downloading $(repo_seco_bin_url) && \
	wget -q $(repo_seco_bin_url) -O imx-seco.bin && chmod +x imx-seco.bin && \
	./imx-seco.bin --auto-accept && mv `basename -s .bin $(repo_seco_bin_url)` imx-seco && rm -f imx-seco.bin; \
    fi && \
    if [ ! -f $(FWDIR)/imx-scfw/mx8qx-mek-scfw-tcm.bin ]; then \
	wget -q $(repo_scfw_bin_url) -O imx-scfw.bin && chmod +x imx-scfw.bin && \
	./imx-scfw.bin --auto-accept && mv `basename -s .bin $(repo_scfw_bin_url)` imx-scfw && rm -f imx-scfw.bin; \
    fi && \
    \
    if echo $1 | grep -qE ^imx8mp_ddr4_evk; then \
	SOC=iMX8MP; SOC_FAMILY=iMX8M; target=flash_ddr4_evk; \
    elif echo $1 | grep -qE ^imx8mp_evk; then \
	SOC=iMX8MP; SOC_FAMILY=iMX8M; target=flash_evk; \
    elif echo $1 | grep -qE ^imx8mm_ddr4_evk; then \
	SOC=iMX8MM; SOC_FAMILY=iMX8M; target=flash_ddr4_evk; \
    elif echo $1 | grep -qE ^imx8mm_evk; then \
	SOC=iMX8MM; SOC_FAMILY=iMX8M; target=flash_evk; \
    elif echo $1 | grep -qE ^imx8mn_ddr4_evk; then \
	SOC=iMX8MN; SOC_FAMILY=iMX8M; target=flash_ddr4_evk; \
    elif echo $1 | grep -qE ^imx8mn_evk; then \
	SOC=iMX8MN; SOC_FAMILY=iMX8M; target=flash_evk; \
    elif echo $1 | grep -qE ^imx8mq_ddr4_val; then \
	SOC=iMX8M; SOC_FAMILY=iMX8M; target=flash_ddr4_val; \
    elif echo $1 | grep -qE ^imx8mq_evk; then \
	SOC=iMX8M; SOC_FAMILY=iMX8M; target=flash_evk; \
    elif echo $1 | grep -qE ^imx8qm; then \
	SOC=iMX8QM; SOC_FAMILY=iMX8QM; target=flash_spl; \
	cp -f $(FWDIR)/imx-scfw/mx8qm-mek-scfw-tcm.bin $(FWDIR)/imx_mkimage/iMX8QM/scfw_tcm.bin; \
	cp -f $(FWDIR)/imx-seco/firmware/seco/mx8qmb0-ahab-container.img $(FWDIR)/imx_mkimage/iMX8QM; \
    elif echo $1 | grep -qE ^imx8qx; then \
	SOC=iMX8QX; SOC_FAMILY=iMX8QX; target=flash_spl; \
	cp -f $(FWDIR)/imx-scfw/mx8qx-mek-scfw-tcm.bin $(FWDIR)/imx_mkimage/iMX8QX/scfw_tcm.bin; \
	cp -f $(FWDIR)/imx-seco/firmware/seco/mx8qx*-ahab-container.img $(FWDIR)/imx_mkimage/iMX8QX; \
    fi; \
    \
    cd $(FWDIR)/imx_mkimage && \
    $(MAKE) clean && $(MAKE) bin && \
    $(MAKE) SOC=$$SOC -C iMX8M -f soc.mak mkimage_imx8 && \
    if [ $(MACHINE) = imx8qmevk ];  then \
	$(MAKE) -C iMX8QM -f soc.mak imx8qm_dcd.cfg.tmp; \
    elif [ $(MACHINE) = imx8qxpmek ]; then \
	$(MAKE) -C iMX8QX REV=B0 -f soc.mak imx8qx_dcd.cfg.tmp; \
    fi && \
    \
    cp -f $(FWDIR)/firmware-imx/firmware/ddr/synopsys/*.bin $(FWDIR)/imx_mkimage/$$SOC_FAMILY; \
    bl32=$(PACKAGES_PATH)/apps/security/optee_os/out/arm-plat-imx/core/tee_$$brd.bin && \
    if [ $(CONFIG_APP_OPTEE) = y -a ! -f $$bl32 ]; then \
	flex-builder -c optee_os -m $$brd -f $(CFGLISTYML); \
    fi && \
    cp -t $(FWDIR)/imx_mkimage/$$SOC_FAMILY \
	$(FWDIR)/firmware-imx/firmware/hdmi/cadence/signed*_imx8m.bin \
	$$opdir/spl/u-boot-spl.bin $$opdir/u-boot.bin \
	$$opdir/arch/arm/dts/*$${MACHINE:0:6}*.dtb \
	$$opdir/u-boot-nodtb.bin && \
    cp -f $$bl32 $(FWDIR)/imx_mkimage/$$SOC_FAMILY/tee.bin && \
    cp -f $$opdir/tools/mkimage $(FWDIR)/imx_mkimage/$$SOC_FAMILY/mkimage_uboot; \
    cp -f $(FWDIR)/atf/build/$${MACHINE:0:6}/release/bl31.bin $(FWDIR)/imx_mkimage/$$SOC_FAMILY/; \
    \
    $(MAKE) SOC=$$SOC $$REV_OPTION $$target && \
    mkdir -p $(FBOUTDIR)/firmware/imx-mkimage/$$brd && \
    if [ -z "$(BOARD_VARIANTS)" ]; then \
	cp $$SOC_FAMILY/flash.bin $(FBOUTDIR)/firmware/imx-mkimage/$$brd/flash.bin; \
    elif [ $(MACHINE) = imx8mpevk -o $(MACHINE) = imx8mnevk -o $(MACHINE) = imx8mmevk -o \
	   $(MACHINE) = imx8mqevk ] && [ $$target = flash_ddr4_evk -o $$target = flash_ddr4_val ]; then \
	cp $$SOC_FAMILY/flash.bin $(FBOUTDIR)/firmware/imx-mkimage/$$brd/flash-ddr4.bin; \
    elif [ $(MACHINE) = imx8mpevk -o $(MACHINE) = imx8mnevk -o $(MACHINE) = imx8mmevk -o \
	   $(MACHINE) = imx8mqevk ] && [ $$target = flash_evk ]; then \
	cp $$SOC_FAMILY/flash.bin $(FBOUTDIR)/firmware/imx-mkimage/$$brd/flash-lpddr4.bin; \
    fi && \
    if [ $(MACHINE) = imx8qxpmek ]; then \
	mv $$SOC_FAMILY/flash.bin $(FBOUTDIR)/firmware/imx-mkimage/$$brd/flash-b0.bin; \
	$(MAKE) clean && $(MAKE) bin && \
	$(MAKE) SOC=$$SOC -C iMX8M -f soc.mak mkimage_imx8 && \
	$(MAKE) SOC=iMX8QX REV=C0 $$target && \
	mv $$SOC_FAMILY/flash.bin $(FBOUTDIR)/firmware/imx-mkimage/$$brd/flash-c0.bin; \
    fi
endef
