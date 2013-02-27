$source = "http://www.fanboy.co.nz/adblock/opera/complete/urlfilter.ini"
$destination = "C:/Program Files (x86)/SRWare Iron/adblock.ini"

$newValue = (new-object net.webclient).DownloadString($source).Replace('*','').Replace('#',' ')

if ($newValue -gt '') {
    Remove-Item -Path $destination 
    Add-Content -Path $destination -Value $newValue
}




