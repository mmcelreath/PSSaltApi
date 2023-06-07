# Get-SaltApiMinionGrain - Examples
Gets grains for Minions returned by a Target.

This function will use Invoke-SaltApiFunction to call the grains.get or grains.items function returning a list of minions and their grains. TargetType defaults to `glob`.

### Connect to the salt-api

```powershell
PS> Connect-SaltApi -Server 127.0.0.1 -Port 8000 -Credential $credential
```

## Example - Return all grains for all Minions

```powershell
PS> Get-SaltApiMinionGrain -Target '*'

MinionID Grains
-------- ------
minion1  @{cwd=/; ip_gw=True; …}
minion2  @{cwd=/; ip_gw=True; …}
```

## Example - Return the 'os' grain for all minions

```powershell
PS> Get-SaltApiMinionGrain -Target * -Grain os

MinionID Grains
-------- ------
minion1  @{os=Ubuntu}
minion2  @{os=Ubuntu}
```

## Example - Using a compound query, this will return the grains for minions where 'os' equals 'Ubuntu'

```powershell
PS> Get-SaltApiMinionGrain -Target 'G@os:Ubuntu' -TargetType compound

MinionID Grains
-------- ------
minion1  @{cwd=/; ip_gw=True; …}
minion2  @{cwd=/; ip_gw=True; …}
```
