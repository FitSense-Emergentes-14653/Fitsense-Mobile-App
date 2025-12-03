# Script para depurar Progress Tab en diferentes plataformas
# Uso: .\debug-progress-tab.ps1 [web|android]

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('web', 'android', 'both')]
    [string]$Platform = 'both'
)

$ErrorActionPreference = "Continue"

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PROGRESS TAB DEBUG - Comparación Mobile vs Web           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

function Start-FlutterApp {
    param(
        [string]$Device,
        [string]$LogFile
    )

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "  Iniciando Flutter en: $Device" -ForegroundColor Yellow
    Write-Host "  Logs guardados en: $LogFile" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

    # Limpiar
    Write-Host "[1/3] Limpiando..." -ForegroundColor Cyan
    flutter clean | Out-Null

    Write-Host "[2/3] Obteniendo dependencias..." -ForegroundColor Cyan
    flutter pub get | Out-Null

    Write-Host "[3/3] Compilando y ejecutando en $Device..." -ForegroundColor Cyan
    Write-Host "⏳ Espera a que la app cargue completamente...`n" -ForegroundColor Gray

    # Ejecutar y capturar logs
    $process = Start-Process -FilePath "flutter" -ArgumentList "run", "-d", $Device, "--verbose" `
        -RedirectStandardOutput $LogFile `
        -RedirectStandardError "${LogFile}.err" `
        -NoNewWindow -PassThru

    Write-Host "✓ Proceso iniciado (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

    return $process
}

function Wait-ForProgressTabLogs {
    param(
        [string]$LogFile,
        [int]$TimeoutSeconds = 120
    )

    Write-Host "Esperando logs de PROGRESS TAB..." -ForegroundColor Cyan
    $startTime = Get-Date
    $found = $false

    while (((Get-Date) - $startTime).TotalSeconds -lt $TimeoutSeconds) {
        if (Test-Path $LogFile) {
            $content = Get-Content $LogFile -Tail 50 -ErrorAction SilentlyContinue
            if ($content -match "PROGRESS TAB.*RESULTADO DE CARGA") {
                $found = $true
                break
            }
        }
        Start-Sleep -Milliseconds 500
    }

    if ($found) {
        Write-Host "✓ Logs encontrados!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "⚠ Timeout esperando logs" -ForegroundColor Yellow
        return $false
    }
}

function Extract-ProgressData {
    param(
        [string]$LogFile,
        [string]$Platform
    )

    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║  DATOS DE $Platform" -ForegroundColor Magenta -NoNewline
    Write-Host (" " * (57 - $Platform.Length)) -NoNewline
    Write-Host "║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Magenta

    if (-not (Test-Path $LogFile)) {
        Write-Host "❌ Archivo de log no encontrado: $LogFile" -ForegroundColor Red
        return
    }

    $content = Get-Content $LogFile

    # Buscar el bloque de RESULTADO DE CARGA
    $inResultBlock = $false
    $resultLines = @()

    foreach ($line in $content) {
        if ($line -match "RESULTADO DE CARGA") {
            $inResultBlock = $true
        }

        if ($inResultBlock) {
            $resultLines += $line

            if ($line -match "CARGA COMPLETADA") {
                break
            }
        }
    }

    if ($resultLines.Count -gt 0) {
        foreach ($line in $resultLines) {
            if ($line -match "✅|❌|totalCaloriesBurned|exercisesCompleted|glasses|daysCompleted") {
                Write-Host $line
            }
        }
    } else {
        Write-Host "⚠ No se encontraron datos de PROGRESS TAB en los logs" -ForegroundColor Yellow
        Write-Host "`nMostrando últimas 20 líneas del log:" -ForegroundColor Gray
        Get-Content $LogFile -Tail 20
    }

    Write-Host ""
}

# Crear directorio para logs
$logsDir = "debug_logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$webLog = "$logsDir/progress_web_$timestamp.log"
$androidLog = "$logsDir/progress_android_$timestamp.log"

# Ejecutar según plataforma seleccionada
if ($Platform -eq 'web' -or $Platform -eq 'both') {
    $webProcess = Start-FlutterApp -Device "chrome" -LogFile $webLog

    Write-Host "Esperando 60 segundos para que la app cargue en Chrome..." -ForegroundColor Gray
    Write-Host "Por favor, navega al Progress Tab en la app" -ForegroundColor Yellow
    Start-Sleep -Seconds 60

    # Extraer datos
    Extract-ProgressData -LogFile $webLog -Platform "WEB (CHROME)"

    # Detener proceso
    Write-Host "Deteniendo Flutter Web..." -ForegroundColor Gray
    Stop-Process -Id $webProcess.Id -Force -ErrorAction SilentlyContinue
}

if ($Platform -eq 'android' -or $Platform -eq 'both') {
    if ($Platform -eq 'both') {
        Write-Host "`n`n⏳ Esperando 5 segundos antes de iniciar Android..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }

    # Verificar si hay dispositivo Android
    $devices = flutter devices
    if ($devices -notmatch "android") {
        Write-Host "❌ No se encontró dispositivo Android. Inicia un emulador." -ForegroundColor Red
    } else {
        $androidProcess = Start-FlutterApp -Device "android" -LogFile $androidLog

        Write-Host "Esperando 60 segundos para que la app cargue en Android..." -ForegroundColor Gray
        Write-Host "Por favor, navega al Progress Tab en la app" -ForegroundColor Yellow
        Start-Sleep -Seconds 60

        # Extraer datos
        Extract-ProgressData -LogFile $androidLog -Platform "ANDROID"

        # Detener proceso
        Write-Host "Deteniendo Flutter Android..." -ForegroundColor Gray
        Stop-Process -Id $androidProcess.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  DEBUG COMPLETADO                                          ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "📁 Logs guardados en:" -ForegroundColor Cyan
if (Test-Path $webLog) {
    Write-Host "   - Web: $webLog" -ForegroundColor White
}
if (Test-Path $androidLog) {
    Write-Host "   - Android: $androidLog" -ForegroundColor White
}

Write-Host "`n💡 Tip: Revisa los logs completos para más detalles" -ForegroundColor Yellow
Write-Host ""

