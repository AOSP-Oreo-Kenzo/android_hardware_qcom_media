LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# ---------------------------------------------------------------------------------
# 				Common definitons
# ---------------------------------------------------------------------------------

libmm-venc-def := -g -O3 -Dlrintf=_ffix_r
libmm-venc-def += -D__align=__alignx
libmm-venc-def += -D__alignx\(x\)=__attribute__\(\(__aligned__\(x\)\)\)
libmm-venc-def += -DT_ARM
libmm-venc-def += -Dinline=__inline
libmm-venc-def += -D_ANDROID_
libmm-venc-def += -UENABLE_DEBUG_LOW
libmm-venc-def += -UENABLE_DEBUG_HIGH
libmm-venc-def += -DENABLE_DEBUG_ERROR
libmm-venc-def += -UINPUT_BUFFER_LOG
libmm-venc-def += -UOUTPUT_BUFFER_LOG
libmm-venc-def += -USINGLE_ENCODER_INSTANCE
libmm-venc-def += -Werror
libmm-venc-def += -Wno-error=literal-suffix
libmm-venc-def += -D_ANDROID_ICS_
libmm-venc-def += -D_MSM8974_

TARGETS_THAT_USE_FLAG_MSM8226 := msm8226 msm8916 msm8909 msm8952
TARGETS_THAT_NEED_SW_VENC_MPEG4 := msm8909
TARGETS_THAT_NEED_SW_VENC_HEVC := msm8992 msm8952

ifeq ($(TARGET_BOARD_PLATFORM),msm8610)
libmm-venc-def += -DMAX_RES_720P
libmm-venc-def += -D_MSM8610_
else
ifeq ($(TARGET_BOARD_PLATFORM),msm8226)
libmm-venc-def += -DMAX_RES_1080P
else
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -DMAX_RES_1080P_EBI
endif
endif

ifeq ($(call is-board-platform-in-list, $(TARGETS_THAT_USE_FLAG_MSM8226)),true)
libmm-venc-def += -D_MSM8226_
endif

ifeq ($(TARGET_USES_ION),true)
libmm-venc-def += -DUSE_ION
endif

ifeq ($(TARGET_USES_MEDIA_EXTENSIONS),true)
libmm-venc-def += -DUSE_NATIVE_HANDLE_SOURCE
endif

ifeq ($(TARGET_USES_MEDIA_EXTENSIONS),true)
libmm-venc-def += -DSUPPORT_CONFIG_INTRA_REFRESH
endif

# Common Includes
libmm-venc-inc      := $(LOCAL_PATH)/inc
libmm-venc-inc      += $(OMX_VIDEO_PATH)/vidc/common/inc
libmm-venc-inc      += $(QCOM_MEDIA_ROOT)/mm-core/inc
libmm-venc-inc      += $(QCOM_MEDIA_ROOT)/libstagefrighthw
libmm-venc-inc      += $(TARGET_OUT_HEADERS)/qcom/display
libmm-venc-inc      += $(TARGET_OUT_HEADERS)/adreno
libmm-venc-inc      += frameworks/native/include/media/hardware
libmm-venc-inc      += frameworks/native/include/media/openmax
libmm-venc-inc      += $(QCOM_MEDIA_ROOT)/libc2dcolorconvert
libmm-venc-inc      += frameworks/av/include/media/stagefright
ifeq ($(TARGET_COMPILE_WITH_MSM_KERNEL),true)
libmm-venc-inc      += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include

# Common Dependencies
libmm-venc-add-dep  := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr
endif

# ---------------------------------------------------------------------------------
# 			Make the Shared library (libOmxVenc)
# ---------------------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE                    := libOmxVenc
LOCAL_MODULE_TAGS               := optional
LOCAL_PROPRIETARY_MODULE        := true
LOCAL_CFLAGS                    := $(libmm-venc-def)
LOCAL_CLANG := false
LOCAL_C_INCLUDES                := $(libmm-venc-inc)
LOCAL_ADDITIONAL_DEPENDENCIES   := $(libmm-venc-add-dep)

LOCAL_PRELINK_MODULE      := false
LOCAL_SHARED_LIBRARIES    := liblog libutils libbinder libcutils \
                             libc2dcolorconvert libdl libgui
LOCAL_SHARED_LIBRARIES += libqdMetaData
LOCAL_STATIC_LIBRARIES    := libOmxVidcCommon

LOCAL_SRC_FILES   := src/omx_video_base.cpp
LOCAL_SRC_FILES   += src/omx_video_encoder.cpp
LOCAL_SRC_FILES   += src/video_encoder_device_v4l2.cpp
LOCAL_SRC_FILES   += src/neon.c

include $(BUILD_SHARED_LIBRARY)

# SW codec OMX components not built in OSS builds as QCPATH is null in OSS builds.
ifneq "$(wildcard $(QCPATH) )" ""

ifeq ($(call is-board-platform-in-list, $(TARGETS_THAT_NEED_SW_VENC_MPEG4)),true)
# ---------------------------------------------------------------------------------
# 			Make the Shared library (libOmxSwVencMpeg4)
# ---------------------------------------------------------------------------------

include $(CLEAR_VARS)

libmm-venc-inc      += $(TARGET_OUT_HEADERS)/mm-video/swvenc

LOCAL_MODULE                    := libOmxSwVencMpeg4

LOCAL_MODULE_TAGS               := optional
LOCAL_PROPRIETARY_MODULE        := true
LOCAL_CFLAGS                    := $(libmm-venc-def)
LOCAL_C_INCLUDES                := $(libmm-venc-inc)
LOCAL_ADDITIONAL_DEPENDENCIES   := $(libmm-venc-add-dep)

LOCAL_PRELINK_MODULE      := false
LOCAL_SHARED_LIBRARIES    := liblog libutils libbinder libcutils \
                             libc2dcolorconvert libdl libgui
LOCAL_SHARED_LIBRARIES    += libMpeg4SwEncoder
LOCAL_STATIC_LIBRARIES    := libOmxVidcCommon

LOCAL_SRC_FILES   := src/omx_video_base.cpp
LOCAL_SRC_FILES   += src/omx_swvenc_mpeg4.cpp
LOCAL_CLANG := false

include $(BUILD_SHARED_LIBRARY)
endif

endif

# ---------------------------------------------------------------------------------
# 					END
# ---------------------------------------------------------------------------------
