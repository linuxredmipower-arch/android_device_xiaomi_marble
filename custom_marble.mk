#
# PixelOS-CLO A17 product for marble, built on the AOSPA beryl device tree.
#
# SPDX-License-Identifier: Apache-2.0
#

# PixelOS: AOSP Soong audio service installs the init rc; skip the Make copy.
TARGET_SKIP_MAKE_AUDIO_SERVICE_RC := true

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
