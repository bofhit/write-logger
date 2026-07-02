# write-logger

## Purpose
A PowerShell module (`Write-Logger`) providing the same multi-destination logging concept as `ivy`/`logger`, but for PowerShell scripts: send log messages to console, file, and/or a syslog server, each with independently configurable severity thresholds (syslog levels 0-7, RFC 5424 style).

## Language / Stack
PowerShell module (`.psm1`/`.psd1`). Depends on the **Posh-SYSLOG** PowerShell module for syslog delivery (`Send-SyslogMessage`); the module checks for and refuses to load without it.

## Structure
Two published versions side by side:
- `1.0.0/Write-Logger.psd1` + `.psm1`
- `1.1.0/Write-Logger.psm1` + `.psd1`, plus `1.1.0/tests/Unit.Tests.ps1` (Pester tests)

1.1.0 adds a `LoggerName` parameter and convenience wrapper functions (`Write-LogDebug`, `Write-LogInfo`, `Write-LogWarning`, `Write-LogError`, `Write-LogCatchError`).

## Usage
Typical pattern: define a `$logArgs` hashtable (console/file/syslog levels, log file path, syslog server/port/facility) once at the top of a script, then call `Write-Logger -LogMessage '...' -LogLevel N @logArgs` (or the convenience functions) throughout. Destination levels default to `-1`, which disables that destination.

## Setup notes
Requires `Posh-SYSLOG` installed (`Get-Module -ListAvailable -Name Posh-SYSLOG` check at module load). No other dependencies.

## Security/quality flags
- No secrets found.
- Versioned releases with a real README and Pester unit tests — this is one of the more mature/polished repos in the set.
- Actively maintained: last commit 2025-09-30.
- This is the PowerShell counterpart to `ivy` (Python) — together they appear to be BoH's standard logging approach across both stacks.
