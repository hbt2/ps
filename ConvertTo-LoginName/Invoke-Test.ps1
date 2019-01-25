Import-Module "$PSScriptRoot\ConvertTo-LoginName.psm1" -Force

Function New-PSCustomObjectByFullName
{
    Param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FullName
    )
    
    Process
    {
        $LoginName = ConvertTo-LoginName -FullName $FullName -ErrorAction SilentlyContinue

        $Success = -not [string]::IsNullOrEmpty($LoginName)

        [PSCustomObject][Ordered]`
        @{
            FullName = $FullName
            LoginName = $LoginName
            Success = $Success
        }
    }
}

$FullNames = 
@(
    'ХРЕНОВ ЯРОСЛАВ ЮФИМОВИЧ'
    'ХРЕНОВ ЯРОСЛАВ'
    'Щеглов Ярослав Юфимович'
    'Хоботов Ярослав Юфимович'
    'Хо хо хо'
)

$FullNames | New-PSCustomObjectByFullName