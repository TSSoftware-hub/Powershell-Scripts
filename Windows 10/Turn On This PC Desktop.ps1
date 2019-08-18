# Author: Sergey Trukhanov
# Version: 1
# Description: turns on This PC shortcut on the Desktop

$ErrorActionPreference1 = "SilentlyContinue"
If ($Error) {$Error.Clear()}

$RegistryPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
If (-Not(Test-Path $RegistryPath1)) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "Explorer" -Force | Out-Null
}
If (Test-Path $RegistryPath1) {
	#This PC
	$Res1 = Get-ItemProperty -Path $RegistryPath1 -Name "NoStartMenuMorePrograms"
	If (-Not($Res1)) {
		New-ItemProperty -Path $RegistryPath1 -Name "NoStartMenuMorePrograms" -Value "1" -PropertyType DWORD -Force | Out-Null
	}
	$Check1 = (Get-ItemProperty -Path $RegistryPath1 -Name "NoStartMenuMorePrograms")."NoStartMenuMorePrograms"
	If ($Check1 -NE 0) {
		New-ItemProperty -Path $RegistryPath1 -Name "NoStartMenuMorePrograms" -Value "1" -PropertyType DWORD -Force | Out-Null
	}
}
If ($Error) {$Error.Clear()}


#=======================================

# Restart the Explorer and refresh the Desktop, Start, and Taskbar

Stop-Process -ProcessName Explorer -Force