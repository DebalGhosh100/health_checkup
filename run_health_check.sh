#!/bin/bash
set -euo pipefail

HEALTH_CHECK_REPO="https://github.com/DebalGhosh100/health_checkup.git"
CYAN='\033[1;36m'; YELLOW='\033[1;33m'; GREEN='\033[1;32m'; RED='\033[1;31m'; NC='\033[0m'

# Work in a temp dir to avoid nuking your repo
WORKDIR="$(mktemp -d)"
STORAGE_DIR="./storage"

cleanup() {
  echo -e "${YELLOW}[CLEANUP] Removing temp workspace: ${WORKDIR}${NC}"
  rm -rf -- "${WORKDIR}" || true
  # If you REALLY want to delete copied artifacts in CWD, be explicit and careful.
  # Avoid deleting .git/.gitignore and your run script.
}
trap cleanup EXIT  # or: trap cleanup ERR, or both

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

echo -e "${YELLOW}[2/6] Cloning health_checkup workflow into temp...${NC}"
git clone --depth 1 "$HEALTH_CHECK_REPO" "${WORKDIR}/health_checkup"

echo -e "${YELLOW}Current working directory: $(pwd)${NC}"

# Copy only what you need from the cloned repo to current dir (avoid .git)
cp -a "${WORKDIR}/health_checkup"/. .
rm -rf "${WORKDIR}/health_checkup"

mkdir -p "${STORAGE_DIR}"
cp ./servers.yaml "${STORAGE_DIR}/servers.yaml"
echo -e "${GREEN}✓ Configuration ready${NC}"

echo -e "${YELLOW}[6/6] Running blocks script...${NC}"
echo -e "${YELLOW}Fetching: https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh${NC}"

# With pipefail set, this will fail if curl OR bash fails.
if curl -fsSL https://raw.githubusercontent.com/DebalGhosh100/blocks/main/run_blocks.sh | bash; then
  echo -e "${GREEN}✓ Blocks script executed successfully${NC}"
else
  echo -e "${RED}✗ Blocks script failed with exit code ${status}${NC}"
  # If you want overall failure:
  exit 1
fi

echo -e "Done"
