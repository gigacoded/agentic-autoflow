#!/bin/bash
###############################################################################
# Claude Code Workflow Template - Setup Script
###############################################################################
#
# This script installs the Claude Code workflow infrastructure into your
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
echo -e "${BLUE}║  Claude Code Workflow Template - Installation             ║${NC}"
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
if [ -d ".claude/skills/task-management-dev" ]; then
    echo -e "${YELLOW}⚠️  Claude Code infrastructure already exists in this directory${NC}"
    read -p "Do you want to overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}Installing Claude Code workflow infrastructure...${NC}"
echo ""

# Step 1: Create .claude directory structure
echo -e "${BLUE}1️⃣  Creating .claude directory structure...${NC}"
mkdir -p .claude/skills
mkdir -p .claude/commands
mkdir -p .claude/hooks-global

# Step 2: Copy core infrastructure files
echo -e "${BLUE}2️⃣  Copying core infrastructure files...${NC}"

# Copy settings.json (hooks configuration)
if [ -f "$TEMPLATE_DIR/.claude/settings.json" ]; then
    cp "$TEMPLATE_DIR/.claude/settings.json" .claude/
    echo -e "   ${GREEN}✓${NC} .claude/settings.json (hooks configuration)"
fi

# Copy hooks-global scripts
if [ -d "$TEMPLATE_DIR/.claude/hooks-global" ]; then
    cp -r "$TEMPLATE_DIR/.claude/hooks-global/"* .claude/hooks-global/ 2>/dev/null || true
    echo -e "   ${GREEN}✓${NC} .claude/hooks-global/ (skill activation & quality checks)"
fi

# Copy all skills
if [ -d "$TEMPLATE_DIR/.claude/skills" ]; then
    cp -r "$TEMPLATE_DIR/.claude/skills/"* .claude/skills/ 2>/dev/null || true
    echo -e "   ${GREEN}✓${NC} .claude/skills/ (frontend-dev, convex-backend-dev, task-management-dev)"
fi

# Copy commands
if [ -d "$TEMPLATE_DIR/.claude/commands" ]; then
    cp -r "$TEMPLATE_DIR/.claude/commands/"* .claude/commands/ 2>/dev/null || true
    echo -e "   ${GREEN}✓${NC} .claude/commands/ (dev docs commands)"
fi

# Copy .mcp.json (MCP server configuration)
echo -e "${BLUE}3️⃣  Copying MCP configuration...${NC}"
if [ -f "$TEMPLATE_DIR/.mcp.json" ]; then
    if [ ! -f ".mcp.json" ]; then
        cp "$TEMPLATE_DIR/.mcp.json" .
        echo -e "   ${GREEN}✓${NC} .mcp.json (Convex & Chrome DevTools MCP)"
    else
        echo -e "   ${YELLOW}⚠${NC}  .mcp.json already exists (skipping)"
    fi
fi

# Step 4: Copy docs/delivery structure
echo -e "${BLUE}4️⃣  Creating docs/delivery structure...${NC}"
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

# Step 5: Create dev/active directory for dev docs
echo -e "${BLUE}5️⃣  Creating dev docs directory...${NC}"
mkdir -p dev/active
echo -e "   ${GREEN}✓${NC} dev/active/ (for long-running tasks)"

# Step 6: Copy CLAUDE.md template
echo -e "${BLUE}6️⃣  Installing CLAUDE.md...${NC}"
if [ ! -f "CLAUDE.md" ]; then
    cp "$TEMPLATE_DIR/CLAUDE.template.md" CLAUDE.md
    echo -e "   ${GREEN}✓${NC} CLAUDE.md (customize this for your project!)"
else
    echo -e "   ${YELLOW}⚠${NC}  CLAUDE.md already exists (skipping)"
fi

# Step 7: Add to .gitignore if exists
echo -e "${BLUE}7️⃣  Updating .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    if ! grep -q "^.claude/settings.local.json" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Code - Local settings" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
        echo -e "   ${GREEN}✓${NC} Added .claude/settings.local.json to .gitignore"
    else
        echo -e "   ${YELLOW}⚠${NC}  .gitignore already configured"
    fi
fi

# Step 8: Create initial backlog entry
echo ""
echo -e "${BLUE}8️⃣  Would you like to customize the backlog now? (y/N)${NC}"
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

    # Replace placeholders in CLAUDE.md
    if [ -f "CLAUDE.md" ]; then
        sed -i.bak "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" CLAUDE.md
        sed -i.bak "s/{{DEV_SERVER_COMMAND}}/npm run dev/g" CLAUDE.md
        sed -i.bak "s/{{BUILD_COMMAND}}/npm run build/g" CLAUDE.md
        sed -i.bak "s/{{LINT_COMMAND}}/npm run lint/g" CLAUDE.md
        sed -i.bak "s/{{TYPECHECK_COMMAND}}/npm run typecheck/g" CLAUDE.md
        sed -i.bak "s/{{SOURCE_DIR}}/src/g" CLAUDE.md
        sed -i.bak "s/{{COMPONENTS_DIR}}/components/g" CLAUDE.md
        sed -i.bak "s/{{BACKEND_DIR}}/api/g" CLAUDE.md
        rm CLAUDE.md.bak 2>/dev/null || true
        echo -e "   ${GREEN}✓${NC} Customized CLAUDE.md"
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
echo -e "1. Review and customize ${YELLOW}CLAUDE.md${NC} for your project:"
echo -e "   - Update Quick Start commands"
echo -e "   - Customize Project Structure"
echo -e "   - Add project-specific rules"
echo ""
echo -e "2. Review ${YELLOW}docs/delivery/backlog.md${NC} and create your first PBI"
echo ""
echo -e "3. Check out ${YELLOW}docs/delivery/examples/1/${NC} for PBI structure reference"
echo ""
echo -e "4. Optional: Add project-specific skills to ${YELLOW}.claude/skills/${NC}"
echo ""
echo -e "5. Start using: Create PBIs, break into tasks, let Claude Code assist!"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "   - .claude/README.md"
echo -e "   - .claude/skills/task-management-dev/SKILL.md"
echo -e "   - CLAUDE.md"
echo ""
echo -e "${GREEN}Happy coding with structured workflow! 🚀${NC}"
echo ""
