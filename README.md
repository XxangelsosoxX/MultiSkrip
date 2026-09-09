# 🛠️ MULTISKRIP - KSHY112L

> Herramienta creada por **XxangelsosoxX**  
> Suite multifunción desarrollada en **PowerShell** para análisis, diagnóstico, reparación y revisión de sistemas Windows.

---

## 🔗 Enlaces Oficiales

- 📥 **GitHub / Releases:**  
  https://github.com/XxangelsosoxX/MultiSkrip/releases/tag/v1.0-beta

- 📢 **Discord / Updates:**  
  https://discord.gg/PWSbNGPvnH

---

## 📖 Descripción

**MultiSkrip** es una suite interactiva desarrollada de forma nativa en **PowerShell**, orientada a la revisión profunda del sistema, diagnóstico y análisis de artefactos de Windows (SS)

La herramienta reúne **más de 35 funciones** dentro de un menú centralizado.

El objetivo del proyecto es proporcionar diferentes herramientas de análisis y administración desde una única interfaz de consola, utilizando funciones nativas de Windows y PowerShell siempre que sea posible.

> ⚠️ Algunas funciones requieren ejecutar PowerShell como **Administrador**.

---

# 🖥️ System Information

Al iniciar MultiSkrip, la herramienta puede mostrar información general del sistema y realizar comprobaciones iniciales de servicios y eventos.

```text
================================================================
                    SYSTEM INFORMATION
                    Made by XxangelsosoxX
================================================================
 PC Name   : DESKTOP-EJEMPLO
 User      : Usuario
 OS        : Microsoft Windows 10 Pro
 Arch      : 64-bit
 Boot Time : 2026-09-07 00:23:37
 Uptime    : 1 días, 19 horas, 24 minutos
 Admin     : Sí
================================================================

[ --- HEALTH CHECK --- ]
 - pcasvc    : Running
 - DPS       : Running
 - eventlog  : Running
 - bam       : Running
 - Appinfo   : Running
 - SysMain   : Running
```

### 📊 Información inicial

- **System Information:** muestra información básica del equipo, arquitectura, usuario, privilegios y tiempo de actividad.
- **Health Check:** comprueba el estado de diferentes servicios de Windows.
- **Recent System Events:** permite revisar eventos recientes relacionados con apagados, reinicios y errores del sistema.

---

# ⚠️ Alerta de Arranque por Eventos de Energía

MultiSkrip puede revisar eventos recientes del sistema para detectar situaciones como:

- **Kernel-Power 41:** apagados o reinicios inesperados.
- **EventID 6008:** apagado inesperado del sistema.
- **BugCheck 1001:** eventos relacionados con errores graves/BSOD.
- **EventID 1074:** reinicios o apagados iniciados por procesos o usuarios.

La finalidad es proporcionar contexto sobre el estado reciente del sistema.

---

# 🚀 Módulos del Menú Principal

MultiSkrip organiza sus herramientas mediante diferentes módulos.

## 🎥 Recording Killer

Escanea procesos relacionados con grabadores o transmisores de pantalla.

Permite:

- Visualizar procesos detectados.
- Seleccionar procesos individualmente.
- Finalizar procesos seleccionados.
- Trabajar con múltiples procesos.

---

## 🧠 Filelezz

Suite de análisis que reúne diferentes comprobaciones relacionadas con:

- Comandos ejecutados.
- Políticas de PowerShell.
- PSReadLine.
- Persistencias del Registro.
- Indicadores encontrados durante el análisis.
- Sistema de puntuación/correlación.

---

## 🧩 IFEO

Analiza las configuraciones de:

```text
Image File Execution Options
```

Busca configuraciones como valores:

```text
Debugger
```

que puedan modificar el comportamiento de ejecución de determinados programas.

---

## 📁 Directorio Scanner V2

Motor de búsqueda basado en patrones e indicadores.

Funciones:

- Escaneo de directorios.
- Búsqueda de nombres o patrones.
- Contador de resultados.
- Barra de progreso.
- Revisión de ubicaciones seleccionadas.

---

## 🌐 VPN Detector

Realiza una comprobación de red para detectar indicios de:

- Proxy.
- VPN.
- Configuraciones de red relacionadas.

> Los resultados dependen de la información disponible en el sistema y de la red utilizada.

---

## 📊 Extractor ShowJumpView

Analiza información relacionada con elementos recientes de Windows para mostrar datos como:

- Elementos utilizados.
- Conteos de uso.
- Información de archivos.
- Firmas digitales cuando están disponibles.

---

## ⚙️ Services

Muestra información de servicios de Windows:

- Nombre.
- Estado.
- Tipo de inicio.
- Información relevante del servicio.

---

## 🔍 File Scanner

Analizador heurístico de archivos.

Puede buscar indicadores como:

```text
MZ
PK
```

