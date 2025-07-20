# Soul Installation Script for Windows
# Run with: iwr -useb https://raw.githubusercontent.com/gantz-ai/soul-release/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

# Base URL for Soul releases
$BaseURL = "https://raw.githubusercontent.com/gantz-ai/soul-release/main"

Write-Host "Soul Installation Script" -ForegroundColor Blue
Write-Host "========================" -ForegroundColor Blue

try {
    # Get latest version
    Write-Host "`nFetching latest version..." -ForegroundColor Yellow
    $LatestVersion = (Invoke-WebRequest -Uri "$BaseURL/latest.txt" -UseBasicParsing).Content.Trim()
    Write-Host "Latest version: $LatestVersion" -ForegroundColor Green
    
    # Download archive
    $ArchiveName = "soul-$LatestVersion-windows-amd64.zip"
    $DownloadURL = "$BaseURL/windows/$ArchiveName"
    
    # Create temp directory
    $TempDir = New-TemporaryFile | %{ rm $_; mkdir $_ }
    $TempArchive = "$TempDir\$ArchiveName"
    
    Write-Host "`nDownloading Soul $LatestVersion..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadURL -OutFile $TempArchive -UseBasicParsing
    
    # Extract archive
    Write-Host "Extracting archive..." -ForegroundColor Yellow
    Expand-Archive -Path $TempArchive -DestinationPath $TempDir -Force
    
    # Find the executable
    $ExtractedExe = Get-ChildItem -Path $TempDir -Filter "soul-$LatestVersion.exe" -Recurse | Select-Object -First 1
    
    if (!$ExtractedExe) {
        throw "Could not find soul executable in archive"
    }
    
    # Create Soul directory in user's home
    $InstallDir = "$env:USERPROFILE\.soul\bin"
    if (!(Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
    
    $DestPath = "$InstallDir\soul.exe"
    
    # Copy executable
    Copy-Item -Path $ExtractedExe.FullName -Destination $DestPath -Force
    
    # Cleanup
    Remove-Item -Path $TempDir -Recurse -Force
    
    # Add to PATH if not already there
    $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($UserPath -notlike "*$InstallDir*") {
        Write-Host "`nAdding Soul to PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
        $env:PATH = "$env:PATH;$InstallDir"
        Write-Host "Added $InstallDir to PATH" -ForegroundColor Green
    }
    
    # Verify installation
    Write-Host "`n✓ Soul installed successfully!" -ForegroundColor Green
    Write-Host "Installation location: $DestPath" -ForegroundColor Cyan
    Write-Host "`nTo use Soul, open a new PowerShell/Command Prompt and run:" -ForegroundColor Yellow
    Write-Host "  soul --help" -ForegroundColor Cyan
    
} catch {
    Write-Host "`nError: Installation failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}