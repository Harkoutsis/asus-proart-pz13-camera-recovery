# Recovery decision guide (ASUS HT5306QA only)

**Read before doing anything.** This is a community case study and does not supply a one-click installer. If your camera works, do not change anything. If your device is not the ASUS ProArt PZ13 **HT5306QA**, do **not** use the ASUS driver versions as a repair recipe.

## Step 1 - Confirm the actual failure

- Confirm the laptop's full model and architecture (`ARM64`), OS build, and BIOS version.
- Check camera privacy and hardware shutter controls, if applicable.
- Inspect Windows Application event logs for `svchost.exe_FrameServer` crashing in `QcDeviceMFT8380.dll` with exception `0xc0000005`.
- Record the camera devices, **original INF basenames**, and signed driver versions. `oemNN.inf` numbers are specific to each Windows installation.
- Prefer an independent frame-capture test, not merely whether Device Manager says the camera is OK.

The read-only helper in `scripts/Inspect-QualcommCamera.ps1` displays key properties and recent crash events; it does not install or roll back anything.

## Step 2 - Use official sources and take backups

- Obtain camera components only from your exact model's official ASUS support page or the Microsoft Windows Update ecosystem.
- Check SHA-256 and digital signatures. OEM package hashes can change when ASUS refreshes an installer; an unexplained hash difference requires investigation.
- Preserve the current working drivers and map each original INF to its precise hardware IDs before any change.
- Create a **new** backup and document a feasible rollback procedure for the **current** state. A backup of an earlier broken state is not a generic undo.
- Check which OEM extension INF files belong with the components; do not assume mixed versions are automatically compatible.

## Step 3 - Understand the successful case

On 12 November 2026 the reported ASUS system moved to seven specific signed packages, detailed in the [technical case study](TECHNICAL_CASE_STUDY.md). The active AVStream INF and the faulting Qualcomm DLL remained unchanged. The change was applied using the Windows API `UpdateDriverForPlugAndPlayDevicesW` (`INSTALLFLAG_FORCE=1`) by a locally validated, model-checked tool. A reboot was required.

**Force selection overrides normal ranking.** It can destabilize a device when used incorrectly. No public force-install script is supplied, and installing these packages blindly is **not** recommended. If you are not experienced with driver recovery, ask your OEM's technical support to review the recorded working driver set and current OS version.

## Step 4 - Verify results if you perform an authorized repair

- Reboot after saving work if the driver installer requests it.
- Confirm both rear and front RGB cameras actually deliver image frames.
- Check that the Camera app opens normally and can switch between both cameras.
- Verify intended signed driver versions and no newly problematic devices.
- Review fresh Application events for FrameServer, `QcDeviceMFT8380.dll`, and Windows Camera crashes.
- Preserve test records and the *actual* current backup for any later recovery.

## Do NOT

- Download a standalone `QcDeviceMFT8380.dll` from an unknown website.
- Copy drivers from HP/Acer/Lenovo into an ASUS or vice versa.
- Delete the entire Qualcomm driver store, disable signature checks, or disable Secure Boot.
- Use forced driver selection if hardware IDs or package signatures do not match.
- Uninstall Windows updates just to prove which change fixed the case.
- Assume the case applies to all Snapdragon laptops or all Windows builds.

### Potentially relevant Microsoft references

- [Microsoft camera troubleshooting](https://support.microsoft.com/en-us/windows/hardware/camera/camera-doesn-t-work-in-windows)
- [PnPUtil syntax](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/pnputil-command-syntax)
- [Windows API referenced in the case study](https://learn.microsoft.com/en-us/windows/win32/api/newdev/nf-newdev-updatedriverforplugandplaydevicesw)