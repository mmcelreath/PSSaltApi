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
function Invoke-SaltApiState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        [Parameter(Mandatory = $false)]
        [String]
        $State,
        [String]
        [Validateset('glob','compound','grain','list')]
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
    try {
        Check-SaltAPIConnection
    }
    catch {
        throw $_
    }

    $TargetType = $TargetType.ToLower()
    $arg = @()
    
    if ($State -eq 'highstate') {
        $function = 'state.highstate'
    } else {
        $function = 'state.apply'
        $arg += @($state)
    }

    if ($Exclude) {
        $arg += "exclude=$Exclude"
    }

    if ($Test) {
        $arg += 'test=true'
    }

    $kwarg = @{
        tgt      = $Target
        tgt_type = $TargetType
    }

    $parameters = @{
        Client               = 'local'
        kwarg                = $kwarg
        Function             = $function
        Arg                  = $arg
        SkipCertificateCheck = $SkipCertificateCheck
    }

    $return = Invoke-SaltApiFunction @parameters

    $minionNames = $return.Content.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name

    $obj =  [PSCustomObject]@{}

    Write-Output $return

}