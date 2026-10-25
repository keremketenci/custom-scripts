# Re-launch as administrator if needed
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$serviceName = "goodbyedpi-global"
# Services that handle the same traffic: paused while global runs, started again when it closes
$pauseNames = @("goodbyedpi-custom", "zapret-custom")
$myPid = $PID

# Messages in the language saved by the create scripts (language.txt), English by default
$lang = "en"
$langFile = Join-Path $PSScriptRoot "language.txt"
if ((Test-Path $langFile) -and ((Get-Content $langFile -TotalCount 1).Trim() -eq "tr")) { $lang = "tr" }
$messages = @{
    en = @{
        PressEnter    = "Press Enter to close"
        NotFound      = "$serviceName service not found. Run service_global_create.cmd first."
        AlreadyOn     = "$serviceName is already running. It may be open in another window."
        OtherGlobal   = "zapret-global is running. Both can't run at the same time, close the zapret-global window first."
        Pausing       = "Pausing"
        Starting      = "Starting $serviceName..."
        StartFail     = "Couldn't start $serviceName. Your antivirus may have blocked goodbyedpi.exe or WinDivert."
        StoppedAtOnce = "$serviceName stopped right after starting.`nRun service_global_create.cmd again and pick another setting (this GoodbyeDPI version may not support the chosen one), or check your antivirus."
        Running       = "$serviceName is running. Closing this window stops the service."
        WillRestart   = "will start again when this window closes."
        HowToStop     = "Press Ctrl+C or close this window to stop."
        Died          = "$serviceName stopped unexpectedly. Your antivirus may have blocked it."
    }
    tr = @{
        PressEnter    = "Kapatmak icin Enter'a bas"
        NotFound      = "$serviceName servisi bulunamadi. Once service_global_create.cmd'yi calistir."
        AlreadyOn     = "$serviceName zaten calisiyor. Baska bir pencerede acik olabilir."
        OtherGlobal   = "zapret-global calisiyor. Ikisi ayni anda acik olamaz, once zapret-global penceresini kapat."
        Pausing       = "Gecici olarak durduruluyor:"
        Starting      = "$serviceName baslatiliyor..."
        StartFail     = "$serviceName baslatilamadi. Antivirus goodbyedpi.exe veya WinDivert'i engellemis olabilir."
        StoppedAtOnce = "$serviceName baslar baslamaz durdu.`nservice_global_create.cmd'yi tekrar calistirip baska bir ayar sec (bu GoodbyeDPI surumu secilen ayari desteklemiyor olabilir) ya da antivirusunu kontrol et."
        Running       = "$serviceName calisiyor. Bu pencereyi kapatinca servis duracak."
        WillRestart   = "pencere kapaninca tekrar baslatilacak."
        HowToStop     = "Cikmak icin Ctrl+C'ye bas ya da pencereyi kapat."
        Died          = "$serviceName beklenmedik sekilde durdu. Antivirus engellemis olabilir."
    }
}
$M = $messages[$lang]

function Exit-WithMessage($message) {
    Write-Host $message -ForegroundColor Red
    Read-Host $M.PressEnter
    exit 1
}

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if (-not $service) {
    Exit-WithMessage $M.NotFound
}
if ($service.Status -eq 'Running') {
    Exit-WithMessage $M.AlreadyOn
}
if ((Get-Service -Name "zapret-global" -ErrorAction SilentlyContinue).Status -eq 'Running') {
    Exit-WithMessage $M.OtherGlobal
}

$paused = @(Get-Service -Name $pauseNames -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Running' } | ForEach-Object { $_.Name })
$restartLines = ($paused | ForEach-Object { "Start-Service -Name '$_' -ErrorAction SilentlyContinue" }) -join "`n"

# Hidden watcher that stops the service when this window/process closes
$watcherFile = Join-Path $env:TEMP "goodbyedpi_watcher_$myPid.ps1"
@"
Wait-Process -Id $myPid -ErrorAction SilentlyContinue
Stop-Service -Name '$serviceName' -ErrorAction SilentlyContinue
$restartLines
Remove-Item -Path `"$watcherFile`" -Force -ErrorAction SilentlyContinue
"@ | Set-Content -Path $watcherFile -Encoding UTF8

Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$watcherFile`""

foreach ($name in $paused) {
    Write-Host "$($M.Pausing) $name"
    Stop-Service -Name $name -ErrorAction SilentlyContinue
}

Write-Host $M.Starting
try {
    Start-Service -Name $serviceName -ErrorAction Stop
} catch {
    Exit-WithMessage "$($M.StartFail)`n$($_.Exception.Message)"
}

# GoodbyeDPI exits right away if it doesn't accept a setting, so make sure it's still running
Start-Sleep -Seconds 3
if ((Get-Service -Name $serviceName).Status -ne 'Running') {
    Exit-WithMessage $M.StoppedAtOnce
}

Write-Host $M.Running -ForegroundColor Green
if ($paused.Count -gt 0) {
    Write-Host "$($paused -join ', ') $($M.WillRestart)"
}
Write-Host $M.HowToStop

while ($true) {
    Start-Sleep -Seconds 2
    if ((Get-Service -Name $serviceName).Status -ne 'Running') {
        Exit-WithMessage $M.Died
    }
}
