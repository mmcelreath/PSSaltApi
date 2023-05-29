function Set-SaltApiKeyState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [String]
        $Match,
        [String]
        [Validateset('accept', 'reject','delete')]
        $KeyState,
        [Parameter(Mandatory = $false)]    
        [Switch]
        $SkipCertificateCheck = $false
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltAPIConnection) {
        Write-Error 'You are not currently connected to any SaltStack APIs. Please connect first using Connect-SaltApi.'
        return
    }

    switch ($KeyState) {
        'accept' { $function = 'key.accept'}
        'reject' { $function = 'key.reject'}
        'delete' { $function = 'key.delete'}
        Default {$function = $null}
    }

    $kwarg = @{match = $Match }

    $parameters = @{
        Client               = 'wheel'
        Function             = $function
        Kwarg                = $kwarg
        SkipCertificateCheck = $SkipCertificateCheck
    }

    $return = Invoke-SaltApiFunction @parameters

    Add-Member -InputObject $return.Content.data -MemberType NoteProperty -Name Match -Value $match 

    $return.Content.data
    

}