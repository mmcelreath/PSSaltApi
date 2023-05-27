$a = Invoke-SaltApiFunction -Client wheel -Function 'key.list_all' -SkipCertificateCheck 

$a.Content.data.return

$accept = Invoke-SaltApiFunction -Client wheel -Function 'key.accept' -Arguments @(,'minion1') -SkipCertificateCheck 
$accept.Content.data.return


