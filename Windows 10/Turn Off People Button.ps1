# Author: Sergey Trukhanov
# Version: 1
# Description: turns off People Button

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}
$RegistryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
If (Test-Path $RegistryPath3) {
	#This PC
	$Res3 = Get-ItemProperty -Path $RegistryPath3 -Name "PeopleBand"
	If (-Not($Res3)) {
		New-ItemProperty -Path $RegistryPath3 -Name "PeopleBand" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check3 = (Get-ItemProperty -Path $RegistryPath3 -Name "PeopleBand")."PeopleBand"
	If ($Check3 -NE 0) {
		New-ItemProperty -Path $RegistryPath3 -Name "PeopleBand" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
If ($Error) {$Error.Clear()}
