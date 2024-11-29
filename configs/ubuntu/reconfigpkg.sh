#!/bin/bash
#
# Copyright 2018 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#
# reconfigure default setting



# automatically load the specified module during booting up
if ! grep -q mali-dp /etc/modules; then
    echo mali-dp >> /etc/modules
fi
