#!/bin/bash
set -euo pipefail

HEALTH_CHECK_REPO="https://github.com/DebalGhosh100/health_checkup.git"
CYAN='\033[1;36m'; YELLOW='\033[1;33m'; GREEN='\033[1;32m'; RED='\033[1;31m'; NC='\033[0m'

cleanup() {
  echo -e "${YELLOW}[CLEANUP] Removing cloned artifacts and temp files...${NC}"
  # Use -- to guard against file names starting with -
  rm -rf -- .git .gitignore main.yaml README.md run_health_check.ps1 run_health_check.sh servers.yaml.example storage || true
}
trap cleanup EXIT   # ← this guarantees cleanup runs no matter what

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   System Health Check${NC}"
echo -e "${CYAN}   Powered by Cocoon Framework${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Step 0: Verify servers.yaml exists
if [ ! -f "./servers.yaml" ]; then
  echo -e "${RED}Error: servers.yaml not found in current directory${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Found servers.yaml${NC}"

echo -e "${YELLOW}[2/6] Cloning health_checkup workflow...${NC}"
rm -rf ./health_checkup
git clone --depth 1 "$HEALTH_CHECK_REPO"

echo -e "${YELLOW}Current working directory: $(pwd)${NC}"

# Copy contents including hidden files; then remove the folder
if [ -d "./health_checkup" ]; then
  cp -a ./health_checkup/. .
  rm -rf ./health_checkup
else
  echo -e "${RED}✗ Expected ./health_checkup directory not found after clone${NC}"
  exit 1
fi

mkdir -p ./storage
cp ./servers.yaml "./storage/servers.yaml"
echo -e "${GREEN}✓ Configuration ready${NC}"

echo -e "${YELLOW}[6/6] Running blocks script...${NC}"
echo -e "${YELLOW}Fetching: https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh${NC}"

# Run and report status clearly
if curl -fsSL https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh | bash; then
  echo -e "${GREEN}✓ Blocks script executed successfully${NC}"
  cleanup()
else
  status=$?
  echo -e "${RED}✗ Blocks script failed with exit code ${status}${NC}"
  # Do not 'exit 1' here if you want cleanup to be the only exit path; trap will still run.
  # If you *do* want to fail overall, keep 'exit 1' here:
  exit 1
fi

echo -e "Done"
