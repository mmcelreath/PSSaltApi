$a = Invoke-SaltApiFunction -Client local -Target 'minion1' -Function 'state.highstate'-SkipCertificateCheck 
$a.Content

$a = Invoke-SaltApiFunction -Client local -Target 'ubu' -Function 'state.apply' -Arg @('teststate', 'test=true') -SkipCertificateCheck
$a.content.ubu

$a = Invoke-SaltApiFunction -Client wheel -Function 'key.list_all' -SkipCertificateCheck
$a.Content.data.return

$kwarg = @{match=@('minion1', 'ubu')}

$a = Invoke-SaltApiFunction -Client wheel -Function 'key.finger' -SkipCertificateCheck -Kwarg $kwarg
$a.Content.data.return

$kwarg2 = @{match=@('minion1')}

$a = Invoke-SaltApiFunction -Client wheel -Function 'key.reject' -SkipCertificateCheck -Kwarg $kwarg2
$a.Content.data.return

Invoke-SaltApiFunction -Client wheel  -Function 'key.list_all' -SkipCertificateCheck

$arg = @('highstate')
Invoke-SaltApiFunction -Client local  -Function 'state.apply' -Arg $arg -SkipCertificateCheck -Target '*'

Invoke-SaltApiFunction -Client local -Target '*' -Function 'test.version' -SkipCertificateCheck 
Invoke-SaltApiFunction -Client local -Target '*' -Function 'test.ping' -SkipCertificateCheck 

Invoke-SaltApiFunction -Client local -Target '*' -Function 'grains.items' -SkipCertificateCheck
Invoke-SaltApiFunction -Client local -Target '*' -Function 'grains.get' -SkipCertificateCheck -Arg 'nodename'

# https://docs.saltproject.io/en/latest/ref/wheel/all/salt.wheel.minions.html

#########################################################################################

$arg = @{match = 'ubu'}



$a = Invoke-SaltApiFunction -Client wheel -Function 'key.accept' -SkipCertificateCheck -Match @('minion1')
$a.Content.data.return

# Need to change $Arguments to $Arg and add $Parameters(Name?)

$a.Content.data.return

$Arguments = @{
    match = @{
        minions = @('minion1')
    }
}








