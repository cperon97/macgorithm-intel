#!/bin/bash
# Builds only the modified DLLs (x86_64) from Wine 11.18 + patches/:
#  comdlg32.dll (native macOS Open/Save panels), gdi32.dll (font fallback for Thai).
# The engine stays the official Gcenx build (same version 11.18): only these DLLs are replaced.
source "$(dirname "$0")/common.sh"
TC="$WORK/toolchain"
if [ ! -x "$TC/bin/x86_64-w64-mingw32-clang" ]; then
  f=$(fetch "$LLVM_MINGW_URL" "$LLVM_MINGW_SHA"); rm -rf "$TC"; mkdir -p "$TC"; tar -xf "$f" -C "$TC" --strip-components=1
fi
brew list bison >/dev/null 2>&1 || brew install bison flex
export PATH="/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/flex/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$TC/bin"
SRC="$WORK/wine-src"
if [ ! -d "$SRC/.git" ]; then
  git init -q "$SRC"; git -C "$SRC" remote add origin "$WINE_SRC_REPO"
  git -C "$SRC" fetch -q --depth 1 origin "$WINE_SRC_COMMIT"; git -C "$SRC" checkout -q FETCH_HEAD
fi
git -C "$SRC" diff --quiet && for p in "$ROOT"/patches/*.patch; do echo ">> patch $(basename "$p")"; git -C "$SRC" apply "$p"; done
BUILD="$WORK/wine-build"; mkdir -p "$BUILD"; cd "$BUILD"
[ -f Makefile ] || "$SRC/configure" --host=x86_64-apple-darwin --enable-archs=x86_64 --without-x --disable-tests \
    --without-freetype --without-gnutls --without-sdl --without-vulkan --without-usb --without-pcap --without-cups \
    --without-gstreamer --without-krb5 --without-netapi --without-opencl --without-pcsclite --without-v4l2 \
    CC="clang -arch x86_64" > configure.log 2>&1 || { tail -20 configure.log; exit 1; }
DLLS="comdlg32 gdi32"
make -j"$(sysctl -n hw.ncpu)" $(for d in $DLLS; do echo dlls/$d/x86_64-windows/$d.dll; done) > make.log 2>&1 || { tail -30 make.log; exit 1; }
mkdir -p "$WORK/out"; for d in $DLLS; do cp dlls/$d/x86_64-windows/$d.dll "$WORK/out/"; done
echo "OK: $WORK/out ($DLLS)"
