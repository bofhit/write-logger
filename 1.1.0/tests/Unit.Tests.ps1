$script:ModuleName = 'Write-Logger'

# Removes all versions of the module from the session before importing
Get-Module $ModuleName | Remove-Module

$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path

# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Tests') {
     $ModuleBase = Split-Path $ModuleBase -Parent
}

Import-Module $ModuleBase\$ModuleName.psd1 -PassThru -ErrorAction Stop | Out-Null

InModuleScope $script:ModuleName {
    Describe 'Basic function unit tests.' {

        BeforeEach {
            $logArgs = @{
                LoggerName = 'Test logger name.'
                LogMessage = 'My test message.'
                LogSeverity = 7
            }
        }

        It 'Should work with no optional params.' {
            {Write-Logger $logArgs | Should Not Throw}
        }

        It 'Should not work with no logger name provided.' {
            $logArgs.Remove('LoggerName')
            {Write-Logger $logArgs | Should Throw 'LoggerName cannot be null or empty.'}
        }

        It 'Should not work with an invalid type for the logger name.' {
            $logArgs.LoggerName = 55
            {Write-Logger $logArgs | Should Throw 'LoggerName must be a string.'}
        }

        It 'Should not work with no log message provided.' {
            $logArgs.Remove('LogMessage')
            {Write-Logger $logArgs | Should Throw 'LogMessage cannot be null or empty.'}
        }

        It 'Should not work with an invalid type for the log message.' {
            $logArgs.LogMessage = 55
            {Write-Logger $logArgs | Should Throw 'LogMessage must be a string.'}
        }

        It 'Should not work with no log severity provided.' {
            $logArgs.Remove('LogSeverity')
            {Write-Logger $logArgs | Should Throw 'LogSeverity cannot be null or empty.'}
        }
    }    

#TODO: Test writing to console.
#TODO: Test writing to file.
#TODO: Test writing to syslog.

}

