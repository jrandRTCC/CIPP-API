param($tenant)

try {
    $DehydratedTenant = (New-ExoRequest -tenantid $Tenant -cmdlet "Get-OrganizationConfig").IsDehydrated
    if ($DehydratedTenant) {
        New-ExoRequest -tenantid $Tenant -cmdlet "Enable-OrganizationCustomization"
    }
    $users = New-GraphGetRequest -uri "https://graph.microsoft.com/beta/users/?`$top=999&`$select=id,userPrincipalName,assignedLicenses" -Tenantid $tenantfilter
    $MaxSendSize = "150MB"
    $MaxReceiveSize = "150MB"
    (New-ExoRequest -tenantid $TenantFilter -cmdlet "Get-mailbox") |Select UserPrincipalName|%{  (New-ExoRequest -tenantid $TenantFilter -cmdlet "Set-Mailbox" -cmdParams @{Identity = $_.userprincipalname; MaxSendSize = $MaxSendSize; MaxReceiveSize = $MaxReceiveSize;}})
}
catch {
    $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
    Write-LogMessage -API "Standards" -tenant $tenant -message "Failed to apply Unified Audit Log Extra. Error: $ErrorMessage" -sev Error
}