# Get-SaltApiCacheGrains - Examples
Gets cached grains of the targeted minions.

This function will use the Invoke-SaltApiFunction to call the cache.grains function returning a list of minions and their grains. TargetType defaults to 'glob'.

### Connect to the salt-api

```powershell
PS> Connect-SaltApi -Server 127.0.0.1 -Port 8000 -Credential $credential
```

## Example - Return all grains for all Minions

```powershell
PS> Get-SaltApiCacheGrains -Target '*'

MinionID Grains
-------- ------
minion1  @{cwd=/; ip_gw=True; …}
minion2  @{cwd=/; ip_gw=True; …}
```

## Example - Return the grains for 'minion1'

```powershell
PS> Get-SaltApiCacheGrains -Target 'minion1'

MinionID Grains
-------- ------
minion1  @{cwd=/; ip_gw=True;…}
```

## Example - Return the grains for minions where 'os' equals 'Ubuntu' using a compound query

```powershell
PS> Get-SaltApiCacheGrains -Target 'G@os:Ubuntu' -TargetType compound
```