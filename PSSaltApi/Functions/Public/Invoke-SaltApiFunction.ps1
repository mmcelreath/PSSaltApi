# Add note about 400 Bad Request
# Client disabled: 'wheel'. Add to 'netapi_enable_clients' master config option to enable.

# Invoke-SaltApiFunction -Client wheel  -Function 'key.list_all' -SkipCertificateCheck

# $arg = @('highstate')
# Invoke-SaltApiFunction -Client local  -Function 'state.apply' -Arguments $arg -SkipCertificateCheck -Target '*'

# Invoke-SaltApiFunction -Client local -Target '*' -Function 'state.highstate'-SkipCertificateCheck 

# Invoke-SaltApiFunction -Client local -Target '*' -Function 'test.version' -SkipCertificateCheck 
# Invoke-SaltApiFunction -Client local -Target '*' -Function 'test.ping' -SkipCertificateCheck 

# Invoke-SaltApiFunction -Client local -Target '*' -Function 'grains.items' -SkipCertificateCheck
# Invoke-SaltApiFunction -Client local -Target '*' -Function 'grains.get' -SkipCertificateCheck -Arguments 'nodename'

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
        $Function,[Parameter(Mandatory = $false, Position = 3)]
        # [string]
        $Arguments,
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
    # $Function = 'key.accept'

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltAPIConnection) {
        Write-Error 'You are not currently connected to any SaltStack APIs. Please connect first using Connect-SaltApi.'
        return
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
        # tgt    = $Target
        # arg    = @('highstate')
    }

    if ($Target) {
        $body.Add('tgt', $Target)
    }

    if ($Arguments) {
        $body.Add('arg', $Arguments)
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