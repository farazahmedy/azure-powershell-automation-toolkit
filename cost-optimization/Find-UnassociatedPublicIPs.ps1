<#
.SYNOPSIS
    Identifies unassociated Azure Public IP addresses generating idle reservation fees.

.DESCRIPTION
    Scans the current subscription for Public IPs not bound to any Network Interface or Load Balancer.

.EXAMPLE
    .\Find-UnassociatedPublicIPs.ps1 -DeleteUnused
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$DeleteUnused
)

Write-Host "==> Scanning for unassociated Public IP addresses..." -ForegroundColor Cyan

$pips = Get-AzPublicIpAddress
$unusedPips = $pips | Where-Object { $null -eq $_.IpConfiguration }

if ($unusedPips.Count -eq 0) {
    Write-Host "✅ All Public IP addresses are currently in use." -ForegroundColor Green
    return
}

Write-Host "⚠️ Found $($unusedPips.Count) unassociated Public IP(s):" -ForegroundColor Yellow
$unusedPips | Select-Object Name, ResourceGroupName, Location, IpAddress, PublicIpAllocationMethod | Format-Table

if ($DeleteUnused) {
    foreach ($pip in $unusedPips) {
        if ($PSCmdlet.ShouldProcess($pip.Name, "Delete unassociated Public IP")) {
            Write-Host "Deleting Public IP: $($pip.Name)..." -ForegroundColor Red
            Remove-AzPublicIpAddress -ResourceGroupName $pip.ResourceGroupName -Name $pip.Name -Force
            Write-Host "Deleted $($pip.Name)." -ForegroundColor Green
        }
    }
}
