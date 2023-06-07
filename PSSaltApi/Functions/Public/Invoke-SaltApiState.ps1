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
function Invoke-SaltApiState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        [Parameter(Mandatory = $true)]
        [String]
        $State,
        [String]
        [Validateset('glob','compound')] # To add: 'grain','list'
        $TargetType = 'glob',
        [String]
        $Exclude,
        [Switch]
        $Test,
        [Parameter(Mandatory = $false)]    
        [Switch]
        $SkipCertificateCheck = $false
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltAPIConnection) {
        Write-Error 'You are not currently connected to any SaltStack APIs. Please connect first using Connect-SaltApi.'
        return
    }

    $TargetType = $TargetType.ToLower()
    $arg = @()

    $arg += @($state)
    $function = 'state.apply'

    if ($Exclude) {
        $arg += "exclude=$Exclude"
    }

    if ($Test) {
        $arg += 'test=true'
    }

    $parameters = @{
        Client               = 'local'
        Target               = $Target
        Function             = $function
        Arg                  = $arg
        SkipCertificateCheck = $SkipCertificateCheck
    }

    $return = Invoke-SaltApiFunction @parameters

    $minionNames = $return.Content.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name

    $obj =  [PSCustomObject]@{}

    Write-Output $return

}