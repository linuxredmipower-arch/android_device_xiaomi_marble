#
# PixelOS-CLO A17 product for marble, built on the AOSPA beryl device tree.
#
# SPDX-License-Identifier: Apache-2.0
#

# Audio
# AOSPA blobs provide the primary HAL module (audio.primary.taro.so) and the
# QTI PAL/AGM userspace. Build the AOSP HIDL wrapper that loads them; the
# device manifest already declares android.hardware.audio@7.0.
PRODUCT_PACKAGES += \
    android.hardware.audio@7.0-impl:64 \
    android.hardware.audio.effect@7.0-impl:64 \
    android.hardware.audio.service_64 \
    audio.r_submix.default:64 \
    audio.usb.default:64

# AOSP base products (AOSPA's aospa_marble.mk does the same)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit from marble device (AOSPA tree)
$(call inherit-product, device/xiaomi/marble/device.mk)

# AOSPA QTI init: loads /vendor_dlkm/lib/modules/modules.load at early-init
# and sets vendor.all.modules.ready, which init.qti.kernel.target.rc waits for.
# KERNEL_MODULES_OUT must be non-empty, otherwise qti-init.mk skips
# vendor_modprobe.sh and only sets the property without loading modules.
QCOM_COMMON_PATH := device/xiaomi/marble
KERNEL_MODULES_OUT := $(OUT_DIR)/target/product/$(TARGET_PRODUCT)/vendor_dlkm/lib/modules
include $(QCOM_COMMON_PATH)/vendor/init/qti-init.mk

# QTI common blobs (taro / kernel 5.10). AOSPA normally wires these through
# device/qcom/common + TARGET_COMMON_QTI_COMPONENTS; this tree does not carry
# that repo, so pull the component makefiles directly.
$(call inherit-product, vendor/qcom/common/vendor/adreno/s/adreno-vendor.mk)
# NOTE: the vendor/qcom/common display blobs overlap the AOSPA device display
# blobs (libsdm-disp-vndapis / libsdmextension install the same paths), so the
# common display-vendor.mk is intentionally not inherited here. The device
# blobs provide the composer stack; only optional HDR helpers are affected.
$(call inherit-product, vendor/qcom/common/vendor/media/5.10/media-vendor.mk)
$(call inherit-product, vendor/qcom/common/vendor/perf/perf-vendor.mk)
# Device blobs already provide cnss-daemon (cnss-daemon_xiaomi); the common
# wlan-vendor.mk would install a second /vendor/bin/cnss-daemon, so skip it and
# only pull the libraries the Wi-Fi stack needs.

# Dependencies of the cnss-daemon / lowi-server blobs.
PRODUCT_PACKAGES += \
    libcld80211 \
    libwpa_client

# Wi-Fi (QCOM WLAN, PixelOS-CLO flat qcwcn tree)
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/wlan \
    hardware/qcom-caf/wlan/qcwcn

BOARD_HAS_QCOM_WLAN := true
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
# (1 STA + 1 AP) or (1 STA + 1 of (P2P or NAN)) or (2 AP) or (2 STA)
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{AP}, 1}}, {{{STA}, 1}, {{P2P, NAN}, 1}}, {{{AP}, 2}}, {{{STA}, 2}}
WIFI_DRIVER_BUILT := qca_cld3
WIFI_DRIVER_DEFAULT := qca_cld3
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wlan"
WIFI_DRIVER_STATE_OFF := "OFF"
WIFI_DRIVER_STATE_ON := "ON"
WIFI_FEATURE_HOSTAPD_11AX := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    hostapd_cli \
    libwifi-hal-qcom:64 \
    wpa_cli \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml

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

# AOSPA display product config: sets SOONG_CONFIG_qtidisplay_default=true,
# which is what adds display_headers to libqdutils/libqservice etc.
BUILD_DISPLAY_TECHPACK_SOURCE := true
-include hardware/qcom/display/config/display-product.mk
SOONG_CONFIG_qtidisplay_displayconfig_enabled := true
SOONG_CONFIG_qtidisplay_var1 := false
SOONG_CONFIG_qtidisplay_var2 := false
SOONG_CONFIG_qtidisplay_var3 := false

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

# AOSPA device/qcom/common: only sepolicy is used; exclude its Soong modules to
# avoid duplicating hardware/qcom-caf/common.
PRODUCT_SOURCE_ROOT_DIRS += -device/qcom/common

# Other-platform display trees duplicate AOSPA hardware/qcom/display modules.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8450-6.6/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8550/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8650/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8750/display
PRODUCT_SOURCE_ROOT_DIRS += -hardware/qcom-caf/sm8850/display

# AOSPA blobs provide the vendor display stack; the source tree duplicates
# libsdmcore/libsdmutils and the displayfeature HIDL.
PRODUCT_SOURCE_ROOT_DIRS += -hardware/xiaomi/interfaces/xiaomi/hardware/displayfeature
