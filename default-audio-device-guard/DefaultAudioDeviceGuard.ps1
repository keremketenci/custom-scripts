# DefaultAudioDeviceGuard.ps1
# Stops Windows from switching your default audio devices on its own. When a newly plugged-in or
# reconnected device, a driver or a virtual mixer loading at logon changes the default playback /
# recording device (or the default communication device), it is set back within about a second.
#
# Changing a default yourself (Sound settings, the taskbar, your mixer app, ...) still works: a
# change that doesn't follow a device being added, removed or enabled/disabled is treated as
# deliberate, and that device is guarded from then on.
#
# Event driven: it sleeps until Windows reports a device change, so it uses no CPU while nothing
# is happening.
#
# Usage:
#   .\DefaultAudioDeviceGuard.ps1              setup: pick devices, install and start the background task
#                                              (run it again any time to change the devices)
#   .\DefaultAudioDeviceGuard.ps1 -List        list audio devices, the current defaults and the guarded ones
#   .\DefaultAudioDeviceGuard.ps1 -Once        set the guarded devices once, then exit
#   .\DefaultAudioDeviceGuard.ps1 -Uninstall   remove the background task and installed files
#   .\DefaultAudioDeviceGuard.ps1 -Run         background mode (this is what the scheduled task runs)

param(
    [switch]$Run,
    [switch]$List,
    [switch]$Once,
    [switch]$Uninstall
)

$TaskName   = 'DefaultAudioDeviceGuard'
$InstallDir = Join-Path $env:LOCALAPPDATA 'DefaultAudioDeviceGuard'
$Installed  = Join-Path $InstallDir 'DefaultAudioDeviceGuard.ps1'
$ConfigPath = Join-Path $InstallDir 'config.json'

# One entry per slot, in the same order as Defaults.Labels in the C# code.
$SlotKeys = 'PlaybackDefault', 'PlaybackCommunication', 'RecordingDefault', 'RecordingCommunication'

$src = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;

