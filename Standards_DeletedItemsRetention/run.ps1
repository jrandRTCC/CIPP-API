param($tenant)

try {
    $DehydratedTenant = (New-ExoRequest -tenantid $Tenant -cmdlet "Get-OrganizationConfig").IsDehydrated
    if ($DehydratedTenant) {
        New-ExoRequest -tenantid $Tenant -cmdlet "Enable-OrganizationCustomization"
    }
    $users = New-GraphGetRequest -uri "https://graph.microsoft.com/beta/users/?`$top=999&`$select=id,userPrincipalName,assignedLicenses" -Tenantid $tenantfilter
    (New-ExoRequest -tenantid $TenantFilter -cmdlet "Get-mailbox") |Select UserPrincipalName|%{  (New-ExoRequest -tenantid $TenantFilter -cmdlet "Set-Mailbox" -cmdParams @{Identity = $_.userprincipalname; RetainDeletedItemsFor = 30}})
    (New-ExoRequest -tenantid $TenantFilter -cmdlet "Get-mailboxPlan") |Select UserPrincipalName|%{  (New-ExoRequest -tenantid $TenantFilter -cmdlet "Set-MailboxPlan" -cmdParams @{Identity = $_.userprincipalname; RetainDeletedItemsFor = 30}})
}
catch {
    $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
    Write-LogMessage -API "Standards" -tenant $tenant -message "Failed to apply Unified Audit Log Extra. Error: $ErrorMessage" -sev Error
}