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
HEALTH_CHECK_REPO="https://github.com/DebalGhosh100/health_checkup.git"
COCOON_TEMP=".cocoon_temp"
HEALTH_TEMP=".health_temp"

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

# Step 0: Verify servers.yaml exists
if [ ! -f "./servers.yaml" ]; then
    echo -e "${RED}Error: servers.yaml not found in current directory${NC}"
    echo ""
    echo "Please create a servers.yaml file with your server list:"
    echo ""
    echo "all_servers:"
    echo "  - ip: \"10.49.74.104\""
    echo "    username: \"admin\""
    echo "    password: \"your_password\""
    echo ""
    exit 1
fi
echo -e "${GREEN}✓ Found servers.yaml${NC}"
echo ""

# Step 1: Clone repositories
echo -e "${YELLOW}[1/6] Cloning Cocoon framework...${NC}"
if [ -d "$COCOON_TEMP" ]; then
    rm -rf "$COCOON_TEMP"
fi
git clone --depth 1 "$COCOON_REPO" "$COCOON_TEMP" > /dev/null 2>&1
echo -e "${GREEN}✓ Framework cloned${NC}"

echo -e "${YELLOW}[2/6] Cloning health_checkup workflow...${NC}"
if [ -d "$HEALTH_TEMP" ]; then
    rm -rf "$HEALTH_TEMP"
fi
git clone --depth 1 "$HEALTH_CHECK_REPO" "$HEALTH_TEMP" > /dev/null 2>&1
echo -e "${GREEN}✓ Workflow cloned${NC}"
echo ""

# Step 2: Install dependencies
echo -e "${YELLOW}[3/6] Installing dependencies...${NC}"
pip3 install -q -r "$COCOON_TEMP/requirements.txt"
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 3: Copy user's servers.yaml to health_temp
echo -e "${YELLOW}[4/6] Preparing configuration...${NC}"
cp ./servers.yaml "$HEALTH_TEMP/servers.yaml"
echo -e "${GREEN}✓ Configuration ready${NC}"
echo ""

# Step 4: Execute health checks
echo -e "${YELLOW}[5/6] Running health checks on all servers...${NC}"
echo ""
cd "$HEALTH_TEMP"
python3 "../$COCOON_TEMP/blocks_executor.py" main.yaml --storage storage
cd ..
echo ""

# Step 5: Copy reports to current directory
echo -e "${YELLOW}[6/6] Copying reports...${NC}"
if [ -d "$HEALTH_TEMP/health_reports" ]; then
    cp -r "$HEALTH_TEMP/health_reports" ./
    echo -e "${GREEN}✓ Reports copied to ./health_reports/${NC}"
    echo ""
    echo "Reports generated:"
    ls -lh ./health_reports/*.log 2>/dev/null || echo "No log files found"
else
    echo -e "${RED}⚠ No reports generated. Check for errors above.${NC}"
fi
echo ""

# Step 6: Cleanup temporary directories
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -rf "$COCOON_TEMP" "$HEALTH_TEMP"
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
echo "  curl -sSL https://raw.githubusercontent.com/DebalGhosh100/health_checkup/main/run_health_check.sh | bash"
echo ""
