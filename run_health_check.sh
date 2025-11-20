#!/bin/bash
# Health Checkup - One-Command Execution Script
# This script clones the Cocoon framework, installs dependencies, runs health checks, and cleans up
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/health_checkup/main/run_health_check.sh | bash
#   ./run_health_check.sh

set -e  # Exit on any error

# Configuration
COCOON_REPO="https://github.com/DebalGhosh100/blocks.git"
TEMP_DIR=".cocoon_temp"
WORKFLOW_FILE="main.yaml"
STORAGE_DIR="storage"

# Colors for terminal output
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   System Health Check${NC}"
echo -e "${CYAN}   Powered by Cocoon Framework${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Step 1: Clone Cocoon framework
echo -e "${YELLOW}[1/5] Cloning Cocoon framework...${NC}"
if [ -d "$TEMP_DIR" ]; then
    echo "Cleaning up existing framework directory..."
    rm -rf "$TEMP_DIR"
fi
git clone --depth 1 "$COCOON_REPO" "$TEMP_DIR"
echo -e "${GREEN}✓ Framework cloned${NC}"
echo ""

# Step 2: Install dependencies
echo -e "${YELLOW}[2/5] Installing dependencies...${NC}"
pip3 install -q -r "$TEMP_DIR/requirements.txt"
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 3: Execute health checks
echo -e "${YELLOW}[3/5] Running health checks on all servers...${NC}"
echo ""
python3 "$TEMP_DIR/blocks_executor.py" "$WORKFLOW_FILE" --storage "$STORAGE_DIR"
echo ""

# Step 4: Display summary
echo -e "${YELLOW}[4/5] Generating summary...${NC}"
if [ -d "./health_reports" ] && [ "$(ls -A ./health_reports/*.log 2>/dev/null)" ]; then
    echo -e "${GREEN}✓ Health checks completed successfully!${NC}"
    echo ""
    echo "Reports generated:"
    ls -lh ./health_reports/*.log
else
    echo -e "${RED}⚠ No reports generated. Check for errors above.${NC}"
fi
echo ""

# Step 5: Cleanup framework
echo -e "${YELLOW}[5/5] Cleaning up framework files...${NC}"
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}   Health Check Complete!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "View reports with:"
echo "  cat ./health_reports/<ip>_health.log"
echo "  cat ./health_reports/<ip>_services.log"
echo ""
echo "Next run:"
echo "  curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/health_checkup/main/run_health_check.sh | bash"
echo ""
