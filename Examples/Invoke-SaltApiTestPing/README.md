# Invoke-SaltApiTestPing - Examples
Runs a test ping against a Target.

This function will use Invoke-SaltApiFunction to call the test.ping function.

### Connect to the salt-api

```powershell
PS> Connect-SaltApi -Server 127.0.0.1 -Port 8000 -Credential $credential
```

## Example - Runs a test ping against all minions

```powershell
PS> Invoke-SaltApiTestPing -Target '*' 

MinionID Return
-------- ------
minion1    True
minion2    True
```

## Example - Runs a test ping against a minion called 'minion1'

```powershell
PS> Invoke-SaltApiTestPing -Target 'minion1' 

MinionID Return
-------- ------
minion1    True
```

## Example - Using a compound query, runs a test ping against minions where os = Ubuntu

```powershell
PS> Invoke-SaltApiTestPing -Target 'G@os:Ubuntu' -TargetType compound  

MinionID Return
-------- ------
minion1    True
minion2    True
```
