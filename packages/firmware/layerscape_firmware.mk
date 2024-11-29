#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK firmware Components


uefi_machine_list = ls1043ardb ls1046ardb ls2088ardb lx2160ardb_rev2

.PHONY: uefi_bin
uefi uefi_bin:
ifeq ($(CONFIG_FW_UEFI_BIN), "y")
	@$(call fbprint_b,"UEFI_BIN") && \
	 $(call fetch-git-tree,uefi_bin,firmware) && \
	 cd $(FWDIR) && \
	 for brd in $(uefi_machine_list); do \
	     if [ $$brd = lx2160ardb_rev2 ]; then brd=$${brd:0:10}; fi; \
	     mkdir -p $(FBOUTDIR)/firmware/uefi/$$brd; \
	     if [ ! -f $(FBOUTDIR)/firmware/uefi/$$brd/*RDB_EFI* ]; then \
		cp uefi_bin/$$brd/*.fd $(FBOUTDIR)/firmware/uefi/$$brd/; \
	     fi; \
	 done && mkdir -p $(FBOUTDIR)/firmware/uefi/grub && \
	 cp uefi_bin/grub/BOOTAA64.EFI $(FBOUTDIR)/firmware/uefi/grub && \
	 $(call fbprint_d,"UEFI_BIN")
endif



.PHONY: grub
grub:
ifeq ($(CONFIG_FW_GRUB), "y")
	@$(call fbprint_b,"grub") && \
	 $(call fetch-git-tree,grub,firmware) && cd $(FWDIR)/grub && \
	 ./bootstrap && ./autogen.sh && \
	 ./configure --target=aarch64-linux-gnu && \
	 make && echo 'configfile ${cmdpath}/grub.cfg' > grub.cfg && \
	 grub-mkstandalone --directory=./grub-core -O arm64-efi -o BOOTAA64.EFI \
			   --modules "part_gpt part_msdos" /boot/grub/grub.cfg=./grub.cfg && \
	 mkdir -p $(FBOUTDIR)/firmware/grub && cp -f BOOTAA64.EFI $(FBOUTDIR)/firmware/grub && \
	$(call fbprint_d,"grub")
endif



.PHONY: rcw
rcw:
ifeq ($(CONFIG_FW_RCW), "y")
	@$(call fbprint_b,"RCW") && \
	 $(call fetch-git-tree,rcw,firmware) && \
	 cd $(FWDIR) && mkdir -p $(FBOUTDIR)/firmware/rcw
ifeq ($(MACHINE), all)
	@cd $(FWDIR) && \
	 for brd in `find rcw -maxdepth 1 -type d -name "l*"|cut -d/ -f2`; do \
	     if [ $$brd = ls1088ardb_pb ]; then brd=ls1088ardb; fi && \
	     test -f rcw/$$brd/Makefile || continue; \
	     $(MAKE) -C rcw/$$brd && \
	     $(MAKE) -C rcw/$$brd install DESTDIR=$(FBOUTDIR)/firmware/rcw/$$brd; \
	 done
else
	@if [ $(MACHINE) = ls1088ardb_pb ]; then brd=ls1088ardb; else brd=$(MACHINE); fi && \
	 cd $(FWDIR) && $(MAKE) -C rcw/$$brd && \
	 $(MAKE) -C rcw/$$brd install DESTDIR=$(FBOUTDIR)/firmware/rcw/$$brd
endif
	@rm -f $(FBOUTDIR)/firmware/rcw/*/README && $(call fbprint_d,"RCW")
endif



.PHONY: mc_utils
mc_utils:
	@ $(call fetch-git-tree,mc_utils,firmware) && \
	 cd $(FWDIR) && \
	 if [ ! -h $(FBOUTDIR)/firmware/mc_utils ]; then \
	     ln -s $(FWDIR)/mc_utils $(FBOUTDIR)/firmware/mc_utils; \
	 fi && \
	 $(MAKE) -C mc_utils/config && \
	 $(call fbprint_d,"mc_utils")



.PHONY: fm_ucode
fm_ucode:
	@$(call fetch-git-tree,fm_ucode,firmware)
	@if [ ! -h $(FBOUTDIR)/firmware/fm_ucode ]; then \
	     ln -s $(FWDIR)/fm_ucode $(FBOUTDIR)/firmware/fm_ucode; \
	 fi && \
	 $(call fbprint_d,"fm_ucode")


.PHONY: qe_ucode
qe_ucode:
	@$(call fetch-git-tree,qe_ucode,firmware) && cd $(FWDIR) && \
	 if [ ! -h $(FBOUTDIR)/firmware/qe_ucode ]; then \
	     ln -s $(FWDIR)/qe_ucode $(FBOUTDIR)/firmware/qe_ucode; \
	 fi && \
	 $(call fbprint_d,"qe_ucode")



.PHONY: dp_firmware_cadence
dp_firmware_cadence:
	@if [ ! -d $(FWDIR)/dp_firmware_cadence ]; then \
	     mkdir -p $(FWDIR) && cd $(FWDIR) && \
	     echo Downloading $(repo_dp_firmware_cadence_bin_url) && \
             wget -q $(repo_dp_firmware_cadence_bin_url) -O dp_firmware_cadence.bin && \
	     chmod +x dp_firmware_cadence.bin && \
             ./dp_firmware_cadence.bin --auto-accept && \
	     mv firmware-cadence-* dp_firmware_cadence && \
	     rm -f dp_firmware_cadence.bin; \
         fi && \
	 if [ ! -L $(FBOUTDIR)/firmware/dp_firmware_cadence ]; then \
	     ln -sf $(FWDIR)/dp_firmware_cadence $(FBOUTDIR)/firmware/dp_firmware_cadence; \
	 fi && \
	 $(call fbprint_d,"dp_firmware_cadence")



.PHONY: mc_bin
mc_bin:
	@$(call fetch-git-tree,mc_bin,firmware) && \
	 cd $(FWDIR) && \
	 if [ ! -h $(FBOUTDIR)/firmware/mc_bin ]; then \
	     ln -s $(FWDIR)/mc_bin $(FBOUTDIR)/firmware/mc_bin; \
	 fi && \
	 $(call fbprint_d,"mc_bin")



.PHONY: phy_cortina
phy_cortina:
	@$(call fetch-git-tree,phy_cortina,firmware) && cd $(FWDIR) && \
	 if [ ! -h $(FBOUTDIR)/firmware/phy_cortina ]; then \
	     ln -s $(FWDIR)/phy_cortina $(FBOUTDIR)/firmware/phy_cortina; \
	 fi && \
	 $(call fbprint_d,"phy_cortina")



.PHONY: phy_inphi
phy_inphi:
	@$(call fetch-git-tree,phy_inphi,firmware) && cd $(FWDIR) && \
	 if [ ! -h $(FBOUTDIR)/firmware/phy_inphi ]; then \
	     ln -s $(FWDIR)/phy_inphi $(FBOUTDIR)/firmware/phy_inphi; \
	 fi && \
	 $(call fbprint_d,"phy_inphi")



.PHONY: pfe_bin
pfe_bin:
	@$(call fetch-git-tree,pfe_bin,firmware) && cd $(FWDIR) && \
	 if [ ! -h $(FBOUTDIR)/firmware/pfe_bin ]; then \
	     ln -s $(FWDIR)/pfe_bin $(FBOUTDIR)/firmware/pfe_bin; \
	 fi && \
	 $(call fbprint_d,"pfe_bin")



.PHONY: ddr_phy_bin
ddr_phy_bin:
	@$(call fetch-git-tree,ddr_phy_bin,firmware) && \
	 $(call fetch-git-tree,atf,firmware) && \
	 if [ ! -f $(FWDIR)/atf/tools/fiptool/fiptool ]; then \
	     $(MAKE) -C $(FWDIR)/atf fiptool; \
	 fi && \
	 if [ ! -f $(FBOUTDIR)/firmware/ddr_phy_bin/fip_ddr_all.bin ]; then \
	     ln -sf $(FWDIR)/ddr_phy_bin $(FBOUTDIR)/firmware/ddr_phy_bin; \
	     cd $(FWDIR)/ddr_phy_bin/lx2160a && $(FWDIR)/atf/tools/fiptool/fiptool create \
	     --ddr-immem-udimm-1d ddr4_pmu_train_imem.bin \
	     --ddr-immem-udimm-2d ddr4_2d_pmu_train_imem.bin \
	     --ddr-dmmem-udimm-1d ddr4_pmu_train_dmem.bin \
	     --ddr-dmmem-udimm-2d ddr4_2d_pmu_train_dmem.bin \
	     --ddr-immem-rdimm-1d ddr4_rdimm_pmu_train_imem.bin \
	     --ddr-immem-rdimm-2d ddr4_rdimm2d_pmu_train_imem.bin \
	     --ddr-dmmem-rdimm-1d ddr4_rdimm_pmu_train_dmem.bin \
	     --ddr-dmmem-rdimm-2d ddr4_rdimm2d_pmu_train_dmem.bin \
	     $(FBOUTDIR)/firmware/ddr_phy_bin/fip_ddr_all.bin && \
	     cp -f *.bin $(FWDIR)/atf/; \
	 fi && \
	 $(call fbprint_d,"ddr_phy_bin")
