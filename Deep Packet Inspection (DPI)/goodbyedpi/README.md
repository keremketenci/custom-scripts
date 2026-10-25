# Custom GoodbyeDPI for Windows 11

🇹🇷 [Turkish version](README.tr.md)

A small set of ready-made scripts on top of [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) for bypassing DPI blocks on Windows 11.

There are two GoodbyeDPI versions. **Pick one**:

| Folder | Version | Default settings |
|---|---|---|
| `turkey` | [GoodbyeDPI-Turkey](https://github.com/cagritaskn/GoodbyeDPI-Turkey) (0.2.3rc3), a fork of ValdikSS's tool made for Turkey | `-5` + DNS redirect. Has extra alternative settings (mainly for Superonline). |
| `valdik` | Original [ValdikSS GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI) (0.2.2) | `-5` + DNS redirect |

The scripts in both folders are the same. The only difference is the options in the settings menu shown during install (`select-profile.cmd`). They also use the same service names, so installing one replaces the other. Only one can be installed at a time.

Each version has two modes:

| Mode | What it affects | How it runs |
|---|---|---|
| **goodbyedpi-custom** | Only the sites in `list-custom.txt` (Discord by default) | Windows service, **starts automatically** every time the PC boots |
| **goodbyedpi-global** | **All** sites on the PC | Runs only while its terminal window is open. Close the window → it stops |

> ℹ️ With the menu options marked "+ DNS" (including the default), DNS requests are redirected to Yandex DNS (`77.88.8.8`, port 1253), so you don't need to change DNS in Windows settings. This redirect applies to the **whole PC**, regardless of the list.

> ⚠️ **About Discord voice:** the list covers every Discord domain (app, images, file uploads, voice servers, Activities, gift links...), but GoodbyeDPI can only modify web traffic (TCP) and DNS. Voice and video calls travel over UDP, which GoodbyeDPI can't touch. So voice works if your provider only blocks Discord's domain names, but not if it also blocks the voice traffic itself. If text works and voice gets stuck on "RTC Connecting", use [zapret](../zapret), which handles voice too.

---

## Installation

### 0. (Optional) Get the latest version

GoodbyeDPI is already included in the folders, so **you can skip this step**. If you want the latest version:

- Turkey: https://github.com/cagritaskn/GoodbyeDPI-Turkey/releases
- Valdik: https://github.com/ValdikSS/GoodbyeDPI/releases

Download and extract the zip, then use that folder instead of the included one in the steps below. It should contain `x86` and `x86_64` folders.

> ℹ️ **The scripts adapt to newer versions:** they find `goodbyedpi.exe` even if the zip extracts into an extra subfolder, copy the WinDivert files with wildcards instead of exact names, and check a few seconds after installing that the service is really running. GoodbyeDPI quits right away on a setting it doesn't support, so if that happens you get an `ERROR:` message telling you to pick another setting. The valdik menu only uses modes `-1` … `-6`, which every version since 0.2.2 supports.
>
> ⚠️ **Remaining risk:** if a future version renames `goodbyedpi.exe` or changes the `x86` / `x86_64` folder layout, the create scripts show an `ERROR:` message. In that case go back to the included folder. The `.zip` next to it is an untouched copy if you break the folder.

### 1. Copy the files

Copy **everything inside** your chosen version's `custom-files` folder into the GoodbyeDPI folder of the same version:

| Version | From | To |
|---|---|---|
| Turkey | `turkey\custom-files` | `turkey\goodbyedpi-0.2.3rc3-turkey` |
| Valdik | `valdik\custom-files` | `valdik\goodbyedpi-0.2.2` |

So `service_custom_create.cmd` should sit next to the `x86_64` folder.

> ℹ️ The create scripts copy the needed files to `C:\ProgramData\goodbyedpi-custom` and `C:\ProgramData\goodbyedpi-global`, and the services run from there. You can move the folder after installing, but keep it if you want to edit the site list or uninstall later.

### 2. Install the services

In the GoodbyeDPI folder, **double-click** these and click **Yes** on the admin (UAC) prompt:

- `service_custom_create.cmd` → installs and starts **goodbyedpi-custom**. From now on it runs automatically on every boot.
- `service_global_create.cmd` → installs **goodbyedpi-global**. It doesn't start it; global is only started manually (see below).

Both first ask for the **language** (`1) English  2) Turkce`) and then show a **settings menu**. If you don't know what to pick, **just press Enter** both times: English and the default setting. Your choices are saved (`language.txt`, `profile.txt`) and come up as the default next time (global included). The remove scripts and the global window use the saved language without asking. To change only the language, double-click `select-language.cmd`. (`select-profile.cmd` is only used by the create scripts; opening it directly just tells you that.) Your choice is saved and comes up as the default next time (global included). If a site won't open, see *Troubleshooting* below.

When you see `Installed.` / `GoodbyeDPI Global service created.`, press any key to close the window. If something goes wrong, you'll see a message starting with `ERROR:` explaining what to do.

> ℹ️ If the `GoodbyeDPI` or `GoodbyeDPI-discord` services from older scripts are installed, `service_custom_create.cmd` removes them automatically so they don't process the same traffic twice.

---

## Usage

### goodbyedpi-custom (specific sites, always on)

Nothing to do. It's always running in the background.

To add or remove sites, edit `list-custom.txt` (one domain per line), e.g.:

```
nonexistent.domain
discord.com
discord.gg
example.com
```

Leave the `nonexistent.domain` line at the top as it is.

Then run `service_custom_create.cmd` again. It copies the new list and restarts the service.

### goodbyedpi-global (whole PC, on demand)

1. Double-click `run-goodbyedpi-global.bat`.
2. Click **Yes** on the admin (UAC) prompt.
3. A terminal window opens and says the service is running.
4. **Keep the window open** while you need it (you can minimize it).
5. To stop it, just **close the window** (or press `Ctrl+C`). The service stops automatically.

While global is on, `goodbyedpi-custom` and `zapret-custom` are paused so the same traffic isn't processed twice. They start again automatically when you close the window.

---

## Using it together with zapret

GoodbyeDPI and zapret do the same job. If both run at once, sites may stop opening, so **only one tool can be installed per mode**:

- `service_custom_create.cmd` → **completely removes** zapret's custom service (`zapret-custom`), then installs itself. zapret's create script removes GoodbyeDPI's the same way.
- `service_global_create.cmd` → does the same on the global side (`zapret-global` ↔ `goodbyedpi-global`).
- Turkey and valdik already share service names, so installing one replaces the other.

So whichever tool's create script you ran last is the one that's installed. To switch back, just run the other tool's create script.

Custom and global can come from different tools (e.g. zapret custom, GoodbyeDPI global). When the global window opens, it pauses the running custom service and starts it again when closed.

---

## Uninstall

Double-click (it asks for admin permission):

- `service_custom_remove.cmd` → removes goodbyedpi-custom
- `service_global_remove.cmd` → removes goodbyedpi-global

These also delete the copies in `C:\ProgramData`. Turkey and valdik use the same service names, so it doesn't matter which folder you run them from.

---

## Troubleshooting

- **Antivirus deletes / blocks `goodbyedpi.exe` or `WinDivert`** → add the `goodbyedpi` folder, `C:\ProgramData\goodbyedpi-custom` and `C:\ProgramData\goodbyedpi-global` to your antivirus exclusions. It's a false positive; antiviruses don't like tools that intercept network packets.
- **Global window says "service not found"** → run `service_global_create.cmd` first.
- **"The service was created but isn't running" / "stopped right after starting"** → run the create script again and pick another setting; your GoodbyeDPI version may not support the chosen one. If none work, check your antivirus.
- **A site still doesn't open** → check that it's in `list-custom.txt`, then try another setting as described below.
- **The valdik service won't start (and antivirus isn't blocking it)** → valdik uses an old WinDivert driver (1.4) that Windows 11's *Core isolation / Memory integrity* may block. Use the turkey version; its driver is up to date.
- **Discord text works but voice is stuck on "RTC Connecting"** → your provider also blocks the voice traffic (UDP), which GoodbyeDPI can't modify. Use zapret.
- **Check if the services exist / are running** → press `Win + R`, type `services.msc`, look for `goodbyedpi-custom` and `goodbyedpi-global`.

