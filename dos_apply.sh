#!/bin/bash
#DivestOS: A privacy focused mobile distribution
#Copyright (c) 2015-2022 Divested Computing Group
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.
umask 0022;
set -eo pipefail;

#Last verified: 2023-02-12

if [[ -n ${ANDROID_BUILD_TOP} ]]; then
  echo "ANDROID_BUILD_TOP set, valid basenames are 'lineage-20.0' and 'lineage-19.0'"
  export PROJECT_ROOT=${ANDROID_BUILD_TOP}
else
  echo "ANDROID_BUILD_TOP not set, using PWD for project root. must be named 'grapheneos-13'"
  export PROJECT_ROOT=${PWD}
fi

echo PROJECT_ROOT=${PROJECT_ROOT}
export PATCH_DIR="${GIT_LOCAL}/lineage_pixel_hardening/${PROJECT_ROOT##*/}"

export DOS_WORKSPACE_ROOT=${GIT_LOCAL}"/DivestOS-Build"; #XXX: THIS MUST BE CORRECT TO PATCH
[[ ${PROJECT_ROOT##*/} =~ "lineage" ]] && source "${DOS_WORKSPACE_ROOT}/Scripts/init.sh" # Skip DOS scripts for GOS

#
#START OF CHANGES
#

if [[ ${PROJECT_ROOT,,} =~ "lineage" ]]; then
  #ROM
  if enterAndClear "build/make"; then
    [[ -n "${DOS_DEBLOBBER_REMOVE_FP} = true" ]] && applyPatch "${PATCH_DIR}/android_build/0001-Remove-fp.patch"; #Remove fingerprint module
    [[ -n ${AVB} ]] && applyPatch "${PATCH_DIR}/android_build/0002-Patch-makefile-for-custom-avb.patch"; #Add support for custom AVB key
  fi;

  if enterAndClear "frameworks/base"; then
    [[ -n "${MICROG}" || "${WITH_GMS}" = true ]] && applyPatch "${PATCH_DIR}/android_frameworks_base/0001-Apply-restricted-sig-spoof.patch"; #Support restricted sig spoofing
    applyPatch "${PATCH_DIR}/android_frameworks_base/0002-Use-alternate-ntp-pool.patch"; #Use non-Android ntp pool
  fi;

  if enterAndClear "hardware/google/pixel"; then
    applyPatch "${PATCH_DIR}/android_hardware_google_pixel/0001-Remove-wifi-ext.patch"; #Remove wifi-ext
  fi;

  if enterAndClear "vendor/lineage"; then
    applyPatch "${PATCH_DIR}/android_vendor_lineage/0001-Allow-custom-build-types.patch"; #Remove restriction for build type
    applyPatch "${PATCH_DIR}/android_vendor_lineage/0002-Update-webview-providers.patch"; #Allowlist Bromite webview
    applyPatch "${PATCH_DIR}/android_vendor_lineage/0003-Replace-default-browser.patch"; #Install Bromite browser
    [[ ! "${WITH_GMS}" = true ]] && applyPatch "${PATCH_DIR}/android_vendor_lineage/0004-Add-extra-apks.patch"; #Add additional apks
    [[ -n "${MICROG}" && ! "${WITH_GMS}" = true ]] && applyPatch "${PATCH_DIR}/android_vendor_lineage/0005-Add-microg-apks.patch"; #Add microg apks
    [[ -n "${OLD_VVM}" ]] && git revert --no-edit e0d3e2892dcfbe281e3db63e314b63274c8b1063 #Use older visual voicemail dialer cfg
  fi;

  #DEVICE

  if enterAndClear "device/google/bramble"; then
    applyPatch "${PATCH_DIR}/android_device_google_bramble/0001-bramble-Disable-mainline-checking.patch"; #Allow extra apks at build time
  fi;

  if enterAndClear "device/google/crosshatch"; then
    applyPatch "${PATCH_DIR}/android_device_google_crosshatch/0001-b1c1-Remove-modules.patch"; #Debloat
    applyPatch "${PATCH_DIR}/android_device_google_crosshatch/0002-b1c1-Remove-default-permissions.patch"; #Remove unused permissions
    [[ -n ${AVB} ]] && applyPatch "${PATCH_DIR}/android_device_google_crosshatch/0003-b1c1-Add-custom-avb-key.patch"; #Add support for AVB
  fi;

  if enterAndClear "device/google/redbull"; then
    applyPatch "${PATCH_DIR}/android_device_google_redbull/0001-redbull-Remove-modules.patch"; #Debloat
    applyPatch "${PATCH_DIR}/android_device_google_redbull/0002-redbull-Remove-default-permissions.patch"; #Remove unused permissions
    [[ -n ${AVB} ]] && applyPatch "${PATCH_DIR}/android_device_google_redbull/0003-redbull-Add-custom-avb-key.patch"; #Add support for AVB
  fi;

  #KERNEL

  if enterAndClear "kernel/google/redbull"; then
    "${GIT_LOCAL}"/DivestOS-Build/Scripts/"${BUILD_WORKING_DIR}"/CVE_Patchers/android_kernel_google_redbull.sh
  fi;

  if enterAndClear "kernel/google/msm-4.9"; then
    "${GIT_LOCAL}"/DivestOS-Build/Scripts/"${BUILD_WORKING_DIR}"/CVE_Patchers/android_kernel_google_msm-4.9.sh
  fi;

  #VENDOR

  if enterAndClear "vendor/google/bramble"; then
    git am "${PATCH_DIR}/proprietary_vendor_google_bramble/0001-bramble-Add-gesture-input.patch";
    applyPatch "${PATCH_DIR}/proprietary_vendor_google_bramble/0002-bramble-Update-priv-apps.patch"; #Deblob priv-apps
    applyPatch "${PATCH_DIR}/proprietary_vendor_google_bramble/0003-bramble-Update-apps.patch"; #Deblob apps
  fi;

  if enterAndClear "vendor/google/crosshatch"; then
    git am "${PATCH_DIR}/proprietary_vendor_google_crosshatch/0001-crosshatch-Add-gesture-input.patch";
    applyPatch "${PATCH_DIR}/proprietary_vendor_google_crosshatch/0002-crosshatch-Update-priv-apps.patch"; #Deblob priv-apps
    applyPatch "${PATCH_DIR}/proprietary_vendor_google_crosshatch/0003-crosshatch-Update-apps.patch"; #Deblob apps
  fi;
elif [[ ${PROJECT_ROOT,,} =~ "graphene" ]]; then
  #ROM
  # if enterAndClear "frameworks/base"; then
  #   applyPatch "${PATCH_DIR}/platform_frameworks_base/0001-Update-dns-references.patch"; #Use quad9 dns
  #   applyPatch "${PATCH_DIR}/platform_frameworks_base/0002-Use-alternate-ntp-pool.patch"; #Use non-Android ntp pool
  # fi;

  # if enterAndClear "packages/inputmethods/LatinIME"; then
  #   applyPatch "${PATCH_DIR}/platform_packages_inputmethods_LatinIME/0001-Enable-gesture-input.patch"; #Reenable swipe keyboard
  # fi;

  # if enterAndClear "packages/modules/Connectivity"; then
  #   applyPatch "${PATCH_DIR}/platform_packages_modules_Connectivity/0001-Update-dns-references.patch"; #Use quad9 dns
  # fi;

  # if enterAndClear "script"; then
  #   applyPatch "${PATCH_DIR}/script/0001-Alias-signify-cmd-if-applicable.patch"; #Add shim for signing on debian
  # fi;

  # do this outside of DOS for now
  cd frameworks/base
  git am ${PATCH_DIR}/platform_frameworks_base/0001-Update-dns-references.patch
  git am ${PATCH_DIR}/platform_frameworks_base/0002-Use-alternate-ntp-pool.patch
  cd ${PROJECT_ROOT}

  cd packages/inputmethods/LatinIME
  git am ${PATCH_DIR}/platform_packages_inputmethods_LatinIME/0001-Enable-gesture-input.patch
  cd ${PROJECT_ROOT}
  
  cd packages/modules/Connectivity
  git am ${PATCH_DIR}/platform_packages_modules_Connectivity/0001-Update-dns-references.patch
  cd ${PROJECT_ROOT}

  cd script
  git am ${PATCH_DIR}/script/0001-Alias-signify-cmd-if-applicable.patch
  cd ${PROJECT_ROOT}

fi

#
#END OF CHANGES
#

