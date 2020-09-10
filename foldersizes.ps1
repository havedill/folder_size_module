$path = $args[0]
$exclude=@("public", ".NET*", "Administrator", "Default*")
$topcount = 5
$subDirectories = Get-ChildItem $path -Exclude $exclude | Where-Object{($_.PSIsContainer)}

$data = @()
$sizeinfo = @{}


foreach ($i in $subDirectories.fullName)
	{
    $size=((robocopy.exe $i c:\fakepathduh /L /XJ /R:0 /W:1 /NP /E /BYTES /NFL /NDL /NJH /MT:64)[-4] -replace '\D+(\d+).*','$1')
    $sizeinfo.Add($i.Replace("\","/"), $size)
   
}

$topvalues = ($sizeinfo.GetEnumerator() | Sort-Object -Property Value -Descending | select -first $topcount)
foreach($value in $topvalues){
    if($value.value -eq ""){
        $value.value = -1000
    }
    $data += [PSCustomObject]@{"{#DIR}" = $value.name}
        
    #remove out-null and add -vv for debugging if your not seeing items populate
    C:\zabbix\bin\zabbix_sender.exe -c "C:\zabbix\conf\zabbix_agentd.conf" -s $ENV:computername -k "folder.size[$($value.name)]" -o $value.value | out-null

}
$json = [PSCustomObject]@{"data" = $data}
$json | convertto-json
