# Invoke-SaltApiFunction - Examples
Invokes functions against a Salt Master running REST_CHERRYPY using [Salt's Python API](https://docs.saltproject.io/en/latest/ref/clients/index.html#python-api)

Everything possible at the CLI is possible through the Python API. Commands are executed on the Salt Master.

Invoke-SaltApiFunction accepts a Target paramerter as well as parameters for both arguments ($Arg) and kwargs ($kwarg). Arguments are passed in as Arrays and kwargs are passed in as a hashtable (or dictionary).

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
