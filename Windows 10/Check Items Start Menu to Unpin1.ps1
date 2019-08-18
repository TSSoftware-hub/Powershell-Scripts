# Author: Sergey Trukhanov
# Version: 1
# Description: check what can be unpinned from Start menu

(New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
    ? { $null -ne ($_.Verbs() | ? {$_.Name -match 'Un.*pin from Start'})} |
    select Name

Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")