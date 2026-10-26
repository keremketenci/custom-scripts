# Custom Zapret for Windows 11

🇹🇷 [Turkish version](README.tr.md)

A small set of ready-made scripts on top of [zapret-win-bundle](https://github.com/bol-van/zapret-win-bundle) for bypassing DPI blocks on Windows 11.

It has two modes:

| Mode | What it affects | How it runs |
|---|---|---|
| **zapret-custom** | Only the sites in `files\list-custom.txt` (Discord by default) + Discord voice chat | Windows service, **starts automatically** every time the PC boots |
| **zapret-global** | **All** traffic on the PC | Runs only while its terminal window is open. Close the window → it stops |

---

## Installation

### 0. (Optional, recommended) Get the latest zapret

This package already includes a `zapret-win-bundle-master` folder, so **you can skip this step** and it will work fine.

But zapret gets updated regularly (fixes, better bypass methods), and the included copy may be outdated by the time you get it. If you want the latest version:

1. Go to https://github.com/bol-van/zapret-win-bundle
2. Click **Code → Download ZIP**. Before extracting, unblock the zip as described in [If Windows blocks the scripts](https://github.com/keremketenci/custom-scripts#if-windows-blocks-the-scripts), then extract it.
3. Use that new `zapret-win-bundle-master` folder instead of the included one in the steps below.

> ℹ️ **The scripts adapt to newer versions:** they copy the DLLs and drivers with wildcards instead of exact names, skip filter files that a newer version no longer has (if the Discord voice filter is missing, you get a warning), and check with `winws --dry-run` that the version accepts the chosen setting **before** touching any service. If it doesn't, you're asked to pick another setting.
>
> ⚠️ **Remaining risk:** if a future zapret version drops `winws.exe` entirely (zapret2 / `winws2.exe` uses a different syntax) or rejects all the settings, the create scripts show an `ERROR:` message explaining this. In that case, just go back to the **included** `zapret-win-bundle-master` folder; the scripts were made for that version. The `zapret-win-bundle-master.zip` next to it is an untouched copy if you break the folder.

### 1. Copy the files

Copy **everything inside** the `custom-files` folder into:

```
zapret-win-bundle-master\zapret-winws
```

If Windows asks to replace any files, click **Replace**.

### 2. Install the services

Inside `zapret-win-bundle-master\zapret-winws`, **double-click** these and click **Yes** on the admin (UAC) prompt:

- `service_custom_create.cmd` → installs and starts **zapret-custom**. From now on it runs automatically on every boot. Nothing else to do.
- `service_global_create.cmd` → installs **zapret-global** (does not start it, it is only started manually — see below).

Both first ask for the **language** (`1) English  2) Turkce`) and then show a **settings menu**. If you don't know what to pick, **just press Enter** both times: English and the default setting. **On Superonline, type `2` in the settings menu.** Your choices are saved (`language.txt`, `profile.txt`) and come up as the default next time (global included). The remove scripts and the global window use the saved language without asking. To change only the language, double-click `select-language.cmd`. (`select-profile.cmd` is only used by the create scripts; opening it directly just tells you that.) Your choice is saved and comes up as the default next time (global included). If a site won't open, see *Troubleshooting* below.

When you see `Installed.` / `Zapret Global service created.`, press any key to close the window. If something goes wrong, you'll see a message starting with `ERROR:` explaining what to do.

> ℹ️ **Together with GoodbyeDPI:** if both run at once, sites may stop opening, so only one tool can be installed per mode. `service_custom_create.cmd` **completely removes** GoodbyeDPI's custom service (`goodbyedpi-custom`, plus the old `GoodbyeDPI` / `GoodbyeDPI-discord` services), and `service_global_create.cmd` removes `goodbyedpi-global`. GoodbyeDPI's create scripts remove zapret the same way. Whichever you installed last is the one that stays.

### 3. After installing: you can delete the downloaded folder

The create scripts copy everything the services need to `C:\ProgramData`, and the services run from there. You don't need the downloaded folder anymore:

| Folder | What's in it |
|---|---|
| `C:\ProgramData\zapret-custom` | zapret-custom's files and its `uninstall.cmd` |
| `C:\ProgramData\zapret-global` | zapret-global's files, `run-zapret-global.bat` (starts global) and its `uninstall.cmd` |

Keep the downloaded folder only if you want to change the site list or the setting later: both are done by running `service_custom_create.cmd` again from it. (Deleted it already? Just download the zip again.)

---

## Usage

### zapret-custom (specific sites, always on)

Nothing to do — it's always running in the background.

To add/remove sites, edit `files\list-custom.txt` (one domain per line), e.g.:

```
discord.com
discord.gg
example.com
```

Subdomains are included automatically: `example.com` also covers `www.example.com`, `cdn.example.com`, etc.

Then run `service_custom_create.cmd` again — it copies the new list and restarts the service. (Editing `C:\ProgramData\zapret-custom\files\list-custom.txt` directly does nothing until the service restarts.)

> ℹ️ Discord voice traffic doesn't carry a site name, so it can't be picked by the list. That's why custom always handles Discord voice and STUN packets (some other voice/video apps use STUN too), regardless of the list.

### zapret-global (whole PC, on demand)

1. Double-click `run-zapret-global.bat` in `C:\ProgramData\zapret-global` (the one in the downloaded folder does the same).
2. Click **Yes** on the admin (UAC) prompt.
3. A terminal window opens and says the service is running.
4. **Keep the window open** while you need it (you can minimize it).
5. To stop it, just **close the window** (or press `Ctrl+C`). The service stops automatically.

While global is on, zapret-custom (and goodbyedpi-custom, if installed) is paused (so the same traffic isn't processed twice) and it starts again automatically when you close the window. It won't start while goodbyedpi-global is running.

---

## Uninstall

Double-click the `uninstall.cmd` of what you want to remove (it asks for admin permission):

- `C:\ProgramData\zapret-custom\uninstall.cmd` → removes zapret-custom
- `C:\ProgramData\zapret-global\uninstall.cmd` → removes zapret-global

Still have the downloaded folder? `service_custom_remove.cmd` and `service_global_remove.cmd` there do the same.

They remove the service and its folder in `C:\ProgramData`. The WinDivert driver stays loaded until you restart the PC, so its `WinDivert64.sys` may be left in the folder; restart and delete what's left.

---

## Troubleshooting

- **"Smart App Control blocked a file that may be unsafe" / the scripts won't open** → Windows blocks files downloaded from the internet. See [If Windows blocks the scripts](https://github.com/keremketenci/custom-scripts#if-windows-blocks-the-scripts) in the main README.
- **Antivirus deletes / blocks `winws.exe` or `WinDivert`** → add the `zapret-win-bundle-master`, `C:\ProgramData\zapret-custom` and `C:\ProgramData\zapret-global` folders to your antivirus exclusions. It's a false positive (it intercepts network packets, which antiviruses don't like).
- **Says "The WinDivert driver couldn't be loaded" (error 1058)** → it's not an antivirus problem, adding exclusions won't help. Restart the PC and run the create script again. If it keeps happening, remove other DPI tools (other zapret packages, GoodbyeDPI) or check your anti-cheat (Vanguard, FACEIT).
- **Global window says "service not found"** → run `service_global_create.cmd` first.
- **"This zapret version doesn't accept the chosen setting"** → pick another number. If it accepts none of them, use the included `zapret-win-bundle-master`.
- **"WARNING: ... Discord voice may not work"** → your zapret version has no Discord voice filter. Web still works; for voice, use the included `zapret-win-bundle-master`.
- **A site still doesn't open** → check that it's in `list-custom.txt`, then try another setting as described below.
- **Check if the services exist / are running** → press `Win + R`, type `services.msc`, look for `zapret-custom` and `zapret-global`.

### If a site won't open: try another setting

What bypasses the block depends on your internet provider, so the default may not work on yours. That's why the create scripts come with ready-made alternatives:

1. Run `service_custom_create.cmd` again.
2. Type the **next number** in the menu (e.g. `2`) and press Enter. The service is reinstalled with the new setting in a few seconds.
3. Test the site. Restarting the browser or refreshing with `Ctrl+F5` helps. If it still doesn't open, go back to step 1 and try the next number.
4. Once you find one that works, there's nothing else to do; the choice is saved. When installing global (`service_global_create.cmd`), just press Enter in the menu and the same setting is used.

| | Setting | What it does |
|---|---|---|
| 1 | fake, TTL 5 (default) | Fake packet that expires after 5 hops. Works on Türk Telekom and most providers |
| 2 | fake, TTL 7 | Same, expires after 7 hops. **Superonline users: pick this one** |
| 3 | fake, auto TTL | Same, but picks the TTL for each site automatically. Try this if neither 1 nor 2 works |
| 4 | fake, md5sig | Corrupts the fake packet a different way |
| 5 | fake, badseq | Corrupts the fake packet a different way |
| 6 | hostfakesplit, md5sig | Splits the site name and inserts a fake one |
| 7 | multidisorder | Sends no fake packets; splits the packet and sends the pieces out of order |

The menu setting only affects websites (TCP 80/443). The Discord voice setting stays the same whatever you pick.

Blocking differs between providers, so on yours some settings may not work; that's why there are several. The TTLs for 1 and 2 come from what works with GoodbyeDPI on these providers. Settings 2–7 all opened Discord in our test on one Turkish connection (October 2026).

### If none of them work: blockcheck

If none of the menu settings work, to find what works on your connection:

1. Stop both services first (close the global window, stop `zapret-custom` in `services.msc`).
2. Run `zapret-win-bundle-master\blockcheck\blockcheck.cmd` and enter the site you want to test (e.g. `discord.com`).
3. When it finishes, the working methods are listed at the end under `* SUMMARY`. Pick a line that starts with `curl_test_https_tls12` (HTTPS) and copy the part from the first `--dpi-desync` to the end of the line (leave out `--wf-l3` and `--wf-tcp`).
4. Open `select-profile.cmd` in Notepad and paste it on one of the `PROFILE_ARGS=` lines, replacing the setting there. For example, to put it on number 7:
   ```
   if "%SEL%"=="7" set "PROFILE_ARGS=--dpi-desync=fakedsplit --dpi-desync-fooling=md5sig --dpi-desync-split-pos=1"
   ```
5. Run `service_custom_create.cmd` and pick that number. The script checks that zapret accepts it before installing.
