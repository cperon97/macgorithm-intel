# Technical notes — Flowgorithm x86_64 (Intel / Rosetta)

## Components

| | |
|---|---|
| Engine | Official Wine 11.18 x86_64 build for macOS (Gcenx), unmodified except for 2 DLLs |
| Rebuilt DLLs | `comdlg32.dll`, `gdi32.dll` from Wine 11.18 + `patches/` (llvm-mingw 20260922) |
| .NET | Wine Mono 11.3.0 x86 (in `share/wine/mono`, found by mscoree without an MSI install) |
| Launcher | Universal Swift binary: x86_64 (macOS 10.15+) + arm64 (macOS 11+) |

`Flowgorithm.exe` is AnyCPU (IL-only): on x86_64 Wine it runs as a 64-bit process.

## Patches (`patches/`)

| Patch | What it does |
|---|---|
| 0004 | Uniscribe (in gdi32): `ScriptShape` returns `USP_E_SCRIPT_NOT_IN_FONT` when the font has no glyphs for the run → Thai uses font linking instead of boxes |
| 0005 | comdlg32 (`IFileDialog::Show`, used by WinForms): when `MACGORITHM_FILE_PANEL` points to a helper, show the native `NSOpenPanel`/`NSSavePanel` through `__wine_unix_spawnvp`, set the result and call `OnFileOk`; otherwise use Wine's dialog |

The Apple Silicon version uses the same patches.

## App layout

```
Flowgorithm.app/Contents/
  MacOS/Flowgorithm                    Swift launcher (LSUIElement, receives .fprg files from the Finder)
  Resources/Engine/Flowgorithm.app/    "engine": nested bundle carrying Flowgorithm's name and icon
      Contents/MacOS/wine -> ../Resources/wine/lib/wine/x86_64-unix/wine
      Contents/Resources/wine/         Wine 11.18 + Wine Mono x86
  Resources/FilePanel.app/             native Open/Save panel helper
  Resources/Flowgorithm/Flowgorithm.exe
```

- Without the "engine" bundle the process showed up in the Dock as **"wine"** (verified with `lsappinfo`). Started through the symlink inside the nested bundle, AppKit associates it with that bundle: Flowgorithm's name and icon. (A bundle whose executable is a symlink cannot be signed on its own: it is sealed as a resource of the app.)
- The launcher stays alive (invisible) while any Flowgorithm window is open, to receive documents opened from the Finder; each document opens a new instance.
- On first launch it creates the prefix (`prefix-intel`) and sets up font fallbacks (`FontLink\SystemLink` to macOS system fonts). The `.reg` file is UTF-16LE with a BOM.

## Build notes

- flowgorithm.org serves an invalid TLS certificate: `scripts/common.sh` retries downloads without TLS verification, which is safe because every file is checked against the pinned SHA-256.
- The build was verified from a clean clone: the rebuilt DMG contains exactly the same files as the published one.
