# Technical case study: Windows 11 ARM64 Qualcomm camera pipeline crash

## Scope

Observed on **ASUS ProArt PZ13 HT5306QA**, Qualcomm Snapdragon X Plus, Windows 11 Pro 26H2 (ARM64), BIOS `HT5306QA.311`. Test and repair occurred on **12 November 2026**; records were reviewed on **13 November 2026**.

A Windows reinstall was followed by a black Camera preview (sometimes hanging), despite enabled camera permissions, present cameras, and functional device enumeration. Standard Camera app reset, Basic Camera, full ASUS BSP install, PnP restarts, and a Windows Update search for an exact AVStream update had not resolved it.

## Verified failure signature

Application events recorded:

```text
Application: svchost.exe_FrameServer
Module:      QcDeviceMFT8380.dll, version 4815.910.0.0
Exception:   0xc0000005
Fault offset: 0x0000000000740f24
Event 1000: 2026-11-12 01:30:57 (UTC+02:00)
WER 1001:   2026-11-12 01:31:14 (UTC+02:00)
```

`0xc0000005` is an access violation; it does not reveal the internal bug or establish whether a specific driver, MFT, Windows component, or hardware interface caused the failure.

A local MediaCapture / MediaFrameReader probe showed:

| Measurement | Before, rear 13 MP | Before, front 5 MP | After, rear | After, front |
| --- | --- | --- | --- | --- |
| MediaCapture initialize | 555 ms | Timed out | 298 ms | 106 ms |
| Reader start | Success | Not reached | Success | Success |
| Distinct frames | 0 | No frames | 52 | 42 |
| CPU bitmap frames | 0 | None | 52 | 42 |
| Probe finished | Timeout at 25 s | Timeout at 25 s | Yes | Yes |
| Frame dimensions | N/A | N/A | 640 x 480 | 2560 x 1440 |

These are frame samples in bounded probes, **not measured nominal camera frame rates**. Frame content statistics and a final user check supported genuine images rather than fixed black data.

## Exact signed driver selection

All seven component packages came from the OEM's official `Qualcomm Board Support Package V1.311.7800.0` for HT5306QA. The existing ASUS installer was selectively extracted, and each chosen original INF was verified against its signed package/catalog, target hardware ID, source hash, and a backup. A Windows API call (`UpdateDriverForPlugAndPlayDevicesW` with `INSTALLFLAG_FORCE=1`) explicitly selected the intended INF. Seven calls succeeded (`Win32Error=0`); five reported that a reboot was required.

| Original INF | Hardware ID prefix | Previously active | Selected from ASUS BSP |
| --- | --- | --- | --- |
| `qccamrearsensor8380.inf` | `ACPI\QCOM0C26` | `1.0.4338.2200` | `4885.512.0.0` |
| `qccamflash8380.inf` | `ACPI\QCOM0C27` | `5102.349.0.0` | `1.0.4228.1700` |
| `qccamplatform8380.inf` | `ACPI\QCOM0C32` | `5102.348.0.0` | `4815.842.0.0` |
| `qccamisp8380.inf` | `ACPI\QCOM0C25` | `1.0.4478.2200` | `1.0.4228.1700` |
| `qccamjpege8380.inf` | `ACPI\QCOM0C33` | `1.0.4478.2200` | `1.0.4228.1700` |
| `qccammipicsi8380.inf` | `ACPI\QCOM0C98` | `1.0.4478.2200` | `1.0.4228.1700` |
| `qccamsecureisp8380.inf` | `ACPI\QCOM0CCC` | `1.0.4478.2200` | `1.0.4228.1700` |

The **AVStream** component `qccamavs8380.inf` remained on driver `4815.841.0.0`; the front sensor remained `4885.512.0.0`, and auxiliary sensor `4885.549.0.0`. Both camera captures therefore worked with the *same AVStream driver* that had been present during the failures.

The faulting `QcDeviceMFT8380.dll` was **unchanged**: version `4815.910.0.0`, SHA-256 `16468FC348643D0F917E6CB64ECC676414963EC0886094BFBDC0D35416831B69`, valid Authenticode signature. A different INF package version number and DLL version number within the same OEM release is not by itself evidence of corruption.

## Windows update confounder

During the same repair window, Windows servicing independently staged and installed **KB5132688** and **KB5132061**. The latter required a reboot and completed at approximately `07:00` local time on 12 November 2026. The recorded Windows build changed from `26300.9711` to `26300.9974`. The seven driver changes were applied earlier, approximately `06:38`; the reboot started approximately `06:57`. Automated camera tests succeeded at approximately `09:57` local time.

The repair did **not** run the KB installer. **There was no controlled before/after experiment isolating the effects of the seven driver selections from the OS update.** The documented outcome is the combination of selected OEM component drivers + updated Windows + reboot.

## What was NOT done

- No manual modification or replacement of Qualcomm DLLs.
- No change to AVStream or front/auxiliary sensor drivers during the successful repair.
- No disabling driver signature verification or Secure Boot.
- No registry workaround for FrameServer / MFT / Studio Effects.
- No BIOS flash, mass Qualcomm driver removal, or third-party driver downloads.
- No Windows reinstall as part of this repair.

## Outcome and limitations

Post-reboot checks confirmed 7/7 intended active driver versions, valid driver signatures, no newly problematic PnP devices, successful frame capture from both RGB cameras, and no relevant new FrameServer crashes in the reviewed test window. The user confirmed normal Camera operation. This did **not** test Windows Hello, every camera photo/video mode, long-term reliability, or reproduce the original fault on the new Windows build.

We cannot infer a unique defective component from these observations. The original capture pipeline may have been affected by a mismatched driver set, Windows changes, or both. Replicating the same selection on another OEM model is unsupported.

## References

- ASUS official support for HT5306QA: <https://www.asus.com/us/supportonly/ht5306qa/helpdesk_download/>
- Microsoft API (advanced reference; not a recommendation to force-install): <https://learn.microsoft.com/en-us/windows/win32/api/newdev/nf-newdev-updatedriverforplugandplaydevicesw>
- Microsoft PnPUtil syntax and rank behavior: <https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/pnputil-command-syntax>
- Microsoft Device MFT architecture: <https://learn.microsoft.com/en-us/windows-hardware/drivers/stream/dmft-design>

This document summarizes a privately retained, timestamped diagnostic report. Raw logs, local filesystem identifiers, proprietary packages and driver binaries have not been uploaded.