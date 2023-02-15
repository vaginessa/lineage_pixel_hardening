# android_patches
Extra patches for some Google devices on LineageOS-20.0.  
Uses the danielk43/DivestOS-Build project fork.  
Applied by DOS functions after sourcing.
## Usage
Clone this repo, and danielk43/DivestOS-Build to same directory  
Set these variables:
* Required
    * GIT_LOCAL (Path leading to both android_patches and DivestOS repos. Must be in same dir for now)
* Optional (LOS only)
    * AVB (Include patches for custom AVB key, to re-lock bootloader)
    * LINEAGE_BUILDTYPE (Set with this var for something besides UNOFFICIAL)
    * MICROG (Apply restricted sig spoof and add MicroG apks. Use this if not also using WITH_GMS)
    * WITH_GMS (Apply spoof, Use partitioning logic + gms makefile apks in vendor/lineage)
    * GMS_MAKEFILE (Specify path to makefile with apks in vendor/partner_gms)

Copy the appropriate set of manifests to .repo/local_manifests (LOS only)  
Prepare source:
```
rm -f .repo/local_manifests/roomservice.xml && \
repo forall -c "git am --abort; git add -A; git reset --hard" && \
repo sync --force-sync -j$(nproc)
```
Run the script:
```
${GIT_LOCAL}/android_patches/dos_apply.sh
```
To also apply DOS patches (optional, working for LOS20 Google devices):
```
${GIT_LOCAL}/DivestOS-Build/Scripts/LineageOS-20.0/Patch.sh
```
If AVB var is set, generate the private key + pkmd per [GrapheneOS instructions](https://grapheneos.org/build#generating-release-signing-keys)  
Run only two AVB steps (generate pem + extract), substituting -scrypt with -nocrypt  
Place avb.pem, avb_pkmd.bin in keys/crosshatch or keys/redbull depending on device  
Continue the rest of the build as usual, flash avb_pkmd.bin after if necessary
## Notes
Project is WIP  
LOS20 included devices supported  
GOS13 all devices partially supported (no DOS patching, manual update of gesture input lib)  
LOS19 unsupported