para identificar archivos que podrían contener estructuras de ejecutables o archivos comprimidos.

> Es un análisis heurístico y un indicador encontrado no significa automáticamente que el archivo sea malicioso.

---

## 📦 ForensicsWinrar

Analiza artefactos relacionados con WinRAR y archivos abiertos recientemente.

Permite revisar información disponible sobre:

- Archivos utilizados.
- Historial.
- Elementos recientes.

---

## 🧠 BAM Detector

Analiza información del:

```text
Background Activity Monitor (BAM)
```

para mostrar registros relacionados con actividad de aplicaciones.

---

## 🌳 Parent Process Analyzer

Muestra la relación jerárquica entre procesos.

Permite visualizar:

```text
Proceso padre
    └── Proceso hijo
          └── Proceso hijo
```

Esto ayuda a comprender el contexto de ejecución de diferentes procesos.

---

## 🌐 DNS Cache Viewer

Muestra información disponible en la caché DNS del sistema.

Permite revisar:

- Dominios.
- Resoluciones almacenadas.
- Información de caché disponible.

---

## ⏰ Tareas Programadas

Analiza las tareas programadas de Windows y permite filtrar aquellas que no pertenecen a Microsoft.

Puede mostrar:

- Nombre.
- Ruta.
- Estado.
- Información de ejecución.

---

## 📄 Recent Files Analyzer

Muestra archivos utilizados recientemente por Windows.

Permite consultar los elementos recientes disponibles en el sistema.

---

## ⚡ Prefetch Inventory

Analiza archivos:

```text
*.pf
```

dentro de las ubicaciones correspondientes al sistema.

Puede mostrar:

- Nombre.
- Fecha.
- Información disponible del archivo.

---

## 🌐 Network Connections

Muestra conexiones TCP activas y relaciona información como:

```text
Connection
PID
Process
Path
```

Esto permite asociar una conexión con el proceso que la está realizando.

---

## 👤 UserAssist Analyzer

Analiza las entradas UserAssist del Registro de Windows.

Incluye decodificación ROT13 para interpretar las entradas almacenadas por Windows.

Puede mostrar:

- Aplicaciones.
- Ejecuciones.
- Frecuencia disponible.

---

## 🧪 PfCheck

Comprueba archivos Prefetch y busca indicadores como:

- Archivos de 0 bytes.
- Cabeceras inesperadas.
- Archivos potencialmente corruptos.

---

## ☕ JavaJarDetector V2

Analiza información relacionada con Java y archivos `.jar`.

Puede correlacionar información proveniente de:

- Argumentos `-jar`.
- Información de procesos.
- Logs.
- Historiales disponibles.

También permite identificar patrones de nombres o extensiones sospechosas.

---

## 🗃️ PCAStoreAnalyzer

Analiza:

```text
Compatibility Assistant
```

y la información registrada por PCA/PcaSvc.

Permite revisar ejecuciones registradas en la base de datos correspondiente.

---

## 💥 AppCrasherAnalyzer

Analiza eventos:

```text
EventID 1000
```

para mostrar cierres inesperados de aplicaciones.

Puede mostrar los últimos eventos encontrados y su información asociada.

---

## 📂 TempAnalyzer

Analiza archivos recientes ubicados en:

```text
%TEMP%
```

Incluye comprobaciones a nivel de archivo para obtener información adicional.

---

## 🕐 Recent System Events

Genera una línea de tiempo de eventos recientes relacionados con:

- Apagados.
- Reinicios.
- Kernel-Power.
- Errores importantes del sistema.

Los eventos especialmente recientes pueden resaltarse visualmente.

---

## 🕒 TimeChangeDetector

Analiza eventos relacionados con cambios de fecha y hora.

Entre los eventos considerados pueden encontrarse:

```text
EventID 4616
EventID 1
```

El objetivo es identificar modificaciones registradas de la hora del sistema.

---

# 🔧 Panel Avanzado / Restauración

MultiSkrip incluye herramientas adicionales destinadas al diagnóstico y restauración de determinadas configuraciones de Windows.

---

## 🌐 URL Block Audit / Repair

Revisa determinadas configuraciones de bloqueo de URLs asociadas a navegadores como:

- Chrome.
- Edge.
- Brave.

Permite revisar y, cuando corresponde, realizar acciones de reparación.

---

## 💻 Unlock CMD

Busca restricciones relacionadas con:

```text
DisableCMD
```

y proporciona una opción para restaurar el acceso a la consola cuando dicha restricción está presente.

---

## 🚫 Clear DisallowRun

Analiza configuraciones:

```text
DisallowRun
```

relacionadas con restricciones de ejecución de determinadas aplicaciones.

---

## 📝 Gpedit / Registry Tools

Permite revisar configuraciones relacionadas con:

```text
DisableRegistryTools
```

y proporcionar acciones de restauración cuando corresponda.

---

## 🛠️ Repair CMD / Power

