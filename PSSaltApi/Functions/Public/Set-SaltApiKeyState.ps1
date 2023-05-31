<#
.SYNOPSIS
    Sets the key state for a minion(s).
.DESCRIPTION
    This function will use the Invoke-SaltApiFunction to call the key.accept, key.reject or key.delete function depending on the value specified for KeyState.
.EXAMPLE
    Set-SaltApiKeyState -Match minion1 -KeyState accept

    This will accept an unaccepted key for a minion matching 'minion1'.
.EXAMPLE
    Set-SaltApiKeyState -Match minion1 -KeyState delete

    This will delete the key for a minion matching 'minion1'.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
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

    $minions = @()

    foreach ($minion in $return.Content.data.return.minions) {
        $minions += $minion
    }
    
    Add-Member -InputObject $return.Content.data -MemberType NoteProperty -Name Match -Value $match 
    Add-Member -InputObject $return.Content.data -MemberType NoteProperty -Name Minions -Value $minions

    Write-Output $return.Content.data    

}