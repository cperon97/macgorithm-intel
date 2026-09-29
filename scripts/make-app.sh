#!/bin/bash
# Assembles Flowgorithm.app (Intel x86_64; via Rosetta 2 on Apple Silicon) and the DMG in dist/.
# Requires: scripts/build-dlls.sh (work/out/*.dll).
source "$(dirname "$0")/common.sh"

BUNDLE_ID=com.macgorithm.flowgorithm.intel
[ -f "$WORK/out/comdlg32.dll" ] && [ -f "$WORK/out/gdi32.dll" ] || { echo "!! run scripts/build-dlls.sh first" >&2; exit 1; }
STAGE="$WORK/stage"; APP="$STAGE/Flowgorithm.app"
C="$APP/Contents"; RES="$C/Resources"
ENGINE="$RES/Engine/Flowgorithm.app"; EW="$ENGINE/Contents/Resources/wine"
rm -rf "$STAGE"; mkdir -p "$C/MacOS" "$RES/Flowgorithm" "$ENGINE/Contents/MacOS" "$ENGINE/Contents/Resources"

subst() { sed "s#@VERSION@#$APP_VERSION#g; s#@MIN_MACOS@#$MIN_MACOS#g; s#@BUNDLE_ID@#$BUNDLE_ID#g; s#@PREFIX@#prefix-intel#g" "$1" > "$2"; }

# --- Wine 11.18 engine (Gcenx) in the nested bundle: Flowgorithm's name and icon in the Dock
f=$(fetch "$WINE_URL" "$WINE_SHA"); rm -rf "$WORK/gcenx"; mkdir -p "$WORK/gcenx"; tar -xf "$f" -C "$WORK/gcenx"
cp -R "$WORK/gcenx/Wine Devel.app/Contents/Resources/wine" "$EW"
f=$(fetch "$MONO_URL" "$MONO_SHA"); mkdir -p "$EW/share/wine/mono"; tar -xf "$f" -C "$EW/share/wine/mono"
cp "$WORK/out/comdlg32.dll" "$WORK/out/gdi32.dll" "$EW/lib/wine/x86_64-windows/"   # native dialogs, Thai font fallback
ln -s ../Resources/wine/lib/wine/x86_64-unix/wine "$ENGINE/Contents/MacOS/wine"
subst "$ROOT/resources/Engine-Info.plist.in" "$ENGINE/Contents/Info.plist"
cp "$ROOT/resources/Flowgorithm.icns" "$ENGINE/Contents/Resources/"

# --- launcher and file panel (universal: x86_64 for Intel Macs, native arm64 on Apple Silicon)
build_universal() {  # $1=source $2=output
  swiftc -O -target "x86_64-apple-macos$MIN_MACOS" -Xlinker -weak_framework -Xlinker UniformTypeIdentifiers -o "$2.x86_64" "$1"
  swiftc -O -target arm64-apple-macos11.0 -o "$2.arm64" "$1"
  lipo -create "$2.x86_64" "$2.arm64" -output "$2"; rm "$2.x86_64" "$2.arm64"
}
build_universal "$ROOT/launcher/Launcher.swift" "$C/MacOS/Flowgorithm"
FP="$RES/FilePanel.app/Contents"; mkdir -p "$FP/MacOS" "$FP/Resources"
build_universal "$ROOT/launcher/FilePanel.swift" "$FP/MacOS/FilePanel"
subst "$ROOT/resources/FilePanel-Info.plist.in" "$FP/Info.plist"
cp "$ROOT/resources/Flowgorithm.icns" "$FP/Resources/"

# --- Flowgorithm (official, unmodified executable), metadata, licenses
f=$(fetch "$FLOWGORITHM_URL" "$FLOWGORITHM_SHA"); unzip -q -o "$f" -d "$RES/Flowgorithm"
subst "$ROOT/resources/Info.plist.in" "$C/Info.plist"
cp "$ROOT/resources/Flowgorithm.icns" "$ROOT/resources/NOTICE.txt" "$RES/"
cp -R "$ROOT/licenses" "$RES/licenses"
cp "$ROOT/LICENSE" "$RES/licenses/Wrapper-LICENSE.txt"

# --- ad-hoc signing (each Mach-O on its own, keeping any entitlements), then the bundles
xattr -cr "$APP"
find "$EW" -type f \( -perm +111 -o -name '*.so' -o -name '*.dylib' \) -print0 | while IFS= read -r -d '' f; do
  if file -b "$f" | grep -q Mach-O; then codesign -f -s - --preserve-metadata=entitlements "$f" 2>/dev/null || codesign -f -s - "$f"; fi
done
codesign -f -s - "$RES/FilePanel.app"
codesign -f -s - "$APP"
codesign --verify --strict "$APP" && echo ">> signature OK"

# --- DMG: drag Flowgorithm to Applications
DMG="$ROOT/dist/Flowgorithm-$APP_VERSION-Intel.dmg"; mkdir -p "$ROOT/dist"; rm -f "$DMG"
ln -s /Applications "$STAGE/Applications"
hdiutil create -quiet -volname "Flowgorithm $APP_VERSION" -srcfolder "$STAGE" -fs HFS+ -format ULMO "$DMG"
rm "$STAGE/Applications"
( cd "$(dirname "$DMG")" && shasum -a 256 "$(basename "$DMG")" | tee "$(basename "$DMG").sha256" )
echo "OK: $DMG"
