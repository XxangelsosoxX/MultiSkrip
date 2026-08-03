# ==========================================================
# MULTISCRIPT - (KSHY112L) - Made By XxAngelsosoxX
# ==========================================================

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- FUNCIÓN DE CONFIRMACIÓN RÁPIDA (UX MEJORADA PARA SCREENSHARE) ---
function Confirm-Action {
    param(
        [string]$Message,
        [string]$Default = "S"
    )
    $resp = Read-Host "$Message ¿Deseas continuar? [S/N] (Por defecto: $Default)"
    if ([string]::IsNullOrWhiteSpace($resp)) { $resp = $Default }
    return ($resp -match '^[SsYy]$')
}

function Select-NumberList {
    param(
        [int]$Max,
        [string]$Prompt = "Selecciona números separados por comas"
    )
    $raw = Read-Host $Prompt
    $result = @()
    foreach ($part in ($raw -split ",")) {
        if ($part.Trim() -match '^\d+$') {
            $n = [int]$part.Trim()
            if ($n -ge 1 -and $n -le $Max) { $result += $n }
        }
    }
    return $result | Select-Object -Unique
}

function Backup-RegistryKey {
    param([string]$RegistryPath)
    try {
        $native = $RegistryPath -replace '^HKCU:', 'HKEY_CURRENT_USER' -replace '^HKLM:', 'HKEY_LOCAL_MACHINE'
        $safe = ($native -replace '[\\/:*?"<>| ]', '_')
        $backupDir = Join-Path $env:TEMP "Multiskrip_Backups"
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        $file = Join-Path $backupDir "$safe-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg"
        & reg.exe export $native $file /y 2>$null | Out-Null
        if (Test-Path $file) { return $file }
    } catch {}
    return $null
}

function Get-ProcessInfoSafe {
    param([int]$Id)
    try {
        $p = Get-CimInstance Win32_Process -Filter "ProcessId=$Id" -ErrorAction Stop
        return $p
    } catch { return $null }
}

# --- FUNCIÓN DE MATADO FORZADO CON REPORTE DE ERRORES ---
function Stop-ProcessForce {
    param(
        [int]$TargetPid,
        [string]$ProcessName
    )
    
    # 1. Intento nativo de PowerShell
    try {
        Stop-Process -Id $TargetPid -Force -ErrorAction Stop
    } catch {}

    # 2. Verificar si sobrevivió
    $stillAlive = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
    if ($stillAlive) {
        # 3. Intento forzado a nivel de sistema operativo con Taskkill (Árbol completo /T)
        $cmdOutput = & taskkill.exe /F /T /PID $TargetPid 2>&1
        $stillAlive = Get-Process -Id $TargetPid -ErrorAction SilentlyContinue
        
        if ($stillAlive) {
            $reason = if ($cmdOutput) { $cmdOutput -join " " } else { "Acceso denegado o proceso protegido por el sistema/Anti-Cheat." }
            Write-Host "  [!] No se pudo cerrar $ProcessName (PID $TargetPid). Motivo: $reason" -ForegroundColor Red
            return $false
        } else {
            Write-Host "  [+] $ProcessName (PID $TargetPid) cerrado a la fuerza (Taskkill)." -ForegroundColor Green
            return $true
        }
    } else {
        Write-Host "  [+] $ProcessName (PID $TargetPid) cerrado exitosamente." -ForegroundColor Green
        return $true
    }
}

