#
# PixelOS-CLO: LOS lineage-24.0 source kernel integration for the AOSPA
# marble device tree.
#
# The AOSPA tree normally uses a prebuilt kernel from
# device/xiaomi/marble-kernel; this file switches it to the LineageOS
# source kernel while keeping AOSPA's GKI/partition settings.
#

# Kernel image
BOARD_KERNEL_BASE        := 0x00000000
BOARD_KERNEL_PAGESIZE    := 4096
BOARD_KERNEL_IMAGE_NAME  := Image

# DTB merge: marble is ukee-based (SM7475); keep the base dtb name.
TARGET_MERGE_DTBS_WILDCARD := ukee*

# Source kernel
TARGET_KERNEL_ADDITIONAL_FLAGS := TARGET_PRODUCT=$(PRODUCT_DEVICE)
TARGET_KERNEL_SOURCE := kernel/xiaomi/sm8450
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/waipio_GKI.config \
    vendor/xiaomi_GKI.config \
    vendor/$(PRODUCT_DEVICE)_GKI.config \
    vendor/debugfs.config

# Vendor ramdisk / dlkm layout
BOARD_VENDOR_RAMDISK_FRAGMENTS := dlkm
BOARD_VENDOR_RAMDISK_FRAGMENT.dlkm.KERNEL_MODULE_DIRS := top

# Kernel modules
first_stage_modules := $(strip $(shell cat $(TARGET_KERNEL_SOURCE)/modules.list.msm.waipio))
second_stage_modules := $(strip $(shell cat $(COMMON_PATH)/modules.list.second_stage))
vendor_dlkm_exclusive_modules := $(strip $(shell cat $(COMMON_PATH)/modules.list.vendor_dlkm))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD += $(first_stage_modules)
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD += $(first_stage_modules) $(second_stage_modules)
BOARD_VENDOR_KERNEL_MODULES_LOAD += $(second_stage_modules) $(vendor_dlkm_exclusive_modules)

BOOT_KERNEL_MODULES += $(first_stage_modules) $(second_stage_modules)

BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules.vendor_blocklist.msm.waipio
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE)

# Out-of-tree modules
TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm8450-modules
TARGET_KERNEL_EXT_MODULES := \
    qcom/opensource/mmrm-driver \
    qcom/opensource/audio-kernel \
    qcom/opensource/camera-kernel \
    qcom/opensource/cvp-kernel \
    qcom/opensource/dataipa/drivers/platform/msm \
    qcom/opensource/datarmnet/core \
    qcom/opensource/datarmnet-ext/aps \
    qcom/opensource/datarmnet-ext/offload \
    qcom/opensource/datarmnet-ext/shs \
    qcom/opensource/datarmnet-ext/perf \
    qcom/opensource/datarmnet-ext/perf_tether \
    qcom/opensource/datarmnet-ext/sch \
    qcom/opensource/datarmnet-ext/wlan \
    qcom/opensource/display-drivers/msm \
    qcom/opensource/eva-kernel \
    qcom/opensource/video-driver \
    qcom/opensource/wlan/qcacld-3.0/.qca6490 \
    qcom/opensource/wlan/qcacld-3.0/.qca6750

# PixelOS does not use AOSPA's vendor.aospa.power extension; disable the
# optional power feature library from the AOSPA common tree.
TARGET_POWER_FEATURE_EXT_LIB :=
