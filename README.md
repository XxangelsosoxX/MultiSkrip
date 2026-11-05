
# 🛠️ MULTISKRIP - KSHY112L

> Herramienta creada por **XxangelsosoxX**  
> Suite multifunción desarrollada en **PowerShell** para análisis, diagnóstico, reparación y revisión de sistemas Windows.

**[⬇️ HAZ CLIC AQUÍ PARA DESCARGAR MULTISKRIP](https://github.com/XxangelsosoxX/MultiSkrip/releases/latest)**

---

### ⚡ Instalación Rápida

```powershell
irm 'https://raw.githubusercontent.com/XxangelsosoxX/MultiSkrip/main/MultiSkrip.ps1' | iex
## 📢 Discord / Updates
---
Servidor de Discord: https://discord.gg/PWSbNGPvnH  
Discord de contacto directo: **xxangelsosoxx**

---

## ✍️ Autor

**XxangelsosoxX**

Proyecto desarrollado en **PowerShell**.

### ⚠️ Aclaraciones Importantes:

* **Falsos Positivos:** Al ser una herramienta de auditoría que analiza memoria y registros del sistema, algunos antivirus o navegadores pueden detectarla como falso positivo. La ejecución es completamente transparente y de código abierto.
* **Desarrollo Activo (Beta):** Al encontrarse en fase Beta, se lanzarán **actualizaciones periódicas** para corregir detalles, añadir nuevos módulos y mejorar la detección.

## MultiSkrip es una herramienta de análisis, diagnóstico y administración de Windows.

Los resultados de determinados módulos se basan en heurísticas, registros y artefactos disponibles en el sistema. Un indicador detectado **no constituye por sí solo una prueba definitiva** de actividad maliciosa; existen mods o programas legales que usan inyección de código o métodos similares a un bypass-attempt, dejando residuos en memoria que sueltan falsos positivos. Quien haga el screenshare debe revisar más a fondo y validar el hallazgo encontrado antes de sancionar, evitando así el **FALSE BAN**.

---

## 📖 Descripción

**MultiSkrip** es una suite interactiva desarrollada de forma nativa en **PowerShell**, orientada a la revisión profunda del sistema, diagnóstico y análisis de artefactos de Windows (SS).

La herramienta reúne **más de 35 funciones** dentro de un menú centralizado.

El objetivo del proyecto es proporcionar diferentes herramientas de análisis y administración desde una única interfaz de consola, utilizando funciones nativas de Windows y PowerShell siempre que sea posible.

> ⚠️ Algunas funciones requieren ejecutar PowerShell como **Administrador**.

---

# 🖥️ System Information

Al iniciar MultiSkrip, la herramienta muestra información general del sistema y realiza comprobaciones iniciales de servicios y eventos.

```text
================================================================
                    SYSTEM INFORMATION
                    Made by XxangelsosoxX
================================================================
 PC Name   : DESKTOP-EJEMPLO
 User      : Usuario
 OS        : Microsoft Windows 10 Pro (10.0.19045)
 Arch      : 64-bit
 Boot Time : 2025-11-03 00:23:37
 Uptime    : 1 días, 19 horas, 24 minutos
 Admin     : Sí
================================================================

[ --- HEALTH CHECK --- ]
 Sistema   : [+] Admin   [+] Firewall (3/3)   [+] Defender   [+] DNS (142)
 Sesiones  : [+] 1 activa (Usuario)
 Red       : [+] Conectividad   [+] Sin RDP   [+] Sin VPN
 Reloj     : [+] 2025-11-03 19:47:12 (UTC-05:00)

 Chequeos
    Prefetch   : [+] 312 archivos .pf | Accesible
    BAM        : [+] 1456 entradas
    Papelera   : [+] Sin vaciado reciente
    Logs       : [+] Security y System intactos
    Hora       : [+] Sin cambios sospechosos
    Eventos    : [+] Sin eventos sospechosos en 24h

  Utilidades  : [+] UserAssist (842)   [+] SRUM
  Servicios   : [+] 13/13 running
================================================================
```

### 📊 Información inicial

- **System Information:** muestra información básica del equipo, arquitectura, usuario, privilegios y tiempo de actividad.
- **Health Check:** comprueba el estado de diferentes servicios de Windows (DcomLaunch, RpcSs, RpcEptMapper, EventLog, Schedule, Winmgmt, BFE, MpsSvc, pcasvc, DPS, SysMain, Appinfo, bam).
- **Recent System Events:** permite revisar eventos recientes relacionados con apagados, reinicios y errores del sistema.

---

# ⚡ Alerta de Arranque por Eventos de Energía

MultiSkrip **captura** los eventos de energía recientes del sistema para **reconstruir** la línea temporal de apagados y reinicios:

- **Kernel-Power 41:** apagados o reinicios inesperados.
- **EventID 6008:** apagado inesperado del sistema.
- **BugCheck 1001:** eventos relacionados con errores graves/BSOD.
- **EventID 1074:** reinicios o apagados iniciados por procesos o usuarios.

La finalidad es proporcionar contexto sobre el estado reciente del sistema.

---

## 1. 🚀 INICIO Y HEALTH CHECK (Boot)

### 1.1 — Inicialización de consola y QuickEdit
**Configura** el buffer a 2000 líneas y **desactiva** QuickEdit mediante P/Invoke a **`kernel32.dll`**:

```powershell
Add-Type -Name "K32" -Namespace "W32" -MemberDefinition '
  [DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
  [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
  [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);'
$h = $kernel32::GetStdHandle(-10)                      # STD_INPUT_HANDLE
$kernel32::SetConsoleMode($h, $m -band -bnot 0x0040)   # quita ENABLE_QUICK_EDIT_MODE
```

### 1.2 — Selección de idioma (ES/EN)
- `[1]` → `ES` · cualquier otro → `EN` (default).
- `$Global:Traducciones` con **~500 claves por idioma**. Función `T 'Clave'` **resuelve** la traducción o devuelve la clave literal si falta.

### 1.3 — Consentimiento
- **ES:** `¿El usuario autorizó la revisión del sistema? [S/N]`
- **EN:** `Did the user authorize system review? [Y/N]`
- **Valida** entradas: `s`, `si`, `sí`, `y`, `yes`. Cualquier otra → exit.

### 1.4 — Comprobación de PowerShell 5.1
**Evalúa** `$PSVersionTable.PSVersion.Major -lt 5`. Si falla:
- **Expone** la versión detectada y el requisito mínimo (5.1).
- Enlace WMF 5.1: `https://www.microsoft.com/en-us/download/details.aspx?id=54616`
- **Alerta crítica:** *"Si estás en un screenshare EN VIVO, NO reinicies la PC."*
- **Documenta** versiones por defecto: W8/8.1 trae PS 3.0; W10/11 trae 5.1.

### 1.5 — Auto-elevación
**Consulta** `WindowsPrincipal.IsInRole(Administrator)`:
- `.exe` compilado → `Start-Process -FilePath $currentExe -Verb RunAs`
- Script → `Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs` + `Exit`

Si no es admin, **relanza** el script entero elevado.

### 1.6 — Validación de entorno
**Verifica** la disponibilidad de 4 cmdlets críticos: `Get-WinEvent`, `Get-AuthenticodeSignature`, `Get-CimInstance`, `Get-FileHash`. Si falta alguno, **advierte** sin abortar y garantiza que los módulos dependientes muestren error explícito.

### 1.7 — Health Check (`Update-MenuCache`)
**Construye** un snapshot del sistema **una sola vez** y **cachea** en `$Global:Cached*`:

| Caché | Origen |
|-------|--------|
| `CachedAdmin` | `IsInRole(Administrator)` |
| `CachedOS` | `Get-CimInstance Win32_OperatingSystem` |
| `CachedFirewall` | `Get-NetFirewallProfile \| Where Enabled` |
| `CachedDefender` | `(Get-MpComputerStatus).RealTimeProtectionEnabled` |
| `CachedDns` | `@(Get-DnsClientCache).Count` |
| `CachedSessions` | `quser.exe` (skip header) |
| `CachedRdp` | `Get-Service TermService` + `Win32_LogonSession LogonType=10` |
| `CachedVpn` | `Get-NetAdapter Status=Up` con `Name` match `vpn\|wireguard\|openvpn\|tap\|tun` |
| `CachedPfPath` | `Test-Path "C:\Windows\Prefetch"` |
| `CachedPfCount` | Count de `.pf` |
| `CachedBamPath` | `HKLM:\...\bam\State\UserSettings\<SID>` |
| `CachedBamCount` | Count de propiedades BAM |
| `CachedRbVaciada` | Carpeta `S-1-5-21-*` en `C:\$Recycle.Bin` con `$I`/`$R` ausentes y `LastWriteTime < 24h` |
| `CachedLogsOk` | `false` si Event **1102** o **104** presentes |
| `CachedHoraOk` | `false` si Event **1** (`Kernel-General`) en 24h excluyendo suspensión |
| `CachedEventosSosp` | Array de **41/1074/6008** en 24h |
| `CachedUserAssist` | Suma de counts de `UserAssist\*\Count` |
| `CachedSrum` | `Test-Path "C:\Windows\System32\sru\SRUDB.dat"` |
| `CachedServices` | 13 servicios críticos: `DcomLaunch, RpcSs, RpcEptMapper, EventLog, Schedule, Winmgmt, BFE, MpsSvc, pcasvc, DPS, SysMain, Appinfo, bam` |

### 1.8 — `Test-StartupSystemEvents`
**Reconstruye** la línea temporal de apagados/reinicios de las **últimas 24 h** consultando `System`:

| ID | Origen | Significado |
|----|--------|-------------|
| **41** | `Kernel-Power` | Apagado incorrecto |
| **1074** | `User32` | Apagado/reinicio por usuario/proceso (parsea `User`, `ProcessName`, `Reason`, `ShutdownType`) |
| **6008** | `EventLog` | Apagado inesperado |
| **1001** | `BugCheck` | BSOD / error grave |

**Emite** un banner rojo con el tipo detectado (BSOD / usuario / inesperado).

### 1.9 — `Show-RecentSystemEvents`
**Extrae** los últimos 40 eventos de `System` (`41, 1074, 6005, 6006, 6008`) ordenados desc. **Colorea** por antigüedad: rojo <2h, amarillo <24h, gris resto.

---

## 2. 🔍 MENÚ PRINCIPAL — HERRAMIENTAS DE ANÁLISIS

### [1] 🎥 Recording Killer
**Enumera** procesos de grabación activos combinando 3 vías:
1. **`$recorderNames`** (40+ ejecutables): `obs, obs32, obs64, obs-studio, bdcam, bdcam64, action, action_x64, sharex, gamebar, gamebarft, xboxgamebarwidgets, gamebarpresencewriter, gamedvr, nvsphelper64, nvidia share, snippingtool, screenclippinghost, streamlabsobs, twitchstudio, medal, medalencoder, playstv, fraps, dxtory, camtasia, camtasiastudio, camrecorder, flashback, screentogif, screenrec, icecreamscreenrecorder, movaviscreenrecorder, bandicam, debut, loom, loomdesktop, screenpal, screencastify, ocam, mirillis`
2. **`$whitelist`** (54): chrome, msedge, firefox, brave, opera, vivaldi, msedgewebview2, discord, slack, teams, ms-teams, zoom, skype, telegram, whatsapp, explorer, svchost, system, csrss, wininit, winlogon, services, lsass, smss, dwm, taskhostw, runtimebroker, searchhost, sihost, conhost, dllhost, wmiprvse, spoolsv, audiodg, taskmgr, java, javaw, javaws, minecraft, steam, steamwebhelper, epicgameslauncher, battle.net, riotclientservices, riotclientux, onedrive, dropbox, googledrivefs, searchindexer, searchapp, backgroundtaskhost, applicationframehost, userinit, lockapp
3. **`$fallbackPattern`**: `(?i)(--record-video|--capture-mode|--screencast-mode|--encoder=|--game-capture|--capture-window|--capture-display)` sobre `CommandLine`.

**Acciones:** `[A]` ver / `[B]` cerrar uno / `[C]` varios / `[D]` todos excepto selección / `[E]` todos / `[X]` cancelar. **`Stop-ProcessForce`** aplica `Stop-Process -Force` → si persiste `taskkill.exe /F /T /PID` → si aún vive, **reporta** el motivo real (`Access denied`, `proceso protegido por anti-cheat`).

### [2] 📜 Fileless
Submenú: `[A]` Quick / `[B]` PowerShell / `[C]` Event / `[D]` Persistence / `[E]` Full / `[X]`.

**Aplica** 3 patrones:
- `$filelessPattern`: `(?i)(Invoke-Expression|\bIEX\b|EncodedCommand|-enc\b|DownloadString|Invoke-WebRequest|\biwr\b|Invoke-RestMethod|\birm\b|Start-BitsTransfer|ExecutionPolicy\s+Bypass|\bBypass\b|-nop\b|-w\s+hidden|-windowstyle\s+hidden|FromBase64String|Reflection\.Assembly|Add-Type)`
- `$amsiPattern`: `(?i)(AmsiScanBuffer|AmsiInitialize|amsiInitFailed|AmsiUtils|System\.Management\.Automation\.Amsi)`
- `$lolbinPattern`: `(?i)\b(rundll32|mshta|regsvr32|cscript|wscript)\.exe\b.*(https?://|Invoke|IEX|DownloadString)`

**Auto-excluye** líneas con `Add-Type -MemberDefinition.*GetStdHandle`, `SetConsoleMode.*0x0040`, `MULTISCRIPT - (KSHY112L)`, `MultiSkrip_Report`, `Invoke-PFC`, `Get-MultiSkripSystemId`.

**Pondera** por gravedad: `EncodedCommand`/`-enc`=5 · IEX+Download/IWR/IRM=4 · LOLBIN+URL=4 · AMSI=4 · Comando sospechoso=2-3 · Módulo en Temp/cheats/loader/inject=2.

**Correlaciona** 3 fuentes: PSReadLine (últimas 500, 2 rutas) + Eventos `PowerShell/Operational` IDs **4103, 4104** y `Windows PowerShell` IDs **400, 403, 600, 800** + Persistencia (Run/RunOnce, Tasks no-Microsoft, WMI `root/subscription`).

**Clasifica** el veredicto: BAJO (0-2), MEDIO (3-6), ALTO (7-10). Reporte en `%USERPROFILE%\Downloads\Fileless_Report.txt`.

### [3] 🔌 DMA & Cheat Hardware Analyzer
**Enumera** dispositivos vía `Get-PnpDevice` y **clasifica** cada VID/PID contra 2 diccionarios.

**`$legitVIDs` (63 fabricantes conocidos):** `046D, 1532, 1B1C, 045E, 093A, 24AE, 0B05, 1A2C, 0951, 0BC2, 1058, 13FE, 0781, 090C, 05AC, 04E8, 18D1, 0F0D, 057E, 054C, 044F, 1038, 258A, 0C45, 046A, 047D, 8087, 1022, 10DE, 14E4, 168C, 8086, 1002, 04D9, 04CA, 04F2, 04F3, 0BDA, 0930, 17AA, 413C, 03F0, 1D6B, 0CF3, 0489, 13D3, 144D, 15B7, 1987, 1C5C, 126F, 1344, 1179, 1E0F, 1CC1, 2646, 10EC, 1B21, 1B4B, 11AB, 1912, 1B73, 1106, 14C3, 17CB, 1969`

**`$cheatVIDs` (HIGH — DMA/KMBox):** `1B36`=QEMU/FPGA, `2341`=Arduino, `1B4F`=SparkFun, `2E8A`=Raspberry Pi, `16C0`=Van Ooijen, `1209`=InterBiometrics, `1A86`=QinHeng, `1CBE`=TI, `2A03`=Arduino SA.

**Analiza** clases `HIDClass, USB, Mouse, Keyboard, System, Processor, SCSIAdapter, PCI, PCIEncrypted`. **Descarta** `ROOT\*`, VID `0000`/`FFFF` y fabricantes Microsoft/Windows/standard.

**Clasifica** salida: `cheatHits` (HIGH), `hidDesconocidos` (MEDIA), `pcieDesconocidos` (MEDIA).

### [4] 📁 Directory Analyzer (Ghost Clients)
Submenú: `1) Buscar texto personalizado` / `2) Escaneo de indicadores conocidos`.

**Carga** una lista de **22 indicadores forenses:** `Kill Aura, Crystal Aura, Aim Assist, TriggerBot, Auto Clicker, Chest Stealer, Player ESP, X-Ray, Fake Lag, Ping Spoof, Anti SS Tool, Self Destruct, USN Journal Cleaner, Delete USN Journal, Hooking, Injection, PatternScan, Trampoline, Detour, Internal, Obfuscated, Loader`.

**Recorre** recursivamente el directorio con `Get-ChildItem -Recurse -File`, **lee** `Get-Content -Raw`, y si hay match **repite** línea por línea para **capturar** el número exacto. **Renderiza** progreso con barra de 20 bloques (`█`/`░`).

**Expone** las primeras 20 coincidencias con resaltado ANSI (`\e[91m...\e[0m`). Opciones: `[1]` GridView / `[2]` exportar CSV a `%TEMP%\MultiSkrip_Scan_<timestamp>.csv` / `[0]` continuar.

### [5] 📝 TypedPaths Analyzer
**Extrae** las rutas tecleadas manualmente por el usuario en la barra de direcciones del Explorador. **Parsea** las claves `url1`, `url2`, ... de `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths`, **ordena** numéricamente por índice MRU y **reconstruye** la secuencia de navegación del usuario.

### [6] 🎭 Fake Extension Analyzer
`Invoke-FakeExtensionScanner` — **por defecto escanea `$env:USERPROFILE`**. `-FullScan` cambia root a `C:\` (el menú NO lo activa).

**Valida** la extensión declarada contra **24 firmas magic-byte:** `4D5A` PE, `504B0304` ZIP/JAR/Office, `FFD8FF` JPEG, `89504E47` PNG, `4749463839/37` GIF, `424D` BMP, `25504446` PDF, `526172211A07` RAR, `377ABCAF271C` 7z, `1F8B` GZIP, `425A68` BZIP2, `D0CF11E0A1B11AE1` OLE2, `4F676753` OGG, `664C6143` FLAC, `494433/FFFB/FFF3/FFF2` MP3, `52494646` RIFF, `CAFEBABE` Java Class, `7F454C46` ELF, `53514C69746520666F726D61742033` SQLite, `757374617200` TAR, `EDABEEDB` RPM, `213C617263683E` .deb.

**Reconoce** 22 extensiones texto-puro: txt, log, ini, cfg, conf, md, csv, json, xml, bat, cmd, ps1, vbs, js, py, java, c, h, cpp, html, htm, css, yml, yaml, rtf, reg, sql, sh.

**Descarta** firmas de **33 firmantes legítimos** (Microsoft, Adobe, Google, Mozilla, Apple, Oracle, NVIDIA, AMD, Intel, Realtek, Qualcomm, Broadcom, Valve, Steam, Epic Games, Rockstar, Ubisoft, Electronic Arts, Discord, Slack, Zoom, Cisco, VMware, Citrix, JetBrains, GitHub, Git, Python Software, Node.js, Riot Games, Battle.net, Blizzard, GOG, Amazon, Facebook, Meta, WinRAR, 7-Zip, Igor Pavlov, Alexander Roshal, Notepad++, Don Ho, VideoLAN, VLC).

**Omite** 24 rutas de sistema: WinSxS, System32, SysWOW64, Microsoft.NET, assembly, Installer, WindowsApps, Program Files (+x86), Package Cache, Steam\steamapps, SteamLibrary, Epic Games, GOG Galaxy, Riot Games, Battle.net, Ubisoft, Rockstar Games, Electronic Arts, node_modules, .git, .vscode, .vs, packages, NuGet.

**Muestra** los PE con `FileVersionInfo` (CompanyName, ProductName, FileDescription) y ZIP con las primeras 5 entradas. **Asigna** prioridad 1/2/3. `[G]` GridView / `[C]` CSV / `[X]`.

**Parámetros:** `-FullScan`, `-SkipHashes`, `-ShowAll`.

### [7] 🔄 Autoruns Full
**Enumera** 5 secciones de arranque:
1. **Run/RunOnce (6 rutas):** HKLM/HKCU, WOW6432Node
2. **Startup Folders (2):** usuario + ProgramData
3. **Scheduled Tasks:** `TaskPath -notlike '\Microsoft\*'`
4. **Services:** `Win32_Service StartMode=Auto`
5. **IFEO Debugger:** `HKLM\...\Image File Execution Options\*\Debugger`

**Muestra** si el archivo existe (`Test-Path`), su fecha (`LastWriteTime`), si está en Temp (`EsTemp`) y su **firma digital en paralelo**. `[0-3]` / `[X]`.

### [8] 🛡️ Defender Exclusions Analyzer
**Extrae** las exclusiones activas de `HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions`:
- **Paths** — rojo si match `\\(\.minecraft|cheats?|hacks?|temp|downloads|desktop|appdata)\\`
- **Extensions** — rojo si match `jar|exe|dll|bat|cmd|ps1`
- **Processes** — rojo si match `java|wurst|inject|loader|cheat`

### [9] 🗜️ ForensicsWinrar
**Extrae** el historial de archivos abiertos con WinRAR desde `HKCU:\Software\WinRAR\ArcHistory` y lo **renderiza** en GridView.

### [10] ⏱️ BAMTrace
**Consulta** la primera ruta existente:
- `HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings` (Win 10 1709+)
- `HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings` (previo)

**Traduce** rutas NT a letras de unidad invocando `kernel32.dll::QueryDosDevice`. **Traduce** SID a nombre de usuario. **Descarta** `Version` y `SequenceNumber`. **Interpreta** los primeros **8 bytes** como FILETIME UTC (última ejecución, mostrada en local + UTC).

**Emite** GridView desc. por `UltimaEjecucion`: `Usuario, Ejecutable, UltimaEjecucion, UltimaEjecucionUTC, Existe, SID, RutaNT, Extra`.

### [11] 🌳 Parent Process Analyzer
**Construye** el árbol de procesos vivo con `Win32_Process` + hashmap PID→Process. **Resuelve** el padre de cada proceso y lo **expone** en GridView: `Process, PID, ParentPID, ParentName, Path, CommandLine`.

### [12] 🌐 DNS Cache Viewer
**Extrae** la caché DNS activa vía `Get-DnsClientCache`, **enumera** cada entrada con su `Entry`, `Data` y `Type`, y la **renderiza** en GridView.

### [13] ⏰ Scheduled Tasks
**Enumera** tareas programadas no-Microsoft vía `Get-ScheduledTask` y **captura** `TaskName, TaskPath, State, Actions, Author` en GridView.

### [14] 📌 JumpList Analyzer (submenú)
**1. ShowJumpView:** **parsea** el binario de `HKCU:\...\FeatureUsage\ShowJumpView` como `Int32` offset 0 (conteo) + `FILETIME` offset 4 (última ejecución). **Renderiza** GridView con firma.

**2. AutomaticDestinations:** **lee** `%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.automaticDestinations-ms`.

**3. CustomDestinations:** **lee** `...\CustomDestinations\*.customDestinations-ms`.

`Get-JumpListStrings`: **extrae** strings UTF-16 imprimibles (CP 32-126, 160-0x2FFF), **filtra** basura por longitud 5-500, prefijo válido, paréntesis balanceados, sin repetición 4+, sin `.ms$`.

### [15] 💾 USB Device History Full
**1. USBSTOR (Storage):** **recorre** `HKLM:\...\Enum\USBSTOR`, **extrae** fabricante/modelo, `FriendlyName`, `DeviceDesc`, `Mfg` y **consolida** timestamps de clase + serial.

**2. USB (todos):** **filtra** `VID_*`, **extrae** VID/PID y **deduplica** por `VID|PID|Serial`.

**Cruza** `InstanceId` con `Get-PnpDevice Status=OK` para marcar `ConectadoAhora`.

**Filtros:** `[0]` todas / `[1]` solo storage / `[2]` solo con serial único / `[3]` solo sin serial / `[4]` solo conectados / `[X]` salir.

### [16] 🕸️ Network Connections
**Captura** conexiones TCP `Established` con `Get-NetTCPConnection` y **asocia** el proceso por PID. **Renderiza** GridView: `LocalAddress, LocalPort, RemoteAddress, RemotePort, PID, ProcessName, Path`.

### [17] 🖱️ UserAssist Analyzer
**Decodifica** ROT13 sobre los nombres de `HKCU:\...\Explorer\UserAssist`. **Extrae** ejecuciones (Int32 offset 4) y última ejecución (FILETIME offset 60). **Renderiza** GridView desc. por `Ultima_Vez`.

### [18] 📄 Documents MRU Analyzer
**Correlaciona** 3 fuentes: **RecentDocs**, **ComDlg32** (`OpenSavePidlMRU` + `LastVisitedPidlMRU`) y **Office MRU** (16.0/15.0/14.0).

`Get-PathFromPidl`: **parsea** strings UTF-16, **identifica** `[A-Za-z]:\\` o `\\\\` y **reconstruye** la ruta desde root + segmentos.

**Calcula** score 0-10:

| Condición | Peso |
|-----------|------|
| < 6h | +3 |
| < 24h | +2 |
| < 72h | +1 |
| Ejecutable | +1 |
| No firmado | +4 |
| Ruta `(Downloads\|Desktop\|Escritorio\|Temp\|Public\|AppData\Local\Temp)` | +2 |
| Nombre `(cheat\|hack\|loader\|...\|doomsday\|entropy\|whiteout\|selfdestruct\|autoclicker\|killaura\|stealer)` | +5 |
| Borrado + nombre sosp | +3 |
| Borrado + ruta sosp | +2 |
| Borrado | +1 |

**Filtros:** `[0-5]` / `[G]` GridView / `[X]`. **Helpers:** `Resolve-LnkTarget`, `Try-ResolveFromRecentFolder`, `Clean-BasuraString`.

### [19] 🗑️ Uninstall Registry Deep
**Enumera** 3 rutas: `HKLM\...\Uninstall`, `HKLM\WOW6432Node\...\Uninstall`, `HKCU\...\Uninstall`.

**Prioriza** en 3 niveles:
- **1 (rojo):** publisher match `cheat|hack|loader|inject|spoofer|bypass|crack|keygen|torrent|warez|piracy` **o** nombre match `cheat|...|doomsday` **o** ruta match `\(Temp|AppData|Downloads|Desktop|Documents|Public)\` **o** fecha futura
- **2 (amarillo):** ≤90 días, sin metadata, no firmado
- **3 (gris):** resto

**Parámetros:** `-DiasRecientes 90`, `-OnlyRecent`, `-SkipFirma`.

### [20] 🧩 PCAStoreAnalyzer
**Cruza** 2 fuentes:
1. `HKCU:\...\AppCompatFlags\Compatibility Assistant\Store`
2. `C:\Windows\appcompat\pca\PcaAppLaunchDic.txt` (Win 11 22H2+) — `path|timestamp`

**Extrae** timestamp escaneando cada 4 bytes en busca de un FILETIME válido (2015-2030, ≤ ahora+1) → conserva el más reciente. Fallback a `PcaAppLaunchDic`.

**Valida** firmas en paralelo. **Emite** alerta si `Pcasvc` no está `Running`. **Filtros:** `[0-4]` / paginación `[S]`/`[A]` 50-por-página.

### [21] 🌍 Browser History Full
**Soporta 6 navegadores** (todos los perfiles `Default|Profile \d+`): Chrome, Edge, Brave, Opera, Vivaldi, DuckDuckGo.

**Invoca** `winsqlite3.dll` nativa de Windows. **Ejecuta** `SELECT url, title, visit_count, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 1000`. **Convierte** WebKit epoch (`1601-01-01 UTC`) a `DateTime` local.

**Copia defensivamente** a `%TEMP%\MSK_BH_<guid>\h_<idx>.db` porque Chrome bloquea `History`.

**Clasifica** contra `$patternSosp` (una lista gigante de términos como cheat, hack, ghost client, blatant client, inject, injector, spoofer, hwid, ban evasion, bypass, anticheat, disabler, byppas, bypasear, evadir, evasion, anti ss, antisstool, anti screenshare, borrar usn, borrar journal, delete journal, delete prefetch, clear eventlog, killaura, aimbot, triggerbot, autoclicker, reach, velocity, autocrystal, antiknockback, nofall, scaffold, blink, phase, noclip, freecam, longjump, boatfly, wallhack, tracers, nametags, chams, x-ray, nuker, cheststealer, wurst, impact client, future client, meteor client, sigma, astolfo, entropy, novoline, liquidbounce, aristois, bleachhack, inertia client, lambda client, salhack, kami blue, konas, phobos, pyro client, rusherhack, rise client, sulfur client, jessica client, fdpclient, ravenb, nightx, azura, akira, noise client, huntress client, forgehax, boze, jex client, postman client, mathax, thunderhack, trollhack, gamesense, catalyst, vestige, moon client, augustus, myau, breeze, kawaii, chimera, opus, exhibition, abyss, asteria, aeolus, valkyrie, shadow client, apollo client, zephyr, badman, drizzle, radium, actinium, celsius, skiddle, undisputed, nitr0, cnd, ascendency, ares client, vape (v2/v4/lite/.gg), whiteout, crypt client, remix client, spooky client, fadeaway, moonlight client, tenacity, dream client, lunar client, badlion, feather, labymod, flarial, latite, onix, oderso, lyra, joivo, luconia, prax, horion, borion, protohax, lumina client, xelo client, voidline, soda autoclicker, toad client, peach autoclicker, sapphire autoclicker, epic autoclicker, chromatic autoclicker, krypton autoclicker, mango autoclicker, void clicker, dusk autoclicker, vtf advanced, briiqn, tuxclicker, vupsclick, kauri, onlymc, lunargg, hazelmc, doomsday(client)).

**Filtros:** `[0-4]` / `[X]`. **Máx. 300 mostradas.**

### [22] 🪟 GDI Handles & Orphaned Windows Analyzer
**Usa** funciones nativas de Windows para listar ventanas.

**Enumera** ventanas top-level y **captura** PID, título, visibilidad, estilo y display affinity. **Identifica** `Affinity != 0` como ventana excluida (`WDA_EXCLUDEFROMCAPTURE`). **Descarta** procesos permitidos `^(explorer|nvidia|amd|intel|chrome|msedge|brave|firefox|discord|teams)\.exe$`. **Cuenta** GDI handles (objetos gráficos cargados).

**Clasifica** motivos: `Excluida`, `Oculta` (proceso Java o ruta `\Temp|\Downloads|\Desktop|\AppData\Roaming\`), `Gdi` (`svchost` >150, otro >400).

### [23] 🔗 COM Hijacks Analyzer
**Consulta** `reg.exe query "HKCU\Software\Classes\CLSID" /s` por rendimiento. **Parsea** `{GUID}`, `InprocServer32`/`LocalServer32` y valor default.

**Clasifica** cada CLSID: `SoloHKCU` / `Sobreescrito` / `Espejo`.

**Comprueba** si el archivo existe, su fecha (`CreationTime`/`LastWriteTime`), su firma digital y su SHA256. `[0-4]` / `[X]`.

### [24] ⬇️ Downloaded Files Forensics
**Recorre** `%USERPROFILE%\Downloads` + `%USERPROFILE%\Desktop`.

`Get-ZoneIdentifier` **lee** el flujo NTFS alternativo `Zone.Identifier` y **extrae** `ZoneId`, `HostUrl`, `ReferrerUrl`. **Mapea** `0=My PC, 1=Intranet, 2=Trusted, 3=Internet, 4=Untrusted`.

**Valida** firma solo para `exe|dll|ocx|sys|msi|jar|ps1|bat|cmd|vbs|js`. **Filtros:** `[0-3]` / `[X]`.

### [25] 📊 App History Analyzer
**Parsea** `HKCU:\...\Search\RecentApps` recursivamente. **Extrae** propiedades `LastSeen|LastAccessed|LastAccessTime` (FILETIME en `[byte[]]` offset 0) y **reconstruye** rutas `[A-Z]:\\...\.(exe|dll|jar)`.

### [26] 🗂️ ShellBags
**Enumera** 3 ramas:
- `HKCU:\Software\Microsoft\Windows\Shell\BagMRU`
- `HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU`
- `HKCU:\Software\Microsoft\Windows\ShellNoRoam\BagMRU`

`Get-ShellBagName`: **parsea** strings UTF-16, **identifica** `C:\...`/`\\...` embebidos, **normaliza** eliminando dígitos iniciales y recortando prefijos basura.

**Clasifica:** `USB` (drive letter sola o match USB/Removable/SanDisk/Kingston/Corsair/Toshiba/Seagate/Western), `Red` (`^\\\\[^\\]+`), `Normal`. `[0-3]` / `[X]`.

### [27] 🧠 ShimCache Analyzer
**Lee** `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache` → valor `AppCompatCache`.

`Parse-ShimCacheBlob` **aplica** 2 parsers:
1. **"10ts" (Win 10/11):** **escanea** la firma `31 30 74 73` y **parsea** `"10ts"(4) + unknown(4) + size(4) + pathSize(2) + path(UTF-16) + FILETIME(8) + dataSize(4) + data`. **Valida** `[A-Za-z]:\\`/`\\`/`%VAR%` sin caracteres de control y **calcula** `Next = pOff + pathSize + 12 + dataSize`.
2. **Fallback "strings forense":** **identifica** el `:` de `C:\`, **valida** `X + \0 + \ + \0`, **lee** UTF-16 hasta no imprimible. **Rastrea** FILETIME válido (2015-2030) en los 32 bytes siguientes.

`$Global:ShimCacheParseInfo` = `{FormatoGanador, Entradas, Intentos}`. `[0-2]` / `[X]`.

### [28] 🏷️ MUICache Analyzer
**Parsea** `HKCU:\...\Local Settings\Software\Microsoft\Windows\Shell\MuiCache` + HKLM. **Extrae** pares `<ruta>.FriendlyAppName` y `<ruta>.ApplicationCompany`, **descarta** `C:\Windows\` y **muestra** las fechas de archivo.

### [29] 🗄️ Amcache Analyzer
**Monta** `C:\Windows\AppCompat\Programs\Amcache.hve` como hive temporal en 4 pasos:
1. **Copia** `Amcache.hve` + `LOG1` + `LOG2` a `%TEMP%\MSK_Amcache_<guid>`
2. **Usa** `esentutl.exe /y /vss` (VSS) → fallback `Copy-Item`
3. **Ejecuta** `esentutl.exe /r /p` para recuperación
4. **Desmonta** con `reg.exe unload` → **monta** con `reg.exe load HKLM\MSK_AmcacheTemp <copy>`

**Detecta** raíz:
- Moderna: `Root\InventoryApplicationFile` → `LowerCaseLongPath`, `Name`, `Version`, `Publisher`, `LinkDate`
- Legacy: `Root\File` → `100` (byte[] UTF-16), `101` (Int64 FILETIME), `0/1/2`

**Limpia** en `finally` con `reg.exe unload` + `Remove-Item -Recurse`. **Valida** firmas en paralelo saltando `\WindowsApps\`, `^C:\Windows\`, `^C:\Program Files\`. `[0-2]` / `[X]`.

### [31] 🚫 Ban Evasion Detector

**Genera** el System ID con `Get-MultiSkripSystemId`:
- Salt bytes: `77,83,75,95,118,49,95,83,69,67,82,69,84,95,120,75,57,35,50,48,50,52,95,71,79,84,89` = `"MSK_v1_SECRET_xK9#2024_GOTY"`
- **Combina**: `InstallDate|COMPUTERNAME|TimeZoneId`
- **Emite** `SHA256(salt + "|" + combined)` en hex mayúsculas
- **Muestra** el ID actual en la parte superior de la pantalla para comparación directa.

**Flujo:**
1. **Busca** `MultiSkrip_Report_*.txt` en `%USERPROFILE%\Downloads`
2. Si >1, **enumera** los últimos 5
3. **Parsea** `System ID:`, `PC Name:`, `User:`, `OS:`, `Cuentas:` y bloque `Minecraft Alts`
4. **Compara** con el ID actual

**⚠️ LIMITACIONES DEL SYSTEM ID:**
- **Reinstalar Windows** cambia `InstallDate` → **nuevo System ID**. La misma PC física puede tener IDs distintos.
- **Cambiar la zona horaria** cambia `TimeZoneId` → **nuevo System ID**.
- **Cambiar el `COMPUTERNAME`** cambia el hash → **nuevo System ID**.
- Por tanto:
  - **Coincidencia = evidencia fuerte** de misma instalación de Windows (el salt es secreto, el hash no se puede fabricar sin conocerlo).
  - **No coincidencia ≠ PC distinta.** Puede ser la misma PC con Windows reinstalado, timezone cambiado o nombre cambiado.

> ⚠️ **ACLARACIÓN IMPORTANTE: BAN EVASION**
> Algunos servidores prohíben estrictamente pasar archivos (como TXT o CSV) a la PC del sospechoso durante el SS.
> 
> Para que un **Ban Evasion sea válido**, el equipo de SS **DEBE** tener video del SS anterior donde se demuestre claramente que se usó la herramienta (All Options) en la PC del sospechoso y que el **System ID** coincide con el reporte actual.
> 
> **Sin el video del SS anterior**, un miembro del staff malintencionado podría simplemente inventar o crear un archivo TXT falso con el ID del sospechoso para banearlo injustamente. El staff está OBLIGADO a verificar que la prueba proviene directamente de la PC del usuario y que fue capturada en vivo. Si no hay video, el ban no es válido.

### [34] 📚 User Guide
**Renderiza** la guía integrada con las 34 opciones del menú principal + 44 del submenú 32 + 9 del submenú 33.

---

## 3. 📅 SUBMENÚ 30 — VISOR DE EVENTOS

### [1] 📆 Eventos recientes
**Muestra** los últimos eventos de apagado, reinicio y apagados inesperados para reconstruir lo que pasó en las últimas 24 horas (ver §1.9).

### [2] 💥 AppCrasher Analyzer (Event ID 1000)
**¿Qué hace?** Te dice **exactamente qué aplicación se crasheó** y cuál fue el módulo que falló. 
**¿Por qué es útil?** Si el juego se cerró de golpe, aquí verás si fue por un error del sistema o por un mod/cheat mal programado que hizo crashear el proceso. (Ej: "Minecraft crasheó por una DLL en AppData").

### [3] 🕰️ Time Change Detector (4616 / ID 1)
**¿Qué hace?** Busca si alguien cambió la hora del sistema (muy común para intentar saltarse bans de tiempo o logs).
**⚠️ ¡Cuidado con el ruido!** Windows a veces sincroniza la hora automáticamente (NTP) o suspende la PC, lo que puede dar falsos positivos. **Revisa si el cambio fue manual y drástico** (más de 30 minutos) y si el proceso que lo hizo es sospechoso. **Muy útil si borraron X y cambiaron la hora para ocultarlo.**

### [4] 🧾 Process Creation (Event ID 4688)
**⚠️ Situacional (Depende de Sysmon/Auditoría):** Esta opción **solo funciona si la PC tiene habilitada la auditoría de creación de procesos**. Si el sistema no lo tiene activado, no mostrará nada. Si lo está, es **oro puro** para ver si abrieron PowerShell oculto o inyectaron algo.

### [5] 🧊 Application Hang (Event ID 1002)
**⚠️ Situacional:** Similar al anterior. Depende de los registros de Windows. Te dice qué apps se colgaron. Útil para ver si un cliente de cheat dejó la PC lenta o colgada.

### [6] 📱 App Execution History (903/905)
**⚠️ Situacional:** Depende de los registros de compatibilidad de Windows (Program Compatibility Assistant). Si un programa no se registró ahí, no saldrá. Revisa si hay rastros de ejecución de apps inusuales.

### [7] 🔐 Admin Process Tracker (4688)
**⚠️ Situacional (Depende de Auditoría):** Al igual que el [4], requiere que la auditoría de procesos esté activada. Muestra específicamente los procesos que se ejecutaron **como Administrador**. Muy útil para ver si el sospechoso elevó privilegios para ejecutar un bypass.

### [8] 🚨 Service Sabotage Tracker (7036/7040)
**¿Qué hace?** Rastrea si **detuvieron o deshabilitaron** servicios críticos del sistema (como los logs de eventos o el servicio forense).
**¿Por qué es una mina de oro?** No solo te dice que se detuvo el servicio, sino que **captura la hora exacta (timestamp)** en la que el byppasser lo apagó. Si cruzás esa hora con otros eventos, podés demostrar exactamente cuándo intentó ocultar rastros. **Muy útil si borraron X o apagaron logs.**

---

## 4. 🛠️ SUBMENÚ 32 — REPARACIÓN Y LIMPIEZA

44 opciones. **Toda reparación genera backup** en `%TEMP%\Multiskrip_Backups\`.

### [1] 🚫 URL Block Analysis / Repair
**Te permite ver y ELIMINAR** los bloqueos de URL que se hayan puesto en Chrome/Edge/Brave. **Muy útil si bloquearon páginas de ayuda o herramientas.**

### [2] 🔓 Unlock CMD (DisableCMD)
**Te permite ver y ELIMINAR** la restricción que bloquea el CMD. **Muy útil si deshabilitaron CMD para que no puedas revisar.**

### [3] 🧹 Clear DisallowRun
**Te permite ver y ELIMINAR** los programas que están bloqueados en el sistema. **Muy útil si bloquearon herramientas como el Administrador de tareas.**

### [4] 🔧 Gpedit (DisableRegistryTools)
**Te permite ver y ELIMINAR** la restricción que bloquea el editor de registro (Regedit). **Muy útil si bloquearon el acceso al registro.**

### [5] 🩹 Repair CMD / Power Full
**Detecta y restaura** la consola, el AutoRun sospechoso, las políticas de PowerShell y los servicios de logs.
**Solo reporta** (no repara automáticamente) si el PATH o el `fsutil.exe` están comprometidos. **Muy útil si desconfiguraron toda la consola.**

### [6] 🛡️ Firewall Outbound Analysis / Repair
**Te permite ver y ELIMINAR** reglas de firewall que bloquean salidas (por ejemplo, si bloquearon la conexión a internet de una herramienta).

### [7] 📓 Journal Deleted Analysis
**Revisa** si borraron el USN Journal (registro de actividad de archivos). Si lo borraron, es un intento claro de ocultar qué archivos se crearon o borraron. **Muy útil si borraron X.**

### [8] 🔍 FileInfo Analyzer
**Revisa** si descargaron o descargaron el filtro del sistema (FileInfo). Si se descargó, es un bypass. **Muy útil si intentaron desactivar la protección.**

### [9] 🗑️ Recycle Bin Analysis
**Te muestra** qué archivos hay en la Papelera. **Muy útil si borraron X pero no la vaciaron.**

### [10] 📡 Host
**Analiza** el archivo hosts (que traduce dominios a IPs). 
**⚠️ Ojo con esto:** Las líneas que tienen `#` son comentarios y debes ignorarlas. Si ves una línea que contenga una IP y un sitio importante para la SS (por ejemplo, `127.0.0.1 github.com` o `::1 nirsoft.net`), podría ser un **bypass attempt**. 
**¿Por qué?** Porque están bloqueando el acceso a herramientas clave. **Te permite ELIMINAR estas entradas.**

### [11] 🕵️ Disabled OpenSave Detector
**Revisa y ELIMINA** la configuración que deshabilita el historial de archivos abiertos. **Muy útil si intentaron ocultar qué archivos abrieron.**

### [12] 🔐 UserAssist Integrity Analysis
**Revisa** si manipularon el registro de ejecución de programas. **Permite ELIMINAR** los registros alterados y restaurar el funcionamiento. **Muy útil si borraron X rastro.**

### [13] 🧬 AppX IFEO Debugger Analysis
**Revisa** los secuestros de programas (AppX). **Te permite ver y ELIMINAR** el Debugger modificado. **Muy útil si borraron X programa usando esta técnica.**

### [14] 👻 Silent Process Exit Analysis
**Revisa** si hay procesos que se configuraron para ejecutarse silenciosamente al fallar otro. **Te permite ver y ELIMINAR** esa configuración. **Muy útil si inyectaron X programa.**

### [15] 💥 Kernel Crash Control
**Revisa** si deshabilitaron los volcados de memoria (crash dumps). **Restaura** la configuración si estaba desactivada. **Muy útil si intentaron ocultar errores del sistema.**

### [16] ⚙️ AppCompat Engine Integrity
**Revisa y ELIMINA** si desactivaron el motor de compatibilidad (que a veces usan los cheats para ocultarse).

### [17] 🔎 Explorer Search Policy Analysis
**Revisa y ELIMINA** si desactivaron la búsqueda del explorador de Windows.

### [18] 🔗 CMD Association Integrity
**Revisa y RESTAURA** si alteraron la asociación del comando CMD (por ejemplo, para que abra otro programa).

### [19] 🛤️ Environment PATH Analysis
**Examina** si el PATH del sistema está corrupto o vacío. **⚠️ No se repara automáticamente** para no romper más el sistema. Requiere revisión manual.

### [20] 🔒 Protected Driver Blocklist Analysis
**Muestra** si hay drivers bloqueados (protección del kernel). **⚠️ No se repara automáticamente.** Es solo informativo por seguridad.

### [21] 📝 Input & Script Logging Integrity
**Revisa y RESTAURA** si deshabilitaron el historial de entrada o el registro de scripts de PowerShell. **Muy útil si borraron X registros.**

### [22] 📌 JumpList Status
**Revisa y RESTAURA** si desactivaron el historial de JumpList (accesos directos recientes). **Muy útil si intentaron ocultar actividad.**

### [23] 📊 SRUDB Status
**Revisa y RESTAURA** el servicio que monitorea el uso de recursos (SRUM). **Muy útil si intentaron evadir el monitoreo.**

### [24] 🗄️ Amcache Status
**Revisa** si borraron el archivo Amcache (que registra ejecuciones). **Muy útil si borraron rastros de ejecución.**

### [25] 🗃️ RecentFileCache Status
**Revisa** si falta el archivo RecentFileCache.bcf. **Nota:** En Windows 8 o superior, es **normal** que no exista (fue reemplazado por Amcache). Si estás en Windows 7, es sospechoso.

### [26] 🧠 AppCompatCache Status
**Revisa y RESTAURA** si borraron la caché de compatibilidad de aplicaciones (ShimCache). **Muy útil si borraron rastros.**

### [27] 💾 USB Device Status
**Revisa y RESTAURA** si algún dispositivo USB está deshabilitado o con error (Problem 22). **Muy útil si desactivaron el USB para evitar detecciones.**

### [28] 🧬 IFEO (Debugger)
**Muestra** y **permite ELIMINAR** la configuración de IFEO que redirige un programa a otro (muy usado para secuestrar programas). **Muy útil si borraron X programa.**

### [29] 🖥️ Virtualization Environment Analysis
**Muestra** indicadores de virtualización (VMware, VirtualBox, QEMU, etc.). **⚠️ No se repara**, es informativo. Algunos cheaters usan VMs para evadir detección.

### [30] ⌨️ Run Dialog Policy Analysis
**Revisa y ELIMINA** la restricción que bloquea el diálogo de ejecución (Win+R).

### [31] 📋 Scheduled Task Cache Integrity
**Revisa** si hay tareas huérfanas (que apuntan a archivos que ya no existen). **Muy útil si borraron tareas maliciosas.**

### [32] 🛡️ Windows Defender Log
**Muestra** las detecciones del antivirus (si las hubo). **Muy útil si el antivirus detectó y borró X cheat.**

### [33] 🔌 USB Activity
**Muestra** los eventos de conexión/desconexión de dispositivos USB. **Muy útil si conectaron un USB con cheats.**

### [34] 🚫 Security Log Deleted (1102)
**Revisa** si borraron el log de seguridad de Windows. **No se puede reparar**, pero es prueba directa de evasión.

### [35] 🚫 System Log Deleted (104)
**Revisa** si alguien **borró el registro de eventos del sistema**. Esto es un indicio muy fuerte de que el byppasser intentó ocultar sus movimientos. No se puede reparar (el log ya se perdió), pero es prueba directa de evasión. **Muy útil si borraron X registro.**

### [36] 🚨 EventLog Service Stopped (7036)
**Revisa y REPARA** si detuvieron el servicio de logs de Windows. **Muy útil si intentaron ocultar actividad.**

### [37] 👥 Minecraft Alts Detector
**Busca** cuentas de Minecraft que hayan iniciado sesión en esta PC. 
**⚠️ Blindaje Anti-Fake:** Muestra la **Fuente** (ruta del archivo de log) y la **Fecha de modificación**. Si un cheater intentó inyectar el nick de otra persona en un log falso, verás que la fecha es reciente o que el archivo es sospechoso. **Verifica que la fecha coincida con el SS.**

### [38] 🌐 VPN Detector
**Consulta** tu IP pública y verifica si estás usando una VPN o Proxy. **Muy útil Si el User esta evadiendo Ban, en algunos servdiores Banean por el uso de vpn.**

### [39] 📜 RunMRU Status
**Revisa** el historial de comandos escritos en Win+R. **Muy útil si intentaron ejecutar comandos ocultos.**

[40] 🕰️ **VSS Lite** 
¿Qué hace? Revisa si el sistema tiene copias de seguridad (Snapshots) de Windows y te muestra su información básica (fecha, volumen, etc.).
⚠️ **Aclaración importante** : La tool solo detecta si existen y te da los datos, no extrae ni abre los archivos de las copias (eso requeriría herramientas externas pesadas).
¿Por qué es súper útil en el SS? Porque si la tool te dice que SÍ hay copias, le acabas de dar al staff una pista de oro. El cheater pudo haber borrado archivos o logs, pero si hay un snapshot, el staff puede usar herramientas externas (como ShadowExplorer) para abrir esa copia y recuperar lo que intentaron ocultar.
**⚠️ Nota:** 0 snapshots puede ser normal (una PC sin restauración configurada), no necesariamente un borrado intencional. Requiere contexto.

### [41] 🔬 PfCheck
**Revisa** si deshabilitaron el Prefetch o si alteraron los archivos `.pf`. **Muy útil si borraron rastros de ejecución.**

### [42] 💉 System Drivers (BYOVD)
**Revisa** si hay drivers no firmados o en rutas sospechosas. **Muy útil si instalaron un driver malicioso.**

### [43] 📂 Directories
Divide los accesos rápidos en **3 menús**:
1. **Rutas Básicas:** Prefetch, Recent, Temp, Descargas, .minecraft, etc.
2. **Regedit:** UserAssist, BAM, IFEO, USB Devices, etc.
3. **Visor de eventos y herramientas:** Event Viewer, Task Manager, CMD, etc.
**Utilidad del CMD:** Te permite abrir una consola elevada directamente en la carpeta seleccionada. Esto es útil para usar comandos `cd` (ej: `cd C:\Windows\Prefetch` o `cd %userprofile%\downloads`) sin tener que navegar manualmente.

### [44] ⚡ All Options
**Ejecuta toda la batería de auditoría del Submenú de Reparación (32)** de forma automática. 
**¿Qué incluye?** Corre los chequeos de sabotage, chequeos de logs, artefactos y de red. **Muestra el System ID** al inicio para comparar con reportes anteriores, y exporta los reportes en TXT/CSV detallando los hallazgos (incluyendo las fuentes y fechas de los logs de Alts para evitar falsos positivos).

---

## 5. ☕ SUBMENÚ 33 — JAVA INSPECTOR

**Muestra** el contexto del proceso Java (PID, uptime, ruta y padre). **Alerta** si el padre es `cmd|powershell|pwsh`.

### [1] 🥤 JavaJarDetector
**Busca** comandos `java -jar` que apunten a archivos con **extensiones falsas** (no `.jar`). 
**Cruza** 3 fuentes: `JavaLauncher.log`, procesos activos y el historial de PowerShell. 
**Clasifica** el contexto del archivo (TEMP, DOWNLOADS, DESKTOP, DISCO D:, CHEATS). **Muy útil para detectar bypasses de extensión.**

### [2] 💉 DLL Injection Scanner
**Revisa** los módulos (DLLs) cargados en el proceso de Java. **Ignora** librerías conocidas y firmas de confianza. **Marca** DLLs sin firmar o en rutas sospechosas (Downloads, Desktop, etc.). **Muy útil para detectar inyecciones.**

### [3] 👻 Phantom Module Scanner
**Busca** módulos cargados que ya no existen en disco (auto-destrucción) o módulos inusuales sin firma. **Muy útil si borraron la DLL después de cargarla.**

### [4] 🗂️ JNA Cache Inspector
**Revisa** las carpetas temporales (Temp) en busca de librerías nativas (JNA, LWJGL, etc.). **Marca** archivos creados durante la sesión activa de Java. **Muy útil si inyectaron una librería temporal.**

### [5] 🌐 Network Inspector
**Captura** las conexiones de red activas de Java. **Traduce** IPs a dominios y clasifica los puertos (Minecraft, HTTPS, etc.). **Muy útil para ver si el juego se conectó a algo raro.**

### [6] 📜 Log Analyzer
**Revisa** los logs del juego (`latest.log`, `debug.log`, etc.) en busca de strings de cheats o manipulación. **Detecta** si borraron o recrearon los logs durante la sesión. **Muy útil si intentaron ocultar rastros.**

### [7] 🧠 Memory PE Scanner (Manual Mapping)
**Escanea** la memoria de Java buscando ejecutables (PE) que no tienen un módulo asociado en disco. **Muy útil para detectar inyecciones avanzadas (Manual Mapping).**
**⚠️ Limitación:** Algunos inyectores avanzados pueden ocultar sus rastros. Si no encuentra nada, no garantiza que la memoria esté limpia.

### [8] 🕵️ JVM Agent Inspector
**Busca** argumentos de arranque inusuales (`-javaagent`, `-agentlib`, `-noverify`, etc.). **Detecta** si un agente se adjuntó dinámicamente. **Muy útil para ver si inyectaron un agente en Java.**

### [9] 🧬 Mod Analyzer (Obfuscation)
Analiza el código de los `.jar` instalados. Calcula la **ofuscación** (porcentaje de clases con nombres raros) y busca **strings de clientes conocidos** o mods modificados. También lee la procedencia del archivo para saber de dónde se descargó (Si,me inspire en la tool de tonynoh).
### [A] 🕶️ Hidden Files Scanner
Busca archivos ocultos con extensión ejecutable (`.jar`, `.exe`, `.dll`, etc.) en todas las unidades locales y USB. **El clásico de un byppas común** (cheater que recién empieza): esconder el cheat en el escritorio o un USB y ocultarlo con el atributo `Hidden`. La tool lo encuentra al instante.

---

## 6. ⚠️ LIMITACIONES HONESTAS Y CONTEXTO FORENSE

**Importante:** una tool que promete más de lo que da es peor que no tener tool. El staff debe entender el contexto.

1. **Hardware y Grabadores Avanzados:** Ciertos grabadores o macros a nivel de hardware (dispositivos externos, DMA o emuladores) pueden no dejar rastro en el sistema operativo. Estos casos requieren revisión manual y contextual por parte del staff. MultiSkrip se enfoca en lo que ocurre dentro del sistema.
2. **BAM (Background Activity Monitor):** La ausencia de una entrada en BAM no significa que el archivo no se haya ejecutado. BAM puede limpiarse o no registrar ciertos tipos de ejecuciones. Se debe cruzar siempre con Prefetch y Amcache.
3. **La ausencia de un artefacto no es prueba:** Hasta que se confirma que el sistema **debería** tener ese artefacto (ej. `RecentFileCache.bcf` ausente en Win8+ **es normal**), su ausencia no es prueba de nada.
4. **VSS Lite:** 0 snapshots puede ser una **PC sin restauración configurada**, no necesariamente un borrado intencional. Requiere contexto.
5. **Manipulación avanzada de memoria:** Algunos inyectores avanzados pueden ocultar sus rastros en la memoria. El Memory PE Scanner mostrará indicios, pero la ausencia de estos no garantiza que la memoria esté limpia.

---

## 7. ⚙️ CONSIDERACIONES TÉCNICAS ADICIONALES

### 7.1 — Firmas digitales en paralelo
`Get-ParallelSignatures`:
- **Cachea** en `$Global:SigCache` (evita re-firmar)
- **Abre** `[runspacefactory]::CreateRunspacePool(1, $Hilos)` con `$Hilos = ProcessorCount` (default 8)
- **Retorna** hashtable `Path → Get-AuthenticodeSignature`
- **Deduplica** paths antes

### 7.2 — Backup de registro
`Backup-RegistryKey` → `%TEMP%\Multiskrip_Backups\<safe>-<timestamp>.reg` vía `reg.exe export`.

### 7.3 — DLLs de Windows utilizadas (P/Invoke)
| DLL | Uso |
|-----|-----|
| `kernel32.dll` | `GetStdHandle, GetConsoleMode, SetConsoleMode, OpenProcess, CloseHandle, VirtualQueryEx, ReadProcessMemory, QueryDosDevice, GetGuiResources` |
| `user32.dll` | `EnumWindows, GetWindowThreadProcessId, GetWindowText, IsWindowVisible, GetWindowLong, GetWindowDisplayAffinity` |
| `winsqlite3.dll` | `sqlite3_open16, close, prepare16_v2, step, finalize, column_count, column_name16, column_text16, column_type, column_int64` |

---

## 🛠️ Soporte y Feedback

Esta es la **versión inicial (Release Inicial)** de MultiSkrip. Ha sido probada exhaustivamente en entornos reales, pero al ser la primera versión pública, siempre puede haber margen de mejora.

*   **¿Encontraste un bug o tienes una sugerencia?** Únete al servidor de Discord o háblame directo: **xxangelsosoxx**.
*   **Actualizaciones:** Revisa siempre que esta sea la versión más reciente antes de reportar un problema. Las herramientas se irán actualizando periódicamente con mejoras y correcciones.

---

## 📄 License

MIT License

Copyright (c) 2026 XxAngelsosoxX

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
