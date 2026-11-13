# Security and privacy

- This is a community report, **not** an official OEM update and **not** a guarantee of compatibility.
- `scripts/Inspect-QualcommCamera.ps1` is read-only; review it before running. No signed driver installers, proprietary DLLs, or automated driver rebind scripts are included.
- The private recovery tool used Windows API driver force-selection after extensive model, hardware, signature, hash, and backup checks. Sharing a generic version would be unsafe without further engineering and independent validation.
- When reporting an issue, **do not upload full raw logs**. Remove machine names, Windows usernames, complete home-directory paths, email addresses, serial numbers, device serials, recovery keys, credentials and private project data. You can usually keep hardware *type* IDs and the relevant original INF names/versions.
- Do not replace the Qualcomm camera DLL manually, install other OEM drivers, mass-uninstall camera devices, or disable driver-signing protections.
- The recovery was observed on one ASUS HT5306QA. Windows KB5132061 completed in the same reboot as the driver rebind, so the unique causal fix cannot be isolated from the available evidence.
- Report problems through GitHub Issues using a sanitized description; do not send sensitive logs to strangers.