# DiscordScreenShareEchoFix.ps1
# Fixes the doubled / echoing audio your viewers hear when you share your screen with sound in
# Discord while using a virtual audio mixer (SteelSeries Sonar, Elgato Wave Link, ...).
# It mutes Discord's own audio session on the devices you pick, as soon as that session appears.
#
# Event driven: it sleeps until Windows reports a new audio session or a device change,
# so it uses no CPU while nothing is happening.
#
# Usage:
#   .\DiscordScreenShareEchoFix.ps1              setup: pick devices, install and start the background task
#                                        (run it again any time to change the devices)
#   .\DiscordScreenShareEchoFix.ps1 -List        list audio devices and the Discord sessions on them
#   .\DiscordScreenShareEchoFix.ps1 -Once        mute the selected devices once, then exit
#   .\DiscordScreenShareEchoFix.ps1 -Uninstall   remove the background task and installed files
#   .\DiscordScreenShareEchoFix.ps1 -Run         background mode (this is what the scheduled task runs)

param(
    [switch]$Run,
    [switch]$List,
    [switch]$Once,
    [switch]$Uninstall,
    [string[]]$Devices,                 # overrides the saved device list for -Run / -Once
    [string]$ProcessPrefix = 'Discord'
)

$TaskName   = 'DiscordScreenShareEchoFix'
$InstallDir = Join-Path $env:LOCALAPPDATA 'DiscordScreenShareEchoFix'
$Installed  = Join-Path $InstallDir 'DiscordScreenShareEchoFix.ps1'
$ConfigPath = Join-Path $InstallDir 'config.json'

$src = @'
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

namespace WA
{
    [StructLayout(LayoutKind.Sequential)]
    public struct PROPERTYKEY { public Guid fmtid; public uint pid; }

    // Oversized on purpose so it is safe on both x86 and x64.
    [StructLayout(LayoutKind.Explicit, Size = 24)]
    public struct PROPVARIANT
    {
        [FieldOffset(0)] public ushort vt;
        [FieldOffset(8)] public IntPtr p;
    }

