<#
.SYNOPSIS
    Send log messages to console, file, and/or syslog server.
.DESCRIPTION
    Send log messages to console, file and/or syslog server. 
    * Different log levels can be specified for each destination. 
    * Destination log levels default to -1, which turns logging off for that 
        destination.
    * There a lot of parameters, so normally I would define a hash table 
        at the top of a script, and use parameter splatting.
.EXAMPLE
   Write-Log -LogMessage 'My message.' -LogLevel 6 -ConsoleLogLevel 7
.EXAMPLE
    # Top of the script.
    $logArgs = @{
        ConsoleLogLevel = 7     # Debug 
        FileLogLevel = 6        # Info 
        SyslogLevel = 4         # Warning
        LogFilePath = 'mypath.log'
        SyslogServer = 'server.host'
        SyslogPort = 514
        SyslogFacility = 10
    }
    
    # Later in the script.
    Write-Log -LogMessage 'My message' -LogLevel 5 $logArgs

    # Yet later.
    Write-Log -LogMessage 'My next message' -LogLevel 3 $logArgs

.NOTES
    Depends on PoSH-Syslog to send syslog message.
#>
Function Write-Log {
    [CmdletBinding()]
    Param(
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
            )][Int32]$SyslogFacility
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
    # Assemble message.
    $timestamp = (Get-Date).ToString('yyyy-MM-ddTHH.mm.ss')

    $message = "$timestamp [$($SEVERITY_KEYWORD_LUT[$LogSeverity])] $($LogMessage)"

# ============================================================================
    # Send message.
    if (($ConsoleLogLevel -gt -1) -and ($ConsoleLogLevel -ge $LogSeverity)){
        Write-Host $message
    }

    if (($FileLogLevel -gt -1) -and ($FileLogLevel -ge $LogSeverity)){
        Add-Content $message -Path
    }

    if (($SyslogLogLevel -gt -1) -and ($SyslogLogLevel -ge $LogSeverity)){

        syslogArgs = @{
            Server = $SyslogServer;
            Port = $SyslogPort;
            Message = $message;
            Facility = $SyslogFacility
        }

        Send-SyslogMessage @syslogArgs
    }
}