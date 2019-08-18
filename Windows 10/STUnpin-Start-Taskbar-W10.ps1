# Author: Sergey Trukhanov
# Version: 1
# Description: script which helps to customize user profile (in progress).

function Pin-App ([string]$appname, [switch]$unpin, [switch]$start, [switch]$taskbar, [string]$path) {
    if ($unpin.IsPresent) {
        $action = "Unpin"
    } else {
        $action = "Pin"
    }
    
    if (-not $taskbar.IsPresent -and -not $start.IsPresent) {
        Write-Error "Specify -taskbar and/or -start!"
    }
    
    if ($taskbar.IsPresent) {
        try {
            $exec = $false
            if ($action -eq "Unpin") {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from Taskbar'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' unpinned from Taskbar"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action
                    } else {
                        Write "'$appname' not found or 'Unpin from taskbar' not found on item!"
                    }
                }
            } else {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Pin to Taskbar'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' pinned to Taskbar"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action
                    } else {
                        Write "'$appname' not found or 'Pin to taskbar' not found on item!"
                    }
                }
            }
        } catch {
            Write-Error "Error Pinning/Unpinning $appname to/from taskbar!"
        }
    }
    
    if ($start.IsPresent) {
        try {
            $exec = $false
            if ($action -eq "Unpin") {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from Start'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' unpinned from Start"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action -start
                    } else {
                        Write "'$appname' not found or 'Unpin from Start' not found on item!"
                    }
                }
            } else {
                ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Pin to Start'} | %{$_.DoIt(); $exec = $true}
                
                if ($exec) {
                    Write "App '$appname' pinned to Start"
                } else {
                    if (-not $path -eq "") {
                        Pin-App-by-Path $path -Action $action -start
                    } else {
                        Write "'$appname' not found or 'Pin to Start' not found on item!"
                    }
                }
            }
        } catch {
            Write-Error "Error Pinning/Unpinning $appname to/from Start!"
        }
    }
}

function Pin-App-by-Path([string]$Path, [string]$Action, [switch]$start) {
    if ($Path -eq "") {
        Write-Error -Message "You need to specify a Path" -ErrorAction Stop
    }
    if ($Action -eq "") {
        Write-Error -Message "You need to specify an action: Pin or Unpin" -ErrorAction Stop
    }
    if ((Get-Item -Path $Path -ErrorAction SilentlyContinue) -eq $null){
        Write-Error -Message "$Path not found" -ErrorAction Stop
    }
    $Shell = New-Object -ComObject "Shell.Application"
    $ItemParent = Split-Path -Path $Path -Parent
    $ItemLeaf = Split-Path -Path $Path -Leaf
    $Folder = $Shell.NameSpace($ItemParent)
    $ItemObject = $Folder.ParseName($ItemLeaf)
    $Verbs = $ItemObject.Verbs()
    
    if ($start.IsPresent) {
        switch($Action){
            "Pin"   {$Verb = $Verbs | Where-Object -Property Name -EQ "&Pin to Start"}
            "Unpin" {$Verb = $Verbs | Where-Object -Property Name -EQ "Un&pin from Start"}
            default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
        }
    } else {
        switch($Action){
            "Pin"   {$Verb = $Verbs | Where-Object -Property Name -EQ "Pin to Tas&kbar"}
            "Unpin" {$Verb = $Verbs | Where-Object -Property Name -EQ "Unpin from Tas&kbar"}
            default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
        }
    }
    
    if($Verb -eq $null){
        Write-Error -Message "That action is not currently available on this Path" -ErrorAction Stop
    } else {
        $Result = $Verb.DoIt()
    }
}

#===========================================================================================================================================================================

#Unpin/Pin applications from/to Taskbar and Start

# Unpin from Taskbar
Pin-App "Mail" -unpin -taskbar
Pin-App "Microsoft Store" -unpin -taskbar
Pin-App "Microsoft Edge" -unpin -taskbar

# Unpin from Start
Pin-App "Calendar" -unpin -start
Pin-App "Mail" -unpin -start
Pin-App "My Office" -unpin -start
Pin-App "OneNote" -unpin -start
Pin-App "Microsoft Store" -unpin -start
Pin-App "Microsoft Edge" -unpin -start
Pin-App "Skype" -unpin -start
Pin-App "Weather" -unpin -start
Pin-App "Xbox" -unpin -start
Pin-App "Movies & TV" -unpin -start
Pin-App "Groove Music" -unpin -start
Pin-App "Calculator" -unpin -start
Pin-App "Maps" -unpin -start
Pin-App "Photos" -unpin -start
Pin-App "Alarms & Clock" -unpin -start
Pin-App "Voice Recorder" -unpin -start

