#
# PixelOS-CLO: AOSPA prebuilt kernel integration for marble.
#
# Based on the proven marble-development Lineage 24 recipe:
#   - no BOARD_VENDOR_RAMDISK_FRAGMENTS
#   - first-stage + recovery modules live in the main vendor ramdisk
#   - vendor_dlkm modules come from vendor_dlkm/modules.load
#   - TARGET_NO_KERNEL_OVERRIDE stops Lineage kernel.mk from generating
#     its own dtb/dtbo rules.
#
# The AOSPA kernel repo layout:
#   Image, dtbs/{ukee.dtb,dtbo.img}, kernel-headers/,
#   vendor_ramdisk/{*.ko,modules.load,modules.load.recovery,modules.blocklist},
#   vendor_dlkm/{*.ko,modules.load,modules.blocklist}
#

KERNEL_PREBUILT_DIR := device/xiaomi/marble-kernel

# PixelOS does not use AOSPA's vendor.aospa.power extension.  This blanking
# must stay: sm8450-common/BoardConfigCommon.mk points at a library that does
# not exist in the PixelOS tree.
TARGET_POWER_FEATURE_EXT_LIB :=

# Keep Lineage's kernel.mk out of the way; we use the prebuilt kernel below.
TARGET_NO_KERNEL_OVERRIDE := true
TARGET_KERNEL_SOURCE := $(KERNEL_PREBUILT_DIR)/kernel-headers

TARGET_PREBUILT_KERNEL := $(KERNEL_PREBUILT_DIR)/Image
TARGET_BOARD_KERNEL_HEADERS := $(KERNEL_PREBUILT_DIR)/kernel-headers

LOCAL_KERNEL := $(KERNEL_PREBUILT_DIR)/Image
PRODUCT_COPY_FILES += $(LOCAL_KERNEL):kernel

# Boot image / DTB / DTBO
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true

BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PREBUILT_DIR)/dtbs
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PREBUILT_DIR)/dtbs/dtbo.img

# Main vendor ramdisk: first-stage modules + recovery modules.
# Do NOT set BOARD_VENDOR_RAMDISK_FRAGMENTS; first-stage init reads
# lib/modules/modules.load from the main vendor ramdisk.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := \
    $(addprefix $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := \
    $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.blocklist

BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/modules.load.recovery))
RECOVERY_MODULES := \
    $(addprefix $(KERNEL_PREBUILT_DIR)/vendor_ramdisk/,$(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := \
    $(sort $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES) $(RECOVERY_MODULES))

# Second-stage modules -> vendor_dlkm image.
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(KERNEL_PREBUILT_DIR)/vendor_dlkm/modules.load))
BOARD_VENDOR_KERNEL_MODULES := \
    $(addprefix $(KERNEL_PREBUILT_DIR)/vendor_dlkm/,$(BOARD_VENDOR_KERNEL_MODULES_LOAD))
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := \
    $(KERNEL_PREBUILT_DIR)/vendor_dlkm/modules.blocklist
