# Author: Sergey Trukhanov
# Version: 1
# Description: adds network profile to newly added devices. Currently it is WPA2-Personal profile.

# Check that profile doesn't exist on a laptop
$checkSSID = (Get-NetConnectionProfile).Name

# Get all existing profiles from the folder
if ($checkSSID -eq "netNameHere") {
    Write-Host "netNameHere profile already exists"
} else {
    $XmlDirectory = "pathToFolder"
    Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)}
}