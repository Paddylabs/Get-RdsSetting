<#

  .SYNOPSIS

  Gets all users from an OU and the status of the "Deny this user permissions to log on to Remote Desktop Session Host server" setting.

  .DESCRIPTION

  Gets all users from an OU and the status of the "Deny this user permissions to log on to Remote Desktop Session Host server" setting
  on the Remote desktop service profile tab of the user object.  It logs to seperate files based on the Status of the setting.
  1 means allowed (Box is cleared)
  0 Means Deny (Box is Checked)

  .PARAMETER

  -Region EMEA,APAC,AMRS

  .EXAMPLE

  RDPSetting.ps1 -Region EMEA

  .INPUTS

  None

  .OUTPUTS

  Region_AllowedUsers.txt
  Region_DeniedUsers.txt
  Region_FailedUsers.txt
  results.txt

  .NOTES

  Author:        Patrick Horne
  Creation Date: 19/03/20
  Requires:      ActiveDirectory Module
  Change Log:

  V1.0:         Initial Development

#>

#Requires -Modules ActiveDirectory

param (

    [Parameter(Mandatory)]
    [ValidateSet('EMEA','APAC','AMRS')]
    [String]$Region

)

$UsersDenied = 0
$UsersAllowed = 0
$UsersFailed = 0
$DeniedUsersFile = $region + "_DeniedUsers.csv"
$AllowedUsersFile = $region + "_AllowedUsers.csv"
$FailedUsersFile = $region + "_FailedUsers.csv"
$ResultsFile = $region + "_Results.txt"
$SearchOU = "OU=$Region,OU=PRD,OU=User Accounts,DC=acompany,DC=com"

Set-Location "C:\Users\Patrick\Documents\Scripts\Get-RdsSetting"

$users = get-aduser -Filter * -SearchBase $SearchOU

Foreach ($user in $Users) {
    $UserDN = $User | Select-Object -ExpandProperty DistinguishedName
    $TheUser = [adsi]"LDAP://$UserDN"
    Try { (($TheUser.psbase.invokeget("AllowLogon"))) 
        if (($TheUser.psbase.invokeget("AllowLogon")) -eq "0") {
            $DeniedUser = Get-ADUser $user.DistinguishedName
            $DeniedUser | Export-Csv $DeniedUsersFile -Append -NoTypeInformation
            $UsersDenied++

}

        else  {

            $AllowedUser = Get-ADUser $user.DistinguishedName
            $AllowedUser | Export-Csv $AllowedUsersFile -Append -NoTypeInformation
            $UsersAllowed++

}

}

Catch {

    $FailedUser = Get-ADUser $user.DistinguishedName
    $FailedUser | Export-Csv $FailedUsersFile -Append -NoTypeInformation
    $UsersFailed++

}

}

"$UsersAllowed Users in $Region are allowed logon to RDS" | Out-File $ResultsFile -Append
"$UsersDenied Users in $Region are denied logon to RDS" | Out-File $ResultsFile -Append
"$UsersFailed Users in $Region could not be read" | Out-File $ResultsFile -Append