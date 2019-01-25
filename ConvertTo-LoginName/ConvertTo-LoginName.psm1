Function ConvertTo-LoginName
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $FullName
    )

    Begin
    {
        Function Convert($String, $TranslitTable)
        {
            $LoginName = ''

            Foreach ($char in $String.GetEnumerator())
            {
                $LoginName += $TranslitTable[[string]$char].ToLower()
            }

            $LoginName
        }

        $TranslitTable = [Ordered]`
        @{
            'А'='A'; 'Б'='B'; 'В'='V'; 'Г'='G'; 'Д'='D'; 'Е'='E'; 'Ё'='E'; 'Ж'='ZH'; 'З'='Z'; 'И'='I'; 
            'Й'='Y'; 'К'='K'; 'Л'='L'; 'М'='M'; 'Н'='N'; 'О'='O'; 'П'='P'; 'Р'='R'; 'С'='S'; 'Т'='T'; 
            'У'='U'; 'Ф'='F'; 'Х'='H'; 'Ц'='TS'; 'Ч'='CH'; 'Ш'='SH'; 'Щ'='SCH'; 'Ъ'=''; 'Ы'='Y'; 'Ь'=''; 
            'Э'='E'; 'Ю'='YU'; 'Я'='YA'
        }

        $TranslitTableForInitials = [Ordered]`
        @{
            'А'='A'; 'Б'='B'; 'В'='V'; 'Г'='G'; 'Д'='D'; 'Е'='E'; 'Ё'='E'; 'Ж'='ZH'; 'З'='Z'; 'И'='I'; 
            'Й'='Y'; 'К'='K'; 'Л'='L'; 'М'='M'; 'Н'='N'; 'О'='O'; 'П'='P'; 'Р'='R'; 'С'='S'; 'Т'='T'; 
            'У'='U'; 'Ф'='F'; 'Х'='H'; 'Ц'='TS'; 'Ч'='CH'; 'Ш'='SH'; 'Щ'='SCH'; 'Ъ'=''; 'Ы'='Y'; 'Ь'=''; 
            'Э'='E'; 'Ю'='Y'; 'Я'='Y'
        }
    }

    Process
    {
        $NameObject = ParsePersonalFullName -FullName $FullName

        If ($NameObject -eq $null) { return $null }

        $NameObjectTranslited = [PSCustomObject][Ordered]`
        @{
            'Surname' =    
                Convert `
                    $NameObject.Surname `
                    $TranslitTable

            'Firstname' = 
                Convert `
                    $NameObject.Firstname `
                    $TranslitTableForInitials

            'Middlename' = 
                Convert `
                    $NameObject.Middlename `
                    $TranslitTableForInitials
        }

        $NameObjectTranslited.Surname = 
            $NameObjectTranslited.Surname -replace '^h','kh'

        $NameObjectTranslited.Surname = 
            FirstCharToUpper $NameObjectTranslited.Surname

        $NameObjectTranslited.Firstname  = 
            FirstCharToUpper $NameObjectTranslited.Firstname

        $NameObjectTranslited.Middlename = 
            FirstCharToUpper $NameObjectTranslited.Middlename
    
        '{0}.{1}{2}' -f `
        (
            $NameObjectTranslited.Surname, 
            $NameObjectTranslited.Firstname[0], 
            $NameObjectTranslited.Middlename[0]
        )
    }

    End {}
}

Export-ModuleMember -Function ConvertTo-LoginName

Function FirstCharToUpper
{
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $String
    )

    Process
    {
        $String.Substring(0,1).ToUpper() + `
        $String.Substring(1).ToLower()
    }
}

Function ParsePersonalFullName
{
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $FullName
    )

    Begin
    {
        #$pattern = ('^(?<Surname>{0}+) (?<Firstname>{0}+) (?<Middlename>{0}+)$' -f '\p{IsCyrillic}')
        $pattern = ('^(?<Surname>{0}+) (?<Firstname>{0}+) (?<Middlename>{0}+)$' -f '[А-яЁё]')
    }

    Process
    {
        $Match = [regex]::Match($FullName, $pattern)

        If ($Match.Success -eq $False)
        {
            $ErrorMessage = "Полное имя не соответствует шаблону 'Фамилия Имя Отчество'."

            Write-Error `
                -Message $ErrorMessage `
                -Category 'InvalidData' `
                -ErrorId 'ParameterArgumentValidationErrorNotMatchPattern'

            return
        }

        [PSCustomObject][Ordered]`
        @{
            'Surname'    = (FirstCharToUpper $Match.Groups['Surname'].Value)
            'Firstname'  = (FirstCharToUpper $Match.Groups['Firstname'].Value)
            'Middlename' = (FirstCharToUpper $Match.Groups['Middlename'].Value)
        }
    }

    End {}
}
