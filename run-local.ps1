<#
.SYNOPSIS
    Freight — lokal backend + telefonda ishga tushirish (Windows).

.DESCRIPTION
    Backendni ko'taradi (Docker yoki Gradle), telefonni unga ulaydi, flutter run qiladi.

.PARAMETER Mode
    usb   — telefon USB orqali, adb reverse ishlatiladi (default, eng ishonchli)
    wifi  — telefon Wi-Fi orqali, kompyuterning lokal IP manzili ishlatiladi

.PARAMETER Backend
    docker — backend Docker konteynerda (JDK kerak emas)
    gradle — backend Gradle orqali (JDK 25 kerak)
    skip   — backend allaqachon ishlayapti, tegmaslik

.EXAMPLE
    .\run-local.ps1
    .\run-local.ps1 -Mode wifi
    .\run-local.ps1 -Mode wifi -Backend docker
#>

param(
    [ValidateSet('usb', 'wifi')]  [string]$Mode = 'usb',
    [ValidateSet('docker', 'gradle', 'skip')] [string]$Backend = 'docker',
    [string]$BackendDir = ''
)

$ErrorActionPreference = 'Stop'
$ApiPort = 8080
$HealthUrl = "http://localhost:$ApiPort/actuator/health"

function Info($m) { Write-Host ">>> $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[OK] $m" -ForegroundColor Green }
function Fail($m) { Write-Host "[X] $m" -ForegroundColor Red }

function Test-Backend {
    try {
        $r = Invoke-WebRequest -Uri $HealthUrl -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        return $r.StatusCode -eq 200
    } catch { return $false }
}

$MobileDir = $PSScriptRoot
if (-not $BackendDir) { $BackendDir = Join-Path (Split-Path $MobileDir -Parent) 'freight-backend' }

# ------------------------------------------------------------------
# 1. Backend
# ------------------------------------------------------------------
if (Test-Backend) {
    Ok "Backend allaqachon ishlayapti (localhost:$ApiPort)"
}
elseif ($Backend -eq 'skip') {
    Fail "Backend ishlamayapti, lekin -Backend skip berilgan."
    exit 1
}
else {
    if (-not (Test-Path $BackendDir)) {
        Fail "Backend papkasi topilmadi: $BackendDir"
        Write-Host "   Ishlatish: .\run-local.ps1 -BackendDir D:\IdeaProject\freight-backend"
        exit 1
    }

    Info "Backend ishga tushirilmoqda: $BackendDir"
    Push-Location $BackendDir
    try {
        if ($Backend -eq 'docker') {
            docker info *> $null
            if ($LASTEXITCODE -ne 0) {
                Fail "Docker ishlamayapti. Docker Desktop'ni yoqing yoki: -Backend gradle"
                exit 1
            }
            Info "Docker orqali (postgres + redis + backend)..."
            docker compose up -d postgres redis backend
        }
        else {
            Info "Gradle orqali (JDK 25 kerak). Infra Docker'da..."
            docker compose up -d postgres redis

            $env:DB_URL       = "jdbc:postgresql://localhost:5432/freight"
            $env:DB_USERNAME  = "freight"
            $env:DB_PASSWORD  = "freight"
            $env:REDIS_HOST   = "localhost"
            $env:REDIS_PORT   = "6379"
            $env:REDIS_PASSWORD = ""
            $env:REDIS_SSL_ENABLED = "false"
            $env:JWT_PRIVATE_KEY   = ""
            $env:FREIGHT_SECURITY_DEPLOYMENT = "LOCAL"
            $env:SERVER_PORT = "$ApiPort"

            Start-Process -FilePath ".\gradlew.bat" -ArgumentList "bootRun" -WorkingDirectory $BackendDir -WindowStyle Minimized
        }
    } finally { Pop-Location }

    Info "Backend tayyor bo'lishini kutish..."
    $ready = $false
    foreach ($i in 1..180) {
        if (Test-Backend) { $ready = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $ready) {
        Fail "Backend ishga tushmadi."
        Write-Host "   docker logs freight-backend"
        exit 1
    }
    Ok "Backend tayyor!"
}

# ------------------------------------------------------------------
# 2. Telefonni backendga ulash
# ------------------------------------------------------------------
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Fail "adb topilmadi. Android SDK platform-tools ni PATH ga qo'shing."
    exit 1
}

$devices = (adb devices) | Select-Object -Skip 1 | Where-Object { $_ -match "\sdevice$" }
if (-not $devices) {
    Fail "Ulangan qurilma topilmadi."
    Write-Host "   USB debugging yoqilganini va telefondagi ruxsat oynasini tekshiring."
    exit 1
}

if ($Mode -eq 'usb') {
    foreach ($d in $devices) {
        $serial = ($d -split "\s+")[0]
        adb -s $serial reverse "tcp:$ApiPort" "tcp:$ApiPort" | Out-Null
        Ok "adb reverse: $serial"
    }
    $BaseUrl = "http://localhost:$ApiPort/api/v1"
}
else {
    # Wi-Fi: kompyuterning lokal IP manzili
    $ip = (Get-NetIPConfiguration |
           Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
           Select-Object -First 1).IPv4Address.IPAddress

    if (-not $ip) { Fail "Lokal IP aniqlanmadi. 'ipconfig' bilan qo'lda toping."; exit 1 }
    Ok "Kompyuter IP: $ip"

    # Windows Firewall: 8080 portini private tarmoq uchun ochish
    $ruleName = "Freight Backend $ApiPort"
    if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
        Info "Firewall qoidasi qo'shilmoqda (administrator huquqi kerak)..."
        try {
            New-NetFirewallRule -DisplayName $ruleName -Direction Inbound `
                -LocalPort $ApiPort -Protocol TCP -Action Allow -Profile Private | Out-Null
            Ok "Firewall qoidasi qo'shildi (Private tarmoq)"
        } catch {
            Fail "Firewall qoidasi qo'shilmadi — PowerShell'ni administrator sifatida oching."
            Write-Host "   Yoki qo'lda: New-NetFirewallRule -DisplayName '$ruleName' -Direction Inbound -LocalPort $ApiPort -Protocol TCP -Action Allow -Profile Private"
        }
    } else {
        Ok "Firewall qoidasi allaqachon mavjud"
    }

    Write-Host "   Eslatma: Wi-Fi tarmog'i Windows'da 'Private' bo'lishi kerak (Public emas)." -ForegroundColor Yellow
    $BaseUrl = "http://${ip}:$ApiPort/api/v1"
}

# ------------------------------------------------------------------
# 3. Flutter run
# ------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  Rejim   : $Mode"
Write-Host "  Backend : $BaseUrl"
Write-Host "  Swagger : http://localhost:$ApiPort/swagger-ui/index.html"
Write-Host "  OTP kodi: 123456"
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $MobileDir
flutter run --dart-define=BASE_URL=$BaseUrl @args
