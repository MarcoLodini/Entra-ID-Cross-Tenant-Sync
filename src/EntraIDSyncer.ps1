[CmdletBinding()]
param (
    [string]$SourceTenantId,
    [string]$TargetTenantId,
    [ValidateSet("Member", "Guest")]
    [string]$UserType
)

Start-Transcript -Path .\transcript.txt -Append

Import-Module Microsoft.Graph

Write-Host "Starting sync..."
Write-Host "Connecting to tenant $SourceTenantId..."

$null = Connect-MgGraph -TenantId $SourceTenantId -Scopes "User.Read.All","Directory.ReadWrite.All" -ErrorAction Stop

Write-Host "Connection to tenant $($SourceTenantId) successful."
Write-Host "Extracting users..."

$Users = Get-MgUser -All -Property Mail, UserType, UserPrincipalName, Id, ShownInAddressList, `
            AccountEnabled, StreetAddress, City, State, PostalCode, Country, Department, EmployeeId, DisplayName, GivenName, JobTitle, MailNickname, Manager, PreferredLanguage, Surname

Write-Host "Extracted users. Total users extracted from source tenant: $($Users.Count)"
Write-Host "Connecting to tenant $TargetTenantId..." 

$null = Connect-MgGraph -TenantId $TargetTenantId -Scopes "User.Read.All","Directory.ReadWrite.All" -ErrorAction Stop

Write-Host "Connection to tenant $($SourceTenantId) successful."
Write-Host "Starting import of $($Users.Count) users..."

$UserCounter = 0

# Loop through each user and check their status
foreach ($User in $Users) {

    # We are using the primary SMTP address due to its peculiar constraints when adding guest users
    $ExistingUser = Get-MgUser -Filter "proxyAddresses/any(y:startsWith(y,'SMTP:$($User.Mail)'))"

    If ($null -ne $ExistingUser) {
        $UpdatedUser = Update-MgUser -UserId $ExistingUser.Id -UserType $UserType -ShowInAddressList $User.ShowInAddressList -AccountEnabled $User.AccountEnabled -StreetAddress $User.StreetAddress `
            -City $User.City -State $User.State -PostalCode $User.PostalCode -Country $User.Country -Department $User.Department -EmployeeId $User.EmployeeId `
            -DisplayName $User.DisplayName -GivenName $User.GivenName -JobTitle $User.JobTitle -PreferredLanguage $User.PreferredLanguage -Surname $User.Surname
        
        Write-Host "Updated user $UserCounter of $($Users.Count): $($ExistingUser.Id) - $($ExistingUser.UserPrincipalName)"

    } else {

        $Invitation = New-MgInvitation -InvitedUserEmailAddress $User.UserPrincipalName -InviteRedirectUrl "https://myapps.microsoft.com"  -SendInvitationMessage:$false

        Write-Host "Invited user $UserCounter of $($Users.Count): $($User.UserPrincipalName)"
    }

    $UserCounter++
    
}

Write-Host "Sync completed. Stopping transcript."
Stop-Transcript