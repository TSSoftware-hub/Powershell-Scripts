# Author: Sergey Trukhanov
# Version: 1
# Description: Changes Backblaze settings

If (Test-Path "C:\Programdata\Backblaze\bzdata\bzinfo.xml") {
    [xml]$XMLfile = Get-Content C:\Programdata\Backblaze\bzdata\bzinfo.xml
    $node = $XMLfile.bzinfo.do_backup
    $node.net_auto_throttle='false'
    $node.net_throttle='70'
    $XMLfile.Save(" C:\Programdata\Backblaze\bzdata\bzinfo.xml") 
} else {
    Write-Host "Backblaze is not installed!" -ForegroundColor DarkRed
}
