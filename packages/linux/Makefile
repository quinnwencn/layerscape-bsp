#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK linux kernel and modules components

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/repo.mk

include kernel.mk
include perf.mk
include cryptodev_linux.mk
include lttng_modules.mk
include mdio_proxy_module.mk


.PHONY: linux
linux: kernel
linux-modules: cryptodev_linux mdio_proxy_module




repo_fetch:
	@echo -e "\nfetch linux repositories"
	@$(call repo-update,fetch,$(LINUX_REPO_LIST),linux)

repo_update_branch:
	@echo -e "\nlinux repositories update for branch"
	@$(call repo-update,branch,$(LINUX_REPO_LIST),linux)

repo_update_tag:
	@echo -e "\nlinux repositories update for tag"
	@$(call repo-update,tag,$(LINUX_REPO_LIST),linux)

repo_update_latest:
	@echo -e "\nlinux repositories update to latest HEAD commit"
	@$(call repo-update,update,$(LINUX_REPO_LIST),linux)

repo_update_commit:
	@echo -e "\nlinux repositories update to specified commit ID"
	@$(call repo-update,commit,$(LINUX_REPO_LIST),linux)
