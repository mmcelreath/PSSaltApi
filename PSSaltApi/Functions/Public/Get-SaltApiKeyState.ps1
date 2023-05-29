function Get-SaltApiKeyState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [String]
        [Validateset('accepted', 'unaccepted', 'rejected','denied', 'all')]
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

    $kwarg = @{match = $KeyState }

    $parameters = @{
        Client               = 'wheel'
        Function             = 'key.list'
        Kwarg                = $kwarg
        SkipCertificateCheck = $SkipCertificateCheck
    }

    $return = Invoke-SaltApiFunction @parameters
    $return.Content.data.return
    

}