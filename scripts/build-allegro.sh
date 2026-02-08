#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# build-allegro.sh — Download and build Allegro 5.2.11 from source
#
# Produces a local install tree in allegro-local/ that the lakefile
# discovers automatically via its PKG_CONFIG_PATH fallback.
#
# Works on Linux, macOS, FreeBSD, and other POSIX systems.
#
# Usage:
#   ./scripts/build-allegro.sh              # defaults
#   ./scripts/build-allegro.sh --jobs 8     # override parallelism
#   ./scripts/build-allegro.sh --prefix /opt/allegro   # custom prefix
#   ./scripts/build-allegro.sh --skip-download         # reuse source
# ──────────────────────────────────────────────────────────────────────
set -euo pipefail

ALLEGRO_VERSION="5.2.11"
ALLEGRO_TAG="5.2.11.0"
ALLEGRO_URL="https://github.com/liballeg/allegro5/releases/download/${ALLEGRO_TAG}/allegro-${ALLEGRO_TAG}.tar.gz"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Defaults ──
PREFIX="${PROJECT_ROOT}/allegro-local"
JOBS=""
SKIP_DOWNLOAD=false
CLEAN=false
SOURCE_DIR="${PROJECT_ROOT}/allegro-src"

# ── Parse arguments ──
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)   PREFIX="$2"; shift 2 ;;
    --jobs|-j)  JOBS="$2"; shift 2 ;;
    --skip-download) SKIP_DOWNLOAD=true; shift ;;
    --clean)  CLEAN=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--prefix DIR] [--jobs N] [--skip-download] [--clean]"
      echo ""
      echo "  --prefix DIR       Install prefix (default: allegro-local/)"
      echo "  --jobs N           Parallel build jobs (default: auto-detect)"
      echo "  --skip-download    Reuse existing source in allegro-src/"
      echo "  --clean            Remove source (allegro-src/) and install (allegro-local/) dirs"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Clean mode ──
if [[ "$CLEAN" == true ]]; then
  echo "Cleaning Allegro build artifacts..."
  for d in "$SOURCE_DIR" "$PREFIX"; do
    if [[ -d "$d" ]]; then
      echo "  Removing $d"
      rm -rf "$d"
    else
      echo "  Already absent: $d"
    fi
  done
  echo "Done."
  exit 0
fi

# ── Detect parallelism ──
if [[ -z "$JOBS" ]]; then
  if command -v nproc &>/dev/null; then
    JOBS="$(nproc)"
  elif command -v sysctl &>/dev/null && sysctl -n hw.ncpu &>/dev/null; then
    JOBS="$(sysctl -n hw.ncpu)"
  else
    JOBS=4
  fi
fi

# ── Check build dependencies ──
missing=()
for cmd in cmake make cc; do
  if ! command -v "$cmd" &>/dev/null; then
    missing+=("$cmd")
  fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: Missing required tools: ${missing[*]}"
  echo ""
  echo "Install them first:"
  case "$(uname -s)" in
    Linux)
      if command -v apt-get &>/dev/null; then
        echo "  sudo apt-get install build-essential cmake"
      elif command -v dnf &>/dev/null; then
        echo "  sudo dnf install gcc gcc-c++ cmake make"
      elif command -v pacman &>/dev/null; then
        echo "  sudo pacman -S base-devel cmake"
      fi
      ;;
    Darwin)
      echo "  xcode-select --install && brew install cmake"
      ;;
    FreeBSD)
      echo "  pkg install cmake gmake gcc"
      ;;
  esac
  exit 1
fi

# ── Platform-specific CMake flags ──
CMAKE_EXTRA_FLAGS=()
case "$(uname -s)" in
  Darwin)
    # Homebrew dependency hints
    if command -v brew &>/dev/null; then
      BREW_PREFIX="$(brew --prefix)"
      CMAKE_EXTRA_FLAGS+=(
        "-DCMAKE_PREFIX_PATH=${BREW_PREFIX}"
        "-DCMAKE_FIND_FRAMEWORK=LAST"
      )
    fi
    ;;
  FreeBSD)
    CMAKE_EXTRA_FLAGS+=("-DCMAKE_C_COMPILER=gcc" "-DCMAKE_CXX_COMPILER=g++")
    ;;
