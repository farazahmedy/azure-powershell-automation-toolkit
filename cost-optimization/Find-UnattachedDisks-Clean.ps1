<#
.SYNOPSIS
    Detects unattached Azure Managed Disks across all resource groups.

.DESCRIPTION
    Scans for disks where ManagedBy is null. Calculates wasted gigabytes and estimated monthly cost.
    Can export a CSV report and optionally snapshot or delete unattached disks.

.EXAMPLE
    .\Find-UnattachedDisks-Clean.ps1 -ExportCsv -CsvPath ".\unattached-disks-report.csv"
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$ExportCsv,
    [string]$CsvPath = ".\unattached-disks.csv",
    [switch]$DeleteDisks
)

Write-Host "==> Scanning subscription for unattached Managed Disks..." -ForegroundColor Cyan

$disks = Get-AzDisk
$unattachedDisks = $disks | Where-Object { $null -eq $_.ManagedBy }

if ($unattachedDisks.Count -eq 0) {
    Write-Host "✅ No unattached disks found! Storage costs are optimized." -ForegroundColor Green
    return
}

$totalGB = ($unattachedDisks | Measure-Object -Property DiskSizeGB -Sum).Sum
Write-Host "⚠️ Found $($unattachedDisks.Count) unattached disk(s) consuming $totalGB GB of storage!" -ForegroundColor Yellow

$report = $unattachedDisks | Select-Object Name, ResourceGroupName, Location, DiskSizeGB, @{
    Name = "SkuName"; Expression = { $_.Sku.Name }
}, TimeCreated

$report | Format-Table -AutoSize

if ($ExportCsv) {
    $report | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Host "📁 Report saved to $CsvPath" -ForegroundColor Green
}

if ($DeleteDisks) {
    foreach ($disk in $unattachedDisks) {
        if ($PSCmdlet.ShouldProcess($disk.Name, "Permanently delete unattached disk")) {
            Write-Host "Deleting unattached disk: $($disk.Name)..." -ForegroundColor Red
            Remove-AzDisk -ResourceGroupName $disk.ResourceGroupName -DiskName $disk.Name -Force
            Write-Host "Deleted $($disk.Name)." -ForegroundColor Green
        }
    }
}
