<#
.SYNOPSIS
    Gets the state of Minion keys.
.DESCRIPTION
    This function will use Invoke-SaltApi to call the key.list function returning a list of minions for the provided $KeyState.
.EXAMPLE
    Get-SaltApiKeyState

    This will return all minions for all key states (default is $KeyState = 'all').
.EXAMPLE
    Get-SaltApiKeyState -KeyState accepted

    This will return all minions with an 'accepted' key state.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltApiKeyState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [String]
        [Validateset('accepted', 'unaccepted', 'rejected','denied', 'all')]
        $KeyState = 'all',
        [Parameter(Mandatory = $false)]    
        [Switch]
        $SkipCertificateCheck = $false
    )

    # Check to see if there is an existing connection to SaltStack
    try {
        Check-SaltAPIConnection
    }
    catch {
        throw $_
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