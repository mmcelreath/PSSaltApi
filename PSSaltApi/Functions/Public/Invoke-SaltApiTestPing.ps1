<#
.SYNOPSIS
    Applies a state or states to the specified Target.
.DESCRIPTION
    This function will use Invoke-SaltApiFunction to call the state.apply or state.highstate function.
.EXAMPLE
    PS> Invoke-SaltApiState -Target '*' -State teststate

    Runs the state called 'teststate' against all minions.
.EXAMPLE
    PS> Invoke-SaltApiState -Target '*' -State highstate

    Runs a highstate against all minions.
.EXAMPLE
    PS> Invoke-SaltApiState -Target '*' -State highstate

    Runs a highstate against all minions.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Invoke-SaltApiTestPing {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        [String]
        [Validateset('glob','compound','grain','list')]
        $TargetType = 'glob',
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

    $TargetType = $TargetType.ToLower()

    $function = 'test.ping'

    $kwarg = @{
        tgt      = $Target
        tgt_type = $TargetType
    }

    $parameters = @{
        Client               = 'local'
        kwarg                = $kwarg
        Function             = $function
        SkipCertificateCheck = $SkipCertificateCheck
    }

    $return = Invoke-SaltApiFunction @parameters

    $minionNames = $return.Content.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name

    $array = @()

    foreach ($minion in $minionNames) {
        $hash = [PSCustomObject]@{
            MinionID   = $minion
            Return     = $return.Content.$minion
        }

        $array += $hash
    }

    Write-Output $array

}