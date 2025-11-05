# ==========================================
#  Project: DevSecOps Automation Framework
#  File: build_simulator.ps1
#  Author: 51l3nt5p3ct3r
#  Description: Simulates a basic CI/CD build pipeline with JSON logging.
#  Created: 2025-11-05
#  Version: 1.0
# ==========================================

$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Helper functions for color-coded output
function Write-Ok   ($m){ Write-Host "[OK ] $m"   -ForegroundColor Green  }
function Write-Info ($m){ Write-Host "[INFO] $m"  -ForegroundColor Cyan   }
function Write-Warn ($m){ Write-Host "[WARN] $m"  -ForegroundColor Yellow }
function Write-Err  ($m){ Write-Host "[ERR ] $m"  -ForegroundColor Red    }

# Setup base paths
$Base = $PSScriptRoot
if (-not $Base) { $Base = (Get-Location).Path }

$BuildDir = Join-Path $Base 'build_artifacts'
$LogsDir  = Join-Path $Base 'build_logs'
if (!(Test-Path $BuildDir)) { New-Item -ItemType Directory -Path $BuildDir | Out-Null }
if (!(Test-Path $LogsDir))  { New-Item -ItemType Directory -Path $LogsDir  | Out-Null }

# Generate timestamped file names
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile   = Join-Path $LogsDir ("build_log_{0}.txt" -f $Timestamp)
$JsonFile  = Join-Path $LogsDir ("build_report_{0}.json" -f $Timestamp)

# Simulated environment info
$EnvInfo = [ordered]@{
    "User"         = $env:USERNAME
    "Machine"      = $env:COMPUTERNAME
    "OS_Version"   = [Environment]::OSVersion.VersionString
    "PS_Version"   = $PSVersionTable.PSVersion.ToString()
    "Working_Dir"  = $Base
    "Timestamp"    = $Timestamp
}

# Start log
"Starting build simulation at $Timestamp" | Out-File -FilePath $LogFile -Encoding utf8 -Force
Write-Info "Starting build simulation..."

# Simulated steps
$Steps = @(
    @{ Name = "Check Environment";   Action = { Write-Info "Environment verified." } },
    @{ Name = "Compile Source Code"; Action = { Write-Info "Simulating code compilation..."; Start-Sleep -Seconds 2 } },
    @{ Name = "Run Unit Tests";      Action = { Write-Info "Running fake tests..."; Start-Sleep -Seconds 1 } },
    @{ Name = "Package Artifacts";   Action = { 
        $artifact = Join-Path $BuildDir ("artifact_{0}.zip" -f $Timestamp)
        Write-Info "Packaging fake artifact: $artifact"
        "Fake build data" | Out-File -FilePath $artifact -Encoding utf8
    } }
)

$Results = @()
foreach ($step in $Steps) {
    $stepName = $step.Name
    try {
        & $step.Action
        Add-Content $LogFile "[OK ] $stepName completed."
        $Results += [ordered]@{ Step=$stepName; Status="Success"; Time=(Get-Date).ToString("HH:mm:ss") }
        Write-Ok "$stepName completed."
    } catch {
        Add-Content $LogFile "[ERR] $stepName failed: $_"
        $Results += [ordered]@{ Step=$stepName; Status="Failed"; Time=(Get-Date).ToString("HH:mm:ss") }
        Write-Err "$stepName failed."
    }
}

# Build summary
$Summary = [ordered]@{
    "Environment" = $EnvInfo
    "Results"     = $Results
    "Overall"     = if ($Results.Status -contains "Failed") { "Failed" } else { "Success" }
}

# Write summary to JSON
$Summary | ConvertTo-Json -Depth 4 | Out-File -FilePath $JsonFile -Encoding utf8
Write-Ok "Build report created: $JsonFile"

Write-Info "Build simulation finished."