    [ComImport, Guid("886d8eeb-8cf2-4446-8d02-cdba1dbdcf99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPropertyStore
    {
        void GetCount(out uint c);
        void GetAt(uint i, out PROPERTYKEY k);
        void GetValue(ref PROPERTYKEY k, out PROPVARIANT v);
        void SetValue(ref PROPERTYKEY k, ref PROPVARIANT v);
        void Commit();
    }

    [ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDevice
    {
        void Activate(ref Guid iid, uint clsCtx, IntPtr p, [MarshalAs(UnmanagedType.IUnknown)] out object o);
        void OpenPropertyStore(uint access, out IPropertyStore s);
        void GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);
        void GetState(out uint s);
    }

    [ComImport, Guid("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDeviceCollection
    {
        void GetCount(out uint c);
        void Item(uint i, out IMMDevice d);
    }

    // Callback Windows uses to report audio devices being added, removed or enabled/disabled.
    [ComImport, Guid("7991EEC9-7E89-4D85-8390-6C703CEC60C0"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMNotificationClient
    {
        [PreserveSig] int OnDeviceStateChanged([MarshalAs(UnmanagedType.LPWStr)] string id, uint state);
        [PreserveSig] int OnDeviceAdded([MarshalAs(UnmanagedType.LPWStr)] string id);
        [PreserveSig] int OnDeviceRemoved([MarshalAs(UnmanagedType.LPWStr)] string id);
        [PreserveSig] int OnDefaultDeviceChanged(int flow, int role, [MarshalAs(UnmanagedType.LPWStr)] string id);
        [PreserveSig] int OnPropertyValueChanged([MarshalAs(UnmanagedType.LPWStr)] string id, PROPERTYKEY key);
    }

    [ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDeviceEnumerator
    {
        void EnumAudioEndpoints(uint dataFlow, uint stateMask, out IMMDeviceCollection devs);
        void GetDefaultAudioEndpoint(uint dataFlow, uint role, out IMMDevice dev);
        void GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IMMDevice dev);
        void RegisterEndpointNotificationCallback(IMMNotificationClient c);
        void UnregisterEndpointNotificationCallback(IMMNotificationClient c);
    }

    // Callback Windows uses to report a new audio session on a device.
    [ComImport, Guid("641DD20B-4D41-49CC-ABA3-174B9477BB08"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IAudioSessionNotification
    {
        [PreserveSig] int OnSessionCreated(IntPtr newSession);
    }

    [ComImport, Guid("E2F5BB11-0570-40CA-ACDD-3AA01277DEE8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IAudioSessionEnumerator
    {
        void GetCount(out int c);
        void GetSession(int i, out IAudioSessionControl2 s);
    }

    [ComImport, Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IAudioSessionManager2
    {
        // The first two methods are placeholders that keep the vtable order correct.
        void GetAudioSessionControl(IntPtr g, uint f, out IntPtr c);
        void GetSimpleAudioVolume(IntPtr g, uint f, out IntPtr v);
        void GetSessionEnumerator(out IAudioSessionEnumerator e);
        void RegisterSessionNotification(IAudioSessionNotification n);
        void UnregisterSessionNotification(IAudioSessionNotification n);
        void RegisterDuckNotification(IntPtr a, IntPtr b);
        void UnregisterDuckNotification(IntPtr a);
    }

    [ComImport, Guid("BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IAudioSessionControl2
    {
        void GetState(out int state);
        void GetDisplayName([MarshalAs(UnmanagedType.LPWStr)] out string n);
        void SetDisplayName([MarshalAs(UnmanagedType.LPWStr)] string n, ref Guid ctx);
        void GetIconPath([MarshalAs(UnmanagedType.LPWStr)] out string n);
        void SetIconPath([MarshalAs(UnmanagedType.LPWStr)] string n, ref Guid ctx);
        void GetGroupingParam(out Guid g);
        void SetGroupingParam(ref Guid g, ref Guid ctx);
        void RegisterAudioSessionNotification(IntPtr p);
        void UnregisterAudioSessionNotification(IntPtr p);
        void GetSessionIdentifier([MarshalAs(UnmanagedType.LPWStr)] out string id);
        void GetSessionInstanceIdentifier([MarshalAs(UnmanagedType.LPWStr)] out string id);
        void GetProcessId(out uint pid);
        [PreserveSig] int IsSystemSoundsSession();
        void SetDuckingPreferences([MarshalAs(UnmanagedType.Bool)] bool opt);
    }

    [ComImport, Guid("87CE5498-68D6-44E5-9215-6DA47EF883D8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface ISimpleAudioVolume
    {
        void SetMasterVolume(float level, ref Guid ctx);
        void GetMasterVolume(out float level);
        void SetMute([MarshalAs(UnmanagedType.Bool)] bool mute, ref Guid ctx);
        void GetMute([MarshalAs(UnmanagedType.Bool)] out bool mute);
    }

    public class DeviceInfo
    {
        public string Name;
        public int Sessions;   // Discord sessions on this device
        public int Muted;      // how many of them are muted
    }

    public static class Muter
    {
        [DllImport("ole32.dll")]
        static extern int PropVariantClear(ref PROPVARIANT pv);

        // Number of target sessions seen during the last Scan (muted now or already muted).
        public static int Found;

        internal static IMMDeviceEnumerator NewEnumerator()
        {
            return (IMMDeviceEnumerator)Activator.CreateInstance(
                Type.GetTypeFromCLSID(new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")));
        }

        internal static void Release(object o)
        {
            if (o == null) return;
            try { Marshal.ReleaseComObject(o); } catch { }
        }

        internal static string FriendlyName(IMMDevice dev)
        {
            IPropertyStore ps = null;
            try
            {
                dev.OpenPropertyStore(0, out ps);
                PROPERTYKEY k = new PROPERTYKEY();
                k.fmtid = new Guid("a45c254e-df1c-4efd-8020-67d146a850e0"); // PKEY_Device_FriendlyName
                k.pid = 14;
                PROPVARIANT v;
                ps.GetValue(ref k, out v);
                string s = Marshal.PtrToStringUni(v.p);
                PropVariantClear(ref v);
                return s ?? "";
            }
            catch { return ""; }
            finally { Release(ps); }
        }

        internal static bool Matches(string name, string[] pats)
        {
            if (pats == null) return false;
            foreach (string p in pats)
                if (name.IndexOf(p, StringComparison.OrdinalIgnoreCase) >= 0) return true;
            return false;
        }

        static bool IsTarget(uint pid, string prefix)
        {
            if (pid == 0) return false;
            try
            {
                using (Process p = Process.GetProcessById((int)pid))
                    return p.ProcessName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase);
            }
            catch { return false; }
        }

        // Device kinds for Scan. Only playback devices are ever muted: Discord's session on a
        // recording device is your microphone input, muting it mutes you.
        public const uint Playback = 0, Recording = 1;

        public const int ModeList = 0, ModeMute = 1, ModeUnmute = 2;

        // Lists every active playback device and the Discord sessions on it.
        public static List<DeviceInfo> ListDevices(string prefix)
        {
            List<DeviceInfo> info = new List<DeviceInfo>();
            Scan(Playback, null, prefix, ModeList, null, info);
            return info;
        }

        // ModeList:   only fills 'info' with every active device of this kind and its Discord sessions.
        // ModeMute:   mutes matching sessions that are not muted yet, on devices matching 'devs'.
        // ModeUnmute: unmutes matching sessions, on devices matching 'devs' (undoes ModeMute).
        // Returns the number of sessions that were changed.
        public static int Scan(uint flow, string[] devs, string prefix, int mode, List<string> log, List<DeviceInfo> info)
        {
            int changed = 0;
            Found = 0;

            IMMDeviceEnumerator en = NewEnumerator();
            IMMDeviceCollection col = null;
            try
            {
                en.EnumAudioEndpoints(flow, 1, out col); // active devices only
                uint n;
                col.GetCount(out n);

                for (uint i = 0; i < n; i++)
                {
                    IMMDevice dev = null;
                    IAudioSessionManager2 mgr = null;
                    IAudioSessionEnumerator se = null;
                    try
                    {
                        col.Item(i, out dev);
                        string name = FriendlyName(dev);
                        if (mode != ModeList && !Matches(name, devs)) continue;

                        DeviceInfo d = new DeviceInfo();
                        d.Name = name;
                        if (info != null) info.Add(d);

                        object o;
                        Guid iid = new Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F");
                        dev.Activate(ref iid, 23, IntPtr.Zero, out o); // 23 = CLSCTX_ALL
                        mgr = (IAudioSessionManager2)o;
                        mgr.GetSessionEnumerator(out se);
                        int c;
                        se.GetCount(out c);

                        for (int j = 0; j < c; j++)
                        {
                            IAudioSessionControl2 ctl = null;
                            try
                            {
                                se.GetSession(j, out ctl);
                                uint pid;
                                ctl.GetProcessId(out pid);
                                if (!IsTarget(pid, prefix)) continue;

                                Found++;
                                d.Sessions++;
                                ISimpleAudioVolume vol = (ISimpleAudioVolume)ctl;
                                bool m;
                                vol.GetMute(out m);
                                bool want = mode == ModeMute ? true : mode == ModeUnmute ? false : m;
                                if (m != want)
                                {
                                    Guid g = Guid.Empty;
                                    vol.SetMute(want, ref g);
                                    m = want;
                                    changed++;
                                    if (log != null) log.Add((want ? "Muted: " : "Unmuted: ") + name + " (pid " + pid + ")");
                                }
                                if (m) d.Muted++;
                            }
                            catch { /* session vanished while scanning, ignore */ }
                            finally { Release(ctl); }
                        }
                    }
                    catch { /* device not available right now, retried on the next event */ }
                    finally
                    {
                        Release(se);
                        Release(mgr);
                        Release(dev);
                    }
                }
            }
            finally
            {
                Release(col);
                Release(en);
            }
            return changed;
        }
    }

    [ComVisible(true)]
    public class SessionCallback : IAudioSessionNotification
    {
        public int OnSessionCreated(IntPtr newSession) { Watcher.Signal(false); return 0; }
    }

    [ComVisible(true)]
    public class DeviceCallback : IMMNotificationClient
    {
        public int OnDeviceStateChanged(string id, uint state) { Watcher.Signal(true); return 0; }
        public int OnDeviceAdded(string id) { Watcher.Signal(true); return 0; }
        public int OnDeviceRemoved(string id) { Watcher.Signal(true); return 0; }
        public int OnDefaultDeviceChanged(int flow, int role, string id) { return 0; }
        public int OnPropertyValueChanged(string id, PROPERTYKEY key) { return 0; }
    }

    // Sleeps on an event until Windows reports a new session on a target device (or a device
    // change), then runs a single Scan. Uses no CPU while nothing is happening.
    public static class Watcher
    {
        static readonly AutoResetEvent wake = new AutoResetEvent(false);
        static readonly SessionCallback sessionCb = new SessionCallback();
        static readonly DeviceCallback deviceCb = new DeviceCallback();
        static readonly List<IAudioSessionManager2> managers = new List<IAudioSessionManager2>();
        static volatile bool rebuild, stop;
        static Thread thread;

        public static void Signal(bool devicesChanged)
        {
            if (devicesChanged) rebuild = true;
            wake.Set();
        }

        public static void Start(string[] devs, string prefix)
        {
            if (thread != null) return;
            stop = false;
            // Audio notifications are registered from an MTA thread; PowerShell itself runs STA.
            thread = new Thread(() => Loop(devs, prefix));
            thread.SetApartmentState(ApartmentState.MTA);
            thread.IsBackground = true;
            thread.Start();
        }

        public static void Stop()
        {
            if (thread == null) return;
            stop = true;
            wake.Set();
            thread.Join(5000);
            thread = null;
        }

        static void Log(string s)
        {
            Console.WriteLine("[" + DateTime.Now.ToString("HH:mm:ss") + "] " + s);
        }

        static void MuteNow(string[] devs, string prefix)
        {
            List<string> log = new List<string>();
            try { Muter.Scan(Muter.Playback, devs, prefix, Muter.ModeMute, log, null); } catch { }
            foreach (string l in log) Log(l);
        }

        static void Register(IMMDeviceEnumerator en, string[] devs)
        {
            IMMDeviceCollection col = null;
            try
            {
                en.EnumAudioEndpoints(Muter.Playback, 1, out col);
                uint n;
                col.GetCount(out n);
                for (uint i = 0; i < n; i++)
                {
                    IMMDevice dev = null;
                    IAudioSessionManager2 mgr = null;
                    try
                    {
                        col.Item(i, out dev);
                        string name = Muter.FriendlyName(dev);
                        if (!Muter.Matches(name, devs)) continue;

                        object o;
                        Guid iid = new Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F");
                        dev.Activate(ref iid, 23, IntPtr.Zero, out o);
                        mgr = (IAudioSessionManager2)o;

                        // Windows only starts sending session notifications after the
                        // session enumerator has been requested once.
                        IAudioSessionEnumerator se;
                        mgr.GetSessionEnumerator(out se);
                        Muter.Release(se);

                        mgr.RegisterSessionNotification(sessionCb);
                        managers.Add(mgr);
                        mgr = null;
                        Log("Watching: " + name);
                    }
                    catch { }
                    finally
                    {
                        Muter.Release(mgr);
                        Muter.Release(dev);
                    }
                }
            }
            catch { }
            finally { Muter.Release(col); }
        }

        static void Unregister()
        {
            foreach (IAudioSessionManager2 mgr in managers)
            {
                try { mgr.UnregisterSessionNotification(sessionCb); } catch { }
                Muter.Release(mgr);
            }
            managers.Clear();
        }

        static void Loop(string[] devs, string prefix)
        {
            IMMDeviceEnumerator en = null;
            try
            {
                en = Muter.NewEnumerator();
                en.RegisterEndpointNotificationCallback(deviceCb);
                Register(en, devs);
                MuteNow(devs, prefix);

                while (true)
                {
                    wake.WaitOne();
                    if (stop) break;
                    // Let a burst of events (e.g. during boot or stream start) settle into one scan.
                    Thread.Sleep(500);
                    wake.Reset();
                    if (stop) break;

                    if (rebuild)
                    {
                        rebuild = false;
                        Unregister();
                        Register(en, devs);
                    }
                    MuteNow(devs, prefix);
                }
            }
            catch (Exception e) { Log("Watcher stopped: " + e.Message); }
            finally
            {
                Unregister();
                if (en != null)
                {
                    try { en.UnregisterEndpointNotificationCallback(deviceCb); } catch { }
                    Muter.Release(en);
                }
            }
        }
    }
}
'@

# Compile only once per PowerShell session. If you replace this file with a newer version,
# open a new PowerShell window so the updated C# code is compiled.
if (-not ('WA.Watcher' -as [type])) {
    Add-Type -TypeDefinition $src -Language CSharp
}

function Get-SavedDevices {
    try { return @((Get-Content $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json).Devices) }
    catch { return @() }
}

# Unmutes Discord's sessions on the given devices of one kind (playback or recording).
# Windows only lists a session while Discord uses that device, so Discord has to be running
# (and in a voice call, for the microphone).
function Restore-Discord([string[]]$devs, [uint32]$flow) {
    if (-not $devs) { return }
    $log = New-Object 'System.Collections.Generic.List[string]'
    [WA.Muter]::Scan($flow, $devs, $ProcessPrefix, [WA.Muter]::ModeUnmute, $log, $null) | Out-Null
    $log | ForEach-Object { Write-Host $_ }
}

# Kills the background copy started by the scheduled task (if any), so it can be replaced.
function Stop-Background {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*DiscordScreenShareEchoFix.ps1*-Run*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

function Remove-Task {
    Stop-Background
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
}

function Show-Devices([string[]]$saved) {
    $deviceList = [WA.Muter]::ListDevices($ProcessPrefix)
    Write-Host ''
    for ($i = 0; $i -lt $deviceList.Count; $i++) {
        $d = $deviceList[$i]
        $line = '{0,3}) {1}' -f ($i + 1), $d.Name
        $tags = @()
        if ($d.Sessions -gt 0) { $tags += "Discord audio here ($($d.Muted)/$($d.Sessions) muted)" }
        if ($saved -contains $d.Name) { $tags += 'selected now' }
        if ($tags) { $line += '   <- ' + ($tags -join ', ') }
        if ($d.Sessions -gt 0) { Write-Host $line -ForegroundColor Yellow } else { Write-Host $line }
    }
    Write-Host ''
    return $deviceList
}

# An Uninstall.cmd in the install folder, so it can be removed after the downloaded folder is deleted.
# It runs from a temp copy, because uninstalling deletes the folder it is in.
function Write-Uninstaller {
    $lines = @(
        '@echo off'
        'set "T=%TEMP%\DiscordScreenShareEchoFix-uninstall"'
        'if /i "%~dp0"=="%T%\" goto run'
        'rd /s /q "%T%" >nul 2>&1'
        'md "%T%"'
        'copy /y "%~f0" "%T%\" >nul'
        'copy /y "%~dp0DiscordScreenShareEchoFix.ps1" "%T%\" >nul'
        'cd /d "%TEMP%"'
        'start "" cmd /c ""%T%\%~nx0""'
        'exit /b'
        ':run'
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0DiscordScreenShareEchoFix.ps1" -Uninstall'
        'pause'
        '(goto) 2>nul & rd /s /q "%T%"'
    )
    # Batch files need CRLF line endings
    [IO.File]::WriteAllText((Join-Path $InstallDir 'Uninstall.cmd'), (($lines -join "`r`n") + "`r`n"))
}

function Install-Watcher([string[]]$selected) {
    Remove-Task

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    if ($PSCommandPath -ne $Installed) { Copy-Item $PSCommandPath $Installed -Force }
    Unblock-File $Installed -ErrorAction SilentlyContinue
    ConvertTo-Json @{ Devices = @($selected) } | Set-Content $ConfigPath -Encoding UTF8
    Write-Uninstaller

    # The full COMPUTER\user name: a bare $env:USERNAME is rejected when it is the same as the
    # computer name, or after the account was renamed.
    $user      = [Security.Principal.WindowsIdentity]::GetCurrent().Name

    # conhost --headless keeps the window hidden even when Windows Terminal is the default terminal.
    $psArgs    = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Installed`" -Run"
    $action    = New-ScheduledTaskAction -Execute 'conhost.exe' -Argument "--headless powershell.exe $psArgs"
    $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $user
    $settings  = New-ScheduledTaskSettingsSet `
        -ExecutionTimeLimit ([TimeSpan]::Zero) `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) `
        -MultipleInstances IgnoreNew
    $principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited

    # Stop here on failure, so setup doesn't report "Done" without a task.
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
        -Settings $settings -Principal $principal -Force -ErrorAction Stop | Out-Null
    Start-ScheduledTask -TaskName $TaskName -ErrorAction Stop
}

# ---------------------------------------------------------------- modes

if ($Uninstall) {
    $saved = Get-SavedDevices
    if ($saved -and -not (Get-Process "$ProcessPrefix*" -ErrorAction SilentlyContinue)) {
        Write-Host 'Discord is not running, so its muted sessions cannot be unmuted now.' -ForegroundColor Yellow
        Write-Host 'Start Discord, join a voice call and run Uninstall.cmd again to restore its sound.'
        if ((Read-Host 'Uninstall anyway? (y/N)').Trim() -notmatch '^[Yy]') { return }
    }
    Remove-Task
    # Windows remembers the mute per app, so undo it; otherwise Discord stays muted there.
    Restore-Discord $saved ([WA.Muter]::Playback)
    Restore-Discord $saved ([WA.Muter]::Recording)
    Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host 'DiscordScreenShareEchoFix removed.' -ForegroundColor Green
    return
}

if ($List) {
    Show-Devices (Get-SavedDevices) | Out-Null
    return
}

if ($Run -or $Once) {
    if (-not $Devices) { $Devices = Get-SavedDevices }
    if (-not $Devices) {
        Write-Host 'No devices selected. Run DiscordScreenShareEchoFix.ps1 without parameters to set it up.'
        exit 1
    }

    if ($Once) {
        $log = New-Object 'System.Collections.Generic.List[string]'
        [WA.Muter]::Scan([WA.Muter]::Playback, $Devices, $ProcessPrefix, [WA.Muter]::ModeMute, $log, $null) | Out-Null
        $log | ForEach-Object { Write-Host $_ }
        if ($log.Count -eq 0) {
            if ([WA.Muter]::Found -gt 0) { Write-Host 'Discord sessions were already muted.' }
            else { Write-Host 'No Discord session found on the selected devices.' }
        }
        return
    }

    # Allow only one running copy at a time
    $created = $false
    $mutex = New-Object System.Threading.Mutex($true, 'Local\DiscordScreenShareEchoFix', [ref]$created)
    if (-not $created) {
        Write-Host 'Another copy of this script is already running.'
        return
    }

    try {
        [WA.Watcher]::Start($Devices, $ProcessPrefix)
        # All the work happens on the watcher thread when Windows sends an event.
        # This loop only keeps the script alive (and lets Ctrl+C stop it).
        while ($true) { Start-Sleep -Seconds 3600 }
    }
    finally {
        [WA.Watcher]::Stop()
        $mutex.ReleaseMutex()
    }
    return
}

# ---------------------------------------------------------------- setup (no parameters)

$saved = Get-SavedDevices

# Older versions also listed recording devices, and muting Discord on one muted your microphone.
Restore-Discord $saved ([WA.Muter]::Recording)

Write-Host ''
Write-Host 'DiscordScreenShareEchoFix setup' -ForegroundColor Cyan
Write-Host 'Start a screen share WITH SOUND in Discord now, so its audio shows up in the list.'
Write-Host 'Devices marked "Discord audio here" are the ones to pick.'

while ($true) {
    $deviceList = Show-Devices $saved
    $prompt = 'Device numbers to mute (e.g. 2,5), R = refresh, Q = quit'
    if ($saved) { $prompt += ', Enter = keep current selection' }
    $answer = (Read-Host $prompt).Trim()

    if ($answer -match '^[Qq]$') { return }
    if ($answer -match '^[Rr]$') { continue }

    if ($answer -eq '') {
        if (-not $saved) { continue }
        $selected = $saved
    }
    else {
        $nums = @($answer -split '[,\s]+' | Where-Object { $_ })
        if ($nums | Where-Object { $_ -notmatch '^\d+$' -or [int]$_ -lt 1 -or [int]$_ -gt $deviceList.Count }) {
            Write-Host "Enter numbers between 1 and $($deviceList.Count)." -ForegroundColor Red
            continue
        }
        $selected = @($nums | ForEach-Object { $deviceList[[int]$_ - 1].Name } | Select-Object -Unique)
    }

    Write-Host ''
    Write-Host 'Discord will be muted on:' -ForegroundColor Cyan
    $selected | ForEach-Object { Write-Host "  - $_" }
    if ((Read-Host 'Install? (Y/n)').Trim() -match '^[Nn]') { continue }
    break
}

Install-Watcher $selected

Write-Host ''
Write-Host 'Done. DiscordScreenShareEchoFix is running in the background and starts automatically at logon.' -ForegroundColor Green
Write-Host 'Run this script again any time to change the devices, or with -Uninstall to remove it.'
