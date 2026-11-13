# ASUS ProArt PZ13 (HT5306QA): Qualcomm camera black screen - documented recovery

**A real, tested Windows 11 ARM64 recovery case (12 November 2026), not a universal camera driver or one-click fix.**

On an ASUS ProArt PZ13 HT5306QA with Snapdragon X Plus, both built-in RGB cameras stopped delivering images after Windows was reinstalled. Windows detected the cameras and the camera indicator lit up, but the Camera app showed a black preview or hung.

The application log showed repeated crashes:

```text
Faulting process : svchost.exe_FrameServer
Faulting module  : QcDeviceMFT8380.dll (4815.910.0.0)
Exception        : 0xc0000005 (access violation)
```

A controlled recovery selected **seven specific, signed camera component drivers from the official ASUS Qualcomm BSP V1.311.7800.0**, then rebooted. **Windows Update KB5132061 also completed during that reboot**, changing the Windows build from `26300.9711` to `26300.9974`. Afterwards, a camera probe received **52 frames from the rear camera** and **42 frames from the front camera**, with no relevant new crashes in the reviewed event logs. The user also confirmed normal camera operation.

> **Important limitation:** We cannot prove whether the driver selection alone, the Windows update alone, or their combination was necessary. The crashing Qualcomm DLL was **not** replaced or modified. The AVStream driver was also **not** changed. This is a documented *successful configuration*, not proof of a single root cause.

## What changed?

| Camera component (original INF basename) | Before | Working configuration |
| --- | --- | --- |
| `qccamrearsensor8380.inf` | `1.0.4338.2200` | `4885.512.0.0` |
| `qccamflash8380.inf` | `5102.349.0.0` | `1.0.4228.1700` |
| `qccamplatform8380.inf` | `5102.348.0.0` | `4815.842.0.0` |
| `qccamisp8380.inf` | `1.0.4478.2200` | `1.0.4228.1700` |
| `qccamjpege8380.inf` | `1.0.4478.2200` | `1.0.4228.1700` |
| `qccammipicsi8380.inf` | `1.0.4478.2200` | `1.0.4228.1700` |
| `qccamsecureisp8380.inf` | `1.0.4478.2200` | `1.0.4228.1700` |

Unchanged: `qccamavs8380.inf` / AVStream `4815.841.0.0`, front sensor `4885.512.0.0`, auxiliary sensor `4885.549.0.0`, and `QcDeviceMFT8380.dll` `4815.910.0.0` (same SHA-256). Local `oemNN.inf` names differ across installations; **never use these local numbers to identify packages on another PC**.

## For someone with a similar problem

1. **Identify the exact laptop model, Windows build, and camera driver versions.** Don't install ASUS drivers on another brand or model.
2. Check whether the camera failure is accompanied by a `svchost.exe_FrameServer` crash in `QcDeviceMFT8380.dll`. A black preview alone does not establish the same problem.
3. Use the read-only PowerShell helper at [`scripts/Inspect-QualcommCamera.ps1`](scripts/Inspect-QualcommCamera.ps1) to inspect your own system. It does **not** install, remove, or change anything.
4. Check for official firmware/driver guidance from your **own** device manufacturer and Windows Update. Back up the current drivers before any repair.
5. Read [`docs/RECOVERY_GUIDE.md`](docs/RECOVERY_GUIDE.md) and [`docs/TECHNICAL_CASE_STUDY.md`](docs/TECHNICAL_CASE_STUDY.md) to understand the exact successful case and its limits.

**Do not blindly force-install the listed driver versions.** Compatibility depends on your exact hardware identifiers, OEM extensions, Windows build, signatures, and rollback options. The private recovery automation is intentionally **not** distributed until independently reviewed and made model-safe.

## Source and results

- ASUS HT5306QA official drivers: <https://www.asus.com/us/supportonly/ht5306qa/helpdesk_download/>
- Source package used: `SOCPackage_forWebSite_Qualcomm_Z_V1.311.7800.0_43841_1.exe`
- Recorded installer SHA-256: `25C191E84302979AB3510568E2616F9D7B5111A720E23457E86D7C044AA62D6D`
- Before: rear camera 0 frames and FrameServer crash; front camera initialization timeout.
- After reboot: rear 52 frames at 640 x 480; front 42 frames at 2560 x 1440; no new camera-related crashes in reviewed logs.

The original full diagnosis and backup contain machine-specific logs and proprietary OEM packages. They are **not** published here.

## Related reports, not confirmed identical fixes

A [public HP OmniBook Snapdragon report](https://www.reddit.com/r/techsupport/comments/1vps9vb/hp_omnibook_14_snapdragon_x_plus_camera_and/) describes the **same DLL and exception code**, but a different DLL version and different hardware. It suggests a shared failure signature, **not** that ASUS packages should be installed on HP laptops.

## Contributing

If you encountered the same fault, you can open an issue with the laptop model, Windows build, original INF names, driver versions and error signature. **Remove personal names, serial numbers, account names, full machine paths, tokens and private data before posting.** See [`SECURITY_AND_PRIVACY.md`](SECURITY_AND_PRIVACY.md).

This repository is an independent community case study. It is not affiliated with or endorsed by ASUS, Qualcomm or Microsoft. No proprietary drivers or binary DLLs are redistributed.