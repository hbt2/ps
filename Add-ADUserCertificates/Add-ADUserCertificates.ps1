<#
    .SYNOPSIS
        Добавляет сертификаты к учётным записям пользователей в AD

    .NOTES
        Name: Add-ADUserCertificates
        Author: hobbit2000@list.ru
        Version: 0.03 (2016-03-23)
#>
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="Medium")]
Param()

Set-PSDebug -Strict

$RunPath =  (Split-Path -Parent (Get-Variable MyInvocation).Value.MyCommand.Path)

Import-Module ActiveDirectory

$VerbosePreference = 'SilentlyContinue'
#$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
#$DebugPreference = 'Continue'

$Users = @(`
    [PSObject]@{ Name = 'user1'; Cert='user1.cer' },
    [PSObject]@{ Name = 'user2'; Cert='user2.cer' },
    [PSObject]@{ Name = 'user3'; Cert='user3.cer' },
    [PSObject]@{ Name = 'user4'; Cert='user4.cer' },
    [PSObject]@{ Name = 'user5'; Cert='user5.cer' },
    [PSObject]@{ Name = 'user6'; Cert='user6.cer' },
    [PSObject]@{ Name = 'user7'; Cert='user7.cer' },
    [PSObject]@{ Name = 'user8'; Cert='user8.cer' },
    [PSObject]@{ Name = 'user9'; Cert='user9.cer' },
)

$SuccessCount = 0

foreach ($User in $Users) 
{
    # Получить учётную запись из AD
    try 
    {
        $ADUser = Get-ADUser -Identity $User.Name -Server 'contoso.local' -Properties Certificates
        
        Write-Verbose "ПОЛЬЗОВАТЕЛЬ:"
        Write-Verbose "ПОЛЬЗОВАТЕЛЬ: DistinguishedName: $ADUser"
        Write-Verbose "ПОЛЬЗОВАТЕЛЬ: SamAccountName: $($ADUser.SamAccountName)"
        Write-Verbose ''
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        $host.ui.WriteErrorLine("ОШИБКА: Пользователь не найден: ""$($User.Name)""")
        continue
    }
    catch
    {
        Write-Error $_
        continue
    }


    # Создать объект сертификата из файла сертификата
    try
    {
        $CertFilePath = "$RunPath\Certificates\$($User.Cert)"
        $CertFile = Get-Item -Path $CertFilePath -ErrorAction Stop

        $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate $CertFile

        Write-Verbose "СЕРТИФИКАТ:"
        Write-Verbose "СЕРТИФИКАТ: Файл: $CertFile"
        Write-Verbose "СЕРТИФИКАТ: Субъект: $($Cert.Subject)"
        Write-Verbose "СЕРТИФИКАТ: Отпечаток: $($Cert.GetCertHashString())"
        Write-Verbose ''
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        $host.ui.WriteErrorLine("ОШИБКА: Файл сертификата не найден: ""$CertFilePath""")
        continue
    }
    catch
    {
        Write-Error $_
        continue
    }


    # Проверка на существование сертификата у учётной записи
    if ($ADUser.Certificates -contains $Cert)
    {
        Write-Host "ОТКАЗ: Сертификат ""$($CertFile.Name)"" уже добавлен к учётной записи ""$($ADUser.Name)"" ($($ADUser.SamAccountName))"
        continue
    }
    
    # Добавить сертификат к учётной записи в AD
    try
    {
        if ($PSCmdlet.ShouldProcess($ADUser.Name, "Добавить сертификат к учётной записи"))
        {
            Set-ADUser -Identity $ADUser -Certificates @{Add = $Cert }
        }
        else
        {
            continue
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] <#[Microsoft.PowerShell.Commands.WriteErrorException]#> <#[System.SystemException.WriteErrorException]#>
    {
        $host.ui.WriteErrorLine("ОШИБКА: Не удалось добавить сертификат к учётной записи ""$($ADUser.Name)"" ($($ADUser.SamAccountName)): $($_.Exception.Message)")

        continue
    }
    catch
    {
        Write-Error $_
        continue
    }


    # Проверка добавленного сертификата
    $ADUser = Get-ADUser -Identity $ADUser -Properties Certificates

    if (-Not ($ADUser.Certificates -ccontains $Cert))
    {
        Write-Host "ОТКАЗ: Сертификат ""$($CertFile.Name)"" не был добавлен к учётной записи: ""$($ADUser.Name)"" ($($ADUser.SamAccountName))"
        continue
    }
    else
    {
        Write-Host "УСПЕХ: Сертификат ""$($CertFile.Name)"" добавлен к учётной записи: ""$($ADUser.Name)"" ($($ADUser.SamAccountName))"
    }

    
    $SuccessCount++
}

Write-Host "Добавлено сертификатов: $SuccessCount"
Write-Host ""

Read-Host "Нажмите Enter"