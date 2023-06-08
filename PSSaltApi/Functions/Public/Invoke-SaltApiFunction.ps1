<#
.SYNOPSIS
    Invokes functions against a Salt Master running REST_CHERRYPY using Salt's Python API (https://docs.saltproject.io/en/latest/ref/clients/index.html#python-api)
.DESCRIPTION
    Everything possible at the CLI is possible through the Python API. Commands are executed on the Salt Master.

    Invoke-SaltApiFunction accepts a Target paramerter as well as parameters for both arguments ($Arg) and kwargs ($kwarg). Arguments are passed in as Arrays and kwargs are passed in as a hashtable (or dictionary).
.EXAMPLE
    PS> $arg = @('highstate')
    PS> Invoke-SaltApiFunction -Client local -Function 'state.apply' -Target '*' -Arg $arg

    Run the state.apply function on the 'local' client to run the teststate sls against all minions.
.EXAMPLE
    PS> Invoke-SaltApiFunction -Client runner -Function cache.grains -Kwarg @{tgt = 'minion1'}

    Run the cache.grains function on the runner client to get cache grains for the target minion1.
.EXAMPLE
    PS> $kwarg = @{match=@('minion1', 'minion2')}
    PS> Invoke-SaltApiFunction -Client wheel -Function 'key.finger' -Kwarg $kwarg

    Run the key.finger function on the wheel client to get the public key fingerprint for the list of minions.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Invoke-SaltApiFunction {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        [ValidateSet('local', 'runner', 'wheel')]
        $Client,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Target,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        $Function,
        [Parameter(Mandatory = $false, Position = 3)]
        # [string]
        $Arg,
        [Parameter(Mandatory = $false, Position = 4)]
        [hashtable]
        $kwarg,
        [Parameter(Mandatory = $false)]    
        [Switch]
        $SkipCertificateCheck = $false,
        [Parameter(Mandatory = $false)]
        [System.Net.SecurityProtocolType]
        $SslProtocol,
        [Parameter(Mandatory = $false)]
        [string]
        $TimeoutSec
    )

    # # Tests
    # $Client = 'wheel'
    # $Target = $null
    # $Function = 'key.finger'

    # Check to see if there is an existing connection to SaltStack
    try {
        Check-SaltAPIConnection
    }
    catch {
        throw $_
    }

    if ($SslProtocol) {
        [System.Net.ServicePointManager]::SecurityProtocol = $SslProtocol
    }

    $server = $global:SaltAPIConnection.Server
    $port   = $global:SaltAPIConnection.Port
    $token  = $global:SaltAPIConnection.Token

    $url = "https://${server}:$port/"

    $header = @{
        'Accept'       = 'application/json'
        'Content-type' = 'application/json'
        'X-Auth-Token' = $token
    }

    $body = @{
        client = $Client
        fun    = $Function
        # tgt_type = 'compound'
        # tgt    = $Target
        # arg    = @('highstate')
        # match   = @('minion1')
        # include_rejected = $true
    }

    if ($Kwarg) {
        foreach ($k in $kwarg.keys) {
            $body.Add($k, $kwarg[$k])
        }
    }

    if ($Target) {
        $body.Add('tgt', $Target)
    }

    if ($Arg) {
        $body.Add('arg', $Arg)
    }

    $webRequestParams = @{
        Uri                  = $url 
        SkipCertificateCheck = $SkipCertificateCheck
        Body                 = (ConvertTo-Json $body)
        Headers              = $header
        Method               = 'Post'
    }

    if ($TimeoutSec) {
        $webRequestParams.Add('TimeoutSec', $TimeoutSec)
    }

    try {
        $webRequest = Invoke-WebRequest @webRequestParams

        $properties = @{
            StatusCode        = $webRequest.StatusCode
            StatusDescription = $webRequest.StatusDescription
            Content           = $webrequest.Content | ConvertFrom-Json | Select-Object -ExpandProperty return
        }
    
        $obj = New-Object -TypeName PSCustomObject -Property $properties
    
        Write-Output -InputObject $obj | Select-Object StatusCode, StatusDescription, Content
    }
    catch {
        Write-Error ("Failure running the salt-api function: " + $_)
    }

}