# PSSaltApi
SaltStack API PowerShell module. Provides PowerShell function wrappers for the salt-api

This function will allow you to connect to a salt-api instance. Once authenticated, a new token will be generated that has an expiration of 12 hours (by default).
A global variable ($global:SaltAPIConnection) will be set with the Servername & Token details for use by other functions in the module.

To use this module, a Salt Master needs to be configured with REST_CHERRYPY. Here are some helpful links that got me started.

[REST_CHERRYPY](https://docs.saltproject.io/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html)

[EXTERNAL AUTHENTICATION SYSTEM](https://docs.saltproject.io/en/latest/topics/eauth/index.html)

[ACCESS CONTROL SYSTEM](https://docs.saltproject.io/en/latest/topics/eauth/access_control.html#acl)

[SaltStack for Developers - YouTube video - No Sound Unfortunately](https://www.youtube.com/watch?v=pGW20NPAwuo&t=1491s)

## External Authentication System (eAuth)

### `$eAuthSystem` Parameter

Salt's External Authentication System (eAuth) allows for Salt to pass through command authorization to any external authentication system, such as PAM or LDAP.

eAuth using the PAM external auth system requires salt-master to be run as root as this system needs root access to check authentication.

https://docs.saltproject.io/en/latest/topics/eauth/index.html#acl-eauth

## Executing Functions through the `salt-api`

From the [Rest_CherryPy documentation](https://docs.saltproject.io/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html): 

> "This interface directly exposes Salt's [Python API](https://docs.saltproject.io/en/latest/ref/clients/index.html#python-api). Everything possible at the CLI is possible through the Python API. Commands are executed on the Salt Master."

The `PSSaltApi` module provides a wrapper function to interface with the `salt-api` in a PowerShell environment. The wrapper function to use is called `Invoke-SaltApiFunction`.

## Usage

```powershell
# Install Module
> Install-Module PSSaltApi

> $credential = Get-Credential

# Connect to salt-api using the provided credential
# This command will create a Global variable called $global:SaltAPIConnection which will be used for the rest of the functions in this module
> Connect-SaltApi -Server <SALT_MASTER> -Port 8000 -Credential $credential

# This command will use the local client to target all minions ('*') and execute the test.version function
> $return = Invoke-SaltApiFunction -Client local -Target '*' -Function 'test.version'

> $return

StatusCode StatusDescription Content      
---------- ----------------- -------      
       200 OK                @{ubu=3006.1}

> $return.Content

ubu   
---   
3006.1

```