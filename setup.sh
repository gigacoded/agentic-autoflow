#!/bin/bash
###############################################################################
# Gemini CLI Workflow Template - Setup Script
###############################################################################
#
# This script installs the Gemini CLI workflow infrastructure into your
# project, enabling structured PBI/task management and development docs.
#
# Usage:
#   ./setup.sh [target-directory]
#
# If no target directory specified, assumes current directory.
#
###############################################################################

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get target directory
TARGET_DIR="${1:-.}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Gemini CLI Workflow Template - Installation             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}✗ Error: Target directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"

echo -e "${BLUE}📁 Target directory: ${TARGET_DIR}${NC}"
echo ""

# Check if already installed
if [ -d ".gemini/skills/task-management-dev" ]; then
    echo -e "${YELLOW}⚠️  Gemini CLI infrastructure already exists in this directory${NC}"
    read -p "Do you want to overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}Installing Gemini CLI workflow infrastructure...${NC}"
echo ""

# Step 1: Create .gemini directory structure
echo -e "${BLUE}1️⃣  Creating .gemini directory structure...${NC}"
mkdir -p .gemini/skills
mkdir -p .gemini/commands
mkdir -p .gemini/hooks-global

# Step 2: Copy core infrastructure files
echo -e "${BLUE}2️⃣  Copying core infrastructure files...${NC}"

# Copy README
if [ -f "$TEMPLATE_DIR/.gemini/README.md" ]; then
    cp "$TEMPLATE_DIR/.gemini/README.md" .gemini/
    echo -e "   ${GREEN}✓${NC} .gemini/README.md"
fi

# Copy task-management-dev skill (REQUIRED)
if [ -d "$TEMPLATE_DIR/.gemini/skills/task-management-dev" ]; then
    cp -r "$TEMPLATE_DIR/.gemini/skills/task-management-dev" .gemini/skills/
    echo -e "   ${GREEN}✓${NC} .gemini/skills/task-management-dev/ (core workflow)"
fi

# Copy skill-rules.json
if [ -f "$TEMPLATE_DIR/.gemini/skills/skill-rules.json" ]; then
    cp "$TEMPLATE_DIR/.gemini/skills/skill-rules.json" .gemini/skills/
    echo -e "   ${GREEN}✓${NC} .gemini/skills/skill-rules.json"
fi

# Copy commands
if [ -d "$TEMPLATE_DIR/.gemini/commands" ]; then
    cp -r "$TEMPLATE_DIR/.gemini/commands/"* .gemini/commands/ 2>/dev/null || true
    echo -e "   ${GREEN}✓${NC} .gemini/commands/ (dev docs commands)"
fi

# Step 3: Copy docs/delivery structure
echo -e "${BLUE}3️⃣  Creating docs/delivery structure...${NC}"
mkdir -p docs/delivery

# Copy backlog template
if [ -f "$TEMPLATE_DIR/docs/delivery/backlog.md" ]; then
    if [ ! -f "docs/delivery/backlog.md" ]; then
        cp "$TEMPLATE_DIR/docs/delivery/backlog.md" docs/delivery/
        echo -e "   ${GREEN}✓${NC} docs/delivery/backlog.md"
    else
        echo -e "   ${YELLOW}⚠${NC}  docs/delivery/backlog.md already exists (skipping)"
    fi
fi

# Copy example PBI
if [ -d "$TEMPLATE_DIR/docs/delivery/examples" ]; then
    cp -r "$TEMPLATE_DIR/docs/delivery/examples" docs/delivery/
    echo -e "   ${GREEN}✓${NC} docs/delivery/examples/ (reference PBI)"
fi

# Step 4: Create dev/active directory for dev docs
echo -e "${BLUE}4️⃣  Creating dev docs directory...${NC}"
mkdir -p dev/active
echo -e "   ${GREEN}✓${NC} dev/active/ (for long-running tasks)"