namespace DADG
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

    // Callback Windows uses to report audio devices being added, removed, enabled/disabled
    // or a different default device being chosen.
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

    // Undocumented, but what the Sound control panel itself uses to change the default device.
    // Stable since Windows 7.
    [ComImport, Guid("f8679f50-850a-41cf-9c72-430f290290c8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPolicyConfig
    {
        // The first ten methods are placeholders that keep the vtable order correct.
        void GetMixFormat();
        void GetDeviceFormat();
        void ResetDeviceFormat();
        void SetDeviceFormat();
        void GetProcessingPeriod();
        void SetProcessingPeriod();
        void GetShareMode();
        void SetShareMode();
        void GetPropertyValue();
        void SetPropertyValue();
        void SetDefaultEndpoint([MarshalAs(UnmanagedType.LPWStr)] string id, uint role);
    }

    public class DeviceInfo
    {
        public string Id;
        public string Name;
        public int Flow;        // 0 = playback, 1 = recording
        public bool Default;    // current default device
        public bool Comm;       // current default communication device
    }

    public static class Defaults
    {
        // Slots: 0 default playback, 1 communication playback,
        //        2 default recording, 3 communication recording.
        public static readonly string[] Labels =
            { "Default playback", "Communication playback", "Default recording", "Communication recording" };

        static uint Flow(int slot) { return slot < 2 ? 0u : 1u; }

        // "Default device" in the Sound control panel is the console + multimedia roles,
        // "Default communication device" is the communications role.
        static uint[] Roles(int slot) { return slot % 2 == 0 ? new uint[] { 0, 1 } : new uint[] { 2 }; }

        [DllImport("ole32.dll")]
        static extern int PropVariantClear(ref PROPVARIANT pv);

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

        static string FriendlyName(IMMDevice dev)
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

        static string FriendlyName(IMMDeviceEnumerator en, string id)
        {
            IMMDevice d = null;
            try { en.GetDevice(id, out d); return FriendlyName(d); }
            catch { return ""; }
            finally { Release(d); }
        }

        static string Id(IMMDevice dev)
        {
            string id;
            dev.GetId(out id);
            return id;
        }

        static bool Same(string a, string b)
        {
            return !String.IsNullOrEmpty(a) && String.Equals(a, b, StringComparison.OrdinalIgnoreCase);
        }

        static string DefaultId(IMMDeviceEnumerator en, uint flow, uint role)
        {
            IMMDevice d = null;
            try { en.GetDefaultAudioEndpoint(flow, role, out d); return Id(d); }
            catch { return null; } // no device of this kind right now
            finally { Release(d); }
        }

        // Lists every active playback and recording device and which ones are the defaults now.
        public static List<DeviceInfo> ListDevices()
        {
            List<DeviceInfo> info = new List<DeviceInfo>();
            IMMDeviceEnumerator en = NewEnumerator();
            try
            {
                for (uint flow = 0; flow < 2; flow++)
                {
                    string def = DefaultId(en, flow, 0);
                    string comm = DefaultId(en, flow, 2);
                    IMMDeviceCollection col = null;
                    try
                    {
                        en.EnumAudioEndpoints(flow, 1, out col); // active devices only
                        uint n;
                        col.GetCount(out n);
                        for (uint i = 0; i < n; i++)
                        {
                            IMMDevice dev = null;
                            try
                            {
                                col.Item(i, out dev);
                                DeviceInfo d = new DeviceInfo();
                                d.Id = Id(dev);
                                d.Name = FriendlyName(dev);
                                d.Flow = (int)flow;
                                d.Default = Same(d.Id, def);
                                d.Comm = Same(d.Id, comm);
                                info.Add(d);
                            }
                            catch { }
                            finally { Release(dev); }
                        }
                    }
                    finally { Release(col); }
                }
            }
            finally { Release(en); }
            return info;
        }

        // Finds a guarded device: by its ID first, by its exact name if the ID changed (e.g. a USB
        // headset plugged into another port). Returns null if it isn't connected right now.
        static string Resolve(IMMDeviceEnumerator en, int slot, string id, string name)
        {
            if (!String.IsNullOrEmpty(id))
            {
                IMMDevice d = null;
                try
                {
                    en.GetDevice(id, out d);
                    uint state;
                    d.GetState(out state);
                    if (state == 1) return id; // DEVICE_STATE_ACTIVE
                }
                catch { }
                finally { Release(d); }
            }
            if (String.IsNullOrEmpty(name)) return null;

            IMMDeviceCollection col = null;
            try
            {
                en.EnumAudioEndpoints(Flow(slot), 1, out col);
                uint n;
                col.GetCount(out n);
                for (uint i = 0; i < n; i++)
                {
                    IMMDevice dev = null;
                    try
                    {
                        col.Item(i, out dev);
                        if (String.Equals(FriendlyName(dev), name, StringComparison.OrdinalIgnoreCase)) return Id(dev);
                    }
                    catch { }
                    finally { Release(dev); }
                }
            }
            catch { }
            finally { Release(col); }
            return null;
        }

        static void SetDefault(string id, uint role)
        {
            IPolicyConfig pc = (IPolicyConfig)Activator.CreateInstance(
                Type.GetTypeFromCLSID(new Guid("870af99c-171d-4f9e-af0d-e63df40c2bc9")));
            try { pc.SetDefaultEndpoint(id, role); }
            finally { Release(pc); }
        }

        // Makes the guarded devices the defaults again wherever they aren't.
        // ids / names: one entry per slot, empty = slot not guarded.
        // keepNew: a different default is kept instead of set back; ids / names are updated to it.
        // report: also log slots that were already right or whose device isn't connected.
        // Returns true if any slot was kept (ids / names changed).
        public static bool Apply(string[] ids, string[] names, bool keepNew, bool report, List<string> log)
        {
            bool kept = false;
            IMMDeviceEnumerator en = NewEnumerator();
            try
            {
                for (int s = 0; s < 4; s++)
                {
                    if (String.IsNullOrEmpty(ids[s]) && String.IsNullOrEmpty(names[s])) continue;

                    string target = Resolve(en, s, ids[s], names[s]);
                    if (target == null)
                    {
                        // Not connected now; set again when Windows reports a new device.
                        if (report) log.Add(Labels[s] + ": " + names[s] + " is not connected");
                        continue;
                    }

                    uint[] roles = Roles(s);
                    string current = DefaultId(en, Flow(s), roles[0]);
                    bool keptThis = keepNew && current != null && !Same(current, target);
                    if (keptThis)
                    {
                        target = current;
                        ids[s] = current;
                        names[s] = FriendlyName(en, current);
                        kept = true;
                        log.Add(Labels[s] + " changed by hand, now guarding: " + names[s]);
                    }

                    bool changed = false;
                    foreach (uint role in roles)
                    {
                        if (Same(DefaultId(en, Flow(s), role), target)) continue;
                        try { SetDefault(target, role); changed = true; }
                        catch (Exception e) { log.Add(Labels[s] + ": could not set " + names[s] + " (" + e.Message + ")"); }
                    }

                    if (changed && !keptThis) log.Add(Labels[s] + " set back: " + names[s]);
                    else if (report && !changed) log.Add(Labels[s] + " already set: " + names[s]);
                }
            }
            finally { Release(en); }
            return kept;
        }
    }

    [ComVisible(true)]
    public class DeviceCallback : IMMNotificationClient
    {
        public int OnDeviceStateChanged(string id, uint state) { Watcher.Signal(true); return 0; }
        public int OnDeviceAdded(string id) { Watcher.Signal(true); return 0; }
        public int OnDeviceRemoved(string id) { Watcher.Signal(true); return 0; }
        public int OnDefaultDeviceChanged(int flow, int role, string id) { Watcher.Signal(false); return 0; }
        public int OnPropertyValueChanged(string id, PROPERTYKEY key) { return 0; }
    }

    // Lets PowerShell wait for a kept change (Register-ObjectEvent needs an instance event).
    public class Notifier
    {
        public event EventHandler Changed;
        internal void Raise()
        {
            EventHandler h = Changed;
            if (h != null) h(this, EventArgs.Empty);
        }
    }

    // Sleeps on an event until Windows reports a device change, then runs a single Apply.
    // Uses no CPU while nothing is happening.
    public static class Watcher
    {
        // A default change this soon after a device was added, removed or enabled/disabled is
        // Windows reacting to that device: it is set back. Any other change is deliberate: it is kept.
        static readonly TimeSpan DeviceWindow = TimeSpan.FromSeconds(10);

        public static readonly Notifier Events = new Notifier();

        static readonly AutoResetEvent wake = new AutoResetEvent(false);
        static readonly DeviceCallback deviceCb = new DeviceCallback();
        static readonly object sync = new object();
        static string[] ids, names;
        static long lastDeviceEvent;   // DateTime.UtcNow.Ticks
        static volatile bool stop;
        static Thread thread;

        public static void Signal(bool deviceEvent)
        {
            if (deviceEvent) Interlocked.Exchange(ref lastDeviceEvent, DateTime.UtcNow.Ticks);
            wake.Set();
        }

        // The devices guarded right now (they change when a deliberate change is kept).
        public static string[] GetIds() { lock (sync) return (string[])ids.Clone(); }
        public static string[] GetNames() { lock (sync) return (string[])names.Clone(); }

        public static void Start(string[] guardIds, string[] guardNames)
        {
            if (thread != null) return;
            ids = (string[])guardIds.Clone();
            names = (string[])guardNames.Clone();
            stop = false;
            // Audio notifications are registered from an MTA thread; PowerShell itself runs STA.
            thread = new Thread(Loop);
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

        static void Check(bool keepNew)
        {
            List<string> log = new List<string>();
            bool kept;
            try
            {
                lock (sync) kept = Defaults.Apply(ids, names, keepNew, false, log);
            }
            catch (Exception e) { Log("Error: " + e.Message); return; }
            foreach (string l in log) Log(l);
            if (kept) Events.Raise();
        }

        static void Loop()
        {
            IMMDeviceEnumerator en = null;
            try
            {
                en = Defaults.NewEnumerator();
                en.RegisterEndpointNotificationCallback(deviceCb);
                for (int s = 0; s < 4; s++)
                    if (!String.IsNullOrEmpty(names[s])) Log("Guarding " + Defaults.Labels[s].ToLower() + ": " + names[s]);
                // Whatever changed while the script wasn't running (e.g. during boot) is set back.
                Check(false);

                while (true)
                {
                    wake.WaitOne();
                    if (stop) break;
                    // Let a burst of events (e.g. many virtual devices loading at logon) settle into one check.
                    Thread.Sleep(1000);
                    wake.Reset();
                    if (stop) break;

                    long since = DateTime.UtcNow.Ticks - Interlocked.Read(ref lastDeviceEvent);
                    Check(since > DeviceWindow.Ticks);
                }
            }
            catch (Exception e) { Log("Watcher stopped: " + e.Message); }
            finally
            {
                if (en != null)
                {
                    try { en.UnregisterEndpointNotificationCallback(deviceCb); } catch { }
                    Defaults.Release(en);
                }
            }
        }
    }
}
'@

# Compile only once per PowerShell session. If you replace this file with a newer version,
# open a new PowerShell window so the updated C# code is compiled.
if (-not ('DADG.Watcher' -as [type])) {
    Add-Type -TypeDefinition $src -Language CSharp
}

# Returns 4 entries (one per slot): an object with Name and Id, or $null if the slot isn't guarded.
function Get-SavedGuards {
    $guards = @($null, $null, $null, $null)
    try {
        $cfg = Get-Content $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json
        for ($s = 0; $s -lt 4; $s++) {
            $entry = $cfg.($SlotKeys[$s])
            if ($entry -and $entry.Name) { $guards[$s] = $entry }
        }
    }
    catch { }
    return , $guards
}

function Save-Guards($guards) {
    $cfg = [ordered]@{}
    for ($s = 0; $s -lt 4; $s++) { $cfg[$SlotKeys[$s]] = $guards[$s] }
    ConvertTo-Json $cfg | Set-Content $ConfigPath -Encoding UTF8
}

# Splits the guards into the two string arrays the C# code takes.
function ConvertTo-GuardArrays($guards) {
    $ids   = [string[]]::new(4)
    $names = [string[]]::new(4)
    for ($s = 0; $s -lt 4; $s++) {
        if ($guards[$s]) { $ids[$s] = $guards[$s].Id; $names[$s] = $guards[$s].Name }
    }
    return @{ Ids = $ids; Names = $names }
}

function Test-Guarded($guard, $device) {
    return $guard -and ($guard.Id -eq $device.Id -or $guard.Name -eq $device.Name)
}

# Prints playback and recording devices, numbered separately. Returns @{ Playback; Recording }.
function Show-Devices($guards) {
    $all = [DADG.Defaults]::ListDevices()
    $groups = @{
        Playback  = @($all | Where-Object { $_.Flow -eq 0 })
        Recording = @($all | Where-Object { $_.Flow -eq 1 })
    }

    foreach ($kind in 'Playback', 'Recording') {
        $first = if ($kind -eq 'Playback') { 0 } else { 2 }   # slot of this kind's default device
        $devs = $groups[$kind]
        Write-Host ''
        Write-Host "$kind devices" -ForegroundColor Cyan
        for ($i = 0; $i -lt $devs.Count; $i++) {
            $d = $devs[$i]
            $line = '{0,3}) {1}' -f ($i + 1), $d.Name
            $tags = @()
            if ($d.Default) { $tags += 'default now' }
            if ($d.Comm) { $tags += 'communication now' }
            $guarded = @()
            if (Test-Guarded $guards[$first] $d) { $guarded += 'default' }
            if (Test-Guarded $guards[$first + 1] $d) { $guarded += 'communication' }
            if ($guarded) { $tags += 'guarded as ' + ($guarded -join ' + ') }
            if ($tags) { $line += '   <- ' + ($tags -join ', ') }
            if ($guarded) { Write-Host $line -ForegroundColor Yellow } else { Write-Host $line }
        }
        if ($devs.Count -eq 0) { Write-Host '  (none)' }
    }
    Write-Host ''
    return $groups
}

function Write-Guards($guards) {
    $labels = [DADG.Defaults]::Labels
    for ($s = 0; $s -lt 4; $s++) {
        $name = if ($guards[$s]) { $guards[$s].Name } else { '(not guarded)' }
        Write-Host ('  {0,-25} {1}' -f ($labels[$s] + ':'), $name)
    }
}

# Kills the background copy started by the scheduled task (if any), so it can be replaced.
function Stop-Background {
    Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*DefaultAudioDeviceGuard.ps1*-Run*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

function Remove-Task {
    Stop-Background
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
}

function Install-Watcher($guards) {
    Remove-Task

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    if ($PSCommandPath -ne $Installed) { Copy-Item $PSCommandPath $Installed -Force }
    Unblock-File $Installed -ErrorAction SilentlyContinue
    Save-Guards $guards

    # conhost --headless keeps the window hidden even when Windows Terminal is the default terminal.
    $psArgs    = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Installed`" -Run"
    $action    = New-ScheduledTaskAction -Execute 'conhost.exe' -Argument "--headless powershell.exe $psArgs"
    $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $settings  = New-ScheduledTaskSettingsSet `
        -ExecutionTimeLimit ([TimeSpan]::Zero) `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) `
        -MultipleInstances IgnoreNew
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
        -Settings $settings -Principal $principal -Force | Out-Null
    Start-ScheduledTask -TaskName $TaskName
}

# ---------------------------------------------------------------- modes

if ($Uninstall) {
    Remove-Task
    Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host 'DefaultAudioDeviceGuard removed. Your current default devices stay as they are.' -ForegroundColor Green
    return
}

if ($List) {
    Show-Devices (Get-SavedGuards) | Out-Null
    return
}

if ($Run -or $Once) {
    $guards = Get-SavedGuards
    if (-not ($guards | Where-Object { $_ })) {
        Write-Host 'No devices are guarded. Run DefaultAudioDeviceGuard.ps1 without parameters (or Setup.cmd) to set it up.'
        exit 1
    }
    $arrays = ConvertTo-GuardArrays $guards

    if ($Once) {
        $log = New-Object 'System.Collections.Generic.List[string]'
        [DADG.Defaults]::Apply($arrays.Ids, $arrays.Names, $false, $true, $log) | Out-Null
        $log | ForEach-Object { Write-Host $_ }
        return
    }

    # Allow only one running copy at a time
    $created = $false
    $mutex = New-Object System.Threading.Mutex($true, 'Local\DefaultAudioDeviceGuard', [ref]$created)
    if (-not $created) {
        Write-Host 'Another copy of this script is already running.'
        return
    }

    try {
        Register-ObjectEvent -InputObject ([DADG.Watcher]::Events) -EventName Changed -SourceIdentifier GuardChanged | Out-Null
        [DADG.Watcher]::Start($arrays.Ids, $arrays.Names)
        # All the work happens on the watcher thread when Windows sends an event. This loop only
        # saves a default you changed by hand, so it is still guarded after a restart.
        while ($true) {
            Wait-Event -SourceIdentifier GuardChanged | Out-Null
            Remove-Event -SourceIdentifier GuardChanged -ErrorAction SilentlyContinue
            $ids   = [DADG.Watcher]::GetIds()
            $names = [DADG.Watcher]::GetNames()
            for ($s = 0; $s -lt 4; $s++) {
                if ($names[$s]) { $guards[$s] = [pscustomobject]@{ Name = $names[$s]; Id = $ids[$s] } }
            }
            Save-Guards $guards
        }
    }
    finally {
        Unregister-Event -SourceIdentifier GuardChanged -ErrorAction SilentlyContinue
        [DADG.Watcher]::Stop()
        $mutex.ReleaseMutex()
    }
    return
}

# ---------------------------------------------------------------- setup (no parameters)

$saved  = Get-SavedGuards
$labels = [DADG.Defaults]::Labels

Write-Host ''
Write-Host 'DefaultAudioDeviceGuard setup' -ForegroundColor Cyan
Write-Host 'Pick the device each default should stay on. Connect your devices and start the apps'
Write-Host 'that create virtual devices (e.g. Wave Link, Sonar) first, so they show up in the list.'
Write-Host 'You can still change a default yourself later; the new one is then guarded instead.'

:setup while ($true) {
    $groups = Show-Devices $saved
    Write-Host 'For each one: a number from the list, 0 = do not guard, Enter = keep current, R = refresh, Q = quit'

    $chosen = @($null, $null, $null, $null)
    for ($s = 0; $s -lt 4; $s++) {
        $devs    = if ($s -lt 2) { $groups.Playback } else { $groups.Recording }
        $current = if ($saved[$s]) { $saved[$s].Name } else { 'not guarded' }

        while ($true) {
            $answer = (Read-Host "$($labels[$s]) [$current]").Trim()
            if ($answer -match '^[Qq]$') { return }
            if ($answer -match '^[Rr]$') { continue setup }
            if ($answer -eq '') { $chosen[$s] = $saved[$s]; break }
            if ($answer -eq '0') { $chosen[$s] = $null; break }
            if ($answer -match '^\d+$' -and [int]$answer -ge 1 -and [int]$answer -le $devs.Count) {
                $d = $devs[[int]$answer - 1]
                $chosen[$s] = [pscustomobject]@{ Name = $d.Name; Id = $d.Id }
                break
            }
            Write-Host "Enter a number between 0 and $($devs.Count), Enter, R or Q." -ForegroundColor Red
        }
    }

    if (-not ($chosen | Where-Object { $_ })) {
        Write-Host ''
        Write-Host 'Nothing is guarded. Pick at least one device, or run Uninstall.cmd to remove DefaultAudioDeviceGuard.' -ForegroundColor Red
        continue
    }

    Write-Host ''
    Write-Host 'These defaults will be guarded:' -ForegroundColor Cyan
    Write-Guards $chosen
    if ((Read-Host 'Install? (Y/n)').Trim() -match '^[Nn]') { continue }
    break
}

Install-Watcher $chosen

Write-Host ''
Write-Host 'Done. DefaultAudioDeviceGuard is running in the background and starts automatically at logon.' -ForegroundColor Green
Write-Host 'Run the setup again any time to change the devices, or Uninstall.cmd to remove it.'
