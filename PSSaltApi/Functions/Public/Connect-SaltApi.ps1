Function Connect-SaltApi {
    <#
    .NOTES
    
    .SYNOPSIS
    Use this function to authenicate with the Salt API
    .DESCRIPTION
    This function will allow you to connect to a salt-api instance. Once authenticated, a new token will be generated that has an expiration of 12 hours (by default).
    A global variable ($global:SaltAPIConnection) will be set with the Servername & Token details for use by other functions in the module.

    To use this module, a Salt Master needs to be configured with REST_CHERRYPY. Here are some helpful links that got me started.

    https://docs.saltproject.io/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html
    https://docs.saltproject.io/en/latest/topics/eauth/index.html#acl-eauth
    https://docs.saltproject.io/en/latest/topics/eauth/access_control.html#acl

    - eAuthSystem: Salt's External Authentication System (eAuth) allows for Salt to pass through command authorization to any external authentication system, such as PAM or LDAP.
    - eAuth using the PAM external auth system requires salt-master to be run as root as this system needs root access to check authentication.
    - https://docs.saltproject.io/en/latest/topics/eauth/index.html#acl-eauth
    .EXAMPLE
    Connect-SaltApi -Server 'salt.example.com' -Credential $Credential

    This will default to PAM authentication forthe Exterhan Authentication System (eAuth).
    .EXAMPLE
    Connect-SaltApi -Server 'salt.example.com'

    This will prompt for credentials
    .EXAMPLE
    $creds = Get-Credential

    Connect-SaltApi -Server 'salt.example.com' -Credential $Credential -eAuthSystem 'LDAP'

    This will connect by authenticating with an LDAP Exterhan Authentication System (eAuth).
    https://docs.saltproject.io/en/latest/ref/auth/all/index.html
#>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Server,
        [Parameter(Mandatory=$false, Position=3)]
        [string]
        [ValidateSet('auto', 'django', 'file', 'keystone', 'ldap', 'mysql', 'pam', 'pki', 'rest', 'sharedsecret', 'yubico')]
        $eAuthSystem = 'pam',
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false)]
        [string]
        $Port = '8000',
        [Parameter(Mandatory = $false)]
        [Switch]
        $SkipCertificateCheck = $false,
        [Parameter(Mandatory = $false)]
        [System.Net.SecurityProtocolType]
        $SslProtocol
    )

    $url = "https://${server}:$port/login"

    $username = $Credential.GetNetworkCredential().username
    $password = $Credential.GetNetworkCredential().password

    if ($SslProtocol) {
        [System.Net.ServicePointManager]::SecurityProtocol = $SslProtocol
    }
    
    try {
        # For PowerShell versions previous to 6.0, Invoke-WebRequest -SkipCertificateCheck was not available. So use the code below if $SkipCertificateCheck = $true
        if (($PSEdition -eq 'Desktop') -and ($SkipCertificateCheck -eq $true)) {
            # This if statement is using example code from https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
            add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
"@
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        }

        $header = @{
            'Accept'       = 'application/json'
            'Content-type' = 'application/json'
        }
        
        $body = @{
            username = $username
            password = $password
            eauth    = $eAuthSystem
        }

        $tokenRequestParams = @{
            Uri = $url 
            SkipCertificateCheck = $SkipCertificateCheck
            Body = (ConvertTo-Json $body)
            Headers = $header
            Method = 'Post'
        }

        $tokenRequest = Invoke-WebRequest @tokenRequestParams

        $tokenDetails = $tokenRequest.Content | convertfrom-json | select -ExpandProperty return

        $obj = @{
            Server = $server
            URL    = $url
            Token  = $tokenDetails.token
            Expire = $tokenDetails.expire
            Start  = $tokenDetails.start
            User   = $tokenDetails.user
            eAuth  = $tokenDetails.eauth
            perms  = $tokenDetails.perms            
        }

        $global:SaltAPIConnection = New-Object -TypeName psobject -Property $obj
    
        # Return the connection object
        $global:SaltAPIConnection

    } catch {
        Write-Error ("Failure connecting to $server. " + $_)
    } # end try/catch block
}