Discord Screen Share Echo Fix

Fixes the doubled / echoing audio your viewers hear when you share your screen with sound in Discord while using a virtual audio mixer such as SteelSeries Sonar or Elgato Wave Link.

With these mixers, Discord's own audio (your friends' voices) ends up on a device that the screen share captures, so everyone watching your stream hears themselves and each other twice. This script mutes Discord's audio session on the devices you choose, automatically, as soon as that session appears.

    One file, no extra tools (no SoundVolumeView, no installs)
    Interactive setup: lists your audio devices, you pick the ones to fix
    Runs hidden in the background and starts automatically at logon
    Event driven: it waits for Windows audio notifications instead of polling, so it uses no CPU while idle

Requirements

    Windows 10 (1809 or newer) or Windows 11
    Windows PowerShell 5.1 (built into Windows)

Install

    Download DiscordScreenShareEchoFix.zip from the newest DiscordScreenShareEchoFix release on the Releases page (https://github.com/keremketenci/custom-scripts/releases). Before extracting, unblock it as described in "If Windows blocks the scripts" in the main README (https://github.com/keremketenci/custom-scripts#if-windows-blocks-the-scripts), then extract it and keep the files together.

    In Discord, start a screen share with sound. The audio session that causes the problem only exists while you are sharing, so it has to be running for the device list to show it.

    Double-click Setup.cmd. It runs the script with -ExecutionPolicy Bypass for this one run only, so you don't have to change any PowerShell setting. (Same thing by hand: powershell -ExecutionPolicy Bypass -File .\DiscordScreenShareEchoFix.ps1)

    Pick the devices to mute. Only playback devices are listed (muting Discord on a microphone would mute you). Devices that currently carry Discord audio are highlighted:

      1) Speakers (Realtek(R) Audio)
      2) Headphones (SteelSeries Sonar - Gaming)
      3) Headphones (SteelSeries Sonar - Chat)   <- Discord audio here (0/2 muted)
    Device numbers to mute (e.g. 2,5), R = refresh, Q = quit: 3

    Don't pick the device you listen to Discord on, or you won't hear your friends. Pick the one the screen share picks up your friends' voices from.

    Press R to refresh the list if you started the screen share after opening the setup.

    Confirm. The script copies itself to %LOCALAPPDATA%\DiscordScreenShareEchoFix, creates a scheduled task named DiscordScreenShareEchoFix and starts it. Keep the downloaded folder if you want to change devices later. An Uninstall.cmd is also placed in the install folder.

Done. From now on, every time you share your screen, Discord's session on those devices is muted within a second, including after restarting Discord or rebooting your PC.
Change devices

Double-click Setup.cmd again. It shows your current selection. Pick new devices, or press Enter to keep the current ones. The scheduled task is deleted and created again each time.
Uninstall

Double-click Uninstall.cmd. If you no longer have the downloaded folder, use the one in the install folder: press Win + R, paste %LOCALAPPDATA%\DiscordScreenShareEchoFix and double-click Uninstall.cmd there.

This removes the scheduled task and the installed files, and unmutes Discord on the selected devices again (Windows remembers the mute per app, so it would stay otherwise). Discord has to be running and in a voice call for that, because Windows only shows its audio sessions while it uses the devices; if it isn't, the uninstall warns you first.
Other options
Command	What it does
-List	Lists audio devices and the Discord sessions on them
-Once	Mutes the selected devices once and exits
-Run	Background mode (what the scheduled task runs). Run it in a normal window to see the log
-Devices 'a','b'	Used with -Run / -Once: overrides the saved devices (part of the name is enough)
How it works

The script uses the Windows Core Audio API (embedded C# compiled at runtime with Add-Type):

    It registers for new audio session notifications on the selected devices, and for device added, removed or state changed notifications. The second kind lets it pick up a headset that is plugged in later, or a virtual device that loads late during startup.
    When Windows reports an event, it checks the selected devices and mutes any unmuted session that belongs to a Discord* process. While nothing happens, the thread just waits.
    The scheduled task runs the script at logon as your user, through conhost.exe --headless, so no window is shown, even when Windows Terminal is the default terminal. The task has no time limit and restarts if the script fails.

Settings are stored in %LOCALAPPDATA%\DiscordScreenShareEchoFix\config.json.
Troubleshooting

    Check that it is running: Get-ScheduledTask DiscordScreenShareEchoFix | Select State should show Running.
    Watch it work: stop the task with Stop-ScheduledTask DiscordScreenShareEchoFix. Then run the installed script with -Run in a normal PowerShell window and start a screen share. You should see Watching: ... and Muted: ... lines. Close the window and start the task again with Start-ScheduledTask DiscordScreenShareEchoFix.
    Wrong device / nothing gets muted: run the setup again while screen sharing and pick the highlighted device.
    Unmuted it by hand? It stays unmuted until the next screen share or a device change. The script does not fight you.
    Your microphone got muted (older versions only): older versions also listed microphones, and picking one muted Discord's microphone input. Join a voice call in Discord and run Setup.cmd with the new version: it unmutes Discord on those microphones again before showing the list.
