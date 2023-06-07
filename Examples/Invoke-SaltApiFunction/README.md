# Invoke-SaltApiFunction - Examples
Gets grains for Minions returned by a Target.

This function will use Invoke-SaltApiFunction to call the grains.get or grains.items function returning a list of minions and their grains. TargetType defaults to `glob`.

### Connect to the salt-api

```powershell
PS> Connect-SaltApi -Server 127.0.0.1 -Port 8000 -Credential $credential
```

## Example - Run the state.apply function on the 'local' client to run the teststate sls against all minions

```powershell
PS> $arg = @('teststate')
PS> Invoke-SaltApiFunction -Client local -Function 'state.apply' -Target '*' -Arg $arg

StatusCode StatusDescription Content
---------- ----------------- -------
       200 OK                @{minion1=; minion2=}
```

## Example - Run the cache.grains function on the runner client to get cache grains for the target minion1

```powershell
PS> Invoke-SaltApiFunction -Client runner -Function cache.grains -Kwarg @{tgt = 'minion1'}

StatusCode StatusDescription Content
---------- ----------------- -------
       200 OK                @{minion1=}
```

## Example - Run the key.finger function on the wheel client to get the public key fingerprint for the list of minions

```powershell
PS> $kwarg = @{match=@('minion1', 'minion2')}
PS> Invoke-SaltApiFunction -Client wheel -Function 'key.finger' -Kwarg $kwarg

StatusCode StatusDescription Content
---------- ----------------- -------
       200 OK                @{tag=salt/wheel/202306092054262424261; data=}
```