# pre-installed apps - need to think how to unpin this crap
# it looks like need to uninstall them
# try to uninstall all:
# Get-AppXPackage | where-object {$_.name –notlike “*store*”} | Remove-AppxPackage
#or unpin all from Start
<#
 (New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
  %{ $_.Verbs() } |
  ?{$_.Name -match 'Un.*pin from Start'} |
  %{$_.DoIt()}
   #>
<#Pin-App "Network Speed Test" -unpin -start
Pin-App "Microsoft News" -unpin -start
Pin-App "Microsoft Remote Desktop" -unpin -start
Pin-App "Stickies" -unpin -start
Pin-App "Microsoft Whiteboard" -unpin -start
Pin-App "Microsoft To-Do" -unpin -start
Pin-App "Office Lens" -unpin -start
Pin-App "Sway" -unpin -start#>

# Pin to Start
Pin-App "Internet Explorer" -pin -start
Pin-App "Google Chrome" -pin -start
Pin-App "Firefox" -pin -start
Pin-App "Outlook" -pin -start
Pin-App "Word" -pin -start
Pin-App "Excel" -pin -start
Pin-App "PowerPoint" -pin -start
Pin-App "Skype for Business" -pin -start
Pin-App "Cisco AnyConnect Secure Mobility Client" -pin -start
Pin-App "Adobe Acrobat XI Standard" -pin -start
Pin-App "Snipping Tool" -pin -start

# Pin to Taskbar
# The Verb Pin to Tas&kbar is no longer works on Windows 10, have some method in try.ps1 but it is not perfect
#Pin-App "Internet Explorer" -pin -taskbar
#Pin-App "Google Chrome" -pin -taskbar
#Pin-App "Firefox" -pin -taskbar
#Pin-App "Outlook" -pin -taskbar
#Pin-App "Word" -pin -taskbar
#Pin-App "Excel" -pin -taskbar
#Pin-App "PowerPoint" -pin -taskbar
#Pin-App "Skype for Business" -pin -taskbar
#Pin-App "Cisco AnyConnect Secure Mobility Client" -pin -taskbar
#Pin-App "Adobe Acrobat XI Standard" -pin -taskbar
#Pin-App "Snipping Tool" -pin -taskbar

#===========================================================================================================================================================================

# Show Desktop Icon

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (Test-Path $RegistryPath) {
	$Res = Get-ItemProperty -Path $RegistryPath -Name "HideIcons"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "HideIcons" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "HideIcons").HideIcons
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "HideIcons" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
If (-Not(Test-Path $RegistryPath)) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "HideDesktopIcons" -Force | Out-Null
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" -Name "NewStartPanel" -Force | Out-Null
}
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
If (-Not(Test-Path $RegistryPath)) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" -Name "NewStartPanel" -Force | Out-Null
}
If (Test-Path $RegistryPath) {
	#This PC
	$Res = Get-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}")."{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
If ($Error) {$Error.Clear()}

#===========================================================================================================================================================================


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

If ($Proc.ExitCode -eq 0) { Write-Host "The Start Menu parameters were changed" }
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

If ($Proc1.ExitCode -eq 0) { Write-Host "The Notification Area parameters were changed" }
Else { Write-Host "Failed to change Notification Area! Exit code: $($Proc1.ExitCode)" }


#===========================================================================================================================================================================

# Set Show Task View Button - Off

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}
$RegistryPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (Test-Path $RegistryPath1) {
	#This PC
	$Res1 = Get-ItemProperty -Path $RegistryPath1 -Name "ShowTaskViewButton"
	If (-Not($Res1)) {
		New-ItemProperty -Path $RegistryPath1 -Name "ShowTaskViewButton" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check1 = (Get-ItemProperty -Path $RegistryPath1 -Name "ShowTaskViewButton")."ShowTaskViewButton"
	If ($Check1 -NE 0) {
		New-ItemProperty -Path $RegistryPath1 -Name "ShowTaskViewButton" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
If ($Error) {$Error.Clear()}

#===========================================================================================================================================================================

# Set Show People Button - Off

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}
$RegistryPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
If (Test-Path $RegistryPath2) {
	#This PC
	$Res2 = Get-ItemProperty -Path $RegistryPath2 -Name "PeopleBand"
	If (-Not($Res2)) {
		New-ItemProperty -Path $RegistryPath2 -Name "PeopleBand" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check2 = (Get-ItemProperty -Path $RegistryPath2 -Name "PeopleBand")."PeopleBand"
	If ($Check2 -NE 0) {
		New-ItemProperty -Path $RegistryPath2 -Name "PeopleBand" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
If ($Error) {$Error.Clear()}


#===========================================================================================================================================================================

# Set Cortana - Hidden

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}
$RegistryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
If (Test-Path $RegistryPath3) {
	#This PC
	$Res3 = Get-ItemProperty -Path $RegistryPath3 -Name "SearchboxTaskbarMode"
	If (-Not($Res3)) {
		New-ItemProperty -Path $RegistryPath3 -Name "SearchboxTaskbarMode" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check3 = (Get-ItemProperty -Path $RegistryPath3 -Name "SearchboxTaskbarMode")."SearchboxTaskbarMode"
	If ($Check3 -NE 0) {
		New-ItemProperty -Path $RegistryPath3 -Name "SearchboxTaskbarMode" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
If ($Error) {$Error.Clear()}


#===========================================================================================================================================================================

# Restart the Explorer and refresh the Desktop, Start, and Taskbar

Stop-Process -ProcessName Explorer -Force