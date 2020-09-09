$path = $args[0]
$csvpath = $args[1]
$exclude=@("public", ".NET*", "Administrator", "Default*")
$topcount = 5
$subDirectories = Get-ChildItem $path -Exclude $exclude | Where-Object{($_.PSIsContainer)}

$data = @()
$sizeinfo = @{}


foreach ($i in $subDirectories.fullName)
	{
    $size=((robocopy.exe $i c:\fakepathduh /L /XJ /R:0 /W:1 /NP /E /BYTES /NFL /NDL /NJH /MT:64)[-4] -replace '\D+(\d+).*','$1') / 1MB -as [int]
    $sizeinfo.Add($i, $size)
   
}

$topvalues = ($sizeinfo.GetEnumerator() | Sort-Object -Property Value -Descending | select -first $topcount)
$topvalues | select Name,Value | Export-Csv $csvpath
foreach($value in $topvalues){
    $data += [PSCustomObject]@{"#DIR" = $value.name}
}
$json = [PSCustomObject]@{"data" = $data}
$json | convertto-json
