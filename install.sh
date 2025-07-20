#!/bin/bash

# Soul Installation Script
# This script downloads and installs the latest version of Soul

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URL for Soul releases
BASE_URL="https://raw.githubusercontent.com/gantz-ai/soul-release/main"

# Detect OS and architecture
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $OS in
        darwin)
            PLATFORM="darwin"
            ;;
        linux)
            PLATFORM="linux"
            ;;
        mingw*|cygwin*|msys*)
            PLATFORM="windows"
            ;;
        *)
            echo -e "${RED}Error: Unsupported operating system: $OS${NC}"
            exit 1
            ;;
    esac
    
    case $ARCH in
        x86_64|amd64)
            ARCH="amd64"
            ;;
        arm64|aarch64)
            if [ "$PLATFORM" = "darwin" ]; then
                ARCH="arm64"
            else
                ARCH="amd64" # Default to amd64 for non-macOS ARM
            fi
            ;;
        *)
            echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
    
    PLATFORM_KEY="${PLATFORM}-${ARCH}"
}

# Download file with progress
download_file() {
    local url=$1
    local output=$2
    
    if command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar -o "$output" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget --show-progress -O "$output" "$url"
    else
        echo -e "${RED}Error: Neither curl nor wget found. Please install one of them.${NC}"
        exit 1
    fi
}

# Main installation function
install_soul() {
    echo -e "${BLUE}Soul Installation Script${NC}"
    echo "========================"
    
    # Detect platform
    detect_platform
    echo -e "${GREEN}Detected platform: ${PLATFORM_KEY}${NC}"
    
    # Get latest version
    echo -e "\n${YELLOW}Fetching latest version...${NC}"
    LATEST_VERSION=$(curl -s "${BASE_URL}/latest.txt" | tr -d '\n')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${RED}Error: Could not fetch latest version${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Latest version: ${LATEST_VERSION}${NC}"
    
    # Get download info from index.json
    echo -e "\n${YELLOW}Fetching download information...${NC}"
    
    # Determine archive name based on platform
    case $PLATFORM_KEY in
        darwin-arm64)
            ARCHIVE_PATH="mac/soul-${LATEST_VERSION}-darwin-arm64.tar.gz"
            ARCHIVE_NAME="soul-${LATEST_VERSION}-darwin-arm64.tar.gz"
            BINARY_NAME="soul-${LATEST_VERSION}"
            ;;
        darwin-amd64)
            ARCHIVE_PATH="mac/soul-${LATEST_VERSION}-darwin-amd64.tar.gz"
            ARCHIVE_NAME="soul-${LATEST_VERSION}-darwin-amd64.tar.gz"
            BINARY_NAME="soul-${LATEST_VERSION}-amd64"
            ;;
        linux-amd64)
            ARCHIVE_PATH="linux/soul-${LATEST_VERSION}-linux-amd64.tar.gz"
            ARCHIVE_NAME="soul-${LATEST_VERSION}-linux-amd64.tar.gz"
            BINARY_NAME="soul-${LATEST_VERSION}"
            ;;
        windows-amd64)
            ARCHIVE_PATH="windows/soul-${LATEST_VERSION}-windows-amd64.zip"
            ARCHIVE_NAME="soul-${LATEST_VERSION}-windows-amd64.zip"
            BINARY_NAME="soul-${LATEST_VERSION}.exe"
            ;;
    esac
    
    DOWNLOAD_URL="${BASE_URL}/${ARCHIVE_PATH}"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # Download archive
    echo -e "\n${YELLOW}Downloading Soul ${LATEST_VERSION}...${NC}"
    TEMP_ARCHIVE="${TEMP_DIR}/${ARCHIVE_NAME}"
    download_file "$DOWNLOAD_URL" "$TEMP_ARCHIVE"
    
    # Extract archive
    echo -e "${YELLOW}Extracting archive...${NC}"
    cd "$TEMP_DIR"
    
    if [[ "$ARCHIVE_NAME" == *.tar.gz ]]; then
        tar -xzf "$ARCHIVE_NAME"
    elif [[ "$ARCHIVE_NAME" == *.zip ]]; then
        unzip -q "$ARCHIVE_NAME"
    fi
    
    # Find the extracted binary
    TEMP_BINARY="${TEMP_DIR}/${BINARY_NAME}"
    
    # Rename to soul if needed
    if [ "$BINARY_NAME" != "soul" ] && [ "$BINARY_NAME" != "soul.exe" ]; then
        if [ "$PLATFORM" = "windows" ]; then
            mv "$TEMP_BINARY" "${TEMP_DIR}/soul.exe"
            TEMP_BINARY="${TEMP_DIR}/soul.exe"
        else
            mv "$TEMP_BINARY" "${TEMP_DIR}/soul"
            TEMP_BINARY="${TEMP_DIR}/soul"
        fi
    fi
    
    # Make binary executable
    chmod +x "$TEMP_BINARY"
    
    # Verify download
    if [ ! -f "$TEMP_BINARY" ]; then
        echo -e "${RED}Error: Binary not found after extraction${NC}"
        exit 1
    fi
    
    # Install based on platform
    case $PLATFORM in
        darwin|linux)
            # Check if we can write to /usr/local/bin
            if [ -w "/usr/local/bin" ]; then
                INSTALL_DIR="/usr/local/bin"
                NEED_SUDO=""
            else
                INSTALL_DIR="/usr/local/bin"
                NEED_SUDO="sudo"
                echo -e "\n${YELLOW}Administrator access required to install to ${INSTALL_DIR}${NC}"
            fi
            
            # Create directory if it doesn't exist
            $NEED_SUDO mkdir -p "$INSTALL_DIR"
            
            # Copy binary
            echo -e "${YELLOW}Installing to ${INSTALL_DIR}/soul...${NC}"
            $NEED_SUDO cp "$TEMP_BINARY" "${INSTALL_DIR}/soul"
            $NEED_SUDO chmod +x "${INSTALL_DIR}/soul"
            
            # Verify installation
            if command -v soul >/dev/null 2>&1; then
                INSTALLED_VERSION=$(soul version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
                echo -e "\n${GREEN}✓ Soul ${INSTALLED_VERSION} installed successfully!${NC}"
                echo -e "${BLUE}Run 'soul --help' to get started${NC}"
            else
                echo -e "\n${YELLOW}Soul installed to ${INSTALL_DIR}/soul${NC}"
                echo -e "${YELLOW}Make sure ${INSTALL_DIR} is in your PATH${NC}"
                echo -e "${BLUE}You can add it to your PATH by adding this line to your shell profile:${NC}"
                echo -e "  export PATH=\"\$PATH:${INSTALL_DIR}\""
            fi
            ;;
            
        windows)
            # For Windows, suggest manual installation location
            echo -e "\n${GREEN}✓ Soul downloaded successfully!${NC}"
            echo -e "${YELLOW}For Windows, please:${NC}"
            echo -e "1. Move ${TEMP_BINARY} to a directory of your choice"
            echo -e "2. Add that directory to your PATH environment variable"
            echo -e "3. Rename the file to 'soul.exe'"
            read -p "Press Enter to continue..."
            ;;
    esac
}

# Run installation
install_soul