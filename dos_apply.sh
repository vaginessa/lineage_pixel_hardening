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

if [[ -n ${ANDROID_BUILD_TOP} ]]; then
  echo "ANDROID_BUILD_TOP set, must be named 'lineage-20.0'"
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
  cd ${PROJECT_ROOT}
  if [[ -d build/make ]]; then
    cd build/make
    printf "Patching build/make\n"
    [[ -n "${DOS_DEBLOBBER_REMOVE_FP} = true" ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_build/0001-Remove-fp.patch"; #Remove fingerprint module
    [[ -n ${AVB} ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_build/0002-Patch-makefile-for-custom-avb.patch"; #Add support for custom AVB key
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d frameworks/base ]]; then
    cd frameworks/base
    printf "Patching frameworks/base\n"
    [[ -n "${MICROG}" || "${WITH_GMS}" = true ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_frameworks_base/0001-Apply-restricted-sig-spoof.patch"; #Support restricted sig spoofing
    git am --whitespace=nowarn "${PATCH_DIR}/android_frameworks_base/0002-Use-alternate-ntp-pool.patch"; #Use non-Android ntp pool
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d hardware/google/pixel ]]; then
    cd hardware/google/pixel
    printf "Patching hardware/google/pixel\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_hardware_google_pixel/0001-Remove-wifi-ext.patch"; #Remove wifi-ext
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d vendor/lineage ]]; then
    cd vendor/lineage
    printf "Patching vendor/lineage\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_vendor_lineage/0001-Allow-custom-build-types.patch"; #Remove restriction for build type
    git am --whitespace=nowarn "${PATCH_DIR}/android_vendor_lineage/0002-Update-webview-providers.patch"; #Allowlist Bromite webview
    git am --whitespace=nowarn "${PATCH_DIR}/android_vendor_lineage/0003-Replace-default-browser.patch"; #Install Bromite browser
    [[ ! "${WITH_GMS}" = true ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_vendor_lineage/0004-Add-extra-apks.patch"; #Add additional apks
    [[ -n "${MICROG}" && ! "${WITH_GMS}" = true ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_vendor_lineage/0005-Add-microg-apks.patch"; #Add microg apks
    curl https://raw.githubusercontent.com/GrapheneOS/platform_packages_apps_Dialer/13/java/com/android/voicemail/impl/res/xml/vvm_config.xml -o overlay/common/packages/apps/Dialer/java/com/android/voicemail/impl/res/xml/vvm_config.xml && git commit -am "GrapheneOS VVM"
    cd ${PROJECT_ROOT}
  fi;

  #DEVICE
  cd ${PROJECT_ROOT}
  if [[ -d device/google/barbet ]]; then
    cd device/google/barbet
    printf "Patching device/google/barbet\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_barbet/0001-barbet-Disable-mainline-checking.patch"; #Allow extra apks at build time
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d device/google/bramble ]]; then
    cd device/google/bramble
    printf "Patching device/google/bramble\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_bramble/0001-bramble-Disable-mainline-checking.patch"; #Allow extra apks at build time
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d device/google/coral ]]; then
    cd device/google/coral
    printf "Patching device/google/coral\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_coral/0001-floral-Disable-mainline-checking.patch"; #Allow extra apks at build time
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_coral/0002-floral-Remove-modules.patch"; #Debloat
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_coral/0003-floral-Remove-default-permissions.patch"; #Remove unused permissions
    [[ -n ${AVB} ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_coral/0004-floral-Add-custom-avb-key.patch"; #Add support for AVB
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d device/google/crosshatch ]]; then
    cd device/google/crosshatch
    printf "Patching device/google/crosshatch\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_crosshatch/0001-b1c1-Remove-modules.patch"; #Debloat
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_crosshatch/0002-b1c1-Remove-default-permissions.patch"; #Remove unused permissions
    [[ -n ${AVB} ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_crosshatch/0003-b1c1-Add-custom-avb-key.patch"; #Add support for AVB
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d device/google/redbull ]]; then
    cd device/google/redbull
    printf "Patching device/google/redbull\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_redbull/0001-redbull-Remove-modules.patch"; #Debloat
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_redbull/0002-redbull-Remove-default-permissions.patch"; #Remove unused permissions
    [[ -n ${AVB} ]] && git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_redbull/0003-redbull-Add-custom-avb-key.patch"; #Add support for AVB
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d device/google/redfin ]]; then
    cd device/google/redfin
    printf "Patching device/google/redfin\n"
    git am --whitespace=nowarn "${PATCH_DIR}/android_device_google_redfin/0001-redfin-Disable-mainline-checking.patch"; #Allow extra apks at build time
    cd ${PROJECT_ROOT}
  fi;

  #KERNEL
  cd ${PROJECT_ROOT}
  if [[ -d kernel/google/redbull ]]; then
    cd kernel/google/redbull
    printf "Patching kernel/google/redbull\n"
    "${GIT_LOCAL}"/DivestOS-Build/Scripts/"${BUILD_WORKING_DIR}"/CVE_Patchers/android_kernel_google_redbull.sh
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d kernel/google/msm-4.14 ]]; then
    cd kernel/google/msm-4.14
    printf "Patching kernel/google/msm-4.14\n"
    "${GIT_LOCAL}"/DivestOS-Build/Scripts/"${BUILD_WORKING_DIR}"/CVE_Patchers/android_kernel_google_msm-4.14.sh
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d kernel/google/msm-4.9 ]]; then
    cd kernel/google/msm-4.9
    printf "Patching kernel/google/msm-4.9\n"
    "${GIT_LOCAL}"/DivestOS-Build/Scripts/"${BUILD_WORKING_DIR}"/CVE_Patchers/android_kernel_google_msm-4.9.sh
    cd ${PROJECT_ROOT}
  fi;

  #VENDOR
  cd ${PROJECT_ROOT}
  for codename in barbet blueline bramble coral crosshatch flame redfin
  do
    if [[ -d vendor/google/"$codename" ]]; then
      cd vendor/google/"$codename"
      printf "Patching vendor/google/$codename\n"
      git am --whitespace=nowarn "${PATCH_DIR}/proprietary_vendor_google_$codename/0001-$codename-Add-gesture-input.patch";
      printf "\nPRODUCT_COPY_FILES += \\ \n    vendor/google/$codename/proprietary/product/lib64/libjni_latinimegoogle.so:\$(TARGET_COPY_OUT_PRODUCT)/lib64/libjni_latinimegoogle.so" | tee -a $codename-vendor.mk
      cd ${PROJECT_ROOT}
    fi;
  done
