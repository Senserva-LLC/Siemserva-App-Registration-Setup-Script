####################################

# Senserva Siemserva App Registration Setup Script
# Copyright 2026 Senserva, LLC
# Author: Thomas (TJ) Dolan

####################################

# Install Microsoft Graph Module, this piece can take a minute. Can omit if you have the module already
Install-Module Microsoft.Graph

Connect-MgGraph -Scopes "Domain.Read.All, Application.ReadWrite.All"

$TenantId = (Get-MgOrganization).Id

# Create the App Registration properties

# Necessary API Permissions

$requiredGrants = New-Object -TypeName System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
$requiredGraphResourceAccess = New-Object -TypeName Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess
$requiredGraphResourceAccess.ResourceAppId = "00000003-0000-0000-c000-000000000000"
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "e4c9e354-4dc5-45b8-9e7c-e1393b0b1a20"; Type = "Scope" } # AuditLog.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "f1493658-876a-4c87-8fa7-edb559b3476a"; Type = "Scope" } # DeviceManagementConfiguration.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "314874da-47d6-4978-88dc-cf0d37f0bb82"; Type = "Scope" } # DeviceManagementManagedDevices.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "0e263e50-5827-48a4-b97c-d940288653c7"; Type = "Scope" } # Directory.AccessAsUser.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "06da0dbc-49e2-44d2-8312-53f166ab848a"; Type = "Scope" } # Directory.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "8f6a01e7-0391-4ee5-aa22-a3af122cef27"; Type = "Scope" } # IdentityRiskEvent.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "ea5c4ab0-5a73-4f35-8272-5d5337884e5d"; Type = "Scope" } # IdentityRiskyServicePrincipal.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "d04bb851-cb7c-4146-97c7-ca3e71baf56c"; Type = "Scope" } # IdentityRiskyUser.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"; Type = "Scope" } # offline_access
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "37f7f235-527c-4136-accd-4a02d197296e"; Type = "Scope" } # openid
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "572fea84-0151-49b2-9301-11cb16974376"; Type = "Scope" } # Policy.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "633e0fce-8c58-4cfb-9495-12bbd5a24f7c"; Type = "Scope" } # Policy.Read.ConditionalAccess
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "14dad69e-099b-42c9-810b-d002981feec1"; Type = "Scope" } # profile
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "02e97553-ed7b-43d0-ab3c-f8bace0d040c"; Type = "Scope" } # Reports.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "48fec646-b2ba-4019-8681-8eb31435aded"; Type = "Scope" } # RoleManagement.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "cce71173-f76d-446e-97ff-efb2d82e11b1"; Type = "Scope" } # RoleManagementAlert.Read.Directory
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "7e26fdff-9cb1-4e56-bede-211fe0e420e8"; Type = "Scope" } # RoleManagementPolicy.Read.AzureADGroup
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "2ef70e10-5bfd-4ede-a5f6-67720500b258"; Type = "Scope" } # SharePointTenantSettings.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "205e70e5-aba6-4c52-a976-6d2d46c48043"; Type = "Scope" } # Sites.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope" } # User.Read
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "a154be20-db9c-4678-8ab7-66f6cc099a59"; Type = "Scope" } # User.Read.All
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "1f6b61c5-2f65-4135-9c9f-31c0f8d32b52"; Type = "Scope" } # UserAuthenticationMethod.Read
$requiredGraphResourceAccess.ResourceAccess += @{ Id = "aec28ec7-4d02-4e8c-b864-50163aea77eb"; Type = "Scope" } # UserAuthenticationMethod.Read.All

$requiredGrants.Add($requiredGraphResourceAccess)

# Create the App registration, use MultipleOrgs so can be multi-tenant scan if desired
$app = New-MgApplication -DisplayName 'Siemserva Application' -RequiredResourceAccess $requiredGrants -SignInAudience "AzureADMultipleOrgs"


# Public Client Redirect, Needed to finish the Consent process
# Patch in after App Registration creation, we need the GUID from the Id property to properly construct the URI

$publicClient = New-Object -TypeName Microsoft.Graph.PowerShell.Models.MicrosoftGraphPublicClientApplication
$publicClient.RedirectUris = @("https://login.microsoftonline.com/common/oauth2/nativeclient", "ms-appx-web://microsoft.aad.brokerplugin/$($app.Id)") 

Update-MgApplication -ApplicationId $($app.Id) -PublicClient $publicClient