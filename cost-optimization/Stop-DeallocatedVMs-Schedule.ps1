<#
.SYNOPSIS
    Stops and deallocates running Virtual Machines tagged for auto-shutdown or in non-prod environments.

.DESCRIPTION
    Iterates through all VMs in the active subscription. Checks for 'AutoShutdown=True' or 'Environment=dev' tags.
    If the VM is running, it safely deallocates the VM, stopping all compute billing.

.EXAMPLE
    .\Stop-DeallocatedVMs-Schedule.ps1 -TagKey "Environment" -TagValue "dev" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$TagKey = "AutoShutdown",
    [string]$TagValue = "True",
    [switch]$Force
)

Write-Host "==> Scanning for Virtual Machines to deallocate..." -ForegroundColor Cyan

$vms = Get-AzVM -Status

$targetVMs = $vms | Where-Object {
    $_.PowerState -eq "VM running" -and 
    ($_.Tags.ContainsKey($TagKey) -and $_.Tags[$TagKey] -eq $TagValue)
}

if ($targetVMs.Count -eq 0) {
    Write-Host "✅ No running VMs matched the shutdown criteria." -ForegroundColor Green
    return
}

Write-Host "Found $($targetVMs.Count) running VM(s) to shut down:" -ForegroundColor Yellow
$targetVMs | Select-Object Name, ResourceGroupName, PowerState | Format-Table

foreach ($vm in $targetVMs) {
    if ($PSCmdlet.ShouldProcess($vm.Name, "Stop and Deallocate VM")) {
        Write-Host "Stopping and deallocating VM: $($vm.Name)..." -ForegroundColor Yellow
        Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force -NoWait
        Write-Host "Shutdown signal sent to $($vm.Name)." -ForegroundColor Green
    }
}