# Step 5: Copy GEMINI.md template
echo -e "${BLUE}5️⃣  Installing GEMINI.md...${NC}"
if [ ! -f "GEMINI.md" ]; then
    cp "$TEMPLATE_DIR/CLAUDE.template.md" GEMINI.md
    echo -e "   ${GREEN}✓${NC} GEMINI.md (customize this for your project!)"
else
    echo -e "   ${YELLOW}⚠${NC}  GEMINI.md already exists (skipping)"
fi

# Step 6: Add to .gitignore if exists
echo -e "${BLUE}6️⃣  Updating .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    if ! grep -q "^.gemini/settings.local.json" .gitignore; then
        echo "" >> .gitignore
        echo "# Gemini CLI - Local settings" >> .gitignore
        echo ".gemini/settings.local.json" >> .gitignore
        echo -e "   ${GREEN}✓${NC} Added .gemini/settings.local.json to .gitignore"
    else
        echo -e "   ${YELLOW}⚠${NC}  .gitignore already configured"
    fi
fi

# Step 7: Create initial backlog entry
echo ""
echo -e "${BLUE}7️⃣  Would you like to customize the backlog now? (y/N)${NC}"
read -p "" -n 1 -r CUSTOMIZE
echo

if [[ $CUSTOMIZE =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Please provide the following information:${NC}"

    read -p "Project Name: " PROJECT_NAME
    read -p "Your Name/Author: " AUTHOR_NAME

    # Replace placeholders in backlog.md
    if [ -f "docs/delivery/backlog.md" ]; then
        sed -i.bak "s/{{DATE}}/$(date +%Y-%m-%d)/g" docs/delivery/backlog.md
        sed -i.bak "s/{{AUTHOR}}/${AUTHOR_NAME}/g" docs/delivery/backlog.md
        sed -i.bak "s/{{ACTOR}}/Developer/g" docs/delivery/backlog.md
        rm docs/delivery/backlog.md.bak 2>/dev/null || true
        echo -e "   ${GREEN}✓${NC} Customized docs/delivery/backlog.md"
    fi

    # Replace placeholders in GEMINI.md
    if [ -f "GEMINI.md" ]; then
        sed -i.bak "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" GEMINI.md
        sed -i.bak "s/{{DEV_SERVER_COMMAND}}/npm run dev/g" GEMINI.md
        sed -i.bak "s/{{BUILD_COMMAND}}/npm run build/g" GEMINI.md
        sed -i.bak "s/{{LINT_COMMAND}}/npm run lint/g" GEMINI.md
        sed -i.bak "s/{{TYPECHECK_COMMAND}}/npm run typecheck/g" GEMINI.md
        sed -i.bak "s/{{SOURCE_DIR}}/src/g" GEMINI.md
        sed -i.bak "s/{{COMPONENTS_DIR}}/components/g" GEMINI.md
        sed -i.bak "s/{{BACKEND_DIR}}/api/g" GEMINI.md
        rm GEMINI.md.bak 2>/dev/null || true
        echo -e "   ${GREEN}✓${NC} Customized GEMINI.md"
    fi
fi

# Installation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Installation Complete!                                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo ""
echo -e "1. Review and customize ${YELLOW}GEMINI.md${NC} for your project:"
echo -e "   - Update Quick Start commands"
echo -e "   - Customize Project Structure"
echo -e "   - Add project-specific rules"
echo ""
echo -e "2. Review ${YELLOW}docs/delivery/backlog.md${NC} and create your first PBI"
echo ""
echo -e "3. Check out ${YELLOW}docs/delivery/examples/1/${NC} for PBI structure reference"
echo ""
echo -e "4. Optional: Add project-specific skills to ${YELLOW}.gemini/skills/${NC}"
echo ""
echo -e "5. Start using: Create PBIs, break into tasks, let Gemini CLI assist!"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "   - .gemini/README.md"
echo -e "   - .gemini/skills/task-management-dev/SKILL.md"
echo -e "   - GEMINI.md"
echo ""
echo -e "${GREEN}Happy coding with structured workflow! 🚀${NC}"
echo ""
