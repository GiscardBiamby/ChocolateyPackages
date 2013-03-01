function Restart-Vpn {
	Restart-Service ipsecd
	Restart-Service iked
}