esac

echo "╔══════════════════════════════════════════╗"
echo "║  Building Allegro ${ALLEGRO_VERSION} from source      ║"
echo "╠══════════════════════════════════════════╣"
echo "║  Prefix : ${PREFIX}"
echo "║  Jobs   : ${JOBS}"
echo "║  OS     : $(uname -s) $(uname -m)"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Download ──
if [[ "$SKIP_DOWNLOAD" == false ]]; then
  if [[ -d "$SOURCE_DIR" ]]; then
    echo "→ Removing old source directory..."
    rm -rf "$SOURCE_DIR"
  fi
  echo "→ Downloading Allegro ${ALLEGRO_TAG}..."
  mkdir -p "$SOURCE_DIR"
  if command -v curl &>/dev/null; then
    curl -fsSL "$ALLEGRO_URL" | tar xz --strip-components=1 -C "$SOURCE_DIR"
  elif command -v wget &>/dev/null; then
    wget -qO- "$ALLEGRO_URL" | tar xz --strip-components=1 -C "$SOURCE_DIR"
  else
    echo "ERROR: Neither curl nor wget found."
    exit 1
  fi
else
  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: --skip-download specified but $SOURCE_DIR does not exist."
    exit 1
  fi
  echo "→ Reusing existing source in $SOURCE_DIR"
fi

# ── Configure ──
BUILD_DIR="${SOURCE_DIR}/build"
mkdir -p "$BUILD_DIR"
echo "→ Configuring..."
cmake -S "$SOURCE_DIR" -B "$BUILD_DIR" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DWANT_NATIVE_DIALOG=ON \
  -DWANT_VIDEO=ON \
  -DWANT_IMAGE=ON \
  -DWANT_FONT=ON \
  -DWANT_TTF=ON \
  -DWANT_PRIMITIVES=ON \
  -DWANT_AUDIO=ON \
  -DWANT_ACODEC=ON \
  -DWANT_COLOR=ON \
  -DWANT_MEMFILE=ON \
  -DWANT_EXAMPLES=OFF \
  -DWANT_DEMO=OFF \
  -DWANT_TESTS=OFF \
  "${CMAKE_EXTRA_FLAGS[@]}"

# ── Build & install ──
echo "→ Building (${JOBS} jobs)..."
cmake --build "$BUILD_DIR" --parallel "$JOBS"

echo "→ Installing to ${PREFIX}..."
cmake --install "$BUILD_DIR"

# ── Verify ──
PC_DIR=""
for d in "$PREFIX/lib/pkgconfig" "$PREFIX/lib64/pkgconfig"; do
  if [[ -f "$d/allegro-5.pc" ]]; then
    PC_DIR="$d"
    break
  fi
done

if [[ -z "$PC_DIR" ]]; then
  echo ""
  echo "⚠  WARNING: allegro-5.pc not found under ${PREFIX}."
  echo "   The lakefile may not discover this install automatically."
  echo "   Use: lake build -K allegroPrefix=${PREFIX}"
else
  echo ""
  echo "✓ Allegro ${ALLEGRO_VERSION} installed to ${PREFIX}"
  echo ""
  echo "  The lakefile will discover it automatically."
  echo "  Or explicitly:  lake build -K allegroPrefix=${PREFIX}"
  echo ""
  # Verify with pkg-config
  if command -v pkg-config &>/dev/null; then
    VER="$(PKG_CONFIG_PATH="$PC_DIR" pkg-config --modversion allegro-5 2>/dev/null || true)"
    if [[ -n "$VER" ]]; then
      echo "  pkg-config reports: allegro-5 version ${VER}"
    fi
  fi
fi

# ── Cleanup hint ──
echo ""
echo "  To reclaim disk space: rm -rf ${SOURCE_DIR}"
echo "  The installed tree (${PREFIX}) is all you need."
