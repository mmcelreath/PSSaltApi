<#
.SYNOPSIS
    Gets grains for Minions returned by a Target.
.DESCRIPTION
    This function will use the Invoke-SaltApiFunction to call the grains.get or grains.items function returning a list of minions and their grains. TargetType defaults to 'glob'.
.EXAMPLE
    Get-SaltApiMinionGrain -Target '*'

    This will return all grains for all Minions.
.EXAMPLE
    Get-SaltApiMinionGrain -Target * -Grain os

    This will return the 'os' grain for all minions.
.EXAMPLE
    Get-SaltApiMinionGrain -Target 'G@os:Ubuntu' -TargetType compound

    Using a compound query, this will return the grains for minions where 'os' equals 'Ubuntu'.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltApiMinionGrain {
    param (
        [String]
        $Target,
        [String]
        [Validateset('glob','compound','grain','list')]
        $TargetType = 'glob',
        [String]
        $Grain,
        [Switch]
        $SkipCertificateCheck = $false
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltAPIConnection) {
        Write-Error 'You are not currently connected to any SaltStack APIs. Please connect first using Connect-SaltApi.'
        return
    }

    $TargetType = $TargetType.ToLower()

    If ($Grain) {
        $function = 'grains.get'
    } else {
        $function = 'grains.items'
    }

    $kwarg = @{
        tgt      = $Target
        tgt_type = $TargetType
    }

    $parameters = @{
        Client               = 'local'
        Function             = $Function
        SkipCertificateCheck = $SkipCertificateCheck
        kwarg                = $kwarg
    }

    if ($Grain) {
        $parameters.Add('Arg', $Grain)
    }

    $return = Invoke-SaltApiFunction @parameters

    $minionNames = $return.Content.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name

    $results = @()

    foreach ($minion in $minionNames) {
        
        if ($Grain) {
            $hash = [PSCustomObject]@{
                MinionID = $minion
                Grains = [PSCustomObject]@{
                    $Grain = $return.Content.$minion
                }
            }
        } else {
            $hash = [PSCustomObject]@{
                MinionID = $minion
                Grains = $return.Content.$minion
            }
        }

        $results += $hash
    }

    Write-Output $results
}