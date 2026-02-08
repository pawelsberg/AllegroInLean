<#
.SYNOPSIS
  Download and build Allegro 5.2.11 from source on Windows (MSYS2/MinGW-w64).

.DESCRIPTION
  Produces a local install tree in allegro-local\ that the lakefile discovers
  automatically via its PKG_CONFIG_PATH fallback.

  Requires MSYS2 with the mingw-w64-x86_64-toolchain group installed.
  Run from a regular PowerShell — the script invokes MSYS2 bash internally.

.PARAMETER Prefix
  Installation prefix (default: allegro-local in the project root).

.PARAMETER Jobs
  Number of parallel build jobs (default: NUMBER_OF_PROCESSORS).

.PARAMETER Msys2Root
  MSYS2 installation root (default: C:\msys64).

.PARAMETER SkipDownload
  Reuse existing source in allegro-src\.

.PARAMETER UseVcpkg
  Use vcpkg instead of building from source. Installs allegro5 via vcpkg and
  copies the install tree to Prefix.

.EXAMPLE
  .\scripts\build-allegro.ps1
  .\scripts\build-allegro.ps1 -Jobs 8
  .\scripts\build-allegro.ps1 -UseVcpkg
#>
[CmdletBinding()]
param(
    [string]$Prefix = "",
    [int]$Jobs = 0,
    [string]$Msys2Root = "C:\msys64",
    [switch]$SkipDownload,
    [switch]$UseVcpkg
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent $ScriptDir

if (-not $Prefix) { $Prefix = Join-Path $ProjectRoot "allegro-local" }
if ($Jobs -eq 0) { $Jobs = [Environment]::ProcessorCount }

$AllegroVersion = "5.2.11"
$AllegroTag = "5.2.11.0"
$AllegroUrl = "https://github.com/liballeg/allegro5/releases/download/$AllegroTag/allegro-$AllegroTag.tar.gz"
$SourceDir = Join-Path $ProjectRoot "allegro-src"

Write-Host ""
Write-Host "=========================================="
Write-Host "  Building Allegro $AllegroVersion from source"
Write-Host "=========================================="
Write-Host "  Prefix : $Prefix"
Write-Host "  Jobs   : $Jobs"
Write-Host ""

# ── vcpkg path ──
if ($UseVcpkg) {
    Write-Host "-> Using vcpkg..."

    $vcpkgExe = $null
    if ($env:VCPKG_ROOT) {
        $vcpkgExe = Join-Path $env:VCPKG_ROOT "vcpkg.exe"
    } elseif (Get-Command vcpkg -ErrorAction SilentlyContinue) {
        $vcpkgExe = (Get-Command vcpkg).Source
    }
    if (-not $vcpkgExe -or -not (Test-Path $vcpkgExe)) {
        Write-Error "vcpkg not found. Set VCPKG_ROOT or add vcpkg to PATH."
        exit 1
    }

    & $vcpkgExe install "allegro5[core,image,font,ttf,primitives,audio,acodec,color,dialog,video,memfile]:x64-windows"
    $vcpkgInstalled = Join-Path (Split-Path $vcpkgExe) "installed\x64-windows"

    if (-not (Test-Path $Prefix)) { New-Item -ItemType Directory -Path $Prefix -Force | Out-Null }
    Copy-Item -Path "$vcpkgInstalled\*" -Destination $Prefix -Recurse -Force
    Write-Host ""
    Write-Host "Done. Allegro installed to $Prefix via vcpkg."
    Write-Host "  lake build -K allegroPrefix=$Prefix"
    exit 0
}

# ── MSYS2 / MinGW path ──
$msysBash = Join-Path $Msys2Root "usr\bin\bash.exe"
if (-not (Test-Path $msysBash)) {
    Write-Error @"
MSYS2 not found at $Msys2Root.
Install MSYS2 from https://www.msys2.org/ and run:
  pacman -S mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake
Or use -UseVcpkg instead.
"@
    exit 1
}

# Download
if (-not $SkipDownload) {
    if (Test-Path $SourceDir) { Remove-Item -Recurse -Force $SourceDir }
    Write-Host "-> Downloading Allegro $AllegroTag..."
    New-Item -ItemType Directory -Path $SourceDir -Force | Out-Null
    $archive = Join-Path $env:TEMP "allegro-$AllegroTag.tar.gz"
    Invoke-WebRequest -Uri $AllegroUrl -OutFile $archive
    # Use MSYS2 tar to extract (handles symlinks correctly)
    $sourceUnix = ($SourceDir -replace '\\', '/' -replace '^([A-Z]):', '/$1').ToLower()
    & $msysBash --login -c "tar xzf '$(($archive -replace '\\', '/' -replace '^([A-Z]):', '/$1').ToLower())' --strip-components=1 -C '$sourceUnix'"
} else {
    if (-not (Test-Path $SourceDir)) {
        Write-Error "allegro-src does not exist. Remove -SkipDownload."
        exit 1
    }
    Write-Host "-> Reusing existing source."
}

# Build via MSYS2 bash (MINGW64 environment)
$prefixUnix = ($Prefix -replace '\\', '/' -replace '^([A-Z]):', '/$1').ToLower()
$sourceUnix = ($SourceDir -replace '\\', '/' -replace '^([A-Z]):', '/$1').ToLower()

$buildScript = @"
set -euo pipefail
export MSYSTEM=MINGW64
source /etc/profile

mkdir -p '$sourceUnix/build'
cd '$sourceUnix/build'

cmake .. -G 'MinGW Makefiles' \
  -DCMAKE_INSTALL_PREFIX='$prefixUnix' \
  -DCMAKE_BUILD_TYPE=Release \
  -DWANT_NATIVE_DIALOG=ON \
  -DWANT_VIDEO=ON \
  -DWANT_IMAGE=ON -DWANT_FONT=ON -DWANT_TTF=ON \
  -DWANT_PRIMITIVES=ON -DWANT_AUDIO=ON -DWANT_ACODEC=ON \
  -DWANT_COLOR=ON -DWANT_MEMFILE=ON \
  -DWANT_EXAMPLES=OFF -DWANT_DEMO=OFF -DWANT_TESTS=OFF

mingw32-make -j$Jobs
mingw32-make install
"@

Write-Host "-> Configuring and building..."
& $msysBash --login -c $buildScript

Write-Host ""
Write-Host "Done. Allegro $AllegroVersion installed to $Prefix"
Write-Host "  lake build -K allegroPrefix=$Prefix"
Write-Host ""
Write-Host "  To reclaim disk space: Remove-Item -Recurse $SourceDir"