Incluye herramientas destinadas a revisar y restaurar determinadas configuraciones relacionadas con:

- CMD.
- Procesadores de comandos.
- Auto-ejecución.
- Políticas del sistema.

---

## 🔥 Firewall Outbound

Permite revisar reglas de salida del Firewall de Windows y detectar configuraciones de bloqueo.

---

## 🧾 Journal Deleted Detector

Busca indicadores relacionados con modificaciones o vaciado del:

```text
USN Journal
```

utilizando la información de eventos disponible.

---

## 📁 Detectar Bypass FileInfo

Analiza determinados eventos relacionados con operaciones de archivos y proporciona información sobre indicadores registrados por Windows.

---

## 🗑️ Recycle Bin Audit

Inspecciona información disponible sobre:

- Papelera de reciclaje.
- Elementos eliminados.
- Metadatos disponibles.

---

## 🌐 Host Repair

Analiza el archivo:

```text
C:\Windows\System32\drivers\etc\hosts
```

para identificar redirecciones o entradas personalizadas.

También proporciona opciones para editar/restaurar el archivo.

---

## 📂 Disabled OpenSave Detector

Busca la configuración:

```text
NotFileMru
```

relacionada con el historial de archivos abiertos/guardados.

---

## 🗂️ Directories

Panel de acceso rápido a diferentes ubicaciones de Windows.

Incluye accesos a:

- Directorios del sistema.
- Carpetas de usuario.
- Registro.
- Cachés.
- Herramientas administrativas.
- Rutas utilizadas durante análisis.

---

# 📖 Guía User

MultiSkrip incluye una sección de ayuda integrada para explicar el funcionamiento general de las diferentes herramientas y opciones del menú.

---

# 🚀 Ejecución Rápida con PowerShell

También puedes ejecutar las versiones `.ps1` directamente desde PowerShell.

> ⚠️ **IMPORTANTE:** `irm ... | iex` descarga código desde Internet y lo ejecuta directamente. Utiliza únicamente las URLs oficiales del proyecto y revisa el código si quieres verificar qué se va a ejecutar.

## 🔵 MultiSkrip v1.0

```powershell
irm 'https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.0.ps1' | iex
```

## 🟢 MultiSkrip v1.1

```powershell
irm 'https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.1.ps1' | iex
```

## 🟣 MultiSkrip v1.2

```powershell
irm 'https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.2.ps1' | iex
```

> Si una versión cambia de Release/tag en el futuro, actualiza las URLs correspondientes.

---

# 📥 Descargas

Todas las versiones disponibles se encuentran en la Release oficial.

## 🔵 MultiSkrip v1.0

**EXE:**

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.0.exe
```

**PowerShell:**

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.0.ps1
```

---

## 🟢 MultiSkrip v1.1

**EXE:**

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.1.exe
```

**PowerShell:**

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.1.ps1
```

---

## 🟣 MultiSkrip v1.2

**EXE:**

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.2.exe
```

**PowerShell:**

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/download/v1.0-beta/MultiSkripV1.2.ps1
```

---

# 📦 Release Oficial

Puedes encontrar todos los archivos compilados y scripts publicados en:

```text
https://github.com/XxangelsosoxX/MultiSkrip/releases/tag/v1.0-beta
```

Actualmente la Release contiene:

```text
MultiSkripV1.0.exe
MultiSkripV1.0.ps1

MultiSkripV1.1.exe
MultiSkripV1.1.ps1

MultiSkripV1.2.exe
MultiSkripV1.2.ps1
```

---

# 📢 Updates / Comunidad

Para recibir actualizaciones, novedades, cambios de versiones, soporte y anuncios del proyecto:

```text
https://discord.gg/PWSbNGPvnH
```

---

# Autor

**XxangelsosoxX**

Proyecto desarrollado en **PowerShell**.

---

### ⚠️ Aclaraciones Importantes:

* **Falsos Positivos:** Al ser una herramienta de auditoría que analiza memoria y registros del sistema, algunos antivirus o navegadores pueden detectarla como falso positivo. La ejecución es completamente transparente y de código abierto.
* **Desarrollo Activo (Beta):** Al encontrarse en fase Beta, se lanzarán **actualizaciones periódicas** para corregir detalles, añadir nuevos módulos y mejorar la detección.

## MultiSkrip es una herramienta de análisis, diagnóstico y administración de Windows.

Los resultados de determinados módulos se basan en heurísticas, registros y artefactos disponibles en el sistema. Un indicador detectado **no constituye por sí solo una prueba definitiva** de actividad maliciosa, existen mods o programas legales que usan inyeccion de codigo o metodos similares a un byppas-attempts,dejando residuos en memoria que sueltan falsos positivos.quien haga el screenshare deve revisar mas a fondo y validad el hallazgo encontrado antes de sancionar,evitando asi el FALSE BAN.

