# Invoke-SaltApiState - Examples
Applies a state or states to the specified Target.

This function will use Invoke-SaltApiFunction to call the state.apply or state.highstate function.

### Connect to the salt-api

```powershell
PS> Connect-SaltApi -Server 127.0.0.1 -Port 8000 -Credential $credential
```

## Example - Runs the state called 'vim' against 'minion1'

```powershell
PS> $result = Invoke-SaltApiState -Target 'minion1' -State vim

PS> $result

MinionID Return
-------- ------
minion1  {@{name=vim; changes=; result=True; comment=The following packages were installed/upd…

PS> $result.Retrun

name        : vim
changes     : @{vim=; vim-runtime=}
result      : True
comment     : The following packages were installed/updated: vim
__sls__     : vim
__run_num__ : 0
start_time  : 20:21:15.360308
duration    : 7635.743
__id__      : vim
```

## Example - Runs a highstate against all minions

```powershell
PS> Invoke-SaltApiState -Target '*' -State highstate

MinionID Return
-------- ------
minion2  {@{name=/etc/Test1.conf; changes=; result=True; comment=Updated times on file /etc/T…
minion1  {@{name=/etc/Test1.conf; changes=; result=True; comment=Updated times on file /etc/T…
```

## Example - Run a highstate against the minions returned by a compound Target (os = 'Ubuntu')

```powershell
PS> Invoke-SaltApiState -Target 'G@os:Ubuntu' -TargetType compound -State highstate

MinionID Return
-------- ------
ubu      {@{name=/etc/Test1.conf; changes=; result=True; comment=Updated times on file…
minion1  {@{name=/etc/Test1.conf; changes=; result=True; comment=Updated times on file…
```
