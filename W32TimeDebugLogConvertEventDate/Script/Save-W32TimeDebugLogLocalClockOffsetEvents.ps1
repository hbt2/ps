#Requires -Version 3.0

<#
    .SYNOPSIS
        Сохраняет строки, содержащие подстроку 'LocalClockOffset' из журнала отладки службы W32Time в отдельный файл.

    .DESCRIPTION

    .NOTES
        Author: Polyakov.VG
        Created: 2018-05-22
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$True)]
    [Alias('Path')]
    [string]$InPath,
    
    [Parameter(Mandatory=$True)]
    [string]$OutPath
)

Begin
{
    Set-StrictMode -Version Latest    

    Import-Module "$PSScriptRoot\W32TimeEventDateEpochDaysToDate.psm1" -Force

    $Init =
    {
        If (-Not (Test-Path $InPath)) { Write-Warning "Файл не найден: $InPath"; exit }
    }
}

Process
{
    . $Init
    
    Get-Content `
        -Path $InPath `
        -Encoding Unicode `
        -ErrorAction Stop `
    | Select-String 'LocalClockOffset' `
    | Set-Content `
        -Path $OutPath `
        -Encoding Unicode `
        -ErrorAction Stop

    Write-Verbose -Verbose "Выходной файл: $OutPath"
}
