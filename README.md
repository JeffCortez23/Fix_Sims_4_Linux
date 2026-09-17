# 🛠️ Fix Sims 4 Linux 🐧 (v2.3)

¡Hola! Si juegas a **Los Sims 4 en Linux o Steam Deck** (mediante **Steam, Lutris, Bottles, Heroic o Wine**), sabes que las actualizaciones de la **EA App** suelen romper la activación de los DLCs, dejar procesos huérfanos, provocar caídas de FPS o tirones por shaders.

Este gestor automatiza por completo la instalación, diagnóstico, optimización gráfica/DXVK, limpieza, gestión de mods y activación de los DLCs de forma no invasiva, compatible con las versiones más recientes de la EA App y Wine/Proton.

---

## 🚀 Instalación y Uso Rápido (1 solo comando)

Abre tu terminal favorita en Linux o el modo escritorio de tu Steam Deck y ejecuta:

```bash
bash <(curl -sSL https://tinyurl.com/2y3tbsq9)
```

> **💡 Consejo:** Si prefieres guardarlo localmente:
> ```bash
> curl -sSL https://tinyurl.com/2y3tbsq9 -o fix_ts4.sh && bash fix_ts4.sh
> ```

---

### ✨ Funciones Principales (v2.3)

* ⚡ **Optimización Gráfica, Hardware & DXVK (Anti-Stuttering)**:
  * **Detección Directa de Hardware:** Lee CPU, GPU (AMD Radeon, NVIDIA, Intel) y RAM directamente desde el kernel de Linux.
  * **Perfil DXVK Ultra-Rendimiento (`dxvk.conf`):** Genera una configuración optimizada en `Game/Bin` activando `GraphicsPipelineLibrary` (GPL), compilación asíncrona de shaders multihilo (`numCompilerThreads`) y presupuesto de memoria VRAM adaptado para erradicar los tirones y congelamientos al viajar o construir.
  * **GraphicsRules Tuning:** Fuerza la memoria de texturas óptima (2048 MB para APUs / 4096 MB para GPUs dedicadas) y activa el nivel gráfico Uber para evitar texturas borrosas o degradadas.
  * **Arranque Rápido & Anti-Lag (`Options.ini`):** Desactiva la telemetría pesada de EA en segundo plano (`enabletelemetry = 0`), suprime la molesta ventana emergente de lista de mods al iniciar (`showmodliststartup = 0` para una carga 3x más rápida con CC) y preconfigura 1080p nativo a 60 FPS.
* 📂 **Acceso Directo a la Carpeta Mods:**
  * Localiza automáticamente la carpeta `Electronic Arts/The Sims 4/Mods` (o `Los Sims 4/Mods`) dentro de tu prefijo Wine/Proton o documentos y la abre con 1 clic en tu explorador de archivos nativo (Dolphin, Nautilus, Thunar, etc.) mediante `xdg-open`.
* 🔍 **Diagnóstico & Health Check de DLCs**:
  * Escanea tu juego y te muestra una lista organizada de todos los Packs de Expansión (EP), Contenido (GP), Accesorios y Kits (SP) instalados con sus nombres reales en español e inglés y tamaño en disco.
  * Verifica el estado de inyección del Unlocker, el registro de Wine (`user.reg`) y los archivos de configuración.
* 🧹 **Limpiador de Caché del Juego**:
  * Pone fin a las pantallas de **carga infinita** y errores de interfaz eliminando con 1 clic archivos residuales (`localthumbcache.package`, `avatarcache.package`, `cache/`, `onlinerequestcache/`, etc.) sin tocar tus partidas (`saves`), casas (`Tray`) ni Mods.
* 🌐 **Auto-Descargador de EA DLC Unlocker**:
  * Descarga y actualiza automáticamente los archivos oficiales más recientes del Unlocker (Anadius / Jardinera) verificando su integridad SHA-256 sin que tengas que buscarlos manualmente por la web.
* 🖥️ **Creador de Acceso Directo (.desktop)**:
  * Genera automáticamente un lanzador con icono temático de Plumbob verde en tu menú de aplicaciones y en el Escritorio (ideal para Steam Deck y modo escritorio).
* 📦 **Instalador de DLCs Individual y por Lotes (Batch)**:
  * Soporta archivos `.zip`, `.rar`, `.7z` individuales.
  * Soporta **carpetas con múltiples archivos comprimidos** (ej. descargas por partes de Telegram o navegadores), descomprimiendo y organizando cada paquete automáticamente con indicador de progreso interactivo.
  * Aplanador inteligente: saca automáticamente las carpetas anidadas (`all in one/`, `The Sims 4/`, `DLCs/`) para colocarlas en la raíz del juego.
* 🔓 **Activación de EA App + Wine DllOverrides**:
  * Inyección dinámica de `version.dll` en todas las subcarpetas versionadas de EA App (`13.xxx/EA Desktop`, `compatibility32/`).
  * Registro automático de `DllOverrides` (`"version"="native,builtin"`) en el registro de Wine/Proton (`user.reg`).
* 🎮 **Soporte Multi-Lanzador**:
  * Detección y selección automática para **Steam** (Nativo, Flatpak, Snap, MicroSD en Steam Deck), **Lutris**, **Bottles**, **Heroic Games Launcher** y prefijos personalizados de Wine.
* 🔪 **Fix Sims (Mata procesos fantasma)**:
  * ¿Steam o la EA App se quedaron trabados en "Detener" o "Ejecutando"? Cierra los procesos huérfanos (`steam-runtime-reaper`, `EADesktop.exe`, `TS4_x64.exe`, `Link2EA.exe`) al instante.

---

