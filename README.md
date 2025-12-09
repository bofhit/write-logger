## Write-Logger

### .SYNOPSIS
    Send log messages to console, file, and/or syslog server.
### .DESCRIPTION
    Send log messages to console, file and/or syslog server.
    * Different log levels can be specified for each destination.
    * Destination log levels default to -1, which disables logging for that
        destination.
    * There a lot of parameters, so normally I would define a hash table
        at the top of a script, and use parameter splatting.
### .EXAMPLE
    # Call from console. Useful for testing.
    Write-Logger -LogMessage 'My message.' -LogLevel 6 -ConsoleLogLevel 7
### .EXAMPLE
    # Use for script logging.
    # Top of the script.
    @logArgs = @{
        ConsoleLogLevel = 7     # Debug
        FileLogLevel = 6        # Info
        SyslogLevel = 4         # Warning
        LogFilePath = 'mypath.log'
        SyslogServer = 'server.host'
        SyslogPort = 514
        SyslogFacility = 10
    }

    # Later in the script.
    Write-Logger -LogMessage 'My info message' -LogLevel 6 @logArgs

    ...

    Write-Logger -LogMessage 'My error message' -LogLevel 3 @logArgs

### .NOTES
    Depends on PoSH-Syslog to send syslog messages.

## Versions
1.0.0- Initial version.
1.1.0- Added logger name param, convenience functions.
1.1.1- Added message format strings.