while($true) {
    Clear-Host
    
    # --- SYSTEM INFORMATION ---
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $bootTime = $osInfo.LastBootUpTime
    $uptime = (Get-Date) - $bootTime
    $isAdmin = if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { "Sí" } else { "No" }
    $arch = if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }

    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "                    SYSTEM INFORMATION                         " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "                    Made by XxAngelsosoxX                      " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host " PC Name   : $env:COMPUTERNAME"
    Write-Host " User      : $env:USERNAME"
    Write-Host " OS        : $($osInfo.Caption) ($($osInfo.Version))"
    Write-Host " Arch      : $arch"
    Write-Host " Boot Time : $($bootTime.ToString('yyyy-MM-dd HH:mm:ss'))"
    Write-Host " Uptime    : $($uptime.Days) días, $($uptime.Hours) horas, $($uptime.Minutes) minutos"
    Write-Host " Admin     : $isAdmin"
    Write-Host "================================================================" -ForegroundColor Cyan

    # --- HEALTH CHECK ---
    Write-Host "`n[ --- HEALTH CHECK --- ]" -ForegroundColor DarkCyan
    $serviciosLista = @("pcasvc","DPS","eventlog","bam","Appinfo","SysMain")
    foreach ($sName in $serviciosLista) {
        $serv = Get-Service -Name $sName -ErrorAction SilentlyContinue
        Write-Host "  - $sName : " -ForegroundColor Gray -NoNewline
        if ($null -eq $serv) {
            Write-Host "No encontrado" -ForegroundColor DarkGray
        } elseif ($serv.Status -eq 'Running') {
            Write-Host "Running" -ForegroundColor Green
        } else {
            Write-Host "$($serv.Status) (informativo; no implica manipulación)" -ForegroundColor Yellow
        }
    }

    Write-Host "`n##########################################################" -ForegroundColor Blue
    Write-Host "#              MULTISCRIPT - (KSHY112L)                  #" -ForegroundColor Blue
    Write-Host "#              Made by XxAngelsosoxX                     #" -ForegroundColor Blue
    Write-Host "#          [ MENÚ DE HERRAMIENTAS ]                      #" -ForegroundColor Blue
    Write-Host "##########################################################" -ForegroundColor Blue
    
    # SECCIÓN 1
    Write-Host "`n[ --- HERRAMIENTAS DE AUDITORÍA Y DETECCIÓN --- ]" -ForegroundColor DarkCyan
    Write-Host " [1]  Recording Killer                   " -ForegroundColor Red
    Write-Host " [2]  Filelezz                           " -ForegroundColor Cyan
    Write-Host " [3]  IFEO                               " -ForegroundColor Green
    Write-Host " [4]  Directorio Escáner (Ghost Clients) " -ForegroundColor Yellow
    Write-Host " [5]  VPN Detector                       " -ForegroundColor Magenta
    Write-Host " [6]  Extractor ShowJumpView             " -ForegroundColor White
    Write-Host " [7]  Services                           " -ForegroundColor DarkCyan
    Write-Host " [8]  File Scanner                       " -ForegroundColor Blue
    Write-Host " [9]  ForensicsWinrar                    " -ForegroundColor Green
    Write-Host " [10] BAM Detector                       " -ForegroundColor Gray
    Write-Host " [11] Parent Process Analyzer            " -ForegroundColor Cyan
    Write-Host " [12] DNS Cache Viewer                   " -ForegroundColor White
    Write-Host " [13] Tareas Programadas                 " -ForegroundColor Green
    Write-Host " [14] Recent Files Analyzer              " -ForegroundColor Magenta
    Write-Host " [15] Prefetch Inventory                 " -ForegroundColor Yellow
    Write-Host " [16] Network Connections                " -ForegroundColor Red
    Write-Host " [17] UserAssist Analyzer                " -ForegroundColor Cyan
    Write-Host " [18] PfCheck                            " -ForegroundColor Yellow
    Write-Host " [19] Submenú (Herramientas de Reparación, Limpieza y Avanzadas)" -ForegroundColor Cyan
    Write-Host " [20] Guía User                          " -ForegroundColor Green
    Write-Host " [0]  SALIR                              " -ForegroundColor DarkRed
    
    Write-Host "`n==========================================================" -ForegroundColor Blue
    
    $opcion = Read-Host "Selecciona una opción (0-20)"

    switch ($opcion) {
        '1' {
            Clear-Host
            Write-Host "[+] Recording Killer: buscando procesos relacionados..." -ForegroundColor Cyan
            $pattern = "obs|bdcam|action|sharex|captur|record|stream|twitch|studio|snipping|magnify|dvr|gamebar|xbox|reply|mirror|espejo"
            $protected = "java|javaw|explorer|svchost|system|csrss|wininit|winlogon|services|lsass|smss|csrss"
            
            $foundProcs = @(
                Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.Name -notmatch $protected -and
                    (($_.Name -match $pattern) -or ($_.CommandLine -match $pattern))
                } |
                ForEach-Object {
                    [PSCustomObject]@{
                        Nombre = $_.Name
                        PID = $_.ProcessId
                        Ruta = $_.ExecutablePath
                        CommandLine = $_.CommandLine
                    }
                }
            )

            if ($foundProcs.Count -eq 0) {
                Write-Host "[-] No se encontraron coincidencias." -ForegroundColor Green
                Read-Host "`nPresiona Enter..."
                break
            }

            for ($i=0; $i -lt $foundProcs.Count; $i++) {
                Write-Host "`n[$($i+1)] $($foundProcs[$i].Nombre) | PID $($foundProcs[$i].PID)" -ForegroundColor Yellow
                Write-Host "    Ruta: $($foundProcs[$i].Ruta)" -ForegroundColor Gray
            }

            Write-Host "`n[A] Solo mostrar / no modificar" -ForegroundColor Green
            Write-Host "[B] Cerrar uno" -ForegroundColor Yellow
            Write-Host "[C] Cerrar varios" -ForegroundColor Yellow
            Write-Host "[D] Cerrar todos excepto una selección" -ForegroundColor Red
            Write-Host "[E] Cerrar todos" -ForegroundColor Red
            Write-Host "[X] Cancelar" -ForegroundColor DarkRed
            $action = Read-Host "Selecciona una opción"

            if ($action -match '^[AaXx]$') {
                Write-Host "[-] No se realizaron modificaciones." -ForegroundColor Cyan
            } elseif ($action -match '^[Bb]$') {
                $n = Read-Host "Número del proceso"
                if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $foundProcs.Count) {
                    $target = $foundProcs[[int]$n-1]
                    if (Confirm-Action "Vas a cerrar $($target.Nombre) (PID $($target.PID)).") {
                        Stop-ProcessForce -TargetPid $target.PID -ProcessName $target.Nombre
                    } else {
                        Write-Host "[-] Acción cancelada por el usuario." -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "[!] Número fuera de rango o inválido (Rango válido: 1 - $($foundProcs.Count))." -ForegroundColor Red
                }
            } elseif ($action -match '^[Cc]$') {
                $selected = Select-NumberList -Max $foundProcs.Count
                if ($selected.Count -gt 0) {
                    if (Confirm-Action "Vas a cerrar $($selected.Count) procesos.") {
                        foreach ($n in $selected) {
                            $target = $foundProcs[$n-1]
                            Stop-ProcessForce -TargetPid $target.PID -ProcessName $target.Nombre
                        }
                    } else {
                        Write-Host "[-] Acción cancelada por el usuario." -ForegroundColor Yellow
                    }
                }
            } elseif ($action -match '^[Dd]$') {
                $keep = Select-NumberList -Max $foundProcs.Count -Prompt "Números que deseas PROTEGER (separados por comas)"
                $targets = 1..$foundProcs.Count | Where-Object { $_ -notin $keep }
                if ($targets.Count -gt 0) {
                    if (Confirm-Action "Vas a cerrar todos los procesos no protegidos.") {
                        foreach ($n in $targets) {
                            $target = $foundProcs[$n-1]
                            Stop-ProcessForce -TargetPid $target.PID -ProcessName $target.Nombre
                        }
                    } else {
                        Write-Host "[-] Acción cancelada por el usuario." -ForegroundColor Yellow
                    }
                }
            } elseif ($action -match '^[Ee]$') {
                if (Confirm-Action "Vas a cerrar TODOS los procesos encontrados.") {
                    foreach ($target in $foundProcs) {
                        Stop-ProcessForce -TargetPid $target.PID -ProcessName $target.Nombre
                    }
                } else {
                    Write-Host "[-] Acción cancelada por el usuario." -ForegroundColor Yellow
                }
            }
            Read-Host "`nPresiona Enter..."
        }
        '2' {
            # --- PATRÓN OPTIMIZADO Y AMPLIADO DE DETECCIÓN FILELEZZ ---
            $filelessPattern = "(?i)(Invoke-Expression|IEX|EncodedCommand|-enc|-e\s|DownloadString|Invoke-WebRequest|iwr|Invoke-RestMethod|irm|Start-BitsTransfer|ExecutionPolicy\s+Bypass|Bypass|-nop|-noexit|-w\s+hidden|-windowstyle\s+hidden)"

            :filelezzWhile while($true) {
                Clear-Host
                Write-Host "==========================================================" -ForegroundColor Cyan
                Write-Host "                       FILELEZZ                           " -ForegroundColor White -BackgroundColor DarkBlue
                Write-Host "==========================================================" -ForegroundColor Cyan
                Write-Host " [A] Quick Scan (Procesos y línea de comandos)            " -ForegroundColor Yellow
                Write-Host " [B] PowerShell Analysis (Políticas, módulos, PSReadLine) " -ForegroundColor Cyan
                Write-Host " [C] Event Viewer (Historial crítico + ShadowClicker)     " -ForegroundColor Green
                Write-Host " [D] Persistence (Startup, Tareas, Run y Registro)        " -ForegroundColor Magenta
                Write-Host " [E] Correlation (Motor de puntuación y reporte final)    " -ForegroundColor White
                Write-Host " [X] Volver al Menú Principal                             " -ForegroundColor DarkRed
                Write-Host "==========================================================" -ForegroundColor Cyan
                
                $opt = Read-Host "Selecciona una opción (A-E, X)"
                switch ($opt.ToUpper()) {
                    'A' {
                        Clear-Host
                        Write-Host "[+] Ejecutando Quick Scan de procesos activos..." -ForegroundColor Cyan
                        $procs = Get-CimInstance Win32_Process -Filter "Name LIKE '%powershell%' OR Name LIKE '%pwsh%' OR Name LIKE '%cmd%'" -ErrorAction SilentlyContinue
                        if ($procs) {
                            $results = foreach ($p in $procs) {
                                $isSuspicious = ($p.CommandLine -match $filelessPattern)
                                [PSCustomObject]@{
                                    PID         = $p.ProcessId
                                    Nombre      = $p.Name
                                    Alerta      = if ($isSuspicious) { "[!] COMANDO SOSPECHOSO" } else { "Normal" }
                                    CommandLine = $p.CommandLine
                                    Ruta        = $p.ExecutablePath
                                }
                            }
                            $results | Out-GridView -Title "Filelezz - Quick Scan (Procesos Activos)"
                        } else {
                            Write-Host "[-] No se detectaron procesos activos de PowerShell o CMD." -ForegroundColor Green
                        }
                        Read-Host "`nPresiona Enter para continuar..."
                    }
                    'B' {
                        Clear-Host
                        Write-Host "[+] Analizando Entorno PowerShell (ExecutionPolicy y PSReadLine)..." -ForegroundColor Cyan
                        $dataB = New-Object System.Collections.Generic.List[PSObject]
                        
                        foreach ($ep in (Get-ExecutionPolicy -List)) {
                            $isBypass = ($ep.ExecutionPolicy -match "Bypass|Unrestricted")
                            $dataB.Add([PSCustomObject]@{ 
                                Tipo      = "ExecutionPolicy"
                                Ubicacion = $ep.Scope
                                Detalle   = $ep.ExecutionPolicy
                                Alerta    = if ($isBypass) { "[!] POLITICA PERMISIVA" } else { "OK" }
                            })
                        }
                        
                        # Soporte multiversión (PowerShell 5.1 y PowerShell 7+)
                        $historyPaths = @(
                            "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
                            "$env:APPDATA\Microsoft\PowerShell\PSReadLine\ConsoleHost_history.txt"
                        )
                        foreach ($hPath in $historyPaths) {
                            if (Test-Path $hPath) {
                                $histLines = Get-Content $hPath -ErrorAction SilentlyContinue | Select-Object -Last 100
                                foreach ($line in $histLines) {
                                    $isSusp = ($line -match $filelessPattern)
                                    $dataB.Add([PSCustomObject]@{ 
                                        Tipo      = "PSReadLine History"
                                        Ubicacion = (Split-Path $hPath -Leaf)
                                        Detalle   = $line
                                        Alerta    = if ($isSusp) { "[!] COMANDO CRÍTICO DETECTADO" } else { "Línea Normal" }
                                    })
                                }
                            }
                        }
                        
                        if ($dataB.Count -gt 0) {
                            $dataB | Out-GridView -Title "Filelezz - PowerShell Analysis"
                        } else {
                            Write-Host "[-] Sin datos relevantes en el análisis de entorno." -ForegroundColor Green
                        }
                        Read-Host "`nPresiona Enter para continuar..."
                    }
                    'C' {
                        Clear-Host
                        Write-Host "[+] Consultando Visor de Eventos e indicadores de inyección..." -ForegroundColor Cyan
                        try {
                            $targetIds = @(400, 403, 600, 800, 4103, 4104)
                            $eventsList = @()
                            
                            # Consultas resilientes independientes por Log
                            foreach ($log in @('Windows PowerShell', 'Microsoft-Windows-PowerShell/Operational')) {
                                $evs = Get-WinEvent -FilterHashtable @{LogName=$log; Id=$targetIds} -MaxEvents 150 -ErrorAction SilentlyContinue
                                if ($evs) { $eventsList += $evs }
                            }

                            $parsed = foreach ($ev in $eventsList) {
                                $msg = $ev.Message
                                $isSusp = ($msg -match $filelessPattern -or $msg -match "ShadowClicker|MeowTonynoh|raw\.github")
                                [PSCustomObject]@{
                                    Fecha   = $ev.TimeCreated
                                    ID      = $ev.Id
                                    Log     = $ev.LogName
                                    Alerta  = if ($isSusp) { "[!] PATRÓN SOSPECHOSO DETECTADO" } else { "Normal" }
                                    Detalle = if ($msg.Length -gt 200) { $msg.Substring(0, 200) + "..." } else { $msg }
                                }
                            }
                            if ($parsed) {
                                $parsed | Out-GridView -Title "Filelezz - Event Viewer & Payload Analyzer"
                            } else {
                                Write-Host "[-] No se encontraron registros para los IDs especificados." -ForegroundColor Green
                            }
                        } catch {
                            Write-Host "[!] Acceso restringido o sin registros disponibles en el visor de eventos." -ForegroundColor Yellow
                        }
                        Read-Host "`nPresiona Enter para continuar..."
                    }
                    'D' {
                        Clear-Host
                        Write-Host "[+] Analizando Vectores de Persistencia..." -ForegroundColor Cyan
                        $persistenceData = New-Object System.Collections.Generic.List[PSObject]
                        
                        $runPaths = @(
                            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
                            "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
                            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
                        )
                        foreach ($rp in $runPaths) {
                            if (Test-Path $rp) {
                                $props = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }
                                foreach ($prop in $props) {
                                    $isSusp = ($prop.Value -match $filelessPattern)
                                    $persistenceData.Add([PSCustomObject]@{ 
                                        Vector    = "Registry Run"
                                        Ubicacion = $rp
                                        Nombre    = $prop.Name
                                        Comando   = $prop.Value
                                        Alerta    = if ($isSusp) { "[!] RUTA SOSPECHOSA" } else { "OK" }
                                    })
                                }
                            }
                        }
                        
                        $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notlike "\Microsoft\*" }
                        foreach ($t in $tasks) {
                            $actions = ($t.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" }) -join " | "
                            $isSusp = ($actions -match $filelessPattern)
                            $persistenceData.Add([PSCustomObject]@{ 
                                Vector    = "Scheduled Task"
                                Ubicacion = $t.TaskPath
                                Nombre    = $t.TaskName
                                Comando   = $actions
                                Alerta    = if ($isSusp) { "[!] TAREA CON PAYLOAD" } else { "OK" }
                            })
                        }
                        
                        if ($persistenceData.Count -gt 0) {
                            $persistenceData | Out-GridView -Title "Filelezz - Persistence Vectors"
                        } else {
                            Write-Host "[-] No se detectaron vectores de persistencia externos." -ForegroundColor Green
                        }
                        Read-Host "`nPresiona Enter para continuar..."
                    }
                    'E' {
                        Clear-Host
                        Write-Host "=======================================================" -ForegroundColor Cyan
                        Write-Host "            FILELEZZ CORRELATION REPORT                " -ForegroundColor White -BackgroundColor DarkBlue
                        Write-Host "=======================================================" -ForegroundColor Cyan
                        
                        $score = 0
                        $procs = Get-CimInstance Win32_Process -Filter "Name LIKE '%powershell%' OR Name LIKE '%pwsh%' OR Name LIKE '%cmd%'" -ErrorAction SilentlyContinue
                        foreach ($p in $procs) {
                            if ($p.CommandLine -match $filelessPattern) { $score += 3 } else { $score += 1 }
                        }
                        
                        $epBypass = @(Get-ExecutionPolicy -List | Where-Object { $_.ExecutionPolicy -match "Bypass|Unrestricted" }).Count
                        if ($epBypass -gt 0) { $score += 2 }
                        
                        $historyPaths = @(
                            "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
                            "$env:APPDATA\Microsoft\PowerShell\PSReadLine\ConsoleHost_history.txt"
                        )
                        foreach ($hPath in $historyPaths) {
                            if (Test-Path $hPath) {
                                $histContent = Get-Content $hPath -ErrorAction SilentlyContinue
                                if ($histContent -match $filelessPattern) {
                                    $score += 4
                                }
                            }
                        }
                        
                        $score = [Math]::Min(10, [Math]::Max(1, $score))
                        $barCount = [Math]::Floor($score)
                        $bar = ("█" * $barCount) + ("░" * (10 - $barCount))
                        
                        $level = if ($score -le 2) { "BAJO (🟢 0-2: Sin evidencia relevante)" }
                                 elseif ($score -le 5) { "MEDIO (🟡 3-5: Actividad sospechosa)" }
                                 elseif ($score -le 8) { "ALTO (🟠 6-8: Múltiples indicadores)" }
                                 else { "CRÍTICO (🔴 9-10: Evidencia muy consistente)" }

                        Write-Host " Score de Evidencia     : $score / 10" -ForegroundColor Yellow
                        Write-Host " Barra de Confianza     : [$bar]" -ForegroundColor Cyan
                        Write-Host " Nivel Evaluado         : $level" -ForegroundColor White
                        Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
                        Write-Host " INTERPRETACIÓN Y RECOMENDACIÓN FORENSE:" -ForegroundColor Green
                        Write-Host " * Búsqueda activa aplicada: Invoke-Expression, EncodedCommand," -ForegroundColor Gray
                        Write-Host "   DownloadString, Invoke-WebRequest, RestMethod," -ForegroundColor Gray
                        Write-Host "   Start-BitsTransfer, ExecutionPolicy Bypass y aliased (-enc, iwr, irm)." -ForegroundColor Gray
                        Write-Host " * Validar marcas de tiempo en el visor de eventos (IDs 4104)." -ForegroundColor Gray
                        Write-Host "=======================================================" -ForegroundColor Cyan
                        Read-Host "`nPresiona Enter para volver..."
                    }
                    'X' {
                        break filelezzWhile
                    }
                }
            }
        }
        '3' {
            Clear-Host
            Write-Host "[+] Analizando Image File Execution Options (IFEO)..." -ForegroundColor Cyan
            $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
            $Reporte = @()
            foreach ($App in (Get-ChildItem -Path $Path -ErrorAction SilentlyContinue)) {
                $Propiedad = Get-ItemProperty -Path $App.PSPath -Name "Debugger" -ErrorAction SilentlyContinue
                if ($null -ne $Propiedad.Debugger) {
                    $Reporte += [PSCustomObject]@{
                        Programa = $App.PSChildName
                        Debugger = $Propiedad.Debugger
                        Registro = $App.PSPath
                    }
                }
            }

            if ($Reporte.Count -eq 0) {
                Write-Host "[-] No se encontraron valores Debugger en IFEO." -ForegroundColor Green
                Read-Host "`nPresiona Enter..."
                break
            }

            for ($i=0; $i -lt $Reporte.Count; $i++) {
                Write-Host "`n[$($i+1)] $($Reporte[$i].Programa)" -ForegroundColor Yellow
                Write-Host "    Debugger: $($Reporte[$i].Debugger)" -ForegroundColor Gray
            }

            Write-Host "`n[A] Solo mostrar / no modificar" -ForegroundColor Green
            Write-Host "[B] Eliminar una entrada Debugger" -ForegroundColor Yellow
            Write-Host "[C] Eliminar varias entradas Debugger" -ForegroundColor Yellow
            Write-Host "[D] Eliminar todas las entradas encontradas" -ForegroundColor Red
            Write-Host "[X] Cancelar" -ForegroundColor DarkRed
            $action = Read-Host "Selecciona una opción"

            if ($action -match '^[Bb]$') {
                $n = Read-Host "Número de la entrada"
                if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $Reporte.Count) {
                    $target = $Reporte[[int]$n-1]
                    if (Confirm-Action "Vas a eliminar el valor Debugger de $($target.Programa).") {
                        $backup = Backup-RegistryKey $target.Registro
                        Remove-ItemProperty -Path $target.Registro -Name "Debugger" -Force -ErrorAction SilentlyContinue
                        Write-Host "[+] Modificación realizada. Backup: $backup" -ForegroundColor Green
                    }
                }
            } elseif ($action -match '^[Cc]$') {
                $selected = Select-NumberList -Max $Reporte.Count
                if ($selected.Count -gt 0 -and (Confirm-Action "Vas a eliminar $($selected.Count) valores Debugger.")) {
                    foreach ($n in $selected) {
                        $target = $Reporte[$n-1]
                        Backup-RegistryKey $target.Registro | Out-Null
                        Remove-ItemProperty -Path $target.Registro -Name "Debugger" -Force -ErrorAction SilentlyContinue
                    }
                    Write-Host "[+] Entradas seleccionadas modificadas." -ForegroundColor Green
                }
            } elseif ($action -match '^[Dd]$') {
                if (Confirm-Action "Vas a eliminar TODOS los valores Debugger encontrados.") {
                    foreach ($target in $Reporte) {
                        Backup-RegistryKey $target.Registro | Out-Null
                        Remove-ItemProperty -Path $target.Registro -Name "Debugger" -Force -ErrorAction SilentlyContinue
                    }
                    Write-Host "[+] Todas las entradas encontradas fueron modificadas." -ForegroundColor Green
                }
            } else {
                Write-Host "[-] No se realizaron modificaciones." -ForegroundColor Cyan
            }
            Read-Host "`nPresiona Enter..."
        }
        '4' {
            Write-Host "[+] Directorio Escáner" -ForegroundColor Cyan
            Write-Host "1. Buscar texto personalizado"
            Write-Host "2. Escaneo de indicadores conocidos"
            $subop = Read-Host "Selecciona una opción"
            if ($subop -eq '2') {
                $terms = @(
                    "Kill Aura","Crystal Aura","Aim Assist","TriggerBot","Auto Clicker","Chest Stealer",
                    "Player ESP","X-Ray","Fake Lag","Ping Spoof","Anti SS Tool","Self Destruct",
                    "USN Journal Cleaner","Delete USN Journal","Hooking","Injection","PatternScan",
                    "Trampoline","Detour","Internal","Obfuscated","Loader"
                )
                $patron = ($terms | ForEach-Object {[regex]::Escape($_)}) -join "|"
            } else {
                $patron = Read-Host "Escribe la palabra o expresión a buscar"
            }
            $ruta = Read-Host "Ingresa la ruta"
            if (Test-Path $ruta) {
                $encontrados = Get-ChildItem -Path $ruta -Recurse -File -ErrorAction SilentlyContinue |
                    Select-String -Pattern $patron -CaseSensitive:$false -ErrorAction SilentlyContinue |
                    Select-Object Path, LineNumber, Line
                if ($encontrados) {
                    Write-Host "[!] Coincidencias encontradas: $($encontrados.Count)" -ForegroundColor Yellow
                    Write-Host "[!] Una coincidencia textual por sí sola no demuestra que exista software malicioso." -ForegroundColor DarkYellow
                    $encontrados | Out-GridView -Title "Coincidencias para revisión"
                } else { Write-Host "[-] No se encontraron coincidencias." -ForegroundColor Green }
            } else { Write-Host "[!] Ruta no encontrada." -ForegroundColor Red }
            Read-Host "Presiona Enter..."
        }
        '5' {
            Write-Host "[+] Analizando conexión..." -ForegroundColor Cyan
            try {
                $ip = (Invoke-RestMethod https://api.ipify.org -ErrorAction Stop).Trim()
                $apiResponse = Invoke-RestMethod -Uri "https://proxycheck.io/v2/$ip`?vpn=1&asn=1"
                $status = $apiResponse.$ip.proxy
                if ($status -eq "yes") { Write-Host "[!] Proxy/VPN detectado: YES" -ForegroundColor Red } 
                else { Write-Host "[+] Proxy/VPN detectado: NO" -ForegroundColor Green }
            } catch { Write-Host "[!] Error al conectar con el servidor." -ForegroundColor Red }
            Read-Host "Presiona Enter..."
        }
        '6' {
            Write-Host "[+] Extrayendo ShowJumpView..." -ForegroundColor Cyan
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView"
            if (Test-Path $regPath) { Get-ItemProperty -Path $regPath | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider | Out-GridView -Title "Historial ShowJumpView" }
            else { Write-Host "[!] No hay registros encontrados." -ForegroundColor Red }
            Read-Host "Presiona Enter..."
        }
        '7' {
            Write-Host "[+] Auditoría de Servicios..." -ForegroundColor Cyan
            $servicios = "pcasvc", "DPS", "eventlog", "Appinfo", "DiagTrack", "SgrmBroker", "DcomLaunch", "bfe", "Dnacache", "WSearch", "Schedule", "StorSvc", "SysMain"
            $result = Get-Service -Name $servicios -ErrorAction SilentlyContinue |
                Select-Object Name, DisplayName, Status, StartType
            if ($result) {
                Write-Host "[!] STOPPED o DISABLED no demuestra por sí solo manipulación." -ForegroundColor DarkYellow
                $result | Out-GridView -Title "Auditoría de Servicios"
            } else { Write-Host "[-] No se encontraron los servicios consultados." -ForegroundColor Yellow }
            Read-Host "Presiona Enter..."
        }
        '8' {
            Write-Host "[+] Iniciando Escáner de Firmas Anómalas en Imágenes..." -ForegroundColor Cyan
            Write-Host "[!] Esto es una heurística: una firma encontrada NO demuestra esteganografía." -ForegroundColor DarkYellow
            $ruta = Read-Host "Ingresa la ruta de la carpeta a escanear"
            if (Test-Path $ruta) {
                $archivos = Get-ChildItem -Path $ruta -Include *.png,*.jpg,*.jpeg -Recurse -File -ErrorAction SilentlyContinue
                foreach ($f in $archivos) {
                    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
                    $mzOffset = -1
                    $pkOffset = -1
                    for ($i=0; $i -lt [Math]::Min($bytes.Length, 100000); $i++) {
                        if ($i+1 -lt $bytes.Length -and $bytes[$i] -eq 0x4D -and $bytes[$i+1] -eq 0x5A) { $mzOffset = $i; break }
                    }
                    for ($i=0; $i -lt [Math]::Min($bytes.Length, 100000); $i++) {
                        if ($i+1 -lt $bytes.Length -and $bytes[$i] -eq 0x50 -and $bytes[$i+1] -eq 0x4B) { $pkOffset = $i; break }
                    }
                    if (($mzOffset -gt 0) -or ($pkOffset -gt 0)) {
                        [PSCustomObject]@{Archivo=$f.FullName; MZ_Offset=$mzOffset; PK_Offset=$pkOffset; Nota="Indicador heurístico; requiere revisión"} | Out-GridView -Title "Firmas Anómalas"
                    }
                }
            } else { Write-Host "[!] Ruta no encontrada." -ForegroundColor Red }
            Read-Host "Presiona Enter..."
        }
        '9' {
            Write-Host "[+] Iniciando ForensicsWinrar..." -ForegroundColor Cyan
            $Resultados = @()
            $ArcPath = "HKCU:\Software\WinRAR\ArcHistory"
            if (Test-Path $ArcPath) {
                Get-ItemProperty -Path $ArcPath | ForEach-Object { $_.PSObject.Properties } | Where-Object { $_.Name -ne "PSPath" } | ForEach-Object {
                    $Resultados += [PSCustomObject]@{ Tipo="WinRAR Artifact"; Detalle="Accedido: " + $_.Value }
                }
            }
            if ($Resultados.Count -gt 0) { $Resultados | Out-GridView -Title "Resultados Forenses" }
            else { Write-Host "[-] No se hallaron artefactos de WinRAR." -ForegroundColor Green }
            Read-Host "Presiona Enter..."
        }
        '10' {
            Write-Host "[+] Detector de BAM (inventario de entradas)" -ForegroundColor DarkGray
            $BamPath = "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings"
            $results = @()
            if (Test-Path $BamPath) {
                foreach ($userKey in Get-ChildItem -Path $BamPath -ErrorAction SilentlyContinue) {
                    $props = Get-ItemProperty -Path $userKey.PSPath -ErrorAction SilentlyContinue
                    foreach ($p in $props.PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'}) {
                        $raw = $p.Value
                        $hex = if ($raw -is [byte[]]) { ([BitConverter]::ToString($raw)).Substring(0, [Math]::Min(80, ([BitConverter]::ToString($raw)).Length)) } else { [string]$raw }
                        $results += [PSCustomObject]@{
                            UsuarioKey = $userKey.PSChildName
                            Ejecutable = $p.Name
                            Datos = $hex
                            Nota = "Entrada BAM encontrada; requiere contexto temporal y correlación."
                        }
                    }
                }
            }
            if ($results.Count -gt 0) { $results | Out-GridView -Title "BAM - Entradas" }
            else { Write-Host "[-] No se encontraron entradas BAM." -ForegroundColor Yellow }
            Read-Host "Presiona Enter..."
        }
        '11' {
            Write-Host "[+] Analizando Árbol de Procesos..." -ForegroundColor Cyan
            $procs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue
            $map = @{}
            foreach ($p in $procs) { $map[[int]$p.ProcessId] = $p }
            $tree = foreach ($p in $procs) {
                $parent = $map[[int]$p.ParentProcessId]
                [PSCustomObject]@{
                    Process = $p.Name
                    PID = $p.ProcessId
                    ParentPID = $p.ParentProcessId
                    ParentName = if ($parent) {$parent.Name} else {"N/A"}
                    Path = $p.ExecutablePath
                    CommandLine = $p.CommandLine
                }
            }
            $tree | Out-GridView -Title "Árbol de Procesos - Contexto"
            Read-Host "Presiona Enter..."
        }
        '12' {
            Write-Host "[+] Extrayendo DNS Cache..." -ForegroundColor Cyan
            try { Get-DnsClientCache | Select-Object Entry, Data, Type | Out-GridView } 
            catch { Write-Host "[!] Error." -ForegroundColor Red }
            Read-Host "Presiona Enter..."
        }
        '13' {
            Write-Host "[+] Tareas Programadas..." -ForegroundColor Cyan
            $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | ForEach-Object {
                $task = $_
                $actions = ($task.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" }) -join " | "
                [PSCustomObject]@{
                    TaskName = $task.TaskName
                    TaskPath = $task.TaskPath
                    State = $task.State
                    Actions = $actions
                    Author = $task.Author
                }
            } | Where-Object { $_.TaskPath -notlike "\Microsoft\*" }
            if ($tasks) { $tasks | Out-GridView -Title "Tareas Programadas - Contexto" }
            else { Write-Host "[-] No se encontraron tareas no-Microsoft." -ForegroundColor Green }
            Read-Host "Presiona Enter..."
        }
        '14' {
            Write-Host "[+] Recientes..." -ForegroundColor Cyan
            $recentPath = "$env:APPDATA\Microsoft\Windows\Recent"
            if (Test-Path $recentPath) { Get-ChildItem -Path $recentPath -Recurse | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime -First 30 | Out-GridView }
            Read-Host "Presiona Enter..."
        }
        '15' {
            Write-Host "[+] Inventario de archivos Prefetch..." -ForegroundColor Yellow
            Write-Host "[!] El nombre/fecha del archivo no se interpreta aquí como prueba única de ejecución." -ForegroundColor DarkYellow
            $prefetchPath = "C:\Windows\Prefetch"
            if (Test-Path $prefetchPath) {
                Get-ChildItem -Path $prefetchPath -File |
                    Sort-Object LastWriteTime -Descending |
                    Select-Object Name, Length, CreationTime, LastWriteTime -First 100 |
                    Out-GridView -Title "Inventario Prefetch"
            } else { Write-Host "[-] Ruta Prefetch no encontrada." -ForegroundColor Yellow }
            Read-Host "`nPresiona Enter..."
        }
        '16' {
            Write-Host "[+] Conexiones activas..." -ForegroundColor Yellow
            $conns = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | ForEach-Object {
                $p = Get-ProcessInfoSafe $_.OwningProcess
                [PSCustomObject]@{
                    LocalAddress=$_.LocalAddress
                    LocalPort=$_.LocalPort
                    RemoteAddress=$_.RemoteAddress
                    RemotePort=$_.RemotePort
                    PID=$_.OwningProcess
                    ProcessName=if($p){$p.Name}else{"N/A"}
                    Path=if($p){$p.ExecutablePath}else{"N/A"}
                }
            }
            if ($conns) { $conns | Out-GridView -Title "Conexiones - Proceso Asociado" }
            else { Write-Host "[-] No se encontraron conexiones establecidas." -ForegroundColor Green }
            Read-Host "Presiona Enter..."
        }
        '17' {
            $basePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
            if (Test-Path $basePath) {
                $allData = New-Object System.Collections.Generic.List[PSObject]
                foreach ($key in Get-ChildItem -Path $basePath) {
                    $countPath = Join-Path -Path $key.PSPath -ChildPath "Count"
                    if (Test-Path $countPath) {
                        foreach ($item in (Get-ItemProperty -Path $countPath).PSObject.Properties) {
                            if ($item.Name -notmatch "^PS") {
                                $decodedName = ""
                                foreach ($c in $item.Name.ToCharArray()) {
                                    $val = [int][char]$c
                                    if ($val -ge 65 -and $val -le 90) { $decodedName += [char](65 + ($val - 65 + 13) % 26) }
                                    elseif ($val -ge 97 -and $val -le 122) { $decodedName += [char](97 + ($val - 97 + 13) % 26) }
                                    else { $decodedName += $c }
                                }
                                if ($item.Value.Length -ge 68) { $allData.Add([PSCustomObject]@{ Programa = $decodedName; Ejecuciones = [BitConverter]::ToInt32($item.Value, 4); Ultima_Vez = [DateTime]::FromFileTime([BitConverter]::ToInt64($item.Value, 60)) }) }
                            }
                        }
                    }
                }
                if ($allData.Count -gt 0) { $allData | Sort-Object Ultima_Vez -Descending | Out-GridView -Title "UserAssist" }
                else { Write-Host "[-] UserAssist vacío." -ForegroundColor Yellow; Start-Sleep 2 }
            } else { Write-Host "[-] Ruta no encontrada." -ForegroundColor Red; Start-Sleep 2 }
            Read-Host "Presiona Enter..."
        }
        '18' {
            Clear-Host
            Write-Host "[+] PfCheck: Analizando integridad de archivos Prefetch (.pf)..." -ForegroundColor Cyan
            
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
            $enablePrefetcher = (Get-ItemProperty -Path $regPath -Name "EnablePrefetcher" -ErrorAction SilentlyContinue).EnablePrefetcher
            Write-Host "  - Estado Registry EnablePrefetcher : $enablePrefetcher" -ForegroundColor $(if($enablePrefetcher -eq 3){"Green"}else{"Yellow"})
            if ($null -eq $enablePrefetcher) { 
                Write-Host "    [!] No se pudo leer el valor de EnablePrefetcher." -ForegroundColor Red 
            } elseif ($enablePrefetcher -eq 0) { 
                Write-Host "    [!] Advertencia: Prefetch está completamente DESHABILITADO (Valor 0)." -ForegroundColor Red 
            } elseif ($enablePrefetcher -ne 3) { 
                Write-Host "    [!] Advertencia: EnablePrefetcher tiene un valor no estándar ($enablePrefetcher)." -ForegroundColor Yellow 
            }

            $prefetchPath = "C:\Windows\Prefetch"
            $anomaliasPf = New-Object System.Collections.Generic.List[PSObject]

            if (Test-Path $prefetchPath) {
                $pfFiles = Get-ChildItem -Path $prefetchPath -Filter *.pf -File -ErrorAction SilentlyContinue
                foreach ($file in $pfFiles) {
                    $isAnomalous = $false
                    $motivo = ""

                    if ($file.Length -eq 0) {
                        $isAnomalous = $true
                        $motivo = "Archivo de 0 bytes (Vaciado/Trunkado por Bloc de Notas)"
                    } else {
                        try {
                            $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
                            if ($bytes.Length -ge 4) {
                                $magic = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
                                if ($magic -notmatch '^(MAM|SCCA)') {
                                    $isAnomalous = $true
                                    $motivo = "Firma de cabecera inválida o corrupta ($magic)"
                                }
                            } else {
                                $isAnomalous = $true
                                $motivo = "Archivo demasiado pequeño para cabecera válida"
                            }
                        } catch {
                            $isAnomalous = $true
                            $motivo = "Error de lectura de bytes"
                        }
                    }

                    if ($isAnomalous) {
                        $anomaliasPf.Add([PSCustomObject]@{
                            Nombre      = $file.Name
                            Ruta        = $file.FullName
                            TamanoBytes = $file.Length
                            UltimaMod   = $file.LastWriteTime
                            Diagnostico = $motivo
                        })
                    }
                }
            } else {
                Write-Host "[-] La ruta C:\Windows\Prefetch no existe o no es accesible." -ForegroundColor Red
            }

            if ($anomaliasPf.Count -eq 0) {
                Write-Host "[-] No se detectaron archivos .pf vacíos, truncados o con firmas alteradas." -ForegroundColor Green
            } else {
                Write-Host "[!] ¡Se encontraron $($anomaliasPf.Count) archivos .pf con anomalías o vaciados!" -ForegroundColor Red
                $anomaliasPf | Out-GridView -Title "PfCheck - Archivos Prefetch Anomalos / Vaciados"
            }
            Read-Host "`nPresiona Enter..."
        }
        '19' {
            :submenuWhile while($true) {
                Clear-Host
                Write-Host "==========================================================" -ForegroundColor Cyan
                Write-Host "        HERRAMIENTAS DE REPARACIÓN Y AVANZADAS            " -ForegroundColor White -BackgroundColor DarkBlue
                Write-Host "==========================================================" -ForegroundColor Cyan
                Write-Host " [1]  URL Block Audit / Repair             " -ForegroundColor Yellow
                Write-Host " [2]  Unlock CMD (Gpedit Bypass)           " -ForegroundColor Magenta
                Write-Host " [3]  Clear DisallowRun (Block Bypass)     " -ForegroundColor Red
                Write-Host " [4]  Gpedit (Regedit Bypass)              " -ForegroundColor Green
                Write-Host " [5]  Repair CMD / Power (Total)           " -ForegroundColor Cyan
                Write-Host " [6]  Firewall Outbound Audit / Repair     " -ForegroundColor Red
                Write-Host " [7]  Journal deleted detector             " -ForegroundColor DarkYellow
                Write-Host " [8]  Detectar Bypass FileInfo             " -ForegroundColor White
                Write-Host " [9]  Recycle Bin Audit                    " -ForegroundColor Green
                Write-Host " [10] SS Repair Kit (Manual/Confirmado)    " -ForegroundColor DarkGray
                Write-Host " [11] Directories                          " -ForegroundColor Cyan
                Write-Host " [0]  Volver al Menú Principal             " -ForegroundColor DarkRed
                Write-Host "==========================================================" -ForegroundColor Cyan
                
                $subChoice = Read-Host "Selecciona una opción (0-11)"
                switch ($subChoice) {
                    '1' {
                        Clear-Host
                        Write-Host "[+] Auditoría de URLBlocklist..." -ForegroundColor Cyan
                        $paths = @(
                            "HKLM:\SOFTWARE\Policies\Google\Chrome\URLBlocklist",
                            "HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLBlocklist",
                            "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\URLBlocklist"
                        )
                        $items = @()
                        foreach ($path in $paths) {
                            if (Test-Path $path) {
                                $props = (Get-ItemProperty -Path $path).PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'}
                                foreach ($item in $props) { $items += [PSCustomObject]@{Ruta=$path; Nombre=$item.Name; Valor=$item.Value} }
                            }
                        }
                        if ($items.Count -eq 0) { Write-Host "[-] No se encontraron entradas URLBlocklist." -ForegroundColor Green }
                        else {
                            $items | Out-GridView -Title "URLBlocklist - Auditoría"
                            Write-Host "[A] Solo ver  [B] Eliminar una  [C] Eliminar varias  [D] Eliminar todas  [X] Cancelar"
                            $action=Read-Host "Selecciona"
                            if ($action -match '^[BbCcDd]$' -and (Confirm-Action "Vas a modificar entradas de políticas de navegador.")) {
                                if ($action -match '^[Bb]$') { $n=Read-Host "Número de entrada"; $sel=@([int]$n) }
                                elseif ($action -match '^[Cc]$') { $sel=Select-NumberList -Max $items.Count }
                                else { $sel=1..$items.Count }
                                foreach ($n in $sel) {
                                    $item=$items[$n-1]; Backup-RegistryKey $item.Ruta | Out-Null
                                    Remove-ItemProperty -Path $item.Ruta -Name $item.Nombre -Force -ErrorAction SilentlyContinue
                                }
                                Write-Host "[+] Entradas seleccionadas modificadas." -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '2' {
                        Clear-Host
                        Write-Host "[+] Auditoría de DisableCMD..." -ForegroundColor Cyan
                        $paths = @("HKCU:\Software\Policies\Microsoft\Windows\System", "HKLM:\Software\Policies\Microsoft\Windows\System")
                        $found=@()
                        foreach($path in $paths) {
                            $v=Get-ItemProperty -Path $path -Name "DisableCMD" -ErrorAction SilentlyContinue
                            if($null -ne $v) { $found += [PSCustomObject]@{Ruta=$path; Valor=$v.DisableCMD} }
                        }
                        if($found.Count -eq 0) { Write-Host "[-] No se encontró DisableCMD." -ForegroundColor Green }
                        else {
                            $found | Out-GridView -Title "DisableCMD - Auditoría"
                            if(Confirm-Action "Vas a eliminar las restricciones DisableCMD encontradas.") {
                                foreach($item in $found) { Backup-RegistryKey $item.Ruta | Out-Null; Remove-ItemProperty -Path $item.Ruta -Name "DisableCMD" -Force -ErrorAction SilentlyContinue }
                                Write-Host "[+] Restricciones seleccionadas modificadas." -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '3' {
                        Clear-Host
                        $paths = @(
                            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun",
                            "HKCU:\Software\Policies\Microsoft\Windows\Explorer\DisallowRun",
                            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun"
                        )
                        $items=@()
                        foreach($path in $paths) {
                            if(Test-Path $path) {
                                $props=(Get-ItemProperty -Path $path).PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'}
                                foreach($p in $props) {$items += [PSCustomObject]@{Ruta=$path; Nombre=$p.Name; Programa=$p.Value}}
                            }
                        }
                        if($items.Count -eq 0) { Write-Host "[-] No se encontraron entradas DisallowRun." -ForegroundColor Green }
                        else {
                            $items | Out-GridView -Title "DisallowRun - Auditoría"
                            Write-Host "[A] Solo ver  [B] Una  [C] Varias  [D] Todas  [X] Cancelar"
                            $action=Read-Host "Selecciona"
                            if($action -match '^[BbCcDd]$' -and (Confirm-Action "Vas a modificar entradas DisallowRun.")) {
                                if($action -match '^[Bb]$'){ $n=Read-Host "Número"; $sel=@([int]$n) }
                                elseif($action -match '^[Cc]$'){ $sel=Select-NumberList -Max $items.Count }
                                else {$sel=1..$items.Count}
                                foreach($n in $sel){$item=$items[$n-1]; Backup-RegistryKey $item.Ruta | Out-Null; Remove-ItemProperty -Path $item.Ruta -Name $item.Nombre -Force -ErrorAction SilentlyContinue}
                                Write-Host "[+] Entradas seleccionadas modificadas." -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '4' {
                        Clear-Host
                        Write-Host "[+] Auditoría de DisableRegistryTools..." -ForegroundColor Cyan
                        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
                        $v=Get-ItemProperty -Path $regPath -Name "DisableRegistryTools" -ErrorAction SilentlyContinue
                        if($null -eq $v) { Write-Host "[-] No se encontró la restricción." -ForegroundColor Green }
                        else {
                            Write-Host "[!] Valor encontrado: $($v.DisableRegistryTools)" -ForegroundColor Yellow
                            if(Confirm-Action "Vas a eliminar DisableRegistryTools.") {
                                $backup=Backup-RegistryKey $regPath
                                Remove-ItemProperty -Path $regPath -Name "DisableRegistryTools" -Force -ErrorAction SilentlyContinue
                                Write-Host "[+] Restricción modificada. Backup: $backup" -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '5' {
                        Clear-Host
                        Write-Host "[+] Repair CMD / Power - modo controlled" -ForegroundColor Cyan
                        Write-Host "Se revisarán configuraciones concretas y solo se modificará lo que confirmes."
                        $findings=@()
                        $cmdPaths=@("HKLM:\SOFTWARE\Microsoft\Command Processor","HKCU:\Software\Microsoft\Command Processor")
                        foreach($path in $cmdPaths){if((Get-ItemProperty -Path $path -Name "AutoRun" -ErrorAction SilentlyContinue)){$findings += [PSCustomObject]@{Tipo="CMD AutoRun";Ruta=$path;Property="AutoRun"}}}
                        $policyPaths=@("HKCU:\Software\Policies\Microsoft\Windows\System","HKLM:\Software\Policies\Microsoft\Windows\System","HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")
                        foreach($path in $policyPaths){
                            if((Get-ItemProperty -Path $path -Name "DisableCMD" -ErrorAction SilentlyContinue)){$findings += [PSCustomObject]@{Tipo="DisableCMD";Ruta=$path;Property="DisableCMD"}}
                            $dr=Join-Path $path "DisallowRun"; if(Test-Path $dr){$findings += [PSCustomObject]@{Tipo="DisallowRun Key";Ruta=$path;Property="DisallowRun"}}
                        }
                        if((Get-ExecutionPolicy -Scope CurrentUser) -ne "Undefined"){$findings += [PSCustomObject]@{Tipo="ExecutionPolicy";Ruta="CurrentUser";Property=""}}
                        if($findings.Count -eq 0){Write-Host "[-] No se encontraron elementos en los puntos consultados." -ForegroundColor Green}
                        else{
                            for($i=0;$i -lt $findings.Count;$i++){Write-Host "[$($i+1)] $($findings[$i].Tipo) | $($findings[$i].Ruta)" -ForegroundColor Yellow}
                            $sel=Select-NumberList -Max $findings.Count
                            if($sel.Count -gt 0 -and (Confirm-Action "Vas a modificar $($sel.Count) elementos.")){
                                foreach($n in $sel){
                                    $item=$findings[$n-1]
                                    if($item.Property -eq "DisallowRun"){Backup-RegistryKey $item.Ruta | Out-Null; Remove-Item -Path (Join-Path $item.Ruta "DisallowRun") -Recurse -Force -ErrorAction SilentlyContinue}
                                    elseif($item.Property){Backup-RegistryKey $item.Ruta | Out-Null; Remove-ItemProperty -Path $item.Ruta -Name $item.Property -Force -ErrorAction SilentlyContinue}
                                    else{Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Undefined -Force -ErrorAction SilentlyContinue}
                                }
                                Write-Host "[+] Cambios seleccionados realizados." -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '6' {
                        Clear-Host
                        Write-Host "[+] Auditoría de reglas Firewall Outbound Block..." -ForegroundColor Cyan
                        $Reglas = @(Get-NetFirewallRule -Direction Outbound -Action Block -ErrorAction SilentlyContinue)
                        if($Reglas.Count -eq 0){Write-Host "[-] No se encontraron reglas de salida bloqueadas." -ForegroundColor Green}
                        else{
                            $data=@()
                            foreach($r in $Reglas){
                                $app=Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $r -ErrorAction SilentlyContinue
                                $data += [PSCustomObject]@{Nombre=$r.DisplayName; Enabled=$r.Enabled; Profile=$r.Profile; Program=($app.Program -join ", ")}
                            }
                            $data | Out-GridView -Title "Firewall - Reglas Outbound Block"
                            for($i=0;$i -lt $Reglas.Count;$i++){Write-Host "[$($i+1)] $($Reglas[$i].DisplayName)" -ForegroundColor Yellow}
                            Write-Host "[A] Solo ver  [B] Una  [C] Varias  [D] Todas  [X] Cancelar"
                            $action=Read-Host "Selecciona"
                            if($action -match '^[BbCcDd]$' -and (Confirm-Action "Vas a eliminar reglas de firewall y puedes afectar conectividad.")){
                                if($action -match '^[Bb]$'){$n=Read-Host "Número";$sel=@([int]$n)}
                                elseif($action -match '^[Cc]$'){$sel=Select-NumberList -Max $Reglas.Count}
                                else{$sel=1..$Reglas.Count}
                                foreach($n in $sel){Remove-NetFirewallRule -Name $Reglas[$n-1].Name -ErrorAction SilentlyContinue}
                                Write-Host "[+] Reglas seleccionadas eliminadas." -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '7' {
                        Write-Host "[+] Journal deleted detector (Buscando eventos de eliminación del USN Journal)..." -ForegroundColor Cyan
                        try {
                            $events = Get-WinEvent -LogName "Microsoft-Windows-NTFS/Operational" -ErrorAction SilentlyContinue |
                                Where-Object { $_.Id -eq 3019 -or $_.Message -match "USN Journal" }
                            if ($events) {
                                Write-Host "[!] ¡Se encontraron eventos relacionados con USN Journal!" -ForegroundColor Yellow
                                $events | Select-Object TimeCreated, Id, Message | Out-GridView -Title "Journal Deleted Detector"
                            } else {
                                Write-Host "[-] No se encontraron eventos de eliminación del USN Journal en el registro NTFS Operational (puede estar deshabilitado)." -ForegroundColor Green
                            }
                        } catch {
                            Write-Host "[-] No se pudo acceder al log NTFS Operational o no hay registros." -ForegroundColor Green
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '8' {
                        Write-Host "[+] Escaneando eventos de sistema en busca de FileInfo..." -ForegroundColor Cyan
                        try {
                            $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
                            $events = Get-WinEvent -LogName System -ErrorAction SilentlyContinue |
                                Where-Object { ($_.Id -eq 1 -or $_.Id -eq 6) -and ($_.TimeCreated -gt $bootTime) -and ($_.Message -match "FileInfo") }
                            if ($events) {
                                Write-Host "[!] ¡Eventos encontrados!" -ForegroundColor Red
                                $events | Sort-Object TimeCreated -Descending | Select-Object TimeCreated, Id, Message | Out-GridView -Title "Bypass FileInfo Detector"
                            } else { Write-Host "[-] No se detectaron eventos sospechosos de FileInfo." -ForegroundColor Green }
                        } catch { Write-Host "[!] Error al acceder los logs." -ForegroundColor Red }
                        Read-Host "Presiona Enter..."
                    }
                    '9' {
                        Write-Host "[+] Recycle Bin Audit (Solo Auditoría)..." -ForegroundColor Cyan
                        try {
                            $recycleBin = (New-Object -ComObject Shell.Application).NameSpace(10).Items()
                            $recycleBin | Select-Object Name, Path, Size, Type, @{Name="Modified";Expression={$_.ModifyDate}} | Out-GridView -Title "Auditoría de Papelera de Reciclaje"
                        } catch {
                            Write-Host "[-] No se pudo acceder a los metadatos de la papelera." -ForegroundColor Yellow
                        }
                        Read-Host "Presiona Enter..."
                    }
                    '10' {
                        Clear-Host
                        Write-Host "[+] SS Repair Kit - modo controlado" -ForegroundColor Yellow
                        Write-Host "1. Auditar restricciones"
                        Write-Host "2. Reparar restricciones seleccionadas"
                        $sub = Read-Host "Selecciona una opción"
                        $items = @()
                        $items += [PSCustomObject]@{Nombre="DisableCMD HKCU"; Path="HKCU:\Software\Policies\Microsoft\Windows\System"; Property="DisableCMD"}
                        $items += [PSCustomObject]@{Nombre="DisableCMD HKLM"; Path="HKLM:\Software\Policies\Microsoft\Windows\System"; Property="DisableCMD"}
                        $items += [PSCustomObject]@{Nombre="DisableRegistryTools"; Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"; Property="DisableRegistryTools"}
                        $items += [PSCustomObject]@{Nombre="PowerShell ExecutionPolicy CurrentUser"; Path=""; Property=""}
                        $found = @()
                        foreach ($item in $items) {
                            if ($item.Path -and (Get-ItemProperty -Path $item.Path -Name $item.Property -ErrorAction SilentlyContinue)) {
                                $found += $item
                            } elseif ($item.Name -like "*ExecutionPolicy*" -and (Get-ExecutionPolicy -Scope CurrentUser) -ne "Undefined") {
                                $found += $item
                            }
                        }
                        if ($found.Count -eq 0) {
                            Write-Host "[+] No se encontraron restricciones en los puntos consultados." -ForegroundColor Green
                        } elseif ($sub -eq '1') {
                            $found | Select-Object Nombre, Path, Property | Out-GridView -Title "Auditoría de Restricciones"
                        } elseif ($sub -eq '2') {
                            for ($i=0; $i -lt $found.Count; $i++) { Write-Host "[$($i+1)] $($found[$i].Nombre)" -ForegroundColor Yellow }
                            $selected = Select-NumberList -Max $found.Count
                            if ($selected.Count -gt 0 -and (Confirm-Action "Vas a modificar $($selected.Count) elementos de configuración.")) {
                                foreach ($n in $selected) {
                                    $item = $found[$n-1]
                                    if ($item.Path) {
                                        Backup-RegistryKey $item.Path | Out-Null
                                        Remove-ItemProperty -Path $item.Path -Name $item.Property -Force -ErrorAction SilentlyContinue
                                    } elseif ($item.Name -like "*ExecutionPolicy*") {
                                        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Undefined -Force -ErrorAction SilentlyContinue
                                    }
                                }
                                Write-Host "[+] Reparaciones seleccionadas completadas." -ForegroundColor Green
                            }
                        }
                        Read-Host "`nPresiona Enter..."
                    }
                    '11' {
                        while ($true) {
                            Clear-Host
                            Write-Host "=========================" -ForegroundColor Cyan
                            Write-Host "Directories" -ForegroundColor White -BackgroundColor DarkBlue
                            Write-Host "Quick Forensic Access" -ForegroundColor Cyan
                            Write-Host "=========================" -ForegroundColor Cyan

                            $dirList = @(
                                @{ Name = "1. Prefetch"; Path = "C:\Windows\Prefetch"; Type = "Folder" },
                                @{ Name = "2. Recent"; Path = "$env:APPDATA\Microsoft\Windows\Recent"; Type = "Folder" },
                                @{ Name = "3. AutomaticDestinations"; Path = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"; Type = "Folder" },
                                @{ Name = "4. CustomDestinations"; Path = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"; Type = "Folder" },
                                @{ Name = "5. PowerShell History"; Path = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"; Type = "File" },
                                @{ Name = "6. Temp usuario"; Path = "$env:TEMP"; Type = "Folder" },
                                @{ Name = "7. Temp Windows"; Path = "C:\Windows\Temp"; Type = "Folder" },
                                @{ Name = "8. Amcache"; Path = "C:\Windows\AppCompat\Programs"; Type = "Folder" },
                                @{ Name = "9. SRUM"; Path = "C:\Windows\System32\sru"; Type = "Folder" },
                                @{ Name = "10. Recycle Bin"; Path = "C:\$Recycle.Bin"; Type = "Folder" },
                                @{ Name = "11. Startup Usuario"; Path = "$([Environment]::GetFolderPath('Startup'))"; Type = "Folder" },
                                @{ Name = "12. Startup Todos"; Path = "$([Environment]::GetFolderPath('CommonStartup'))"; Type = "Folder" },
                                @{ Name = "13. ProgramData"; Path = "C:\ProgramData"; Type = "Folder" },
                                @{ Name = "14. Roaming"; Path = "$env:APPDATA"; Type = "Folder" },
                                @{ Name = "15. Local"; Path = "$env:LOCALAPPDATA"; Type = "Folder" },
                                @{ Name = "16. LocalLow"; Path = "$env:USERPROFILE\AppData\LocalLow"; Type = "Folder" },
                                @{ Name = "17. Downloads"; Path = "$env:USERPROFILE\Downloads"; Type = "Folder" },
                                @{ Name = "18. Desktop"; Path = "$env:USERPROFILE\Desktop"; Type = "Folder" },
                                @{ Name = "19. Documents"; Path = "$env:USERPROFILE\Documents"; Type = "Folder" },
                                @{ Name = "20. UserAssist Registry"; Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"; Type = "Registry" },
                                @{ Name = "21. BAM"; Path = "HKLM\SYSTEM\CurrentControlSet\Services\bam"; Type = "Registry" },
                                @{ Name = "22. IFEO"; Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"; Type = "Registry" },
                                @{ Name = "23. Firewall Rules"; Path = "wf.msc"; Type = "Tool" },
                                @{ Name = "24. Task Scheduler"; Path = "taskschd.msc"; Type = "Tool" },
                                @{ Name = "25. Event Viewer"; Path = "eventvwr.msc"; Type = "Tool" },
                                @{ Name = "26. Services"; Path = "services.msc"; Type = "Tool" },
                                @{ Name = "27. Registry Editor"; Path = "regedit.exe"; Type = "Tool" },
                                @{ Name = "28. CMD"; Path = "cmd.exe"; Type = "Tool" },
                                @{ Name = "29. PowerShell"; Path = "powershell.exe"; Type = "Tool" },
                                @{ Name = "30. Windows Logs"; Path = "C:\Windows\System32\winevt\Logs"; Type = "Folder" },
                                @{ Name = "31. Hosts"; Path = "C:\Windows\System32\drivers\etc\hosts"; Type = "File" },
                                @{ Name = "32. DNS Cache (CMD)"; Path = "ipconfig /displaydns"; Type = "Command" },
                                @{ Name = "33. JumpLists"; Path = "$env:APPDATA\Microsoft\Windows\Recent"; Type = "Folder" },
                                @{ Name = "34. ShellBags"; Path = "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"; Type = "Registry" },
                                @{ Name = "35. WER (Error Reporting)"; Path = "C:\ProgramData\Microsoft\Windows\WER"; Type = "Folder" },
                                @{ Name = "36. CrashDumps"; Path = "C:\Windows\CrashDumps"; Type = "Folder" },
                                @{ Name = "37. ShimCache Registry"; Path = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache"; Type = "Registry" },
                                @{ Name = "38. WER ReportArchive"; Path = "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"; Type = "Folder" },
                                @{ Name = "39. Tasks Folder"; Path = "C:\Windows\System32\Tasks"; Type = "Folder" },
                                @{ Name = "40. Drivers Folder"; Path = "C:\Windows\System32\drivers"; Type = "Folder" },
                                @{ Name = "41. Minidump"; Path = "C:\Windows\Minidump"; Type = "Folder" },
                                @{ Name = "42. WMI Repository"; Path = "C:\Windows\System32\wbem\Repository"; Type = "Folder" },
                                @{ Name = "43. USN Journal (\$Extend)"; Path = "C:\$Extend\$UsnJrnl"; Type = "Folder" }
                            )

                            foreach ($d in $dirList) {
                                Write-Host " [$($d.Name)]" -ForegroundColor Yellow
                            }
                            Write-Host " [0] Volver al Submenú" -ForegroundColor DarkRed
                            Write-Host "==========================================================" -ForegroundColor Cyan

                            $selDir = Read-Host "Selecciona un elemento (1-43) o 0 para salir"
                            if ($selDir -eq '0') { break }
                            if ($selDir -match '^\d+$' -and [int]$selDir -ge 1 -and [int]$selDir -le $dirList.Count) {
                                $targetItem = $dirList[[int]$selDir - 1]
                                
                                while ($true) {
                                    Clear-Host
                                    Write-Host "=========================" -ForegroundColor Cyan
                                    Write-Host "Directories - DETALLE" -ForegroundColor White -BackgroundColor DarkBlue
                                    Write-Host "=========================" -ForegroundColor Cyan
                                    
                                    $exists = $false
                                    if ($targetItem.Type -eq 'Folder' -or $targetItem.Type -eq 'File') {
                                        $exists = Test-Path $targetItem.Path -ErrorAction SilentlyContinue
                                    } elseif ($targetItem.Type -eq 'Registry') {
                                        $regCheck = $targetItem.Path -replace '^HKCU:', 'Registry::HKEY_CURRENT_USER' -replace '^HKLM:', 'Registry::HKEY_LOCAL_MACHINE'
                                        $exists = Test-Path $regCheck -ErrorAction SilentlyContinue
                                    } else {
                                        $exists = $true
                                    }

                                    $existsStr = if ($exists) { "Sí" } else { "No encontrada" }
                                    $statusStr = switch ($targetItem.Type) {
                                        'Folder' { "Carpeta Forense / Sistema" }
                                        'File'   { "Archivo de Registro / Historial" }
                                        'Registry' { "Hive del Registro de Windows" }
                                        'Tool'   { "Herramienta del Sistema (MSC/EXE)" }
                                        'Command'{ "Comando Directo de Consola" }
                                    }

                                    Write-Host "Ruta   : $($targetItem.Path)" -ForegroundColor White
                                    Write-Host "Estado : $statusStr" -ForegroundColor Gray
                                    Write-Host "Existe : $existsStr" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
                                    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
                                    Write-Host " [1] Abrir" -ForegroundColor Green
                                    Write-Host " [2] Copiar Ruta" -ForegroundColor Yellow
                                    Write-Host " [0] Volver al listado" -ForegroundColor DarkRed
                                    Write-Host "==================================================" -ForegroundColor Cyan

                                    $actionChoice = Read-Host "Selecciona una acción"
                                    if ($actionChoice -eq '0') { break }
                                    elseif ($actionChoice -eq '1') {
                                        try {
                                            if ($targetItem.Path -like "*\hosts") {
                                                Start-Process notepad.exe -ArgumentList "`"$($targetItem.Path)`"" -ErrorAction SilentlyContinue
                                            } elseif ($targetItem.Type -eq 'Folder' -or $targetItem.Type -eq 'File') {
                                                if (Test-Path $targetItem.Path) {
                                                    Start-Process explorer.exe -ArgumentList "`"$($targetItem.Path)`"" -ErrorAction SilentlyContinue
                                                } else {
                                                    Write-Host "[!] La ruta no existe en el sistema." -ForegroundColor Red
                                                    Start-Sleep 1
                                                }
                                            } elseif ($targetItem.Type -eq 'Registry') {
                                                Start-Process regedit.exe -ErrorAction SilentlyContinue
                                                Write-Host "[+] Regedit abierto. Navegando a: $($targetItem.Path)" -ForegroundColor Green
                                                Start-Sleep 1
                                            } elseif ($targetItem.Type -eq 'Tool') {
                                                Start-Process $targetItem.Path -ErrorAction SilentlyContinue
                                            } elseif ($targetItem.Type -eq 'Command') {
                                                Start-Process cmd.exe -ArgumentList "/k $($targetItem.Path)" -ErrorAction SilentlyContinue
                                            }
                                        } catch {
                                            Write-Host "[!] No se pudo abrir el recurso." -ForegroundColor Red
                                            Start-Sleep 1
                                        }
                                    }
                                    elseif ($actionChoice -eq '2') {
                                        Set-Clipboard $targetItem.Path
                                        Write-Host "[+] Ruta copiada al portapapeles exitosamente." -ForegroundColor Green
                                        Start-Sleep 1
                                    }
                                }
                            }
                        }
                    }
                    '0' {
                        break submenuWhile
                    }
                }
            }
        }
        '20' {
            Clear-Host
            Write-Host "--- Guía User: MULTISCRIPT (KSHY112L) ---" -ForegroundColor Cyan
            Write-Host "Suite integral de auditoría, análisis forense y reparación controlada." -ForegroundColor White
            Write-Host "`nREGLA GENERAL:" -ForegroundColor Yellow
            Write-Host "Encontrar una pista no equivale automáticamente a demostrar una actividad maliciosa." -ForegroundColor Gray
            
            Write-Host "`n[MÓDULOS DE AUDITORÍA Y DETECCIÓN (SECCIÓN 1)]" -ForegroundColor Green
            Write-Host " [1] Recording Killer: Muestra procesos de grabación/streaming y los cierra a la fuerza con reporte."
            Write-Host " [2] Filelezz: Suite para detectar PowerShell inyectado, comandos ofuscados (Bypass, Encoded, RestMethod) y persistencia."
            Write-Host " [3] IFEO: Muestra valores Debugger en el registro y permite su eliminación."
            Write-Host " [4] Directorio Escáner: Busca texto o indicadores en carpetas."
            Write-Host " [5] VPN Detector: Consulta IP actual para determinar presencia de proxy/VPN."
            Write-Host " [6] ShowJumpView: Extrae historial de uso de elementos recientes."
            Write-Host " [7] Services: Lista servicios del sistema y su estado."
            Write-Host " [8] File Scanner: Analiza firmas anómalas en imágenes (heurística)."
            Write-Host " [9] ForensicsWinrar: Revisa artefactos e historial de WinRAR."
            Write-Host " [10] BAM Detector: Inventario de ejecuciones en Background Activity Monitor."
            Write-Host " [11] Parent Process Analyzer: Analiza árbol de procesos y contexto de padres."
            Write-Host " [12] DNS Cache Viewer: Extrae caché actual de DNS."
            Write-Host " [13] Tareas Programadas: Lista tareas que no pertenecen a Microsoft."
            Write-Host " [14] Recent Files Analyzer: Muestra archivos recientes accedidos."
            Write-Host " [15] Prefetch Inventory: Muestra archivos Prefetch del sistema."
            Write-Host " [16] Network Connections: Relaciona conexiones TCP activas con procesos."
            Write-Host " [17] UserAssist Analyzer: Decodifica ROT13 y lista ejecuciones de interfaz."
            Write-Host " [18] PfCheck: Audita estado de EnablePrefetcher y detecta archivos .pf vaciados o corruptos."
            Write-Host " [19] Submenú: Herramientas de Reparación, Limpieza y Avanzadas."
            Write-Host " [20] Guía User: Visualiza esta guía integrada."

            Write-Host "`n[REPARACIÓN, LIMPIEZA Y AVANZADAS (SUBMENÚ)]" -ForegroundColor Green
            Write-Host " [1-11] Herramientas del submenú avanzado."
            Read-Host "`nPresiona Enter para volver..."
        }
        '0' { 
            Show-ProjectCredits
            Exit 
        }
    }
}

function Show-ProjectCredits {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Proyecto creado por XxangelsosoxX" -ForegroundColor White
    Write-Host ""
    Write-Host "Si encuentras un error o tienes sugerencias," -ForegroundColor Gray
    Write-Host "háblame por Discord: Angel_ytz" -ForegroundColor Gray
    Write-Host "Servidor favorito: Play.tilted.lol" -ForegroundColor Gray
    Write-Host "==================================================" -ForegroundColor Cyan
}