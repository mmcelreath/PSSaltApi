# Get-SaltApiKeyState - Examples
Gets the state of Minion keys.

This function will use Invoke-SaltApi to call the key.list function returning a list of minions for the provided `$KeyState`.

### Connect to the salt-api

```powershell
PS> Connect-SaltApi -Server 127.0.0.1 -Port 8000 -Credential $credential
```

## Example - Return all minions for all key states (default is $KeyState = 'all')

```powershell
PS> Get-SaltApiKeyState

minions          : {minion1, minion2}
minions_pre      : {}
minions_rejected : {}
minions_denied   : {}
local            : {master.pem, master.pub}
```

## Example - Return all minions with an 'accepted' key state

```powershell
PS> Get-SaltApiKeyState -KeyState accepted

minions
-------
{minion1, minion2}
```
