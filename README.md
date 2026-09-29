# Macgorithm (Intel) — Flowgorithm for macOS on Intel (x86_64)

An **unofficial** wrapper that runs [Flowgorithm](https://www.flowgorithm.org) 4.5 (the official, unmodified Windows executable) on macOS with Wine.
This x86_64 version runs natively on **Intel Macs** and on Apple Silicon Macs **through Rosetta 2**.

> Flowgorithm is freeware by Devin Cook. This project is not affiliated with or endorsed by the author.
> On Macs with Apple chips the native version [macgorithm](https://github.com/cperon97/macgorithm) is recommended (macOS 14+, no Rosetta).

## Download and installation

1. Download `Flowgorithm-4.5-Intel.dmg` from the [latest release](https://github.com/cperon97/macgorithm-intel/releases/latest) (its SHA-256 checksum is attached to the release as `Flowgorithm-4.5-Intel.dmg.sha256`).
2. Open the DMG and **drag Flowgorithm into the Applications folder**.
3. On first launch macOS blocks the app: follow [Unblocking the app on first launch](#unblocking-the-app-on-first-launch) (needed only once).
4. "Setting up Flowgorithm…" appears for a few seconds. Later launches are immediate.

**Requirements:** macOS **10.15 Catalina or later**.
On Apple Silicon, Rosetta 2 is required; if it is not installed:

```bash
softwareupdate --install-rosetta --agree-to-license
```

Tested on Apple Silicon (macOS 26.5.1, through Rosetta). **Not yet tested on a real Intel Mac.**
Note: Apple has announced that macOS 26 is the last release for Intel Macs and that Rosetta 2 will remain fully available through macOS 27.

## Unblocking the app on first launch

The app is not (yet) signed with an Apple Developer certificate or notarized by Apple. On first launch macOS therefore shows a warning such as *"Apple could not verify “Flowgorithm” is free of malware"* (or *"…is from an unidentified developer"*) and refuses to open it. You only need to unblock it **once**, in one of these ways.

**macOS 15 Sequoia and later**

1. Open Flowgorithm from the Applications folder. When the warning appears, click **Done** (not "Move to Trash").
2. Open **System Settings → Privacy & Security**.
3. Scroll down to the **Security** section: you will see *"“Flowgorithm” was blocked…"*. Click **Open Anyway**.
4. Confirm with your password or Touch ID, then click **Open** in the final dialog.

The **Open Anyway** button stays visible for about an hour after the blocked launch: if you can't find it, open Flowgorithm again and go back to System Settings.

**macOS 10.15 Catalina – 14 Sonoma**

In the Applications folder, right-click (or Control-click) Flowgorithm → **Open**, then **Open** again in the dialog. Alternatively: **System Preferences / System Settings → Security & Privacy → General → Open Anyway**.

**Alternatively, from Terminal** (any macOS version): this removes the "quarantine" attribute macOS adds to files downloaded from the internet.

```bash
xattr -dr com.apple.quarantine /Applications/Flowgorithm.app
```

> **Why is this needed?** macOS opens apps without warnings only if they are notarized by Apple, a service reserved to members of the paid Apple Developer Program. This project's code is public and the DMG can be rebuilt with the scripts in this repository. To check that you downloaded the original file, compare the output of this command with the `Flowgorithm-4.5-Intel.dmg.sha256` file attached to the release:
>
> ```bash
> shasum -a 256 ~/Downloads/Flowgorithm-4.5-Intel.dmg
> ```

## Features

- Double-click **`.fprg`** files in the Finder to open them in Flowgorithm (even while it is already running).
- **Native macOS Open/Save panels** instead of the Windows ones.
- Flowgorithm's name and icon in the Dock and menu bar (not "wine").
- Readable UI in all 40 Flowgorithm languages (macOS system fonts as fallbacks).
- The small first-launch window and error messages follow the system language (English or Italian).

## Where your data lives / uninstalling

- Wine environment and settings: `~/Library/Application Support/Flowgorithm/prefix-intel`
- Diagnostic log: `~/Library/Logs/Flowgorithm.log`

To uninstall, delete `Flowgorithm.app` from Applications and the `~/Library/Application Support/Flowgorithm` folder.

## Building from source

Requires the Xcode Command Line Tools and Homebrew (`bison`, `flex`). Every input is verified against a pinned SHA-256 (`scripts/config.sh`).

```bash
scripts/build-dlls.sh   # builds only comdlg32.dll and gdi32.dll from Wine 11.18 with the patches in patches/
scripts/make-app.sh     # Wine 11.18 engine (Gcenx) + Wine Mono 11.3.0 x86 + launcher -> dist/*.dmg (published as Release assets)
```

## How it works

- Engine: the official Wine 11.18 x86_64 build for macOS ([Gcenx/macOS_Wine_builds](https://github.com/Gcenx/macOS_Wine_builds)), with only `comdlg32.dll` (patch 0005: native file panel) and `gdi32.dll` (patch 0004: Thai font fallback) replaced, rebuilt from the same 11.18 version.
- .NET runtime: Wine Mono 11.3.0 x86.
- Universal native Swift launcher (`launcher/`): receives `.fprg` files from the Finder and starts Flowgorithm through a nested "engine" bundle, so the process gets Flowgorithm's name and icon.

Details: [docs/TECHNICAL.md](docs/TECHNICAL.md). Licenses: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Licenses

- Code in this repository (launcher, scripts, documentation): [MIT](LICENSE).
- Wine patches (`patches/`): LGPL 2.1 or later, like Wine.
- **Flowgorithm** belongs to Devin Cook and is governed by its [EULA](licenses/Flowgorithm-EULA.pdf): freeware, free to use and install; **commercial redistribution is not allowed** (this package may not be sold or rented). By downloading and installing Flowgorithm you accept its EULA.
- Other components: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
