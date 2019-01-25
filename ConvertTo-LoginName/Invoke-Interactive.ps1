Import-Module "$PSScriptRoot\ConvertTo-LoginName.psm1" -Force

Clear-Host
Write-Host "Введите полное имя пользователя в формате 'Фамилия Имя Отчество'.`n"

While ($true)
{
    $FullName = Read-Host 'Полное имя '
    $LoginName = ''

    try
    {
        $LoginName = ConvertTo-LoginName $FullName -ErrorAction Stop
    }
    catch 
        [System.Management.Automation.ParameterBindingException],
        [Microsoft.PowerShell.Commands.WriteErrorException]
    {
        $e = $_

        switch ($e.CategoryInfo.Category)
        {
            'InvalidData'
            {
                #switch ($e.Exception.ErrorId) 
                switch -Wildcard ($e.FullyQualifiedErrorId) 
                {
                    'ParameterArgumentValidationErrorEmptyStringNotAllowed*' 
                    {
                        $LoginName = ('Ошибка! ({0})' -f 'Полное имя не должно быть пустым.')   
                    }

                    'ParameterArgumentValidationErrorNotMatchPattern*'
                    {
                        $LoginName = ('Ошибка! ({0})' -f $e.Exception.Message)
                    }

                    default 
                    { 
                        $LoginName = ('Ошибка! ({0})' -f $e.Exception.Message)
                    }
                }
            }
        }
    }

    Write-Host "Логин      : $LoginName`n"
}