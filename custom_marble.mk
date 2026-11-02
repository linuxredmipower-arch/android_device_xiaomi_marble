#
# PixelOS-CLO A17 product for marble, built on the AOSPA beryl device tree.
#
# SPDX-License-Identifier: Apache-2.0
#

# PixelOS: AOSP Soong audio service installs the init rc; skip the Make copy.
TARGET_SKIP_MAKE_AUDIO_SERVICE_RC := true

# AOSP base products (AOSPA's aospa_marble.mk does the same)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from marble device (AOSPA tree)
$(call inherit-product, device/xiaomi/marble/device.mk)

# Debug adb for userdebug/eng
ifneq ($(filter userdebug eng,$(TARGET_BUILD_VARIANT)),)
WITH_ADB_INSECURE := true
endif

# Inherit from PixelOS common configuration
$(call inherit-product, vendor/custom/config/common_full_phone.mk)

PRODUCT_NAME := custom_marble
PRODUCT_DEVICE := marble
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := POCO
PRODUCT_MODEL := 23049PCD8G

# Keep the current device fingerprint baseline (OS3.0.5.0). The AOSPA blobs
# are from OS3.0.4.0.VMRMIXM; if strict alignment is needed later, switch
# both blobs and this fingerprint together.
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="marble_global-user 15 AQ3A.241006.001 OS3.0.5.0.VMRCNXM release-keys" \
    BuildFingerprint=POCO/marble_global/marble:15/AQ3A.241006.001/OS3.0.5.0.VMRCNXM:user/release-keys \
    DeviceProduct=marble \
    SystemName=marble_global

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# PixelOS OTA package (m pixelos)
TARGET_FORCE_OTA_PACKAGE := true

# PixelOS qacs interfaces expect the old qcom-caf display config HAL;
# AOSPA display tree does not provide it. Marble does not use qacs.
PRODUCT_SOURCE_ROOT_DIRS += -vendor/qcom/opensource/interfaces/qacs

# AOSPA display tree needs the commonsys-intf display namespace
PRODUCT_SOONG_NAMESPACES += \
    vendor/qcom/opensource/commonsys-intf/display

# AOSPA power feature extension depends on vendor.aospa.power; not used here.
PRODUCT_SOURCE_ROOT_DIRS += -device/xiaomi/sm8450-common/power

# AOSPA-only apps/resources (co.aospa.resources) and PixelOS qac-services
# (ambient AI) are not used by this PixelOS build; prune them before Soong.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/xiaomi/dolby
PRODUCT_SOURCE_ROOT_DIRS += -device/xiaomi/sm8450-common/parts
PRODUCT_SOURCE_ROOT_DIRS += -vendor/qcom/opensource/qac-services
PRODUCT_PACKAGES := $(filter-out XiaomiDolby XiaomiParts,$(PRODUCT_PACKAGES))

# AOSPA hardware/xiaomi megvii duplicates PixelOS hardware/lineage/compat.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/xiaomi/megvii

# PixelOS modules in these namespaces
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/bootctrl \
    hardware/qcom-caf/thermal

# Other-platform display trees duplicate AOSPA hardware/qcom/display modules.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8450-6.6/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8550/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8650/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8750/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8850/display

# AOSPA blobs provide the vendor display stack; the source tree duplicates
# libsdmcore/libsdmutils and the displayfeature HIDL.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/xiaomi/interfaces/xiaomi/hardware/displayfeature
