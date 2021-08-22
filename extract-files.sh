#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib/hw/camera.msm8937.so)
            sed -i 's|libgui.so|libwui.so|g' "${2}"
            ;;
        vendor/lib/libmmcamera_interface.so)
            # Direct loading this into camera.msm8937.so causes segfault
            patchelf --print-needed "${2}"|grep "libshims_gui.so">/dev/null
            if [ $? -ne 0 ]; then
                patchelf --add-needed "libshims_gui.so" "${2}"
            fi
            ;;
        vendor/lib/libmpbase.so \
        |vendor/lib/libFaceGrade.so \
        |vendor/lib/libarcsoft_beauty_shot.so)
            patchelf --replace-needed "libandroid.so" "libshims_android.so" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=riva
export DEVICE_SPECIFIED_COMMON=rova-common
export VENDOR=xiaomi

"./../../${VENDOR}/${DEVICE_SPECIFIED_COMMON}/extract-files.sh" "$@"
