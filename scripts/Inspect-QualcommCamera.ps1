# Read-only Qualcomm camera diagnostic summary for Windows 11.
# Does not change device state, drivers, registry, services, or system policy.
# Does not create files or transmit information.
# Review and redact the output before posting it publicly.

[CmdletBinding()]
param(
    [ValidateRange(1, 90)]
    [int] $LookbackDays = 7
)

$ErrorActionPreference = 'Stop'
Write-Host '== Windows / device =='
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $system = Get-CimInstance -ClassName Win32_ComputerSystem
    [pscustomobject]@{
        Manufacturer = $system.Manufacturer
        Model        = $system.Model
        OS           = $os.Caption
        Version      = $os.Version
        Architecture = $os.OSArchitecture
    } | Format-List | Out-Host
} catch {
    Write-Warning "Unable to read system information: $($_.Exception.Message)"
}

Write-Host '== Qualcomm / Spectra / ASUS camera signed drivers =='
try {
    $drivers = @(Get-CimInstance -ClassName Win32_PnPSignedDriver |
        Where-Object {
            $_.DeviceName -match 'Camera|Spectra|Qualcomm.*(ISP|Sensor|Flash|Mipi|JPEG)' -or
            $_.InfName -match '(?i)qccam'
        } |
        Sort-Object DeviceName)
    if ($drivers.Count -eq 0) { Write-Host 'No matching signed camera drivers found.' }
    else {
        $drivers |
            Select-Object DeviceName, InfName, DriverVersion, DriverProviderName, IsSigned |
            Format-Table -AutoSize -Wrap | Out-Host
    }
} catch {
    Write-Warning "Unable to list signed drivers: $($_.Exception.Message)"
}

Write-Host "== Recent FrameServer / Camera crashes (last $LookbackDays day(s)) =="
try {
    $events = @(Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = @(1000, 1001, 1002)
        StartTime = (Get-Date).AddDays(-$LookbackDays)
    } -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Message -match 'QcDeviceMFT8380|svchost\.exe_FrameServer|WindowsCamera\.exe'
        } |
        Select-Object TimeCreated, Id, ProviderName, Message)
    if ($events.Count -eq 0) {
        Write-Host 'No matching events were returned (or the log had no accessible matches).'
    } else {
        $events | ForEach-Object {
            Write-Host ("[{0}] Event {1} ({2})" -f $_.TimeCreated, $_.Id, $_.ProviderName)
            $brief = $_.Message -split "`r?`n" | Where-Object { $_ -match 'Faulting|Exception|FrameServer|Camera|QcDeviceMFT8380' }
            $brief | Select-Object -First 8 | ForEach-Object { Write-Host $_ }
            Write-Host ''
        }
    }
} catch {
    Write-Warning "Event log query failed: $($_.Exception.Message)"
}

Write-Host '== Finished: read-only inspection =='
Write-Host 'Do not post raw output without redacting user paths, serial numbers and other identifying data.'
