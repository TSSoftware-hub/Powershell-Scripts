param(
  [parameter(Position=0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, mandatory=$false)][string]$SearchBase,
  [parameter(Position=0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, mandatory=$false)][int]$Days
)

Import-Module ActiveDirectory;

if ($searchBase -eq "") {
  $searchBase = (Get-ADRootDSE).defaultNamingContext;
}

if ($Days -lt 1) {
  $Days = 1;
}

$Days *= -1;

$output = New-Object Object | Add-Member NoteProperty mail '' -PassThru | Add-Member NoteProperty sAMAccountName '' -PassThru | Add-Member NoteProperty userAccountControl '' -PassThru | Add-Member NoteProperty changed '' -PassThru;

$users = Get-ADObject -Filter { objectCategory -eq "Person" -and (userAccountControl -bor 8388608) } -SearchBase $SearchBase -Properties sAMAccountName;

$searchFrom = (Get-Date("0:00")).AddDays($Days);

foreach ($userEntry in $users) {
  $user = Get-ADObject -Filter { sAMAccountName -eq $userEntry.sAMAccountName } -Properties sAMAccountName, userAccountControl, mail, "msDS-ReplAttributeMetaData";
  $repData = $repData = [xml] ("<root>"+ $user."msDS-ReplAttributeMetaData" +"</root>").Replace([char]0, " ")
  
  foreach ($attribute in $repData.root.DS_REPL_ATTR_META_DATA) {
    if ($attribute.pszAttributeName -eq "userAccountControl") {
      $changedDate = Get-Date($attribute.ftimeLastOriginatingChange);
      
      if ($changedDate -gt $searchFrom) {
        $output.mail = $user.mail;
        $output.sAMAccountName = $user.sAMAccountName;
        $output.userAccountControl  = $user.userAccountControl;
        $output.changed = $changedDate;
        $output;
      }
    }
  }
}