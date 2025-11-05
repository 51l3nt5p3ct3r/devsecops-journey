# ==========================================
#  DevSecOps – Day 3 Script: Menu Automation
#  Author: 51l3nt5p3ct3r
# ==========================================

$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

function Write-Ok   ($m){ Write-Host "[OK ] $m"   -ForegroundColor Green  }
function Write-Info ($m){ Write-Host "[INFO] $m"  -ForegroundColor Cyan   }
function Write-Warn ($m){ Write-Host "[WARN] $m"  -ForegroundColor Yellow }
function Write-Err  ($m){ Write-Host "[ERR ] $m"  -ForegroundColor Red    }

$Base = $PSScriptRoot
if (-not $Base) { $Base = (Get-Location).Path }

$LogsDir = Join-Path $Base 'project_logs'
if (!(Test-Path -LiteralPath $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

function Create-Log {
    $today = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $LogPath = Join-Path $LogsDir ("log_{0}.txt" -f $today)
    "New log created on $today" | Out-File -FilePath $LogPath -Encoding utf8 -Force
    Add-Content -Path $LogPath -Value ("User: {0}" -f $env:USERNAME)
    Add-Content -Path $LogPath -Value ("OS Version: {0}" -f [Environment]::OSVersion.VersionString)
    Write-Ok "Created new log file: $LogPath"
}

function Clean-OldLogs {
    $limit = (Get-Date).AddDays(-7)
    $files = Get-ChildItem $LogsDir -File | Where-Object { $_.LastWriteTime -lt $limit }
    if ($files.Count -gt 0) {
        $files | Remove-Item -Force
        Write-Warn "Deleted $($files.Count) old log files."
    } else {
        Write-Info "No old log files found."
    }
}

function Show-RecentLogs {
    $files = Get-ChildItem $LogsDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 3
    if ($files.Count -eq 0) {
        Write-Info "No logs found."
    } else {
        Write-Info "Most recent logs:"
        $files | ForEach-Object { Write-Host " - " $_.Name }
    }
}

function Show-Menu {
    Write-Host ""
    Write-Host "========= MENU ========="
    Write-Host "1. Create new log"
    Write-Host "2. Clean logs older than 7 days"
    Write-Host "3. Show 3 most recent logs"
    Write-Host "4. Exit"
    Write-Host "========================="
}

do {
    Show-Menu
    $choice = Read-Host "Select an option (1-4)"

    switch ($choice) {
        1 { Create-Log }
        2 { Clean-OldLogs }
        3 { Show-RecentLogs }
        4 { Write-Info "Exiting..."; break }
        default { Write-Warn "Invalid choice, please try again." }
    }
} while ($choice -ne 4)
