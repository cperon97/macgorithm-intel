# Third-party components

The DMG published in the GitHub Releases redistributes the following components. License texts are in `licenses/` (also copied inside the app, in `Contents/Resources/licenses`).

| Component | Version | License | Source |
|---|---|---|---|
| Flowgorithm (Windows executable, unmodified) | 4.5 | Freeware © Devin Cook — [EULA](licenses/Flowgorithm-EULA.pdf): free to use, no commercial redistribution | https://www.flowgorithm.org |
| Wine (Gcenx macOS build) | 11.18 | LGPL 2.1 or later | https://github.com/Gcenx/macOS_Wine_builds/releases/tag/11.18 — source: https://gitlab.winehq.org/wine/wine/-/tags/wine-11.18 |
| Modified `comdlg32.dll`, `gdi32.dll` | Wine 11.18 + `patches/` | LGPL 2.1 or later | tag `wine-11.18` (commit `7b3fff76fa5178f6ce0141b2c776afa2a822f101`) + `patches/`, rebuilt with `scripts/build-dlls.sh` |
| Wine Mono | 11.3.0 (x86) | MIT / LGPL / others (see `licenses/WineMono-COPYING`) | https://github.com/wine-mono/wine-mono/releases/tag/wine-mono-11.3.0 |
| Libraries bundled in the Gcenx Wine package | — | various (FreeType, GnuTLS, MoltenVK, SDL2, libxml2, ICU, …) | see the `wine-devel-11.18-osx64.tar.xz` package and https://github.com/Gcenx/macports-wine |

The launcher (`launcher/Launcher.swift`) and the file panel (`launcher/FilePanel.swift`) are part of this repository (MIT license, `LICENSE`).
