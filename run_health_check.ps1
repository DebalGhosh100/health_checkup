# Health Checkup - One-Command Execution Script (PowerShell)
# This script clones the Cocoon framework, installs dependencies, runs health checks, and cleans up
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/YOUR_USERNAME/health_checkup/main/run_health_check.ps1 | iex
#   .\run_health_check.ps1

$ErrorActionPreference = "Stop"

# Configuration
$CocoonRepo = "https://github.com/DebalGhosh100/blocks.git"
$TempDir = ".cocoon_temp"
$WorkflowFile = "main.yaml"
$StorageDir = "storage"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   System Health Check" -ForegroundColor Cyan
Write-Host "   Powered by Cocoon Framework" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clone Cocoon framework
Write-Host "[1/5] Cloning Cocoon framework..." -ForegroundColor Yellow
if (Test-Path $TempDir) {
    Write-Host "Cleaning up existing framework directory..."
    Remove-Item -Recurse -Force $TempDir
}
git clone --depth 1 $CocoonRepo $TempDir
Write-Host "✓ Framework cloned" -ForegroundColor Green
Write-Host ""

# Step 2: Install dependencies
Write-Host "[2/5] Installing dependencies..." -ForegroundColor Yellow
pip install -q -r "$TempDir\requirements.txt"
Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 3: Execute health checks
Write-Host "[3/5] Running health checks on all servers..." -ForegroundColor Yellow
Write-Host ""
python "$TempDir\blocks_executor.py" $WorkflowFile --storage $StorageDir
Write-Host ""

# Step 4: Display summary
Write-Host "[4/5] Generating summary..." -ForegroundColor Yellow
if (Test-Path ".\health_reports") {
    $reports = Get-ChildItem -Path ".\health_reports\*.log" -ErrorAction SilentlyContinue
    if ($reports) {
        Write-Host "✓ Health checks completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Reports generated:"
        Get-ChildItem -Path ".\health_reports\*.log" | Format-Table Name, Length, LastWriteTime -AutoSize
    } else {
        Write-Host "⚠ No reports generated. Check for errors above." -ForegroundColor Red
    }
} else {
    Write-Host "⚠ Reports directory not created. Check for errors above." -ForegroundColor Red
}
Write-Host ""

# Step 5: Cleanup framework
Write-Host "[5/5] Cleaning up framework files..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $TempDir
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
Write-Host "  iwr -useb https://raw.githubusercontent.com/YOUR_USERNAME/health_checkup/main/run_health_check.ps1 | iex"
Write-Host ""
