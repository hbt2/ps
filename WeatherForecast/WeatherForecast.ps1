Set-PSDebug -Strict

$RunPath =  (Split-Path -Parent (Get-Variable MyInvocation).Value.MyCommand.Path)
$ScriptBaseName = (Get-ChildItem (Get-Variable MyInvocation).Value.MyCommand.Path).BaseName

Function .\Save-URItoFile ($URI, $Path)
{
    $WebRequest = Invoke-WebRequest -Uri $URI -Proxy 'http://contoso.local:8080' -UseDefaultCredentials -ProxyUseDefaultCredentials

    Set-Content -Path $Path -Value $WebRequest.Content -Encoding Byte
}

Function .\Save-FileToFile ($Path, $Destination)
{
    $inStream  = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open)
    $outStream = [System.IO.File]::Open($Destination, [System.IO.FileMode]::Truncate)

    $inStream.CopyTo($outStream)

    $inStream.Close()
    $outStream.Close()
}

Function .\Hide-File ($Path)
{
    $File = Get-Item -Path $Path -Force
    
    $File.Attributes = $File.Attributes -bor [System.IO.FileAttributes]::Hidden
}

Function .\Convert-PngtoBMP ($Png, $BMP)
{
    $magick = `
        Start-Process `
            -FilePath "magick.exe" `
            -ArgumentList ("""{0}"" BMP3:""{1}""" -f $Png, $BMP) `
            -PassThru -Wait -WindowStyle Hidden

    If ($magick.ExitCode -ne 0)
    {
        throw 'magick.exe: что-то пошло не так'
    }
}

Function yr.no\Convert-PDFtoPng ($PDF, $Png)
{
    $magick = `
        Start-Process `
            -FilePath 'magick.exe' `
            -ArgumentList ( `
                "-units PixelsPerInch " + `
                "-density 400 " + `
                """$PDF"" " + `
                "-crop 3304x2692+0+200 " + `
                "-resize 50% " + `
                "-density 200 " + `
                "-alpha remove " + `
                "-depth 8 "  + `
                """$Png""") `
            -PassThru -Wait -WindowStyle Hidden
    
    If ($magick.ExitCode -ne 0)
    {
        throw 'magick.exe: что-то пошло не так'
    }
}

Function yr.no\Get-FixPDF ($Path, $Destination)
{
    $pdftk = `
        Start-Process `
            -FilePath 'pdftk.exe' `
            -ArgumentList ( `
                """$Path"" " + `
                "output " + `
                """$Destination""") `
            -PassThru -Wait -WindowStyle Hidden
    
    If ($pdftk.ExitCode -ne 0)
    {
        throw 'pdftk.exe: что-то пошло не так'
    }
}