elif [[ ${PROJECT_ROOT,,} =~ "graphene" ]]; then

  #ROM
  cd ${PROJECT_ROOT}
  if [[ -d frameworks/base ]]; then
    cd frameworks/base
    printf "Patching frameworks/base\n"
    git am --whitespace=nowarn ${PATCH_DIR}/platform_frameworks_base/0001-Update-dns-references.patch #Use quad9 dns
    git am --whitespace=nowarn ${PATCH_DIR}/platform_frameworks_base/0002-Use-alternate-ntp-pool.patch #Use non-Android ntp pool
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d packages/inputmethods/LatinIME ]]; then
    cd packages/inputmethods/LatinIME
    printf "Patching packages/inputmethods/LatinIME\n"
    git am --whitespace=nowarn ${PATCH_DIR}/platform_packages_inputmethods_LatinIME/0001-Enable-gesture-input.patch #Reenable gesture typing
    cd ${PROJECT_ROOT}
  fi;
  
  if [[ -d packages/modules/Connectivity ]]; then
    cd packages/modules/Connectivity
    printf "Patching packages/modules/Connectivity\n"
    git am --whitespace=nowarn ${PATCH_DIR}/platform_packages_modules_Connectivity/0001-Update-dns-references.patch #Use quad9 dns
    cd ${PROJECT_ROOT}
  fi;

  if [[ -d script ]]; then
    cd script
    printf "Patching script\n"
    git am --whitespace=nowarn ${PATCH_DIR}/script/0001-Alias-signify-cmd-if-applicable.patch #Add shim for signing builds on debian
    cd ${PROJECT_ROOT}
  fi;
fi

#
#END OF CHANGES
#

