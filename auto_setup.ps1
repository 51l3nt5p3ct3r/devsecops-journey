# ==========================================
#  DevSecOps – Day 2 Script (Clean Version)
#  Author: Daniel Melamed
# ==========================================

# Set UTF-8 output encoding
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Helper functions for color-coded messages
function Write-Ok   ($m){ Write-Host "[OK ] $m"   -ForegroundColor Green  }
function Write-Info ($m){ Write-Host "[INFO] $m"  -ForegroundColor Cyan   }
function Write-Warn ($m){ Write-Host "[WARN] $m"  -ForegroundColor Yellow }
function Write-Err  ($m){ Write-Host "[ERR ] $m"  -ForegroundColor Red    }

# Get the script directory (so the script works from anywhere)
$Base = $PSScriptRoot
if (-not $Base) { $Base = (Get-Location).Path }

# Step 1 - Create a logs directory if it doesn't exist
$LogsDir = Join-Path $Base 'project_logs'
if (!(Test-Path -LiteralPath $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
    Write-Ok "Created logs directory: $LogsDir"
} else {
    Write-Info "Logs directory already exists: $LogsDir"
}

# Step 2 - Create a new log file with current date/time
$today = Get-Date -Format "yyyy-MM-dd_HH-mm"
$LogPath = Join-Path $LogsDir ("log_{0}.txt" -f $today)

"Starting log for $today" | Out-File -FilePath $LogPath -Encoding utf8 -Force
Add-Content -Path $LogPath -Value "System check started..." -Encoding utf8
Add-Content -Path $LogPath -Value ("User: {0}" -f $env:USERNAME) -Encoding utf8
Add-Content -Path $LogPath -Value ("OS Version: {0}" -f [Environment]::OSVersion.VersionString) -Encoding utf8

# Step 3 - Search for the word "System" in the log file
if (Select-String -Path $LogPath -Pattern "System") {
    Write-Ok "Found the word 'System' in the log."
} else {
    Write-Warn "The word 'System' was not found in the log."
}

# Step 4 - Display completion info
Write-Ok "Script finished successfully."
Write-Info ("Log created at: {0}" -f $LogPath)
