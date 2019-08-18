<#The upside is, that this approach works and allows me to pin the shortcut. 
However when you click the shortcut, Explorer execs into the COM object, which creates a duplicate icon on the task bar. 
So even if this gets where you want, it's hardly ideal as it doesn't achieve the same result as manually pinning the Control Panel window.#>


# Get "Control Panel" namespace and localized name
$cplCLSID = "::{26EE0668-A00A-44D7-9371-BEB064C98683}"
$cplNS = (New-Object -Com "Shell.Application").NameSpace("shell:$cplCLSID")
$lnkName = $cplNS.Title

# Create a shortcut in Quick Launch folder
$lnkPath = "$env:AppData\Microsoft\Internet Explorer\Quick Launch\$lnkName.lnk"
$lnk = (New-Object -ComObject "WScript.Shell").CreateShortcut($lnkPath)
$lnk.IconLocation = "$env:WinDir\System32\shell32.dll, 21"
$lnk.TargetPath = "$env:WinDir\explorer.exe"
$lnk.Arguments = "$cplCLSID"
$lnk.Save()

# Bring pinning / unpinning handler into '*' class scope
$pinHandler = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin" -Name "ExplorerCommandHandler"
New-Item -Path "HKCU:Software\Classes\*\shell\pin" -Force | Out-Null
Set-ItemProperty -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Name "ExplorerCommandHandler" -Type String -Value $pinHandler

# Pin / unpin the shortcut
$lnkItem = Get-Item $lnkPath
$lnkItem = (New-Object -Com "Shell.Application").Namespace($lnkItem.DirectoryName).ParseName($lnkItem.Name)
$lnkItem.InvokeVerb("pin")

# Remove the handler
Remove-Item -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Recurse

<# Method2 - didn't work on my PC

# Get "Control Panel" namespace and localized name
$cplCLSID = "::{26EE0668-A00A-44D7-9371-BEB064C98683}"
$cplNS = (New-Object -Com "Shell.Application").NameSpace("shell:$cplCLSID")
$lnkName = $cplNS.Title

# Create a shortcut in taskbar pins folder
$lnkPath = "$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$lnkName.lnk"
$lnk = (New-Object -ComObject "WScript.Shell").CreateShortcut($lnkPath)
$lnk.TargetPath = $cplNS.Self.Path
$lnk.Save()

# Pin / unpin the shortcut
$lnkItem = Get-Item $lnkPath
$lnkItem = (New-Object -Com "Shell.Application").Namespace($lnkItem.DirectoryName).ParseName($lnkItem.Name)
$lnkItem.InvokeVerb("pin")

# Remove the handler
Remove-Item -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Recurse

#>

<# Method3 - didn't work on my PC

# Get "Control Panel" namespace
$cplCLSID = "::{26EE0668-A00A-44D7-9371-BEB064C98683}"
$cplNS = (New-Object -Com "Shell.Application").NameSpace("shell:$cplCLSID")

# Bring pinning / unpinning handler into '*' class scope
$pinHandler = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin" -Name "ExplorerCommandHandler"
New-Item -Path "HKCU:Software\Classes\*\shell\pin" -Force | Out-Null
Set-ItemProperty -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Name "ExplorerCommandHandler" -Type String -Value $pinHandler

# Pin / unpin the COM object
$cplNS.Self.InvokeVerb("pin")

# Remove the handler
Remove-Item -LiteralPath "HKCU:Software\Classes\*\shell\pin" -Recurse

#>