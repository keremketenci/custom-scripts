# custom-scripts

🇹🇷 [Turkish version](README.tr.md)

A collection of ready-made scripts and setups. Each project lives in its own folder, works independently of the others and has its own README with step-by-step instructions.

## Projects

| Project | What it does | Download | Platform |
|---|---|---|---|
| [Deep Packet Inspection (DPI)](Deep%20Packet%20Inspection%20%28DPI%29) | Get past DPI blocks (e.g. the Discord block in Turkey) with zapret or GoodbyeDPI. Double-click installers, a settings menu for different internet providers, English / Turkish. | `zapret.zip` or `goodbyedpi.zip` from the newest **DPI bypass scripts** release | Windows 11 |
| [Default Audio Device Guard](default-audio-device-guard) | Stops Windows from switching your default audio devices on its own. | `DefaultAudioDeviceGuard.zip` | Windows 10 / 11 |
| [Discord Screen Share Echo Fix](discord-screenshare-echo-fix) | Fixes the echo viewers hear when you share your screen with sound in Discord while using a virtual audio mixer. | `DiscordScreenShareEchoFix.zip` | Windows 10 / 11 |

## How to use

1. Open [Releases](https://github.com/keremketenci/custom-scripts/releases) and download the zip of the project you need from its newest release (see the table above). Each zip contains only that project.
2. Before extracting, right-click the zip → **Properties** → tick **Unblock** → **OK** (see [below](#if-windows-blocks-the-scripts)), then extract it.
3. Follow the README inside the extracted folder.

After installing, you can delete the extracted folder: every project copies what it needs to an install folder on your PC, including its own uninstaller. The project's README says where.

## If Windows blocks the scripts

Windows marks files downloaded from the internet, and **Smart App Control** or SmartScreen may then refuse to run the scripts (*"Smart App Control blocked a file that may be unsafe"*). Remove the mark from the zip **before** extracting it:

1. Right-click the downloaded zip → **Properties**.
2. At the bottom of the **General** tab, tick **Unblock** → **OK**. (No Unblock checkbox? Then the file isn't marked; just continue.)
3. Extract the zip. The extracted files won't be blocked.

### Already extracted without unblocking?

The extracted files carry the mark too. Two ways to fix it:

**Option A, extract again (easiest):**

1. Delete the extracted folder.
2. Do steps 1–2 above on the zip (**Properties** → **Unblock** → **OK**).
3. Extract the zip again.

**Option B, unblock the extracted folder (no re-extracting):**

1. Open the extracted folder.
2. Right-click an empty spot inside it → **Open in Terminal**.
3. Paste this line and press **Enter**:
   ```
   Get-ChildItem -Recurse | Unblock-File
   ```
4. Close the window. The scripts in this folder and all its subfolders will run now.

Don't turn Smart App Control off for this: on many Windows versions it can't be turned back on without reinstalling Windows.

## Third-party software

Some projects include programs made by others (always unmodified copies of their official releases). Their authors and licenses are listed in each project's README and folders.

Use at your own risk.
