# android_patches
Extra patches for some Google devices on LineageOS-20.0.  
Uses the danielk43/DivestOS-Build project fork.  
Applied by DOS functions after sourcing.
## Usage
Copy the correct set of manifests to .repo/local_manifests  
Set these variables
* Required
    * GIT_LOCAL (Path leading to both android_patches and DivestOS reops. Must be in same dir for now)
* Optional (LOS only)
    * LINEAGE_BUILDTYPE (Set with this var for something besides UNOFFICIAL)
    * MICROG (Apply signature spoofing and add MicroG apks)
    * WITH_GMS (Use partitioning logic in vendor/lineage)
    * GMS_MAKEFILE (Specify path to makefile with apks in vendor/partner_gms)

Run the script:
```
cd $GIT_LOCAL/android_patches && ./dos_apply.sh
```
To also apply DOS patches (optional):
```
cd $GIT_LOCAL/DivestOS-Build/Scripts/LineageOS-20.0 && ./Patch.sh
```
## Notes
Project is WIP
