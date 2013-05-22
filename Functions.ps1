function Restart-Vpn {
	$vpnClientProcess = Get-Process -Name ipsecc -ErrorAction SilentlyContinue
	if ($vpnClientProcess -eq $null) {
		Write-Host "Vpn client is not running."
	} else {
		Write-Host "Stopping vpn client process."
		Stop-Process -Id $vpnClientProcess.Id
	}
	
	Restart-Service ipsecd
	Restart-Service iked
}
