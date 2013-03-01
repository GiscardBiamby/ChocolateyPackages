Stop-Process -ProcessName WebDev.WebServer40* -Verbose 

$is64bit = (Get-WmiObject Win32_Processor).AddressWidth -eq 64
if ($is64Bit) {
	autoit3_x64 C:\users\giscard\downloads\_RefreshNotificationAreaIcons.au3
} else {
	autoit3 C:\users\giscard\downloads\_RefreshNotificationAreaIcons.au3
}


