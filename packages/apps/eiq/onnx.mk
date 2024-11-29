# Copyright 2019-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




.PHONY: onnx
onnx: dependency
ifeq ($(CONFIG_EIQ_ONNX), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu ] && exit || \
	 $(call fbprint_b,"onnx") && \
	 export ONNX_ML=1 && \
	 $(call fetch-git-tree,onnx,apps/eiq) && \
	 unset ONNX_ML && cd $(eIQDIR)/onnx && \
	 if [ ! -f $(eIQDIR)/protobuf/host_build/usr/local/bin/protoc ]; then \
	    flex-builder -c protobuf -r ubuntu:$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 export LD_LIBRARY_PATH=../protobuf/host_build/usr/local/lib:$(LD_LIBRARY_PATH) && \
	 ../protobuf/host_build/usr/local/bin/protoc onnx/onnx.proto --proto_path=. \
	    --proto_path=$(eIQDESTDIR)/usr/local/include --cpp_out . && \
	 $(call fbprint_d,"onnx")
endif
endif
