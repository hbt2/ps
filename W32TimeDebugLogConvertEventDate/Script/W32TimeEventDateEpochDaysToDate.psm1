Function Replace-W32TimeEventDateEpochDaysToDate
{
    <#
        .SYNOPSIS
            Преобразовывает дату события журнала отладки службы времени Windows (W32Time) в читаемый вид.

        .DESCRIPTION
            Дата в журнале отлидки службы W32Time хранится в виде числа, обозначающего количество дней, 
            прошедших с "начала эпохи" — 01.01.1601 ("windows epoch time"). 
            Такое представление даты неудобно для чтения журнала.
            
            Пример строки:

                "152384 06:28:50.9218750s - ---------- Log File Opened -----------------"

            Строка, проебразованная данной функцией:

                "2018-03-20 06:28:50.9218750s - ---------- Log File Opened -----------------"

        .NOTES
            Author: Polyakov.VG
            Updated: 2018-05-23
    #>

    Param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [String]
        $Event
    )

    Begin
    {
        Function ConvertEpochDaysToDate($Days)
        {
            $EpochDate = Get-Date '1601-01-01'
            Get-Date $EpochDate.AddDays($Days) -Format "yyyy-MM-dd"
        }
            
        $callbackup = 
        {
            Param($Match)
            ConvertEpochDaysToDate($Match[0].Value)
        }
    }
        
    Process
    {
        [regex]::Replace($Event, '^([0-9]*)', $callbackup)
    }
}

Export-ModuleMember -Function Replace-W32TimeEventDateEpochDaysToDate