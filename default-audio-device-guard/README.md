# Default Audio Device Guard

Stops Windows from switching your default audio devices on its own.

Plug in a headset, reconnect a Bluetooth device, update a driver, or let a virtual mixer (Elgato Wave Link, SteelSeries Sonar, ...) load its devices at logon, and Windows often moves your sound or your microphone to the wrong device. This script sets the devices you chose back as the defaults within about a second.

You can still change a default yourself whenever you want. The script notices that the change was deliberate and guards your new choice from then on (see [How it tells your changes apart](#how-it-tells-your-changes-apart)).

It can guard each of these four separately (the same ones you see in the Sound control panel):

| Default | What uses it |
|---|---|
| **Default playback** | Most apps: games, browsers, music |
| **Communication playback** | Voice apps: Discord, Teams, Zoom |
| **Default recording** | Most apps that use a microphone |
| **Communication recording** | Voice apps: Discord, Teams, Zoom |

- One file, no extra tools, nothing to install besides the script itself
- Interactive setup: lists your audio devices, you pick the ones to guard
- Runs hidden in the background and starts automatically at logon
- Event driven: it waits for Windows audio notifications instead of polling, so it uses no CPU while idle

## Requirements

- Windows 10 (1809 or newer) or Windows 11
- Windows PowerShell 5.1 (built into Windows)

## Install

1. Download `DefaultAudioDeviceGuard.zip` from the newest **DefaultAudioDeviceGuard** release on the [Releases](https://github.com/keremketenci/custom-scripts/releases) page. Before extracting, unblock it as described in [If Windows blocks the scripts](https://github.com/keremketenci/custom-scripts#if-windows-blocks-the-scripts), then extract it and keep the files together.
2. Connect your audio devices and start the apps that create virtual devices (e.g. Wave Link), so they show up in the list.
3. Double-click `Setup.cmd`. It runs the script with `-ExecutionPolicy Bypass` for this one run only, so you don't have to change any PowerShell setting.
4. The setup lists your playback and recording devices and shows which ones are the defaults now:
   ```
   Playback devices
     1) Speakers (Realtek(R) Audio)   <- default now
     2) Headphones (USB Headset)   <- communication now

   Recording devices
     1) Microphone (USB Headset)   <- default now, communication now
   ```
5. Answer the four questions with a number from the list:
   ```
   Default playback [not guarded]: 1
   Communication playback [not guarded]: 2
   Default recording [not guarded]: 1
   Communication recording [not guarded]: 0
   ```
   - `0` = don't guard this one (Windows decides, as usual)
   - `Enter` = keep the current choice
   - `R` = refresh the list (e.g. after plugging in a device), `Q` = quit
6. Confirm. The script copies itself to `%LOCALAPPDATA%\DefaultAudioDeviceGuard`, creates a scheduled task named `DefaultAudioDeviceGuard` and starts it. That folder has everything it needs, including an `Uninstall.cmd`, so you can delete the downloaded folder. Keep it only if you want to run the setup again later.

Done. From now on the guarded devices are set back as the defaults whenever Windows switches them, including after rebooting your PC.

A guarded device that isn't connected (e.g. a headset that is switched off) is simply skipped. It becomes the default again as soon as you connect it.

## How it tells your changes apart

Windows doesn't say *who* changed a default device, so the script looks at *when* it happened:

- **Within 10 seconds after a device was added, removed, enabled or disabled** → Windows reacting to that device (headset plugged in, Bluetooth reconnected, virtual devices loading at logon). The change is **set back**.
- **Any other time** → a deliberate change: you picked another device in the Sound settings, the taskbar, your mixer app, EarTrumpet, ... The change is **kept**, and the new device is guarded from then on. It is saved, so it stays your choice after a restart too.

Two things follow from this:

- Right after plugging in or connecting a device, wait about 10 seconds before changing a default yourself, otherwise it is set back.
- An app that changes the default on its own *without* a device change (rare) is treated like you and kept. To undo it, pick your device again.

## Change devices

Change it the normal way in Windows: the script keeps your new choice.

To change several at once, or to stop guarding one, double-click `Setup.cmd` again. It shows the current choices in brackets. Pick new devices, `0` to stop guarding one, or press `Enter` to keep it. The scheduled task is deleted and created again each time.

## Uninstall

Double-click `Uninstall.cmd`. If you no longer have the downloaded folder, use the one in the install folder: press `Win + R`, paste `%LOCALAPPDATA%\DefaultAudioDeviceGuard` and double-click `Uninstall.cmd` there.

This removes the scheduled task and the installed files. Your current default devices stay as they are.

## Using it with Elgato Wave Link or SteelSeries Sonar

These mixers can set the default devices themselves, but not always all four (Wave Link, for example, doesn't keep the communication devices). Guard the ones the mixer doesn't handle, or all four with the same devices the mixer uses. If the mixer sets a different device at logon after its devices have loaded, that counts as a deliberate change and is kept; pick the same devices in both to avoid that.

## Other options

| Command | What it does |
|---|---|
| `-List` | Lists audio devices, the current defaults and the guarded devices |
| `-Once` | Sets the guarded devices once and exits |
| `-Run` | Background mode (what the scheduled task runs). Run it in a normal window to see the log |

## How it works

The script uses the Windows Core Audio API (embedded C# compiled at runtime with `Add-Type`):

- It registers for device notifications: a device being added, removed or enabled/disabled, and a different default device being chosen.
- When Windows reports an event, it waits a second (so a burst of events, e.g. many virtual devices loading at logon, becomes one check). Then it sets every guarded default that changed back, or keeps the change if it was deliberate (see above). While nothing happens, the thread just waits.
- At startup it sets everything back once, since whatever changed while it wasn't running (e.g. during boot) wasn't done through it.
- A device is found by its Windows device ID, or by its exact name if the ID changed (e.g. a USB headset plugged into another port).
- The default device is set the same way the Sound control panel does it: *Default device* sets the console and multimedia roles, *Default communication device* the communications role.
- The scheduled task runs the script at logon as your user, through `conhost.exe --headless`, so no window is shown, even when Windows Terminal is the default terminal. The task has no time limit and restarts if the script fails.

Settings are stored in `%LOCALAPPDATA%\DefaultAudioDeviceGuard\config.json`, and updated when you change a default yourself.

## Troubleshooting

- **Check that it is running:** `Get-ScheduledTask DefaultAudioDeviceGuard | Select State` should show `Running`.
- **Watch it work:** stop the task with `Stop-ScheduledTask DefaultAudioDeviceGuard`. Then run the installed script with `-Run` in a normal PowerShell window and plug in a device or change a default. You should see `Guarding ...`, `... set back: ...` or `... changed by hand, now guarding: ...` lines. Close the window and start the task again with `Start-ScheduledTask DefaultAudioDeviceGuard`.
- **A device isn't in the list:** connect it (or start the app that creates it) and press `R` in the setup.
- **My own change was set back:** you probably changed it within 10 seconds of a device being connected. Wait a moment and change it again.
- **Windows still switched a device and it wasn't set back:** the device took longer than 10 seconds to make itself the default (some Bluetooth devices do), so it counted as deliberate. Pick your device again.
