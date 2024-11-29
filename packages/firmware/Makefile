#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK firmware Components

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/repo.mk

FWDIR = $(PACKAGES_PATH)/firmware


include atf.mk
include u-boot.mk
include layerscape_firmware.mk


firmware: uboot uefi_bin rcw atf bin_firmware


bin_firmware: fm_ucode qe_ucode mc_bin mc_utils phy_cortina phy_inphi pfe_bin ddr_phy_bin dp_firmware_cadence
	@touch $(FBOUTDIR)/firmware/.binfwdone





repo_fetch:
	@echo -e "\nfetch firmware repositories"
	@$(call repo-update,fetch,$(FIRMWARE_REPO_LIST),firmware)

repo_update_branch:
	@echo -e "\nfirmware repositories update for branch"
	@$(call repo-update,branch,$(FIRMWARE_REPO_LIST),firmware)

repo_update_tag:
	@echo -e "\nfirmware repositories update for tag"
	@$(call repo-update,tag,$(FIRMWARE_REPO_LIST),firmware)

repo_update_latest:
	@echo -e "\nfirmware repositories update to latest HEAD commit"
	@$(call repo-update,update,$(FIRMWARE_REPO_LIST),firmware)

repo_update_commit:
	@echo -e "\nfirmware repositories update to specified commit ID"
	@$(call repo-update,commit,$(FIRMWARE_REPO_LIST),firmware)
