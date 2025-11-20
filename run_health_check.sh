
#!/bin/bash
set -euo pipefail

HEALTH_CHECK_REPO="https://github.com/DebalGhosh100/health_checkup.git"

CYAN='\033[1;36m'; YELLOW='\033[1;33m'; GREEN='\033[1;32m'; RED='\033[1;31m'; NC='\033[0m'

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
# Do NOT hide errors during clone; show stderr if it fails
rm -rf ./health_checkup
if ! git clone --depth 1 "$HEALTH_CHECK_REPO"; then
  echo -e "${RED}✗ git clone failed. Check network/repo URL: ${HEALTH_CHECK_REPO}${NC}"
  exit 1
fi

echo -e "${YELLOW}Current working directory: $(pwd)${NC}"

# Copy contents including hidden files; then remove the folder
if [ -d "./health_checkup" ]; then
  cp -a ./health_checkup/. .
  rm -rf ./health_checkup
else
  echo -e "${RED}✗ Expected ./health_checkup directory not found after clone${NC}"
  exit 1
fi

# Ensure target directory exists before copy
mkdir -p ./storage
cp ./servers.yaml "./storage/servers.yaml"
echo -e "${GREEN}✓ Configuration ready${NC}"

echo -e "${YELLOW}[6/6] Running blocks script...${NC}"
# Optional: show the URL first for clarity
echo -e "${YELLOW}Fetching: https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh${NC}"

# Run with pipefail awareness: catch errors from curl OR bash
# (Bash's exit code is already tracked due to set -o pipefail)
if ! curl -sSL https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh | bash; then
  echo -e "${RED}✗ Failed to execute remote blocks script${NC}"
  exit 1
fi

rm -rf .git .gitignore main.yaml README.md run_health_check.ps1 run_health_check.sh servers.yaml.example storage


echo -e "${GREEN}✓ Blocks script executed successfully${NC}"
