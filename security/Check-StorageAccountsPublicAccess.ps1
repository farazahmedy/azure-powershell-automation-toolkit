<#
.SYNOPSIS
    Audits and remediates Azure Storage Accounts that allow public blob access.

.DESCRIPTION
    Checks every Storage Account in the subscription. Flags any account with AllowBlobPublicAccess = $true.
    Can automatically disable public blob access to meet CIS Benchmark 5.1.

.EXAMPLE
    .\Check-StorageAccountsPublicAccess.ps1 -AutoRemediate
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$AutoRemediate
)

Write-Host "==> Auditing Storage Accounts for public access exposure..." -ForegroundColor Cyan

$storageAccounts = Get-AzStorageAccount
$exposed = @()

foreach ($sa in $storageAccounts) {
    if ($sa.AllowBlobPublicAccess -eq $true) {
        $exposed += $sa
    }
}

if ($exposed.Count -eq 0) {
    Write-Host "✅ All storage accounts have public blob access disabled." -ForegroundColor Green
    return
}

Write-Host "🚨 Found $($exposed.Count) storage account(s) permitting public blob access!" -ForegroundColor Red
$exposed | Select-Object StorageAccountName, ResourceGroupName, Location | Format-Table

if ($AutoRemediate) {
    foreach ($sa in $exposed) {
        if ($PSCmdlet.ShouldProcess($sa.StorageAccountName, "Disable AllowBlobPublicAccess")) {
            Write-Host "Remediating: Disabling public access on $($sa.StorageAccountName)..." -ForegroundColor Yellow
            Set-AzStorageAccount -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName -AllowBlobPublicAccess $false
            Write-Host "Secured $($sa.StorageAccountName)." -ForegroundColor Green
        }
    }
}
