$ShortcutPath = "C:\users\username\desktop\test.lnk"
If(Test-Path -Path (Split-Path -Path $ShortcutPath -Parent)){
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = [environment]::getfolderpath("mycomputer")
    $Shortcut.Save()
} Else {
    Write-Host "Unable to create shortcut. Check the path $ShortcutPath."
}