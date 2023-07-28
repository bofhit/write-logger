Function Write-Log {
    [CmdletBinding()]
    Param(
        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$false,
            HelpMessage='Console log level, use standard syslog levels.'
            )][string]$ConsoleLogLevel = -1,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$false,
            HelpMessage='File log level, use standard syslog levels.'
            )][string]$FileLogLevel = -1,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$false,
            HelpMessage='Syslog log level, use standard syslog levels.'
            )][string]$SyslogLogLevel = -1,

        [Parameter(Mandatory=$true,
            HelpMessage='Log message.'
            )][string]$LogMessage,

        [ValidateRange(-1, 7)]
        [Parameter(Mandatory=$true,
            HelpMessage='Log severity'
            )][Int32]$LogSeverity,

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

    $logKeyword = $SEVERITY_KEYWORD_LUT[$LogSeverity]

    # ============================================================================
    # Assemble message.
    $timestamp = (Get-Date).ToString('yyyy-MM-ddTHH.mm.ss')

    $message = "$timestamp [$($logKeyword)] $($LogMessage)"

    write-host $message
}