### 📋 Requisitos

1. **Los Sims 4**: Instalado a través de Steam, Lutris, Bottles, Heroic o Wine.
2. **Herramienta 7z**:
   * Arch / Manjaro / CachyOS / SteamOS: `sudo pacman -S p7zip`
   * Ubuntu / Debian / Mint: `sudo apt install p7zip-full`
   * Fedora: `sudo dnf install p7zip p7zip-plugins`

---

### 🖥️ Menú del Gestor

```text
╭──────────────────────────────────────────────────────────────╮
│         💎 GESTOR DE LOS SIMS 4 (LINUX EDITION) v2.3         │
│       Steam • Steam Deck • Lutris • Bottles • Heroic         │
╰──────────────────────────────────────────────────────────────╯

  [1] 📦  Instalar / Mover DLCs al juego (ZIP, RAR, Lotes)
  [2] 🔓  Reactivar DLCs (Inyección EA App + Wine Override)
  [3] ⚡  Optimización de Gráficos, GPU & DXVK (Anti-Stutter & VRAM)
  [4] 📂  Abrir carpeta Mods del juego (Mods / CC)
  [5] 🔍  Diagnóstico de DLCs e Inyección (Health Check)
  [6] 🧹  Limpiar Caché del Juego (Solución Carga Infinita)
  [7] 🌐  Descargar / Actualizar EA DLC Unlocker (Auto)
  [8] 🖥️   Crear Acceso Directo (.desktop / Steam Deck)
  [9] 🔪  Forzar cierre de procesos colgados (Fix Sims/EA)
  [10] ⚙️   Reconfigurar rutas del script / Lanzador
  [11] ℹ️  Acerca de & Changelog
  [0] 🚪  Salir
```

---

### 💡 PRO-TIP: Crea un atajo rápido (Alias) ⚡

Para abrir el gestor desde cualquier parte escribiendo simplemente `fixsims`:

#### 🐧 Para Bash o Zsh (La mayoría de distros y Steam Deck)
1. Abre tu archivo de configuración:
   ```bash
   nano ~/.bashrc   # o nano ~/.zshrc si usas Zsh
   ```
2. Añade al final:
   ```bash
   alias fixsims='bash /ruta/absoluta/hacia/tu/fix_sims_linux.sh'
   ```
3. Guarda los cambios y recarga tu terminal:
   ```bash
   source ~/.bashrc   # o source ~/.zshrc
   ```

#### 🐟 Para Fish Shell
```bash
alias fixsims "bash /ruta/absoluta/hacia/tu/fix_sims_linux.sh"
funcsave fixsims
```

---

### 📜 Changelog / Historial de Versiones

#### 🚀 Versión 2.3 (Actual)
* **⚡ Optimización Gráfica, GPU & DXVK Anti-Stutter:**
  * Detección dinámica de procesador, núcleos, GPU física y RAM del sistema.
  * Generación automática de `dxvk.conf` con `GraphicsPipelineLibrary` y shaders asíncronos para eliminar micro-congelamientos.
  * Ajuste de `GraphicsRules.sgr` con VRAM calculada y nivel gráfico Uber.
  * Desactivación de telemetría de EA (`enabletelemetry = 0`) y omisión del modal de mods (`showmodliststartup = 0`) en `Options.ini` para acelerar el inicio del juego.
* **📂 Abrir Carpeta Mods:** Acceso directo en el explorador de archivos nativo con `xdg-open` para `The Sims 4` y `Los Sims 4`.
* **⌨️ Entrada Interactiva Robusta (`leer_teclado`):** Reconexión automática a `/dev/tty` para soporte total en ejecuciones mediante tuberías (`curl | bash`).

#### 🚀 Versión 2.2
* **📂 Abrir Carpeta Mods:** Acceso directo en el explorador de archivos nativo con `xdg-open`.
* **🌐 TinyURL Oficial:** Comando rápido de instalación y ejecución en una sola línea.

#### 🚀 Versión 2.1
* **🔍 Diagnóstico & Health Check de DLCs**: Nuevo inspector detallado que lista expansiones, kits y packs instalados con sus nombres reales y verifica el estado de inyección.
* **🧹 Limpiador de Caché de Los Sims 4**: Eliminación segura de `localthumbcache.package`, `avatarcache.package` y cachés temporales para resolver problemas de carga infinita y errores de mods.
* **🌐 Auto-descargador del EA DLC Unlocker**: Descarga e instalación automática de los archivos verificados de Anadius / Jardinera con verificación SHA-256.
* **🖥️ Creador de Acceso Directo**: Generador de archivo `.desktop` con icono SVG de Plumbob para el menú de aplicaciones y escritorio (soporte especial para Steam Deck).
* **🎮 Soporte Multi-Lanzador**: Compatibilidad añadida para detectar y gestionar instalaciones en Lutris, Bottles, Heroic Games Launcher y prefijos manuales de Wine.

#### 🚀 Versión 2.0
* **Compatibilidad con nuevas versiones de EA App**: Localización dinámica de ejecutables en subcarpetas versionadas (`13.xxx/EA Desktop`, `compatibility32/`).
* **Inyección de Wine DllOverrides**: Registro automático de `"version"="native,builtin"` en `user.reg`.
* **Extracción de DLCs por lotes (Batch)**: Detección y descompresión secuencial automática de carpetas con múltiples archivos `.zip`, `.rar`, `.7z`.
* **Aplanador automático de carpetas**: Reorganización automática de carpetas anidadas (`all in one/`, `The Sims 4/`).

#### 📦 Versión 1.0
* Primera versión funcional para Linux con inyección básica en Steam y cierre de procesos colgados.
