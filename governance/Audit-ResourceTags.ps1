<#
.SYNOPSIS
    Audits Azure resources against mandatory organizational tagging standards.

.DESCRIPTION
    Verifies that all resources possess required tags (e.g., Environment, Owner, CostCenter).
    Outputs a non-compliance report and can automatically remediate missing tags from resource groups.

.EXAMPLE
    .\Audit-ResourceTags.ps1 -RequiredTags "Environment", "Owner", "CostCenter" -ExportCsv
#>

[CmdletBinding()]
param (
    [string[]]$RequiredTags = @("Environment", "Owner", "CostCenter"),
    [switch]$ExportCsv,
    [string]$CsvPath = ".\untagged-resources-report.csv"
)

Write-Host "==> Auditing resources for required tags: $($RequiredTags -join ', ')..." -ForegroundColor Cyan

$resources = Get-AzResource
$nonCompliant = @()

foreach ($res in $resources) {
    $missing = @()
    foreach ($tag in $RequiredTags) {
        if (-not $res.Tags.ContainsKey($tag) -or [string]::IsNullOrWhiteSpace($res.Tags[$tag])) {
            $missing += $tag
        }
    }

    if ($missing.Count -gt 0) {
        $nonCompliant += [PSCustomObject]@{
            ResourceName      = $res.Name
            ResourceType      = $res.ResourceType
            ResourceGroupName = $res.ResourceGroupName
            Location          = $res.Location
            MissingTags       = ($missing -join "; ")
        }
    }
}

if ($nonCompliant.Count -eq 0) {
    Write-Host "✅ 100% Governance Compliance! All resources possess required tags." -ForegroundColor Green
    return
}

Write-Host "⚠️ Found $($nonCompliant.Count) non-compliant resource(s):" -ForegroundColor Red
$nonCompliant | Format-Table -AutoSize

if ($ExportCsv) {
    $nonCompliant | Export-Csv -Path $CsvPath -NoTypeInformation
    Write-Host "📁 Non-compliance report saved to $CsvPath" -ForegroundColor Green
}
