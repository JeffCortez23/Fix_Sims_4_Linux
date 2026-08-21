# 🛠️ Fix Sims 4 Linux 🐧 (v2.0)

¡Hola! Si juegas a **Los Sims 4 en cualquier distribución de Linux o en Steam Deck (Steam / Proton)**, sabes que las actualizaciones de la **EA App** a menudo rompen la activación de los DLCs, dejan procesos colgados o dificultan la instalación de expansiones.

Este script automatiza por completo la instalación, organización y activación de los DLCs, haciéndolo compatible con las versiones más recientes de la EA App y Wine/Proton.

---

### ✨ Funciones (v2.0)
* 📦 **Instalador inteligente de DLCs**:
  * Soporta archivos individuales (`.zip`, `.rar`, `.7z`).
  * Soporta **carpetas con múltiples archivos comprimidos** (ej. descargas en lote de Telegram o navegador), descomprimiendo cada paquete automáticamente.
  * Reorganiza y aplana carpetas anidadas (ej. subcarpetas `all in one/` o `The Sims 4/` dentro de la descarga).
* 🔓 **Activación avanzada de EA App + Wine Overrides**:
  * Inyección dinámica de `version.dll` en las nuevas rutas versionadas de la EA App.
  * Registro automático de `DllOverrides` (`"version"="native,builtin"`) en el registro de Proton (`user.reg`).
  * Limpieza de cachés antiguas de EA Desktop para sincronización limpia de licencias.
* 🔪 **Fix Sims (Mata procesos fantasma)**: ¿Steam se queda trabado en "Detener" o "Ejecutando"? Cierra los procesos colgados (`steam-runtime-reaper`, `EADesktop`, `TS4_x64`, `Link2EA`) con un solo clic.
* 🌐 **Compatibilidad universal**: Funciona en Steam Nativo, Steam Flatpak, Steam Snap y SteamOS / Steam Deck (incluso en tarjetas MicroSD).
* ⚙️ **Autoguardado**: Guarda tus rutas en `~/.config/sims4_gestor.conf` para no tener que escribirlas cada vez.

---

### 📋 Requisitos

1. **Juego base**: Instalado en Steam.
2. **Herramienta 7z**:
   * Arch / Manjaro / CachyOS: `sudo pacman -S p7zip`
   * Ubuntu / Debian / Mint: `sudo apt install p7zip-full`
   * Fedora: `sudo dnf install p7zip p7zip-plugins`
3. **Estructura recomendada**: Coloca el script en la misma carpeta que los archivos del *EA DLC Unlocker* (Anadius / Jardinera):

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

1. Abre la terminal en la carpeta donde tienes el script y los archivos del Unlocker.
2. Dale permisos de ejecución:
   ```bash
   chmod +x fix_sims_linux.sh
   ```
3. Ejecútalo:
   ```bash
   ./fix_sims_linux.sh
   ```
4. Elige la opción del menú:
   * **Opción 1**: Para instalar/descomprimir tus DLCs descargados.
   * **Opción 2**: Para activar el Unlocker e inyectarlo en la EA App.
   * **Opción 3**: Para destrabar Steam si el juego no cierra.

---

### 💡 PRO-TIP: Crea un atajo rápido (Alias) ⚡

Si quieres abrir el gestor desde cualquier lugar sin tener que buscar la carpeta cada vez, ¡créale un alias! Así, con solo escribir `fixsims` en tu terminal, el programa se abrirá por arte de magia.

#### 🐧 Para Bash o Zsh (La mayoría de distros)
1. Abre tu archivo de configuración:
   ```bash
   nano ~/.bashrc   # o nano ~/.zshrc si usas Zsh
   ```
2. Ve hasta el final del archivo y pega esta línea (¡reemplaza la ruta por la tuya!):
   ```bash
   alias fixsims='bash /ruta/absoluta/hacia/tu/fix_sims_linux.sh'
   ```
3. Guarda los cambios (Ctrl+O, Enter, Ctrl+X) y recarga tu terminal:
   ```bash
   source ~/.bashrc   # o source ~/.zshrc
   ```

#### 🐟 Para Fish Shell
1. Escribe este comando en tu terminal (reemplazando la ruta con la tuya):
   ```bash
   alias fixsims "bash /ruta/absoluta/hacia/tu/fix_sims_linux.sh"
   ```
2. Guárdalo para siempre escribiendo:
   ```bash
   funcsave fixsims
   ```

🎉 ¡Listo! A partir de ahora, solo escribe **`fixsims`** en cualquier terminal y el menú aparecerá al instante.

