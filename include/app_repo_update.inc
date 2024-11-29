# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


networking_repo_fetch:
	@echo -e "\nfetch networking repositories: $(NETWORKING_REPO_LIST)"
	@$(call repo-update,fetch,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_branch:
	@echo -e "\nnetworking repositories update for branch"
	@$(call repo-update,branch,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_tag:
	@echo -e "\nnetworking repositories update for tag"
	@$(call repo-update,tag,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_latest:
	@echo -e "\nnetworking repositories update to latest HEAD commit"
	@$(call repo-update,update,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_commit:
	@echo -e "\nnetworking repositories update to specified commit ID"
	@$(call repo-update,commit,$(NETWORKING_REPO_LIST),apps/networking)

graphics_repo_fetch:
	@echo -e "\nfetch graphics repositories: $(GRAPHICS_REPO_LIST)"
	@$(call repo-update,fetch,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_branch:
	@echo -e "\ngraphics repositories update for branch"
	@$(call repo-update,branch,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_tag:
	@echo -e "\ngraphics repositories update for tag"
	@$(call repo-update,tag,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_latest:
	@echo -e "\ngraphics repositories update to latest HEAD commit"
	@$(call repo-update,update,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_commit:
	@echo -e "\ngraphics repositories update to specified commit ID"
	@$(call repo-update,commit,$(GRAPHICS_REPO_LIST),apps/graphics)

multimedia_repo_fetch:
	@echo -e "\nfetch multimedia repositories: $(MULTIMEDIA_REPO_LIST)"
	@$(call repo-update,fetch,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_branch:
	@echo -e "\nmultimedia repositories update for branch"
	@$(call repo-update,branch,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_tag:
	@echo -e "\nmultimedia repositories update for tag"
	@$(call repo-update,tag,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_latest:
	@echo -e "\nmultimedia repositories update to latest HEAD commit"
	@$(call repo-update,update,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_commit:
	@echo -e "\nmultimedia repositories update to specified commit ID"
	@$(call repo-update,commit,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

security_repo_fetch:
	@echo -e "\nfetch security repositories: $(SECURITY_REPO_LIST)"
	@$(call repo-update,fetch,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_branch:
	@echo -e "\nsecurity repositories update for branch"
	@$(call repo-update,branch,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_tag:
	@echo -e "\nsecurity repositories update for tag"
	@$(call repo-update,tag,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_latest:
	@echo -e "\nsecurity repositories update to latest HEAD commit"
	@$(call repo-update,update,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_commit:
	@echo -e "\nsecurity repositories update to specified commit ID"
	@$(call repo-update,commit,$(SECURITY_REPO_LIST),apps/security)

generic_repo_fetch:
	@echo -e "\nfetch generic repositories: $(GENERIC_REPO_LIST)"
	@$(call repo-update,fetch,$(GENERIC_REPO_LIST),apps/generic)

generic_repo_update_branch:
	@echo -e "\ngeneric repositories update for branch"
	@$(call repo-update,branch,$(GENERIC_REPO_LIST),apps/generic)

generic_repo_update_tag:
	@echo -e "\ngeneric repositories update for tag"
	@$(call repo-update,tag,$(GENERIC_REPO_LIST),apps/generic)

generic_repo_update_latest:
	@echo -e "\ngeneric repositories update to latest HEAD commit"
	@$(call repo-update,update,$(GENERIC_REPO_LIST),apps/generic)

generic_repo_update_commit:
	@echo -e "\ngeneric repositories update to specified commit ID"
	@$(call repo-update,commit,$(GENERIC_REPO_LIST),apps/generic)

eiq_repo_fetch:
	@echo -e "\nfetch eIQ repositories: $(eIQ_REPO_LIST)"
	@$(call repo-update,fetch,$(eIQ_REPO_LIST),apps/eiq)

eiq_repo_update_branch:
	@echo -e "\neIQ repositories update for branch"
	@$(call repo-update,branch,$(eIQ_REPO_LIST),apps/eiq)

eiq_repo_update_tag:
	@echo -e "\neIQ repositories update for tag"
	@$(call repo-update,tag,$(eIQ_REPO_LIST),apps/eiq)

eiq_repo_update_latest:
	@echo -e "\neIQ repositories update to latest HEAD commit"
	@$(call repo-update,update,$(eIQ_REPO_LIST),apps/eiq)

eiq_repo_update_commit:
	@echo -e "\neIQ repositories update to specified commit ID"
	@$(call repo-update,commit,$(eIQ_REPO_LIST),apps/eiq)
