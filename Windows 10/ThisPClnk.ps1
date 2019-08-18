# Author: Sergey Trukhanov
# Version: 1
# Description: Create a This PC Shortcut with Windows PowerShell

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\This PC.lnk")
$Shortcut.TargetPath = "This PC"
$Shortcut.Save()

Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")