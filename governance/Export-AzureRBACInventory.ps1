<#
.SYNOPSIS
    Exports an inventory of all privileged Azure RBAC role assignments across a subscription.

.DESCRIPTION
    Scans for Owner, Contributor, and User Access Administrator assignments to satisfy
    compliance audits (ISO 27001, SOC 2, CIS Azure Foundations Benchmark).

.EXAMPLE
    .\Export-AzureRBACInventory.ps1 -CsvPath ".\rbac-inventory.csv"
#>

[CmdletBinding()]
param (
    [string]$CsvPath = ".\azure-rbac-audit.csv"
)

Write-Host "==> Auditing privileged RBAC role assignments..." -ForegroundColor Cyan

$assignments = Get-AzRoleAssignment | Where-Object {
    $_.RoleDefinitionName -in @("Owner", "Contributor", "User Access Administrator")
}

$inventory = $assignments | Select-Object @{
    Name = "Role"; Expression = { $_.RoleDefinitionName }
}, @{
    Name = "AssigneeName"; Expression = { $_.DisplayName }
}, @{
    Name = "PrincipalType"; Expression = { $_.ObjectType }
}, @{
    Name = "SignInName"; Expression = { $_.SignInName }
}, Scope

Write-Host "Found $($inventory.Count) privileged assignment(s):" -ForegroundColor Yellow
$inventory | Format-Table -AutoSize

$inventory | Export-Csv -Path $CsvPath -NoTypeInformation
Write-Host "✅ Privilege audit saved to $CsvPath" -ForegroundColor Green
