#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK Application Components
#

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/repo.mk


NETDIR = $(PACKAGES_PATH)/apps/networking
SECDIR = $(PACKAGES_PATH)/apps/security
GENDIR = $(PACKAGES_PATH)/apps/generic
eIQDIR = $(PACKAGES_PATH)/apps/eiq
GRAPHICSDIR = $(PACKAGES_PATH)/apps/graphics
MMDIR = $(PACKAGES_PATH)/apps/multimedia


.PHONY: all

all: $(APPS_REPO_LIST) misc
	@$(call fbprint_d,"apps components")


misc:
	@$(CROSS_COMPILE)gcc $(FBDIR)/packages/rfs/misc/ccsr.c -o $(DESTDIR)/usr/local/bin/ccsr



networking: $(NETWORKING_REPO_LIST)
multimedia: $(MULTIMEDIA_REPO_LIST)
graphics:   $(GRAPHICS_REPO_LIST)
security:   $(SECURITY_REPO_LIST)
generic:    $(GENERIC_REPO_LIST)
eiq:	    $(EIQ_REPO_LIST)


include $(sort $(wildcard $(FBDIR)/packages/apps/*/*.mk))
include $(FBDIR)/include/app_repo_update.inc
