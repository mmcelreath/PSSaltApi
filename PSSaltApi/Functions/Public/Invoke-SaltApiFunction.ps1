function Invoke-SaltApiFunction {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        [ValidateSet('local', 'runner', 'wheel')]
        $Client,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Target,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        $Function,
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
    # $Client = 'local'
    # $Target = '*'
    # $Function = 'test.version'

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
        tgt    = $Target
        fun    = $Function
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