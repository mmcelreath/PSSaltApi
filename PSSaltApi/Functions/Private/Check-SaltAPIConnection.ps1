function Check-SaltAPIConnection {
    # Check to see if there is an existing connection to SaltStack and that the token is not expired
    if (!$global:SaltAPIConnection) {
        throw 'You are not currently connected to any SaltStack APIs. Please connect first using Connect-SaltApi.'
    } else {
        $date = Get-Date
        $expireDate = $global:SaltAPIConnection.ExpireDate

        $timeDiff = $expireDate - $date

        if ($timeDiff.TotalSeconds -lt 1) {
            throw 'The currently stored token is expired. Please run Connect-SaltApi again to obtain a new token.'
        }
    }
}