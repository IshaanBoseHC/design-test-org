#!/bin/bash

# HDS Terraform Remediation Prototype - Initialization Script
# This script sets up the development environment and starts the application

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Start initialization
clear
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║   HDS Terraform Remediation Prototype - Initialization       ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
print_header "Step 1: Checking Prerequisites"

# Check Node.js
if check_command node; then
    NODE_VERSION=$(node --version)
    REQUIRED_VERSION="20"
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d'.' -f1 | sed 's/v//')

    if [ "$NODE_MAJOR" -ge "$REQUIRED_VERSION" ]; then
        print_success "Node.js $NODE_VERSION (>= v${REQUIRED_VERSION} required)"
    else
        print_error "Node.js version $NODE_VERSION is too old (>= v${REQUIRED_VERSION} required)"
        echo ""
        echo "Please upgrade Node.js:"
        echo "  - Using nvm: nvm install 20 && nvm use 20"
        echo "  - Download from: https://nodejs.org/"
        exit 1
    fi
else
    print_error "Node.js is not installed"
    echo ""
    echo "Please install Node.js >= v20:"
    echo "  - Using nvm: nvm install 20 && nvm use 20"
    echo "  - Download from: https://nodejs.org/"
    exit 1
fi

# Check pnpm
if check_command pnpm; then
    PNPM_VERSION=$(pnpm --version)
    print_success "pnpm v$PNPM_VERSION"
else
    print_warning "pnpm is not installed"
    print_info "Installing pnpm..."

    if check_command npm; then
        npm install -g pnpm
        print_success "pnpm installed successfully"
    else
        print_error "Cannot install pnpm (npm not available)"
        exit 1
    fi
fi

# Navigate to project directory
print_header "Step 2: Setting Up Project"

if [ ! -d "hdsproto" ]; then
    print_error "hdsproto directory not found!"
    echo "Please run this script from the repository root."
    exit 1
fi

cd hdsproto
print_success "Changed to hdsproto directory"

# Check if node_modules exists
if [ -d "node_modules" ]; then
    print_warning "node_modules already exists"
    read -p "Do you want to reinstall dependencies? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing existing node_modules..."
        rm -rf node_modules
        print_success "Cleaned node_modules"
    fi
fi

# Install dependencies
if [ ! -d "node_modules" ]; then
    print_header "Step 3: Installing Dependencies"
    print_info "This may take a few minutes..."

    pnpm install

    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
else
    print_header "Step 3: Dependencies Already Installed"
    print_success "Skipping installation"
fi

# Clear Vite cache (common issue fix)
print_header "Step 4: Clearing Caches"

if [ -d "node_modules/.vite" ]; then
    rm -rf node_modules/.vite
    print_success "Cleared Vite cache"
else
    print_info "Vite cache not found (this is normal for first run)"
fi

# Verify critical directories exist
print_header "Step 5: Verifying Project Structure"

REQUIRED_DIRS=("app" "app/components" "app/templates" "tests" "public")
ALL_DIRS_EXIST=true

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_success "Found: $dir"
    else
        print_error "Missing: $dir"
        ALL_DIRS_EXIST=false
    fi
done

if [ "$ALL_DIRS_EXIST" = false ]; then
    print_error "Project structure is incomplete"
    exit 1
fi

# Success message
print_header "✓ Initialization Complete!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ${GREEN}✓${NC} Environment is ready!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask if user wants to start dev server
read -p "Start the development server now? (Y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_header "Starting Development Server"
    print_info "Server will start at http://localhost:4203"
    print_info "Press Ctrl+C to stop the server"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    pnpm start
else
    echo ""
    echo "To start the development server later, run:"
    echo ""
    echo "  ${BLUE}cd hdsproto && pnpm start${NC}"
    echo ""
    echo "Then open http://localhost:4203 in your browser"
    echo ""
fi
