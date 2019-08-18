#requires -version 3
<#
.SYNOPSIS
    Bulk user account creation in Microsoft Active Directory domain from csv file.
.DESCRIPTION
    The New-ADUserAccountCSV cmdlet creates new user accounts on active directory domain controller from CSV file. 
    It asks for parameter valid CSV file path, Optional Active directory domain name and Credential. 
    This cmdlet uses the following parameters:
.PARAMETER Path
    Prompts you for CSV file path. There are 2 alias CSV and File, This is mandatory parameter and require valid path.
.PARAMETER Domain
    This is remote active directory domain name where you want to connect. 
.PARAMETER Credential
    Popups for active directory username password, supply domain admin user account for authentication.
.INPUTS
    [String]
    [Switch]
.OUTPUTS
    Output is on console directly.
.NOTES
    Version:        1.0
    Author:         Sergey Trukhanov 
    Purpose:        Bulk user account creation in Microsoft Active Directory domain from csv file.
    Tested on:      Windows Server 2012 r2
.EXAMPLE1
    PS C:\>STNew-ADUserAccountCSV.ps1 -Path C:\temp\STNew-ADUserAccountCSV.csv
    This command creates bulk users account in logged in domain from CSV file, It uses default logged in Credentials.
.EXAMPLE2
    PS C:\>STNew-ADUserAccountCSV.ps1 -Path C:\temp\STNew-ADUserAccountCSV.csv -Domain mydomain.com -Credential
    Here I have used all the parameters Path with user information, Domain name and Credentials.
.EXAMPLE3
    PS C:\>STNew-ADUserAccountCSV.ps1 -Path C:\temp\STNew-ADUserAccountCSV.csv -Domain mydomain.com
#>

[CmdletBinding(SupportsShouldProcess=$True,
    ConfirmImpact='Medium',
    HelpURI='http://mydomain.com',
    DefaultParameterSetName='File')]
Param
(
    [parameter(ParameterSetName = 'File', Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [parameter(ParameterSetName = 'Credential', Position=0, Mandatory=$true)]
    [alias('CSV', 'File')]
    [ValidateScript({
        If(Test-Path $_){$true}else{throw "Invalid path given: $_"}
        })]
    [String]$Path,
    [Parameter(ParameterSetName='Credential', Position=1, Mandatory=$True)]
    [alias('ADServer', 'DomainName')]
    [String]$Domain,
    [Parameter(ParameterSetName='Credential')]
    [Switch]$Credential
)
#The $Path parameter - paste manually
#C:\temp\STNew-ADUserAccountCSV.csv
if ($Credential.IsPresent -eq $True) {
    $Cred = Get-Credential -Message 'Type domain credentials to connect remote AD' -UserName (WhoAmI)
}
Import-Csv -Path $Path | foreach -Begin {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    catch {
        Write-host "Missing....Install ActiveDirectory Powershell feature -- RSAT (Remote Server Administration). Cannot Create Accounts" -BackgroundColor DarkRed
        Break
    }
# The Set of Parameters (Optimized for Prta user)
} -Process {
    $UserProp = @{ 
            Name = $_.Name
            SamAccountName = $_.SamAccountName 
            UserPrincipalName = $_.UserPrincipalName 
            GivenName = $_.GivenName 
            DisplayName = $_.DisplayName 
            Surname = $_.Surname 
            AccountPassword = (ConvertTo-SecureString -AsPlainText $_.AccountPassword -Force) 
            Description = $_.Description
            EmailAddress = $_.EmailAddress
            Path = $_.Path
            Title = $_.Title
            Manager = $_.Manager
            MobilePhone = $_.MobilePhone
            Company = $_.Company
            Office = $_.Office 
            Department =  $_.Department 
            Division = $_.Division 
            Organization = $_.Organization 
            OfficePhone = $_.OfficePhone 
            StreetAddress = $_.StreetAddress
            City = $_.City
            State = $_.State
            Country = $_.Country
            PostalCode = $_.PostalCode
            ErrorAction = 'Stop'
    }
    try {
        $Name = $_.Name
        Write-Host "Processing account $Name" -NoNewline -BackgroundColor Gray
        switch ($PsCmdlet.ParameterSetName) {
            'Credential' {
                if ($Credential.IsPresent -eq $false) {
                    New-ADUser @UserProp -Server $Domain
                }
                else {
                    New-ADUser @UserProp -Server $Domain -Credential $Cred
                }
                Break
            }
            'File' {
                New-ADUser @UserProp; break
            }
        }
            Enable-ADAccount -Identity $_.SamAccountName -ErrorAction Stop
            #User Must Change Password at Next Log In (False or True)
            Set-ADUser -Identity $_.SamAccountName -ChangePasswordAtLogon $False
            #Begin: add proxyAddresses
            Set-ADUser -Identity $_.SamAccountName -Add @{Proxyaddresses = "SMTP:"+$_.EmailAddress}
            Set-ADUser -Identity $_.SamAccountName -Add @{Proxyaddresses = "smtp:"+$_.SamAccountName+"@mydomain.com"}
            #End: add proxyAddresses
            Write-Host "....Account $Name successfully created" -BackgroundColor DarkGreen
    }
    catch {
        Write-Host "....Processing $Name failed" -BackgroundColor DarkRed
    }
} -End {}