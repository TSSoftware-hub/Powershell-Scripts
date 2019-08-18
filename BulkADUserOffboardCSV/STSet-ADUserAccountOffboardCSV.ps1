#requires -version 3
<#
.SYNOPSIS
    Bulk user account offboard in Microsoft Active Directory domain from csv file.
.DESCRIPTION
    The STSet-ADUserAccountOffboardCSV cmdlet changes some attributes for user accounts on active directory domain controller which it takes from the CSV file. 
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
    Purpose:        Bulk user account offboard in Microsoft Active Directory domain from csv file.
    Tested on:      Windows Server 2012 r2
.EXAMPLE1
    PS C:\>STSet-ADUserAccountOffboardCSV.ps1 -Path C:\temp\STSet-ADUserAccountOffboardCSV.csv
    This command creates bulk users account in logged in domain from CSV file, It uses default logged in Credentials.
.EXAMPLE2
    PS C:\>STSet-ADUserAccountOffboardCSV.ps1 -Path C:\temp\STSet-ADUserAccountOffboardCSV.csv -Domain mydomain.com -Credential
    Here I have used all the parameters Path with user information, Domain name and Credentials.
.EXAMPLE3
    PS C:\>STSet-ADUserAccountOffboardCSV.ps1 -Path C:\temp\STSet-ADUserAccountOffboardCSV.csv -Domain mydomain.com
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
#C:\temp\STSet-ADUserAccountOffboardCSV.csv
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

# The Set of Parameters (Optimized for Prothena user)
} -Process {
    $UserProp = @{ 
            Name = $_.Name
            SamAccountName = $_.SamAccountName 
            AccountExpires = $_.AccountExpires
            AccountPassword = (ConvertTo-SecureString -AsPlainText $_.AccountPassword -Force)
            ErrorAction = 'Stop'
    }
  
   #Staring offboarding process
    try {
        $Name = $_.Name
        $ADDCServer = "test-dc1.mydomain.com"
        Write-Host "Offboarding account $Name" -NoNewline -BackgroundColor Gray
        #Set mailNickname and hide from the addressList (do not have it now, maybe need to use Set-ADObject instead of Set-ADUser)
        #Set-ADUser -Identity $_.SamAccountName -Replace @{MailNickName = $_.SamAccountName}
        #Set-ADUser -Identity $_.SamAccountName -Replace @{msExchHideFromAddressLists = "$true"}
        #Set accountExpires (takes the value from csv file)
        Set-ADAccountExpiration -Identity $_.SamAccountName -DateTime $_.AccountExpires
        #User Cannot Change Password (False or True)
        Set-ADUser -Identity $_.SamAccountName -CannotChangePassword $True
        #Get and Remove all security groups except Domain Users
        $AdGroups = Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | Where {$_.Name -ne "Domain Users"}
            if ($AdGroups -ne $null) {
                Remove-ADPrincipalGroupMembership -Identity $_.SamAccountName -MemberOf $AdGroups -Server $ADDCServer -Confirm:$false
            }
        #Get and Remove manager 
        $UserManager = (Get-ADUser(Get-ADUser -Identity $_.SamAccountName -Properties Manager).Manager).Name
            if ($UserManager -ne $null) {
                Set-ADUser -Identity $_.SamAccountName -Manager $null
            }
        #Disable account
        Disable-ADAccount -Identity $_.SamAccountName -ErrorAction Stop
        #Move account - fails
        #Move-ADObject -Identity "CN=" + $Name + ",OU=Users,OU=MYDOMAIN,DC=mydomain,DC=com" -TargetPath "OU=Disabled Accounts,OU=MYDOMAIN,DC=mydomain,DC=com"
        #Show final status
        Write-Host "....Account $Name successfully offboarded. The manager $UserManager was removed. The following Security Groups were removed $AdGroups" -BackgroundColor DarkGreen
    }
    catch {
        #In case of error show this status
        Write-Host "....Offboarding $Name failed" -BackgroundColor DarkRed
    }
} -End {}