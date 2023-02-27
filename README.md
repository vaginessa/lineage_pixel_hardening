# lineage_pixel_hardening
## patches
Patching for some Pixel devices on LineageOS-20.0 which provide extra features.  

Uses the Divested-Mobile/DivestOS-Build project fork to source patching functions.  
Uses the LineageOS4MicroG/android_vendor_partner_gms project fork for extra apks.  

Combine with DOS source and kernel patches for LineageOS hardening without rebranding, customizable apks.
* Patches from this repo:
    * Restore gesture input (swipe typing) on native AOSP keyboard
    * Enable verified boot (AVB) to re-lock bootloader
    * Add MicroG restricted signature spoofing and installation (optional)
    * Replace default browser and webview with Bromite and Mulch
    * Add FDroid, AuroraStore, and privileged extensions
    * Add GrapheneOS PDFViewer
    * Vendor deblobbing specific to Pixel
    * Disable Google Assistant
    * Use non-Android NTP server
    * Restore pre-November 2022 visual voicemail dialer config (optional)
* DivestOS patches:
    * Kernel and Defconfig hardening
    * Enhance location services
    * Enable full dexpreopt
    * Harden /data
    * Disable APEX
    * Disable enforced RRO
    * Deblob audio
    * SUPL No IMSI
    * SUPL Disable
    * Notify user of SUPL requests
    * Connectivity check options and disable
    * Remove Analytics
    * Remove Fingerprint
    * Remove IMS
    * Fix calling when IMS is removed
    * Tor Support for Updater
    * Remove voice input key
    * AdBlock via hosts file
    * Toggle to disable hosts file
    * Broken Camera fixes
    * Disable DropBox internal logging
    * Disable partition fingerprint mismatch warnings
    * Skip strict update compatibiltity checks
    * Support Android Wear
    * Creates popups to install proprietary print apps
    * Lots more... (See DOS 20.0 Patch.sh)
* GrapheneOS patches:
    * Hardened memory allocation
    * Bionic hardening
    * Exec-based spawning
    * Selective APEX
    * Enable fwrapv
    * Secure camera
    * Constify Java
    * Sensor and Nearby Devices permissions
    * Special runtime permissions
    * Always Restrict Serial
    * Browser No Location
    * Fingerprint Lockout
    * User Logout
    * Automatic Reboot
    * System Server Extensions
    * Enable app compaction
    * Increase default max password length to 64
    * Even more... (See DOS 20.0 Patch.sh)
* CalyxOS Patches:
    * Don't prompt to add account when creating a contact
    * Add a privacy warning banner to calls
    * Private DNS Options
    * WiFi and Bluetooth timeout

Deblobbing privacy limitations:
* WiFi Calling disabled
* eSIM disabled
* GoogleFi disabled
## Usage
Clone this repo, and danielk43/DivestOS-Build to same directory  
Install [Git LFS](https://git-lfs.com)  
Set these variables:
* Required
    * GIT_LOCAL (Path leading to both lineage_pixel_hardening and DivestOS repos. Must be in same dir for now)
* Optional (LOS only)
    * AVB (Include patches for custom AVB key)
    * LINEAGE_BUILDTYPE (Set with this var for something besides UNOFFICIAL)
    * MICROG (Apply restricted sig spoof and add MicroG apks. Use this if not also using WITH_GMS)
    * OLD_VVM (Revert visual voicemail config update which breaks vvm for some carriers)
    * WITH_GMS (Apply spoof, Use partitioning logic + gms makefile apks in vendor/lineage)
    * GMS_MAKEFILE (Specify path to makefile with apks in vendor/partner_gms)

Copy the appropriate set of manifests to .repo/local_manifests (LOS only)  

If AVB var is set, generate the private key + pkmd per [GrapheneOS instructions](https://grapheneos.org/build#generating-release-signing-keys)  

Run only two AVB steps (generate pem + extract), substituting -scrypt with -nocrypt  
Place avb.pem, avb_pkmd.bin in keys/crosshatch or keys/redbull depending on device  

Prepare source:
```
rm -f .repo/local_manifests/roomservice.xml && \
repo forall -c "git am --abort; git add -A; git reset --hard" && \
repo sync --force-sync -j$(nproc) && \
repo forall -c "git lfs pull" && \
source build/envsetup.sh
```
Run the script:
```
${GIT_LOCAL}/lineage_pixel_hardening/dos_apply.sh
```
To also apply DOS patches (optional, working for LOS20 Google devices):
```
${GIT_LOCAL}/DivestOS-Build/Scripts/LineageOS-20.0/Patch.sh
```
Some warnings in red for missing devices/repos are normal, if the Patch scripts run to completion.  

Continue the rest of the build as usual, using the [LineageOS instructions](https://wiki.lineageos.org/signing_builds#generating-the-keys) for signed builds  
If generating keys, make sure to also add bluetooth and sdksandbox to the key generation loop, and remove testkey  

Once finished, before installing the OS flash avb_pkmd.bin after if necessary  
## Notes
Project is WIP  
LOS20 included devices supported  
GOS13 all devices partially supported (no DOS patching, manual update of gesture input lib)  
LOS19 unsupported/untested
