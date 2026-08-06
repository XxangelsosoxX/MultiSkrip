# MultiSkrip (KSHY112L)

MultiSkrip es un entorno de auditoría forense y análisis en tiempo real desarrollado en PowerShell, creado para moderadores y staff que realizan revisiones de ScreenShare (SS) en servidores de Minecraft. Su objetivo principal es simplificar la inspección del sistema operativo, identificar artefactos anómalos y verificar la integridad de Windows durante una auditoría en vivo, manteniendo siempre una postura segura mediante confirmaciones previas y respaldos del Registro.

## Ejemplo de Funcionamiento: Módulo Filelezz

Para entender la capacidad de la suite, el módulo Filelezz Analysis actúa como un motor de correlación e inspección profunda de comandos inyectados en memoria:

* **Auditoría de Procesos y Comandos:** Detecta patrones de ejecución sospechosos u ofuscados, tales como Invoke-Expression, EncodedCommand, DownloadString o ExecutionPolicy Bypass.
* **Análisis de Entorno y Persistencia:** Revisa políticas globales del sistema, el historial de PSReadLine, claves Run del Registro y Tareas Programadas externas.
* **Score de Evidencia:** Procesa los hallazgos y calcula un puntaje (Score de 1 a 10) acompañado de una barra de confianza visual, ofreciendo al moderador un diagnóstico claro sobre la legitimidad de la actividad detectada.

## Criterio y Falsos Positivos en la Auditoría

La herramienta no sanciona de forma automática. MultiSkrip recopila y organiza evidencia del sistema para su revisión. La sola presencia de un registro, comando o marca de tiempo no constituye una prueba infalible por sí sola; el juicio del moderador y la correlación de datos son fundamentales para interpretar correctamente los hallazgos.

## Antivirus / Windows Defender

Al estar desarrollado en PowerShell y realizar lecturas de memoria, inspección del Registro y gestión de procesos, Windows Defender o tu antivirus pueden marcar el script como un Falso Positivo (ej. PUP, AMSIDetection o SuspiciousScript).

* **¿Por qué ocurre?** Los antivirus detectan herramientas administrativas avanzadas (consultas a artefactos BAM/UserAssist y hooks de proceso) como comportamiento inusual.
* **Código Transparente:** MultiSkrip es 100% código abierto (Open Source). Puedes inspeccionar libremente cada línea de código .ps1 antes de ejecutarlo para verificar que no contiene software malicioso ni realiza conexiones no autorizadas.
* **Solución de Ejecución:** Si Windows SmartScreen o el antivirus bloquean la herramienta:
1. Haz clic en "Más información" -> "Ejecutar de todos modos".
2. Si es necesario, desbloquea el archivo desde PowerShell: `Unblock-File -Path .\MultiSkrip.ps1`.
3. Ejecuta siempre la consola con Privilegios de Administrador.



## Guía de Usuario Integrada

La herramienta incluye una documentación nativa ejecutable mediante la Opción [20] Guía User. Este apartado en el menú principal desglosa en pantalla la función exacta de los 18 módulos de auditoría y del submenú de reparación avanzada, permitiendo al moderador consultar el propósito y la interpretación de cada prueba sin necesidad de salir de la consola durante el procedimiento.

## Fase Beta & Reporte de Bugs

MultiSkrip se encuentra actualmente en Fase Beta. Al tratarse de una versión en constante evolución y prueba, es posible que se presenten bugs o incompatibilidades según la versión o configuración del sistema operativo. Se agradece a la comunidad de moderación la lectura crítica de los datos y el reporte de cualquier falla o sugerencia de mejora para seguir puliendo el proyecto.

## Ejecución Rápida

Para ejecutar MultiSkrip directamente sin descargar archivos ni lidiar con falsos positivos de antivirus, abre PowerShell (como Administrador) y pega la siguiente línea:

```powershell
irm https://raw.githubusercontent.com/XxangelsosoxX/MultiSkrip/main/MultiSkripBeta.ps1 | iex

```

## Créditos y Contacto

* **Creador / Desarrollador:** XxangelsosoxX
* **Nick MCxd:** `XxangelsosoxX`
* **Discord:** `Angel_ytz`
* Servidor Favorito xd :v  `Play.tilted.lol`