Function .\Get-UnionImage ($Path, $Destination)
{
    $magick = `
        Start-Process `
            -FilePath 'magick.exe' `
            -ArgumentList ( `
                """$($Path -join '" "')"" " + `
                "-append " + `
                """$Destination""") `
            -PassThru -Wait -WindowStyle Hidden
    
    If ($magick.ExitCode -ne 0)
    {
        throw 'magick.exe: что-то пошло не так'
    }
}

Function .\Get-ReportBody ($Result, $Title)
{
    If ($Result)
    {
        $Body = $null

        foreach ($r in $Result)
        {
            $Body += "# $Title`: ""$r""`n`n"
            $Body += ($r | Out-String) + "`n"
        }

        Return $Body
    }
}

Function .\Send-Report ($ReportBody)
{
    Send-MailMessage `
        -SmtpServer 'mail.contoso.local' `
        -To 'hobbit2000@contoso.com' `
        -From 'hobbit2000@contoso.com' `
        -Subject "$PSCommandPath" `
        -Body $ReportBody `
        -Encoding UTF8
}

# 
Function Get-ForecaInari ([ref]$Result)
{
    $URI = `
        'http://www.foreca.com/meteogram.php?loc_id=100656657&mglang=ru&units=metric&tf=24h'

    $Path = `
        "$BasePath\forecacom_100656657.png"

    $HumanPath = `
        "$BasePath\Прогноз погоды (Инари) (foreca.com).png"

    $WallpaperPath = `
        "$BasePath\SetWeatherForecastWallpaper\forecacom_100656657.bmp"

    $LegacyPath = `
        '\\contoso-old\share\weather\forecast inari (foreca.com).png'

    $r = @()

    try { .\Save-URItoFile `
                -URI $URI `
                -Path $Path

        try { .\Hide-File `
                    -Path $Path } catch { $r += $_ }

        try { .\Save-FileToFile `
                    -Path $Path `
                    -Destination $HumanPath } catch { $r += $_ }

        try { .\Save-FileToFile `
                    -Path $Path `
                    -Destination $LegacyPath } catch { $r += $_ }

        try { .\Convert-PngtoBMP `
                    -Png $Path `
                    -BMP $WallpaperPath } catch { $r += $_ } } catch { $r += $_ }

    $Result.Value += $r
}

# 
Function Get-YrnoRayakoski ([ref]$Result)
{
    $URI = `
        'http://www.yr.no/place/Russia/Murmansk/Rayakoski/forecast.pdf'

    $Path = `
        "$BasePath\yrno_rayakoski.pdf"

    $TmpPath = `
        "$env:TEMP\yrno_rayakoski.pdf"

    $TmpPathFixPdf = `
        "$env:TEMP\yrno_rayakoski_fix.pdf"

    $HumanPath = `
        "$BasePath\Прогноз погоды (Раякоски) (yr.no).pdf"

    $PngPath = `
        "$BasePath\yrno_rayakoski.png"

    $PngTmpPath = `
        "$env:TEMP\yrno_rayakoski.png"

    $PngHumanPath = `
        "$BasePath\Прогноз погоды (Раякоски) (yr.no).png"

    $LegacyPath = `
        '\\contoso-old\share\weather\forecast rayakoski (yr.no).pdf'

    $r = @()

    try { .\Save-URItoFile `
                -URI $URI `
                -Path $TmpPath
        
        try { yr.no\Get-FixPDF `
                    -Path $TmpPath `
                    -Destination $TmpPathFixPdf

            try { .\Save-FileToFile `
                    -Path $TmpPathFixPdf `
                    -Destination $Path

                try { .\Hide-File `
                            -Path $Path } catch { $r += $_ }
        
                try { .\Save-FileToFile `
                            -Path $Path `
                            -Destination $HumanPath } catch { $r += $_ }

                try { .\Hide-File `
                            -Path $HumanPath } catch { $r += $_ }

                try { .\Save-FileToFile `
                            -Path $Path `
                            -Destination $LegacyPath } catch { $r += $_ }

                try { yr.no\Convert-PDFtoPng `
                            -PDF $Path `
                            -Png $PngTmpPath
            
                    try { .\Save-FileToFile `
                            -Path $PngTmpPath `
                            -Destination $PngPath
    
                        try { .\Hide-File `
                                    -Path $PngPath } catch { $r += $_ }
    
                        try { .\Save-FileToFile `
                                    -Path $PngPath `
                                    -Destination $PngHumanPath } catch { $r += $_ } 
                    
                    } catch { $r += $_ } 

                } catch { $r += $_ } 
            
            } catch { $r += $_ }
        
        } catch { $r += $_ } 
    
    } catch { $r += $_ }

    $Result.Value += $r
}

# 
Function Get-YrnoInari ([ref]$Result)
{
    $URI = `
        'http://www.yr.no/place/Finland/Laponia/Inari/forecast.pdf'

    $Path = `
        "$BasePath\yrno_inari.pdf"

    $TmpPath = `
        "$env:TEMP\yrno_inari.pdf"

    $TmpPathFixPdf = `
        "$env:TEMP\yrno_inari_fix.pdf"

    $HumanPath = `
        "$BasePath\Прогноз погоды (Инари) (yr.no).pdf"

    $PngPath = `
        "$BasePath\yrno_inari.png"

    $PngTmpPath = `
        "$env:TEMP\yrno_inari.png"

    $PngHumanPath = `
        "$BasePath\Прогноз погоды (Инари) (yr.no).png"

    $LegacyPath = `
        '\\contoso-old\share\weather\forecast inari (yr.no).pdf'

    $r = @()

    try { .\Save-URItoFile `
                -URI $URI `
                -Path $TmpPath
        
        try { yr.no\Get-FixPDF `
                    -Path $TmpPath `
                    -Destination $TmpPathFixPdf

            try { .\Save-FileToFile `
                    -Path $TmpPathFixPdf `
                    -Destination $Path

                try { .\Hide-File `
                            -Path $Path } catch { $r += $_ }
        
                try { .\Save-FileToFile `
                            -Path $Path `
                            -Destination $HumanPath } catch { $r += $_ }

                try { .\Hide-File `
                            -Path $HumanPath } catch { $r += $_ }

                try { .\Save-FileToFile `
                            -Path $Path `
                            -Destination $LegacyPath } catch { $r += $_ }

                try { yr.no\Convert-PDFtoPng `
                            -PDF $Path `
                            -Png $PngTmpPath
            
                    try { .\Save-FileToFile `
                            -Path $PngTmpPath `
                            -Destination $PngPath
    
                        try { .\Hide-File `
                                    -Path $PngPath } catch { $r += $_ }
    
                        try { .\Save-FileToFile `
                                    -Path $PngPath `
                                    -Destination $PngHumanPath } catch { $r += $_ } 
                    
                    } catch { $r += $_ } 

                } catch { $r += $_ } 
            
            } catch { $r += $_ }
        
        } catch { $r += $_ } 
    
    } catch { $r += $_ }

    $Result.Value += $r
}

# 
Function Get-YrnoRayakoskiMeteogram ([ref]$Result)
{
    $URI = `
        'http://www.yr.no/place/Russia/Murmansk/Rayakoski/meteogram.png'

    $Path = `
        "$BasePath\yrno_rayakoski_meteogram.png"

    $WallpaperPath = `
        "$BasePath\SetWeatherForecastWallpaper\yrno_rayakoski_meteogram.bmp"

    $r = @()

    try { .\Save-URItoFile `
                -URI $URI `
                -Path $Path

        try { .\Hide-File `
                    -Path $Path } catch { $r += $_ }

        try { .\Convert-PngtoBMP `
                    -Png $Path `
                    -BMP $WallpaperPath } catch { $r += $_ } } catch { $r += $_ }

    $Result.Value += $r
}

# 
Function Get-YrnoInariMeteogram ([ref]$Result)
{
    $URI = `
        'http://www.yr.no/place/Finland/Laponia/Inari/meteogram.png'

    $Path = `
        "$BasePath\yrno_inari_meteogram.png"

    $WallpaperPath = `
        "$BasePath\SetWeatherForecastWallpaper\yrno_inari_meteogram.bmp"

    $r = @()

    try { .\Save-URItoFile `
                -URI $URI `
                -Path $Path

        try { .\Hide-File `
                    -Path $Path } catch { $r += $_ }

        try { .\Convert-PngtoBMP `
                    -Png $Path `
                    -BMP $WallpaperPath } catch { $r += $_ } } catch { $r += $_ }
    
    $Result.Value += $r
}

# 
Function Get-UnionMeteogram ([ref]$Result)
{
    $Images = @(`
        "$BasePath\yrno_rayakoski_meteogram.png", `
        "$BasePath\yrno_inari_meteogram.png", `
        "$BasePath\blank20.png"
        "$BasePath\forecacom_100656657.png")

    $Path = `
        "$BasePath\union_meteogram.png"

    $TmpPath = `
        "$env:TEMP\union_meteogram.png"

    $HumanPath = `
        "$BasePath\Все метеограммы одним файлом.png"

    $WallpaperPath = `
        "$BasePath\SetWeatherForecastWallpaper\all_meteogram.bmp"

    $r = @()

    try {.\Get-UnionImage `
                -Path $Images `
                -Destination $TmpPath

        try { .\Save-FileToFile `
                -Path $TmpPath `
                -Destination $Path

            try { .\Hide-File `
                        -Path $Path } catch { $r += $_ }

            try { .\Save-FileToFile `
                        -Path $Path `
                        -Destination $HumanPath } catch { $r += $_ }

            try {.\Convert-PngtoBMP `
                        -Png $Path `
                        -BMP $WallpaperPath } catch { $r += $_ } } catch { $r += $_ } } catch { $r += $_ }

    $Result.Value += $r
}



$Result1 = $Result2 = $Result3 = $Result4 = $Result5 =  $Result6 = @()

$BasePath = `
    '\\contoso\Share\Common\WeatherForecast'


Get-ForecaInari -Result ([ref]$Result1)
Get-YrnoRayakoski -Result ([ref]$Result2)
Get-YrnoInari -Result ([ref]$Result3)
Get-YrnoRayakoskiMeteogram -Result ([ref]$Result4)
Get-YrnoInariMeteogram -Result ([ref]$Result5)
Get-UnionMeteogram -Result ([ref]$Result6)


$Result1
$Result2
$Result3
$Result4
$Result5
$Result6

If ($Result1 -or $Result2 -or $Result3 -or $Result4 -or $Result5 -or $Result6)
{
    $ReportBody = $null
    $ReportBody += .\Get-ReportBody -Result $Result1 -Title 'foreca.com (Inari)'
    $ReportBody += .\Get-ReportBody -Result $Result2 -Title 'yr.no (Rayakoski)'
    $ReportBody += .\Get-ReportBody -Result $Result3 -Title 'yr.no (Inari)'
    $ReportBody += .\Get-ReportBody -Result $Result4 -Title 'yr.no (Rayakoski) (meteogram)'
    $ReportBody += .\Get-ReportBody -Result $Result5 -Title 'yr.no (Rayakoski) (meteogram)'
    $ReportBody += .\Get-ReportBody -Result $Result6 -Title 'meteogram union'

    .\Send-Report -ReportBody $ReportBody
}


<#.\Send-Report `
    -Results ($Result1, $Result2, $Result3) `
    -Titles ('foreca.com (Inari)', 'yr.no (Rayakoski)', 'yr.no (Inari)')#>
