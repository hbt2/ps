$pwgen_CONSONANT = 1
$pwgen_VOWEL     = (1 -shl 1)
$pwgen_DIPTHONG  = (1 -shl 2)
$pwgen_NOT_FIRST = (1 -shl 3)

$pwgen_ELEMENTS = 
    @( 'a',  ($pwgen_VOWEL) ),
    @( 'ae', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'ah', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'ai', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'b',  ($pwgen_CONSONANT) ),
    @( 'c',  ($pwgen_CONSONANT) ),
    @( 'ch', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG) ),
    @( 'd',  ($pwgen_CONSONANT) ),
    @( 'e',  ($pwgen_VOWEL) ),
    @( 'ee', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'ei', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'f',  ($pwgen_CONSONANT) ),
    @( 'g',  ($pwgen_CONSONANT) ),
    @( 'gh', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG -bor $pwgen_NOT_FIRST) ),
    @( 'h',  ($pwgen_CONSONANT) ),
    @( 'i',  ($pwgen_VOWEL) ),
    @( 'ie', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'j',  ($pwgen_CONSONANT) ),
    @( 'k',  ($pwgen_CONSONANT) ),
    @( 'l',  ($pwgen_CONSONANT) ),
    @( 'm',  ($pwgen_CONSONANT) ),
    @( 'n',  ($pwgen_CONSONANT) ),
    @( 'ng', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG -bor $pwgen_NOT_FIRST) ),
    @( 'o',  ($pwgen_VOWEL) ),
    @( 'oh', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'oo', ($pwgen_VOWEL -bor $pwgen_DIPTHONG) ),
    @( 'p',  ($pwgen_CONSONANT) ),
    @( 'ph', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG) ),
    @( 'qu', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG) ),
    @( 'r',  ($pwgen_CONSONANT) ),
    @( 's',  ($pwgen_CONSONANT) ),
    @( 'sh', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG) ),
    @( 't',  ($pwgen_CONSONANT) ),
    @( 'th', ($pwgen_CONSONANT -bor $pwgen_DIPTHONG) ),
    @( 'u',  ($pwgen_VOWEL) ),
    @( 'v',  ($pwgen_CONSONANT) ),
    @( 'w',  ($pwgen_CONSONANT) ),
    @( 'x',  ($pwgen_CONSONANT) ),
    @( 'y',  ($pwgen_CONSONANT) ),
    @( 'z',  ($pwgen_CONSONANT) )

Function pwgen_generate ($pwlen, $inc_capital, $inc_number)
{
    $result = $null

    while (-Not $result)
    {
        $result = (pwgen_generate0 $pwlen $inc_capital $inc_number)
    }

    $result
}

Function pwgen_generate0 ($pwlen, $inc_capital, $inc_number)
{
    $result = ''
    $prev = 0
    $isFirst = $true

    $shouldBe = if (Get-Random -Maximum 2) { $pwgen_VOWEL } else { $pwgen_CONSONANT }

    while ($result.Length -lt $pwlen)
    {
        $i = Get-Random -Maximum ($pwgen_ELEMENTS.Count-1)
        $str = $pwgen_ELEMENTS[$i][0]
        $flags = $pwgen_ELEMENTS[$i][1]

        if (($flags -band $shouldBe) -eq 0)
        {
            continue
        }

        if ($isFirst -and ($flags -band $pwgen_NOT_FIRST))
        {
            continue
        }

        if (($prev -band $pwgen_VOWEL) -and ($flags -band $pwgen_VOWEL) -and ($flags -band $pwgen_DIPTHONG))
        {
            continue
        }

        if (($result.Length + $str.Length) -gt $pwlen)
        {
            continue
        }

        if ($inc_capital)
        {
            if (($isFirst -or ($flags -band $pwgen_CONSONANT)) -and (Get-Random -Maximum 3))
            {
                $str = $str.Substring(0,1).ToUpper() + $str.Substring(1,$str.Length-1)
                $inc_capital = $false
            }
        }

        $result += $str

        if ($inc_number)
        {
            if ((-Not $isFirst) -And (0,1,0 | Get-Random))
            {
                if (($result.Length + $str.Length) -gt $pwlen)
                {
                    $result = $result.Remove($result.Length-1)
                }
                $result += [string](Get-Random -Maximum 10)

                $inc_number = $false

                $isFirst = $true
                $prev = 0
                $shouldBe = if (Get-Random -Maximum 2) { $pwgen_VOWEL} else { $pwgen_CONSONANT }

                continue
            }
        }

        if ($shouldBe -eq $pwgen_CONSONANT)
        {
            $shouldBe = $pwgen_VOWEL
        }
        else
        {
            if (($prev -band $pwgen_VOWEL) -or ($flags -band $pwgen_DIPTHONG) -or (Get-Random -Maximum 3))
            {
                $shouldBe = $pwgen_CONSONANT
            }
            else
            {
                $shouldBe = $pwgen_VOWEL
            }
        }

        $prev = $flags
        $isFirst = $false
    }

    if ($inc_capital -or $inc_number)
    {
        return $null
    }

    return $result
}

Function New-PronounceablePassword
{
    Param
    (
        [int] $Length = 7,
        [int] $Count = 1,
        [switch] $Digits = $true,
        [switch] $Capitals = $true
    )

    while ($Count--)
    {
        pwgen_generate -pwlen $Length -inc_capital $Capitals -inc_number $Digits
    }
}

New-Alias -Name pwgen -Value New-PronounceablePassword

Export-ModuleMember -Function New-PronounceablePassword -Alias pwgen