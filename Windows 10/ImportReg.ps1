# Author: Sergey Trukhanov
# Version: 1
# Description: import reg, in progress, attempting to customize Win 10 user interface

# Set Show app list in Start menu to Off, Choose which folders appear on Start (File Explorer, Settings, Documents, and Downloads) 

# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$$windows.data.unifiedtile.startglobalproperties\Current
# REG_BINARY key
# Configured Start Menu, exported key, called it StartMenu.reg
# Will do import, need to use reg.exe

# reg Import .\StartMenu.reg
# OR

$StartParams = @{
    FilePath = "$Env:SystemRoot\REGEDIT.exe"
    ArgumentList = '/s','C:\Temp\Scripts\StartMenu.reg'
    Verb = 'RunAs'
    PassThru = $True
    Wait = $True
}
$Proc = Start-Process @StartParams

If ($Proc.ExitCode -eq 0) { Write-Host 'The Start Menu parameters were changed' }
Else { Write-Host "Failed to change Start Menu! Exit code: $($Proc.ExitCode)" }

#===========================================================================================================================================================================

# Customize Notification Area
# HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify
# IconStreams - REG_BINARY key
# Hide Action Center
# Allways Show Icons: Sophos, Box Sync, Cisco AnyConnect, and Skype for Business
# Configured Start Menu, exported key, called it StartMenu.reg
# Will do import, need to use reg.exe

$StartParams1 = @{
    FilePath = "$Env:SystemRoot\REGEDIT.exe"
    ArgumentList = '/s','C:\Temp\Scripts\TaskMenu.reg'
    Verb = 'RunAs'
    PassThru = $True
    Wait = $True
}
$Proc1 = Start-Process @StartParams1

If ($Proc1.ExitCode -eq 0) { Write-Host 'The Start Menu parameters were changed' }
Else { Write-Host "Failed to change Start Menu! Exit code: $($Proc1.ExitCode)" }