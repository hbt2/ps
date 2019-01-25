#Requires -Version 3.0

& "$PSScriptRoot\Script\Convert-W32TimeDebugLogEventDate.ps1" `
    -Path "$PSScriptRoot\Log\W32Time.log" `
    -OutPath "$PSScriptRoot\Log\W32Time.out.log"

& "$PSScriptRoot\Script\Save-W32TimeDebugLogLocalClockOffsetEvents.ps1" `
    -Path "$PSScriptRoot\Log\W32Time.out.log" `
    -OutPath "$PSScriptRoot\Log\W32Time.out.localclockoffset.log"