### If a site won't open: try another setting

What bypasses the block depends on your internet provider, so the default may not work on yours. That's why the create scripts come with ready-made alternatives:

1. Run `service_custom_create.cmd` again.
2. Type the **next number** in the menu (e.g. `2`) and press Enter. The service is reinstalled with the new setting in a few seconds.
3. Test the site. Restarting the browser or refreshing with `Ctrl+F5` helps. If it still doesn't open, go back to step 1 and try the next number.
4. Once you find one that works, there's nothing else to do; the choice is saved. When installing global (`service_global_create.cmd`), just press Enter in the menu and the same setting is used.

| | Turkey menu | Valdik menu |
|---|---|---|
| 1 | `-5` + DNS (default) ✅ | `-5` + DNS (default) ✅ |
| 2 | `-5 --set-ttl 5` + DNS (the fork's own default) ❌ | `-5 --set-ttl 5` + DNS ✅ |
| 3 | `-5` ✅ | `-6` + DNS ❌ |
| 4 | `--set-ttl 3` ❌ | `--set-ttl 3` + DNS ❌ |
| 5 | `--set-ttl 3` + DNS ❌ | `-1` + DNS ❌ |
| 6 | `-9` + DNS ❌ | `-5` (no DNS) ✅ |
| 7 | `-9` ❌ | — |

✅ / ❌ = worked / didn't work for Discord in our test on one Turkish connection (October 2026). Blocking differs between providers, so ❌ settings are still worth trying on yours. Turkey options 3–7 are the fork's alternative settings made for Superonline.

If none of them work, switch to the other version (turkey ↔ valdik) or try [zapret](../zapret), which has more bypass methods.

---

## Folder layout

```
goodbyedpi\
├─ turkey\
│  ├─ custom-files\                    ← these scripts
│  ├─ goodbyedpi-0.2.3rc3-turkey\      ← the fork's own files
│  └─ goodbyedpi-0.2.3rc3-turkey.zip   ← untouched original
└─ valdik\
   ├─ custom-files\
   ├─ goodbyedpi-0.2.2\
   └─ goodbyedpi-0.2.2.zip
```
