<#
.SYNOPSIS
    Send log messages to console, file, and/or syslog server.
.DESCRIPTION
    Send log messages to console, file and/or syslog server.
    * Different log levels can be specified for each destination.
    * Destination log levels default to -1, which disables logging for that
        destination.
    * There a lot of parameters, so normally I would define a hash table
        at the top of a script, and use parameter splatting.
.EXAMPLE
    # Call from console. Useful for testing.
    Write-Logger -LogMessage 'My message.' -LogLevel 6 -ConsoleLogLevel 7
.EXAMPLE
    # Use for script logging.
    # Top of the script.
    $logArgs = @{
        LoggerName = 'My-Script'
        ConsoleLogLevel = 7     # Debug
        FileLogLevel = 6        # Info
        SyslogLevel = 4         # Warning
        LogFilePath = 'mypath.log'
        SyslogServer = 'server.host'
        SyslogPort = 514
        SyslogFacility = 10
    }

    # Later in the script.
    Write-Logger -LogMessage 'My info message' -LogLevel 6 $logArgs

    ...

    Write-Logger -LogMessage 'My error message' -LogLevel 3 $logArgs

.NOTES
    Depends on PoSH-Syslog to send syslog messages.
#>

# ============================================================================
# Check for depedency.
if (-not (Get-Module -ListAvailable -Name Posh-SYSLOG)) {
    Write-Host 'Please install the Posh-SYSLOG module.'
    Exit-PSHostProcess
}

# ============================================================================
# Convenience functions.
# Impelmented for levels I use most.

Function Log-Debug{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,
        
        [Parameter(Mandatory=$true,
            HelpMessage='Dictionary of logger arguments.'
            )][hashtable]$LogArgs
    )

    Write-Logger -LogMessage $LogMessage 7 $LogSeverity @LogArgs
}

Function Log-Info {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,
        
        [Parameter(Mandatory=$true,
            HelpMessage='Dictionary of logger arguments.'
            )][hashtable]$LogArgs
    )

    Write-Logger -LogMessage $LogMessage 6 $LogSeverity @LogArgs
}

Function Log-Warning {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,
        
        [Parameter(Mandatory=$true,
            HelpMessage='Dictionary of logger arguments.'
            )][hashtable]$LogArgs
    )

    Write-Logger -LogMessage $LogMessage 4 $LogSeverity @LogArgs
}

Function Log-Error {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,
        
        [Parameter(Mandatory=$true,
            HelpMessage='Dictionary of logger arguments.'
            )][hashtable]$LogArgs
    )

    Write-Logger -LogMessage $LogMessage 3 $LogSeverity @LogArgs
}

Function Log-CatchError {
    <#
    Similar to the other convenience functions, except it sends the last 
    PowerShell error in addition to the message passed as an argument.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,
        
        [Parameter(Mandatory=$true,
            HelpMessage='Dictionary of logger arguments.'
            )][hashtable]$LogArgs
    )

    Write-Logger -LogMessage $LogMessage 3 $LogSeverity @LogArgs
    Write-Logger -LogMessage $Error[-1] 3 $LogSeverity @LogArgs
}

Function Write-Logger {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            HelpMessage='Logger name.'
            )][string]$LoggerName,

        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$true,
            HelpMessage='Log severity'
            )][Int32]$LogSeverity,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$false,
            HelpMessage='Console log level.'
            )][string]$ConsoleLogLevel = -1,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$false,
            HelpMessage='File log level.'
            )][string]$FileLogLevel = -1,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$false,
            HelpMessage='Syslog log level.'
            )][string]$SyslogLogLevel = -1,

        [Parameter(Mandatory=$false,
            HelpMessage='Log file path.'
            )][string]$LogFilePath,

        [Parameter(Mandatory=$false,
            HelpMessage='Syslog server host.'
            )][string]$SyslogServer,

        [Parameter(Mandatory=$false,
            HelpMessage='Syslog server port.'
            )][Int32]$SyslogPort,

        [ValidateRange(0, 23)]
        [Parameter(Mandatory=$false,
            HelpMessage='Syslog facility number'
            )][Int32]$SyslogFacility,

        [Parameter(Mandatory=$false,
            HelpMessage='Log file max lines'
            )][Int32]$LogFileMaxLines=10000
    )

    $SEVERITY_KEYWORD_LUT = @{
        0='EMERG';
        1='ALERT';
        2='CRIT';
        3='ERR';
        4='WARNING';
        5='NOTICE';
        6='INFO';
        7='DEBUG';
    }

# ============================================================================
    # Send message.

    $message = "[$($SEVERITY_KEYWORD_LUT[$LogSeverity])]`t $($LogMessage)"
    $messageWithLoggerName = "[$($SEVERITY_KEYWORD_LUT[$LogSeverity])]`t [$($LoggerName)] $($LogMessage)"

    # To console.
    if (($ConsoleLogLevel -gt -1) -and ($ConsoleLogLevel -ge $LogSeverity)){
        $timestamp = (Get-Date).ToString('HH:mm:ss')
        Write-Host "$timestamp $message"
    }

    # To file.
    if (($FileLogLevel -gt -1) -and ($FileLogLevel -ge $LogSeverity)){
        $timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
        Add-Content "$timestamp $message" -Path $LogFilePath

        $rows = Get-Content $LogFilePath
        Set-Content -Value $rows[-$($LogFileMaxLines).. -1] -Path $LogFilePath
    }

    # To syslog server.
    if (($SyslogLogLevel -gt -1) -and ($SyslogLogLevel -ge $LogSeverity)){

        $syslogArgs = @{
            Message = $messageWithLoggerName;
            Severity = $LogSeverity;
            Server = $SyslogServer;
            Port = $SyslogPort;
            Facility = $SyslogFacility
        }

        Send-SyslogMessage @syslogArgs
    }
}

Export-ModuleMember -Function *

