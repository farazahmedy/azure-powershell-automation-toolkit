# ⚡ Azure PowerShell Automation & FinOps Toolkit

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://learn.microsoft.com/en-us/powershell/azure/)
[![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

A battle-tested collection of production **PowerShell** scripts for Microsoft Azure administrators, FinOps engineers, and cloud architects. Automates daily cloud operations, cuts wasted cloud spend, enforces governance, and audits security compliance.

---

## 🗂️ Script Catalog

```
azure-powershell-automation-toolkit/
├── cost-optimization/
│   ├── Stop-DeallocatedVMs-Schedule.ps1  # Auto-stop idle dev/test VMs (saves ~70% compute)
│   ├── Find-UnattachedDisks-Clean.ps1   # Detect & clean orphan managed disks
│   └── Find-UnassociatedPublicIPs.ps1   # Find & remove unattached paid Public IPs
├── governance/
│   ├── Audit-ResourceTags.ps1           # Audit & report missing organizational tags
│   └── Export-AzureRBACInventory.ps1    # Export privileged Owner/Contributor permissions
├── security/
│   ├── Check-StorageAccountsPublicAccess.ps1 # Detect and disable public blob storage
│   └── Audit-KeyVaultExpiringSecrets.ps1     # Alert on expiring certificates & secrets
└── README.md
```

---

## 🚀 Prerequisites

1. Install the latest Azure PowerShell module:
```powershell
Install-Module -Name Az -Repository PSGallery -Force -AllowClobber
```

2. Authenticate to your Azure tenant:
```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId "<your-subscription-id>"
```

---

## 💡 How to Run as Scheduled Azure Automation Runbooks

All scripts support running both locally from your PowerShell console and in the cloud as **Azure Automation Runbooks**:
1. Create an **Azure Automation Account**.
2. Enable **System-Assigned Managed Identity** on the Automation Account.
3. Grant the Managed Identity `Contributor` (or `Reader` for audit scripts) on your target subscription.
4. Import any script from this toolkit as a PowerShell Runbook and link a Schedule!

---

## 👤 Author

Developed by **Faraz Ahmed** ([@farazahmedy](https://github.com/farazahmedy)).
Contributions, feature requests, and PRs are welcome!
