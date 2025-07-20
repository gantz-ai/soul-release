# Soul Installation

## Quick Install

To install the latest version of Soul, run:

### macOS/Linux

```bash
sh <(curl -fsSL https://soul-lang.com/install.sh)
```

Or with wget:

```bash
sh <(wget -qO- https://soul-lang.com/install.sh)
```

### Windows (PowerShell)

```powershell
iwr -useb https://soul-lang.com/install.ps1 | iex
```

## Manual Installation

1. Check the latest version in `latest.txt`
2. Download the appropriate compressed archive for your platform:
   - macOS (Apple Silicon): `mac/soul-VERSION-darwin-arm64.tar.gz`
   - macOS (Intel): `mac/soul-VERSION-darwin-amd64.tar.gz`
   - Linux: `linux/soul-VERSION-linux-amd64.tar.gz`
   - Windows: `windows/soul-VERSION-windows-amd64.zip`
3. Extract the archive:
   - Unix: `tar -xzf soul-VERSION-PLATFORM.tar.gz`
   - Windows: Extract the ZIP file
4. Rename the binary to `soul` (Unix) or `soul.exe` (Windows)
5. Make it executable (Unix): `chmod +x soul`
6. Move to your PATH:
   - macOS/Linux: `sudo mv soul /usr/local/bin/`
   - Windows: Move to a directory in your PATH

## Installation Locations

- **macOS/Linux**: `/usr/local/bin/soul`
- **Windows**: `%USERPROFILE%\.soul\bin\soul.exe`

## Verify Installation

```bash
soul version
```

## Update Soul

Soul includes a built-in update command:

```bash
# Check for updates and install if available
soul update

# Check for updates without installing (dry run)
soul update --dry-run
```

## Release Structure

Each release includes:

- Compressed archives for each platform in their respective directories
- `latest.txt` - Current version number

### Directory Structure

```
soul-release/
├── latest.txt
├── mac/
│   ├── soul-VERSION-darwin-arm64.tar.gz
│   └── soul-VERSION-darwin-amd64.tar.gz
├── linux/
│   └── soul-VERSION-linux-amd64.tar.gz
└── windows/
    └── soul-VERSION-windows-amd64.zip
```

## Supported Platforms

- macOS arm64 (Apple Silicon)
- macOS amd64 (Intel)
- Linux amd64
- Windows amd64

## Version Information

Latest version: See `latest.txt`
