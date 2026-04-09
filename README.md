# 🛠️ Fix Sims 4 Linux 🐧

¡Hola! Si juegan **Los Sims 4 en cualquier distro de Linux (Steam)**, saben que a veces la EA App se cuelga o instalar DLCs cuesta. Creé este script para automatizar todo.

### ✨ Funciones
* 📦 **Instala DLCs:** Extrae tu `.zip`, `.rar` o copia tu carpeta de expansiones donde corresponde.
* 🔓 **Activa DLCs:** Configura la EA App para que reconozca todo automáticamente.
* 🔪 **Fix Sims:** ¿Botón pegado en "Detener"? Mata procesos fantasma para destrabar Steam.
* ⚙️ **Autoguardado:** Pide tus rutas una vez y las recuerda.

---

### 📋 Requisitos

1. **Juego base:** Instalado en Steam.
2. **Dependencia 7z:** (Ej: `sudo pacman -S p7zip` o `sudo apt install p7zip-full`).
3. **Estructura vital:** El script **debe** estar en la misma carpeta que el *EA DLC Unlocker*. Así:

   📂 EA_DLC_Unlocker/
   ├── 📜 fix_sims_linux.sh
   ├── 📜 config.ini
   └── 📂 ea_app/
       └── ⚙️ version.dll

---

### 🚀 Uso

1. Abre la terminal en la carpeta del Unlocker.
2. Da permisos: `chmod +x fix_sims_linux.sh`
3. Ejecuta: `./fix_sims_linux.sh`
4. Sigue las instrucciones (arrastra tus archivos a la terminal para autocompletar la ruta) y elige del menú.
