<#
.SYNOPSIS
    Scans Azure Key Vaults for secrets, keys, and certificates nearing expiration.

.DESCRIPTION
    Iterates through Key Vaults in the subscription and flags any secret or certificate expiring
    within the threshold window (default: 30 days), preventing unexpected production outages.

.EXAMPLE
    .\Audit-KeyVaultExpiringSecrets.ps1 -DaysThreshold 45
#>

[CmdletBinding()]
param (
    [int]$DaysThreshold = 30
)

Write-Host "==> Scanning Azure Key Vaults for items expiring within $DaysThreshold days..." -ForegroundColor Cyan

$keyVaults = Get-AzKeyVault
$expiringItems = @()
$thresholdDate = (Get-Date).AddDays($DaysThreshold)

foreach ($kv in $keyVaults) {
    # Check Secrets
    try {
        $secrets = Get-AzKeyVaultSecret -VaultName $kv.VaultName
        foreach ($secret in $secrets) {
            if ($secret.Expires -and $secret.Expires -le $thresholdDate) {
                $daysRemaining = [math]::Round(($secret.Expires - (Get-Date)).TotalDays, 0)
                $expiringItems += [PSCustomObject]@{
                    VaultName     = $kv.VaultName
                    ItemType      = "Secret"
                    ItemName      = $secret.Name
                    Expires       = $secret.Expires
                    DaysRemaining = $daysRemaining
                }
            }
        }
    }
    catch {
        Write-Warning "Could not read secrets from Key Vault: $($kv.VaultName). Check access policies."
    }

    # Check Certificates
    try {
        $certs = Get-AzKeyVaultCertificate -VaultName $kv.VaultName
        foreach ($cert in $certs) {
            if ($cert.Expires -and $cert.Expires -le $thresholdDate) {
                $daysRemaining = [math]::Round(($cert.Expires - (Get-Date)).TotalDays, 0)
                $expiringItems += [PSCustomObject]@{
                    VaultName     = $kv.VaultName
                    ItemType      = "Certificate"
                    ItemName      = $cert.Name
                    Expires       = $cert.Expires
                    DaysRemaining = $daysRemaining
                }
            }
        }
    }
    catch {
        Write-Warning "Could not read certificates from Key Vault: $($kv.VaultName)."
    }
}

if ($expiringItems.Count -eq 0) {
    Write-Host "✅ No secrets or certificates expiring within the next $DaysThreshold days." -ForegroundColor Green
    return
}

Write-Host "⚠️ Found $($expiringItems.Count) expiring item(s):" -ForegroundColor Yellow
$expiringItems | Sort-Object DaysRemaining | Format-Table -AutoSize
