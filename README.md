# 🛠️ Fix Sims 4 Linux 🐧 (v2.1)

¡Hola! Si juegas a **Los Sims 4 en Linux o Steam Deck** (mediante **Steam, Lutris, Bottles, Heroic o Wine**), sabes que las actualizaciones de la **EA App** suelen romper la activación de los DLCs, dejar procesos huérfanos o dificultar la instalación de expansiones.

Este gestor automatiza por completo la instalación, diagnóstico, limpieza y activación de los DLCs de forma no invasiva, compatible con las versiones más recientes de la EA App y Wine/Proton.

---

### ✨ Funciones Principales (v2.1)

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
  * Soporta **carpetas con múltiples archivos comprimidos** (ej. descargas por partes de Telegram o navegadores), descomprimiendo y organizando cada paquete automáticamente.
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
   * Arch / Manjaro / CachyOS: `sudo pacman -S p7zip`
   * Ubuntu / Debian / Mint: `sudo apt install p7zip-full`
   * Fedora: `sudo dnf install p7zip p7zip-plugins`
3. **Estructura recomendada**: Puedes colocar el script en cualquier lugar o en la carpeta del Unlocker. Si no tienes los archivos del Unlocker, puedes usar la **Opción 5** del script para descargarlos automáticamente:

```text
📂 EA_DLC_Unlocker/
├── 📜 fix_sims_linux.sh
├── 📜 config.ini
├── 📜 g_LOS SIMS 4.ini
└── 📂 ea_app/
    └── ⚙️ version.dll
```

---

### 🚀 Uso

1. Abre la terminal en la carpeta del script:
2. Dale permisos de ejecución:
   ```bash
   chmod +x fix_sims_linux.sh
   ```
3. Ejecútalo:
   ```bash
   ./fix_sims_linux.sh
   ```
4. Elige la opción que necesites en el menú interactivo:

```text
====================================================
    Gestor de Los Sims 4 (Linux Edition) v2.1       
====================================================
1) Instalar / Mover DLCs al juego (ZIP, RAR, Lotes)
2) Reactivar DLCs (Inyección EA App + Wine Override)
3) 🔍 Diagnóstico de DLCs e Inyección (Health Check)
4) 🧹 Limpiar Caché del Juego (Solución Carga Infinita)
5) 🌐 Descargar / Actualizar EA DLC Unlocker (Auto)
6) 🖥️ Crear Acceso Directo (.desktop / Steam Deck)
7) 🔪 Forzar cierre de procesos colgados (Fix Sims/EA)
8) ⚙️ Reconfigurar rutas del script / Lanzador
9) Salir
====================================================
```

---

### 💡 PRO-TIP: Crea un atajo rápido (Alias) ⚡

Para abrir el gestor desde cualquier parte escribiendo simplemente `fixsims`:

#### 🐧 Para Bash o Zsh (La mayoría de distros)
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

#### 🚀 Versión 2.1 (Actual)
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
