function ConvertFrom-UnixTimestamp {
    param(
        $UnixTimestamp
    )

    $localTime = ((Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($UnixTimestamp))).ToLocalTime()

    return $localTime
}