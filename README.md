# Entra-ID-Cross-Tenant-Sync

# Synchronize Users Between Entra ID Tenants

This script allows for the synchronization of users between two Azure Active Directory (Entra ID) tenants using the Microsoft Graph PowerShell module. It is designed to invite users from the source tenant to the target tenant, creating guest accounts, and keep user information updated as changes are made in the source tenant.

## Prerequisites

- PowerShell 5.1 or later (7.x strongly recommended)
- Microsoft Graph PowerShell module (install using `Install-Module Microsoft.Graph`)
- Appropriate permissions for both the source and target tenants, including `User.Read.All` and `Directory.ReadWrite.All` scopes. Other scopes may be sufficient, but the scripts currently goes with these.

## Installation

1. Clone or download this repository.
2. Open PowerShell as an administrator.
3. Install the Microsoft Graph PowerShell module:
   ```powershell
   Install-Module Microsoft.Graph -Scope <CurrentUser/AllUsers>
   ```

## Usage

Run the script with the following parameters:

```powershell
.\EntraIDSyncer.ps1 -SourceTenantId "<source-tenant-id>" -TargetTenantId "<target-tenant-id>" -UserType "<UserType>"
```

### Parameters

- `-SourceTenantId` (string): The tenant ID of the source Azure AD tenant from which users will be synchronized.
- `-TargetTenantId` (string): The tenant ID of the target Azure AD tenant where users will be invited and synchronized.
- `-UserType` (string): The type of users to synchronize. Acceptable values are `Member` or `Guest`.

### Example

```powershell
.\EntraIDSyncer.ps1 -SourceTenantId "12345678-1234-1234-1234-123456789abc" -TargetTenantId "87654321-4321-4321-4321-abcdef123456" -UserType "Member"
```

## Features

- **Massive User Invitation**: The script invites users from the source tenant to the target tenant as guest users or members based on the specified `UserType`.
- **User Property Synchronization**: It updates user properties (e.g., display name, address, department) in the target tenant whenever changes are made in the source tenant.
- **Error Handling**: The script includes mechanisms to avoid re-inviting users who are already in the target tenant.
- **Transcript Logging**: The script records all activities in a transcript file (`transcript.txt`) for audit and troubleshooting purposes.

## Important Notes

- **Authentication**: The script will prompt you to authenticate for both the source and target tenants. Ensure you use credentials with sufficient permissions.
- **Multiple Re-authentication**: Due to the need to operate in both tenants, the script will re-authenticate between operations, ensuring the proper context for each action.
- **Invitation redemption**: It is recommended to setup automatic invitation redemption in the source tenant external collaboration settings to automatically redeem invitations, prior to running this script.

## Error Logging

 Additionally, a PowerShell transcript (`transcript.txt`) is generated to capture detailed activities during the script execution.

## Limitations

- This script retrieves all users from the source tenant before filtering, which may impact performance if there are many users.
- This script hasn't been throughly tested _yet_. Please be aware of potential issues.

## License

This project is licensed under The Unlicense. See the `LICENSE` file for more details.

## Contributing

Feel free to open issues or submit pull requests to improve this script or add new features.

## Contact

For questions or support, please use GitHub.