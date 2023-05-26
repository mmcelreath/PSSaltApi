Function Disconnect-SaltApi {
    <#
    .SYNOPSIS
    Use this function to disconnect your session to the salt-api
    .DESCRIPTION
    This function will disconnect your session from the salt-api.
    A global variable ($global:SaltAPIConnection), which should have originally been created by the Connect-SaltApi, will be set to $null by running this function.
    .EXAMPLE
    DisConnect-SaltApi

    Disconnect from the salt-api.
#>
    param()

    if (!$global:SaltAPIConnection) {
        Write-Warning 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltApi.'
        return
    } else {
        $url = $global:SaltAPIConnection.URL
        $user = $global:SaltAPIConnection.User
        $global:SaltAPIConnection = $null
        Remove-Variable -Name SaltAPIConnection -Scope global -Force -ErrorAction SilentlyContinue
        Write-Warning "$user has been disconnected fromn $URL. To run commands against the salt-api, run Connect-SaltApi to create a new connection."
    }

}
