Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties * | export-csv c:\ADusers.csv