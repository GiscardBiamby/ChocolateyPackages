function Restart-Vpn {
	Restart-Service iked
	Restart-Service ipsecd
}
