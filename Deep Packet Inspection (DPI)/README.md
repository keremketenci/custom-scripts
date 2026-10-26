# DPI bypass scripts for Windows

🇹🇷 [Turkish version](README.tr.md)

Ready-made scripts for getting past DPI blocks (for example the Discord block in Turkey) on Windows 11, built on top of two well-known tools: **zapret** and **GoodbyeDPI**. Double-click to install, pick a setting from a menu, done. No command line needed.

## Which one should I use?

| | [zapret](zapret) | [GoodbyeDPI](goodbyedpi) |
|---|---|---|
| Websites (Discord, etc.) | ✅ | ✅ |
| Discord voice / video calls | ✅ always handled | ⚠️ only if your provider doesn't block the voice traffic itself |
| Bypass methods in the menu | 7 | 7–8 (two versions: original and a fork made for Turkey) |
| In our test (one Turkish connection, Oct 2026) | all 6 tested settings worked (TTL 5 was added later) | 3 of 7 (turkey), 3 of 6 (valdik) tested settings worked (TTL 7 was added later) |

**Not sure? Start with [zapret](zapret).** If it doesn't work on your connection, try [GoodbyeDPI](goodbyedpi).

## What the scripts do

Both tools come with the same set of scripts:

- **Two modes**
  - **custom:** only the sites in a list (every Discord domain by default). Installed as a Windows service, starts automatically on every boot.
  - **global:** all traffic on the PC. Runs only while its window is open; close the window and it stops.
- **Settings menu:** blocking differs between internet providers, so the installer offers several bypass methods. If a site doesn't open, run the installer again and pick the next number.
- **English / Turkish:** the installer asks for the language first (English by default).
- **One tool at a time:** installing one tool's custom (or global) mode removes the other tool's, so they never process the same traffic twice.
- **Works with newer versions:** the scripts check the files and settings of the tool version they find and tell you clearly if something isn't supported.

## Quick start

1. Open [Releases](https://github.com/keremketenci/custom-scripts/releases) and download `zapret.zip` or `goodbyedpi.zip` from the newest **DPI bypass scripts** release. You only need one; not sure → zapret. Before extracting, unblock the zip as described in [If Windows blocks the scripts](https://github.com/keremketenci/custom-scripts#if-windows-blocks-the-scripts) in the main README, then extract it.
2. Open the extracted [zapret](zapret) or [goodbyedpi](goodbyedpi) folder and follow its README. In short: copy `custom-files` into the tool's folder and double-click `service_custom_create.cmd`.

## Folder layout

```
zapret\
├─ custom-files\                 ← the scripts
├─ zapret-win-bundle-master\     ← zapret itself
├─ zapret-win-bundle-master.zip  ← untouched original
└─ README.md
goodbyedpi\
├─ turkey\                       ← GoodbyeDPI-Turkey fork + its scripts
├─ valdik\                       ← original GoodbyeDPI + its scripts
└─ README.md
```

## Antivirus warnings

Both tools work by intercepting network packets with the WinDivert driver, which antiviruses often flag as a false positive. If yours deletes or blocks files, add the tool's folder and its `C:\ProgramData\...` folder (named in each README) to the exclusions.

## Credits

The bypass tools themselves are made by others; this repository only adds the install scripts and guides around them. The included binaries are unmodified copies from their official releases, and their licenses are in their folders.

- [zapret](https://github.com/bol-van/zapret) / [zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle) by bol-van
- [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) by ValdikSS
- [GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) by cagritaskn
- [WinDivert](https://github.com/basil00/WinDivert) by basil00

Use at your own risk, and check the laws in your country.
