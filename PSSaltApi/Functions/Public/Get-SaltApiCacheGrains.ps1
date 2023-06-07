<#
.SYNOPSIS
    Gets cached grains of the targeted minions.
.DESCRIPTION
    This function will use the Invoke-SaltApiFunction to call the cache.grains function returning a list of minions and their grains. TargetType defaults to 'glob'.
.EXAMPLE
    Get-SaltApiCacheGrains -Target '*'

    This will return the grains for all Minions.
.EXAMPLE
    Get-SaltApiCacheGrains -Target 'minion1'

    This will return the grains for 'minion1'.
.EXAMPLE
    Get-SaltApiCacheGrains -Target 'G@os:Ubuntu' -TargetType compound

    Using a compound query, this will return the grains for minions where 'os' equals 'Ubuntu'.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltApiCacheGrains {
    param (
        [String]
        $Target,
        [String]
        [Validateset('glob','compound','grain','list')]
        $TargetType = 'glob',
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

    $kwarg = @{
        tgt = $Target
        tgt_type = $TargetType
    }

    $return = Invoke-SaltApiFunction -SkipCertificateCheck -Client runner -Kwarg $kwarg -Function cache.grains

    $minionNames = $return.Content.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name

    $results = @()

    foreach ($minion in $minionNames) {
        $hash = [PSCustomObject]@{
            MinionID = $minion
            Grains = $return.Content.$minion
        }

        $results += $hash
    }

    $results
}