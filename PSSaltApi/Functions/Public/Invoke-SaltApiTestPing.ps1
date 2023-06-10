<#
.SYNOPSIS
    Runs a test ping against a Target.
.DESCRIPTION
    This function will use Invoke-SaltApiFunction to call the test.ping function.
.EXAMPLE
    PS> Invoke-SaltApiTestPing -Target '*' 

    Runs a test ping against all minions
.EXAMPLE
    PS> Invoke-SaltApiTestPing -Target 'minion1' 

    Runs a test ping against a minion called 'minion1'
.EXAMPLE
    PS> Invoke-SaltApiTestPing -Target 'G@os:Ubuntu' -TargetType compound  

    Using a compound query, runs a test ping against minions where os = Ubuntu
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