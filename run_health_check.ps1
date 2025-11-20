# Health Checkup - One-Command Execution Script (PowerShell)
# This script clones the Cocoon framework, installs dependencies, runs health checks, and cleans up
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/YOUR_USERNAME/health_checkup/main/run_health_check.ps1 | iex
#   .\run_health_check.ps1

$ErrorActionPreference = "Stop"

# Configuration
$CocoonRepo = "https://github.com/DebalGhosh100/blocks.git"
$HealthCheckRepo = "https://github.com/DebalGhosh100/health_checkup.git"
$CocoonTemp = ".cocoon_temp"
$HealthTemp = ".health_temp"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   System Health Check" -ForegroundColor Cyan
Write-Host "   Powered by Cocoon Framework" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 0: Verify servers.yaml exists
if (-not (Test-Path ".\servers.yaml")) {
    Write-Host "Error: servers.yaml not found in current directory" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create a servers.yaml file with your server list:"
    Write-Host ""
    Write-Host "all_servers:"
    Write-Host "  - ip: `"10.49.74.104`""
    Write-Host "    username: `"admin`""
    Write-Host "    password: `"your_password`""
    Write-Host ""
    exit 1
}
Write-Host "✓ Found servers.yaml" -ForegroundColor Green
Write-Host ""

# Step 1: Clone Cocoon framework
Write-Host "[1/6] Cloning Cocoon framework..." -ForegroundColor Yellow
if (Test-Path $CocoonTemp) {
    Remove-Item -Recurse -Force $CocoonTemp
}
git clone --depth 1 $CocoonRepo $CocoonTemp *> $null
Write-Host "✓ Framework cloned" -ForegroundColor Green

# Step 2: Clone health_checkup workflow
Write-Host "[2/6] Cloning health_checkup workflow..." -ForegroundColor Yellow
if (Test-Path $HealthTemp) {
    Remove-Item -Recurse -Force $HealthTemp
}
git clone --depth 1 $HealthCheckRepo $HealthTemp *> $null
Write-Host "✓ Workflow cloned" -ForegroundColor Green
Write-Host ""

# Step 3: Install dependencies
Write-Host "[3/6] Installing dependencies..." -ForegroundColor Yellow
pip install -q -r "$CocoonTemp\requirements.txt"
Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 4: Copy user's servers.yaml
Write-Host "[4/6] Preparing configuration..." -ForegroundColor Yellow
Copy-Item ".\servers.yaml" "$HealthTemp\servers.yaml" -Force
Write-Host "✓ Configuration ready" -ForegroundColor Green
Write-Host ""

# Step 5: Execute health checks
Write-Host "[5/6] Running health checks on all servers..." -ForegroundColor Yellow
Write-Host ""
Push-Location $HealthTemp
python "..\$CocoonTemp\blocks_executor.py" main.yaml --storage storage
Pop-Location
Write-Host ""

# Step 6: Copy reports to current directory
Write-Host "[6/6] Copying reports..." -ForegroundColor Yellow
if (Test-Path "$HealthTemp\health_reports") {
    Copy-Item -Path "$HealthTemp\health_reports" -Destination ".\" -Recurse -Force
    Write-Host "✓ Reports copied to .\health_reports\" -ForegroundColor Green
    Write-Host ""
    Write-Host "Reports generated:"
    Get-ChildItem -Path ".\health_reports\*.log" -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime -AutoSize
} else {
    Write-Host "⚠ No reports generated. Check for errors above." -ForegroundColor Red
}
Write-Host ""

# Step 7: Cleanup temporary directories
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $CocoonTemp, $HealthTemp -ErrorAction SilentlyContinue
Write-Host "✓ Cleanup complete" -ForegroundColor Green
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Health Check Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "View reports with:"
Write-Host "  Get-Content .\health_reports\<ip>_health.log"
Write-Host "  Get-Content .\health_reports\<ip>_services.log"
Write-Host ""
Write-Host "Next run:"
Write-Host "  iwr -useb https://raw.githubusercontent.com/DebalGhosh100/health_checkup/main/run_health_check.ps1 | iex"
Write-Host ""
