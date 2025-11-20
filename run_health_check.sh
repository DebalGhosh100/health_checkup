#!/bin/bash
# Health Checkup - One-Command Execution Script
# This script clones the Cocoon framework, installs dependencies, runs health checks, and cleans up
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/health_checkup/main/run_health_check.sh | bash
#   ./run_health_check.sh

set -e  # Exit on any error

# Configuration
HEALTH_CHECK_REPO="https://github.com/DebalGhosh100/health_checkup.git"

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


echo -e "${YELLOW}[2/6] Cloning health_checkup workflow...${NC}"

git clone --depth 1 "$HEALTH_CHECK_REPO" > /dev/null 2>&1
echo -e "${YELLOW}Current working directory: $(pwd)${NC}"

mv -r ./health_checkup .
rm -rf ./health_checkup

echo -e "${GREEN}✓ Workflow cloned${NC}"
echo ""

cp ./servers.yaml "./storage/servers.yaml"
echo -e "${GREEN}✓ Configuration ready${NC}"

