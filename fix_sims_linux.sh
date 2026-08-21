#!/usr/bin/env bash

# ==========================================
#   Gestor de Los Sims 4 (Linux Edition) v2.0
#   Compatible con nuevas versiones de EA App
# ==========================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$HOME/.config/sims4_gestor.conf"
UNLOCKER_STORE="$HOME/.local/share/sims4_unlocker"

# Rutas estándar de Steam
STEAM_PATHS=(
    "$HOME/.local/share/Steam"
    "$HOME/.steam/steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
    "$HOME/snap/steam/common/.local/share/Steam"
)

# --- FUNCIÓN DE BÚSQUEDA AUTOMÁTICA DE ARCHIVOS DEL UNLOCKER ---
localizar_archivos_unlocker() {
    UNLOCKER_DLL=""
    UNLOCKER_INI=""
    UNLOCKER_GAME_INI=""

    CANDIDATOS=(
        "$UNLOCKER_STORE"
        "$SCRIPT_DIR"
        "$SCRIPT_DIR/EA DLC Unlocker v3.3"
        "$HOME/Downloads/jardinera_extracted"
        "$HOME/Downloads/EA Abono WIN 3.3/EA DLC Unlocker v3.3"
        "$HOME/Downloads/Web Jardinera Unlocker - Linux"
    )

    for dir in "${CANDIDATOS[@]}"; do
        if [ -f "$dir/ea_app/version.dll" ] && [ -f "$dir/config.ini" ] && [ -f "$dir/g_LOS SIMS 4.ini" ]; then
            UNLOCKER_DLL="$dir/ea_app/version.dll"
            UNLOCKER_INI="$dir/config.ini"
            UNLOCKER_GAME_INI="$dir/g_LOS SIMS 4.ini"
            return 0
        fi
    done
    return 1
}

# --- FUNCIÓN DE CONFIGURACIÓN INICIAL ---
configurar_rutas() {
    clear
    echo -e "\e[36m==========================================\e[0m"
    echo -e "\e[1;33m      Configuración Inicial de Rutas      \e[0m"
    echo -e "\e[36m==========================================\e[0m"
    echo "Buscando bibliotecas de Steam en tu sistema..."

    DETECTED_LIBS=()
    for base_steam in "${STEAM_PATHS[@]}"; do
        vdf="$base_steam/steamapps/libraryfolders.vdf"
        if [ -f "$vdf" ]; then
            while read -r path; do
                if [ -d "$path" ] && [[ ! " ${DETECTED_LIBS[*]} " =~ " ${path} " ]]; then
                    DETECTED_LIBS+=("$path")
                fi
            done < <(grep -i '"path"' "$vdf" | awk -F '"' '{print $4}')
        fi
    done

    AUTODETECTED_SIMS=""
    for lib in "${DETECTED_LIBS[@]}"; do
        if [ -d "$lib/steamapps/common/The Sims 4" ]; then
            AUTODETECTED_SIMS="$lib"
            break
        fi
    done

    if [ ${#DETECTED_LIBS[@]} -gt 0 ]; then
        echo -e "\n\e[1;32m¡Se encontraron estas carpetas de Steam!\e[0m"
        for i in "${!DETECTED_LIBS[@]}"; do
            if [ "${DETECTED_LIBS[$i]}" = "$AUTODETECTED_SIMS" ]; then
                echo -e "$((i+1)). ${DETECTED_LIBS[$i]} \e[1;32m(Los Sims 4 detectado aquí)\e[0m"
            else
                echo "$((i+1)). ${DETECTED_LIBS[$i]}"
            fi
        done
        echo "$(( ${#DETECTED_LIBS[@]} + 1 )). Introducir ruta manualmente"
        
        read -p "Elige una opción (1-$(( ${#DETECTED_LIBS[@]} + 1 ))): " opcion_lib
        
        if [ "$opcion_lib" -ge 1 ] && [ "$opcion_lib" -le "${#DETECTED_LIBS[@]}" ] 2>/dev/null; then
            STEAM_LIBRARY="${DETECTED_LIBS[$((opcion_lib-1))]}"
        fi
    fi

    if [ -z "$STEAM_LIBRARY" ]; then
        echo -e "\n\e[1;34m💡 PRO-TIP:\e[0m Arrastra la carpeta donde instalaste tu Biblioteca de Steam"
        echo "hacia esta ventana de la terminal."
        read -p "Ruta de la biblioteca: " input_lib
        STEAM_LIBRARY="${input_lib//\'/}"
        STEAM_LIBRARY="${STEAM_LIBRARY%"${STEAM_LIBRARY##*[![:space:]]}"}"
    fi

    STEAM_COMPATDATA="$STEAM_LIBRARY"

    echo -e "\n\e[1;32mExcelente.\e[0m Ahora necesitamos la ruta de tus DLCs."
    echo -e "\e[1;34m💡 PRO-TIP:\e[0m Arrastra el archivo (.zip/.rar/.7z) o la CARPETA con tus DLCs hacia esta ventana."
    read -p "> " input_dlc
    
    input_dlc="${input_dlc//\'/}"
    input_dlc="${input_dlc%"${input_dlc##*[![:space:]]}"}"
    DLC_SOURCE="${input_dlc}"

    mkdir -p "$HOME/.config"
    cat <<EOF > "$CONFIG_FILE"
STEAM_LIBRARY="$STEAM_LIBRARY"
STEAM_COMPATDATA="$STEAM_COMPATDATA"
DLC_SOURCE="$DLC_SOURCE"
EOF

    echo -e "\n\e[1;32m¡Configuración guardada con éxito en $CONFIG_FILE!\e[0m"
    sleep 1
}

# --- CARGA DE CONFIGURACIÓN ---
if [ ! -f "$CONFIG_FILE" ]; then
    configurar_rutas
fi

source "$CONFIG_FILE"

SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
PREFIX="$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx"
USER_REG="$PREFIX/user.reg"

# --- FUNCIÓN DE APLICAR OVERRIDE EN USER.REG ---
aplicar_dll_override() {
    local reg_file="$1"
    if [ ! -f "$reg_file" ]; then
        echo -e "\e[33mNo se encontró $reg_file aún. Ejecuta el juego una vez para generar el prefijo.\e[0m"
        return 1
    fi

    if grep -q '"version"="native,builtin"' "$reg_file"; then
        echo -e "\e[32m✔ Override de version.dll ya está registrado en el registro de Wine.\e[0m"
        return 0
    fi

    echo "Añadiendo DllOverride para version.dll en Wine..."
    timestamp=$(date +%s)
    cat <<EOF >> "$reg_file"

[Software\\\\Wine\\\\DllOverrides] $timestamp
"version"="native,builtin"
EOF
    echo -e "\e[32m✔ DllOverride añadido exitosamente a $reg_file\e[0m"
}

# --- FUNCIÓN PARA ORGANIZAR DLCS (Sacar de subcarpetas si existen) ---
arreglar_estructura_dlcs() {
    local sims_path="$1"
    if [ -d "$sims_path/all in one" ]; then
        echo "Detectada carpeta anidada 'all in one'. Moviendo DLCs a la raíz..."
        mv -n "$sims_path/all in one/"* "$sims_path/" 2>/dev/null
        rmdir "$sims_path/all in one" 2>/dev/null || true
    fi

    for sub in "$sims_path/The Sims 4" "$sims_path/Los Sims 4" "$sims_path/DLCs"; do
        if [ -d "$sub" ]; then
            echo "Moviendo archivos desde $sub a la raíz del juego..."
            mv -n "$sub/"* "$sims_path/" 2>/dev/null
            rmdir "$sub" 2>/dev/null || true
        fi
    done
}

# --- MENÚ INTERACTIVO ---
while true; do
    clear
    echo -e "\e[36m====================================================\e[0m"
    echo -e "\e[1;32m    Gestor de Los Sims 4 (Linux Edition) v2.0       \e[0m"
    echo -e "\e[36m====================================================\e[0m"
    echo "1) Instalar / Mover DLCs al juego (ZIP, RAR, Carpeta)"
    echo "2) Reactivar DLCs (Inyección EA App + Wine Override)"
    echo "3) Forzar cierre de procesos colgados (Fix Sims/EA)"
    echo "4) Reconfigurar rutas del script"
    echo "5) Salir"
    echo -e "\e[36m====================================================\e[0m"
    read -p "Elige una opción (1-5): " opcion

    case $opcion in
        1)
            echo -e "\n\e[1;33m[Iniciando instalación / organización de DLCs...]\e[0m"
            mkdir -p "$SIMS_DIR"
            
            if [ -d "$DLC_SOURCE" ]; then
                # Verificar si la carpeta contiene archivos comprimidos (.zip, .rar, .7z)
                mapfile -t ARCHIVOS_COMPRIMIDOS < <(find "$DLC_SOURCE" -maxdepth 1 -type f \( -iname "*.zip" -o -iname "*.rar" -o -iname "*.7z" \) | sort)
                
                if [ ${#ARCHIVOS_COMPRIMIDOS[@]} -gt 0 ]; then
                    echo -e "\e[1;36mSe detectaron ${#ARCHIVOS_COMPRIMIDOS[@]} archivos comprimidos en la carpeta.\e[0m"
                    echo "Descomprimiendo cada paquete en $SIMS_DIR..."
                    
                    for i in "${!ARCHIVOS_COMPRIMIDOS[@]}"; do
                        arch="${ARCHIVOS_COMPRIMIDOS[$i]}"
                        echo -e "[$((i+1))/${#ARCHIVOS_COMPRIMIDOS[@]}] Extrayendo: \e[1;37m$(basename "$arch")\e[0m..."
                        7z x "$arch" -o"$SIMS_DIR" -y > /dev/null
                    done
                fi

                # Copiar también carpetas o archivos no comprimidos que haya en la fuente
                echo "Copiando y organizando carpetas y archivos directos..."
                for item in "$DLC_SOURCE"/*; do
                    [ -e "$item" ] || continue
                    case "$item" in
                        *.zip|*.rar|*.7z|*.ZIP|*.RAR|*.7Z) ;;
                        *) cp -av "$item" "$SIMS_DIR/" 2>/dev/null ;;
                    esac
                done

                arreglar_estructura_dlcs "$SIMS_DIR"
                echo -e "\n\e[1;32m¡Instalación y organización de DLCs completada!\e[0m"
                
            elif [ -f "$DLC_SOURCE" ]; then
                if ! command -v 7z &> /dev/null; then
                    echo -e "\e[31m¡Error! No tienes '7z' instalado en tu sistema.\e[0m"
                    read -p "Presiona Enter para continuar..."
                    continue
                fi
                echo "Modo Archivo único detectado. Descomprimiendo en $SIMS_DIR..."
                7z x "$DLC_SOURCE" -o"$SIMS_DIR" -y
                arreglar_estructura_dlcs "$SIMS_DIR"
                echo -e "\n\e[1;32m¡Extracción y organización terminada!\e[0m"
                
            else
                echo -e "\e[33mAviso: No se encontró archivo o carpeta en '$DLC_SOURCE'.\e[0m"
                echo "Revisando y organizando DLCs ya presentes en la carpeta del juego..."
                arreglar_estructura_dlcs "$SIMS_DIR"
            fi

            COUNT=$(ls -d "$SIMS_DIR"/[EGDFS]* 2>/dev/null | grep -E '/(EP|GP|SP|FP)[0-9]+' | wc -l)
            echo -e "\n\e[1;32mTotal de carpetas de DLCs listas en el juego: $COUNT\e[0m"
            
            read -p "Presiona Enter para continuar..."
            ;;
            
        2)
            echo -e "\n\e[1;34m[Arrancando inyección de DLCs Unlocker...]\e[0m"
            
            if ! localizar_archivos_unlocker; then
                echo -e "\e[31m¡Error! No se encontraron los archivos del Unlocker (version.dll, config.ini, g_LOS SIMS 4.ini).\e[0m"
                read -p "Presiona Enter para continuar..."
                continue
            fi

            echo -e "Usando archivos del Unlocker desde: \e[36m$(dirname "$UNLOCKER_INI")\e[0m"

            if [ ! -d "$PREFIX" ]; then
                echo -e "\e[31m¡Error! No se encontró el prefijo de Proton en: $PREFIX\e[0m"
                echo "Asegúrate de haber iniciado el juego al menos una vez desde Steam."
                read -p "Presiona Enter para continuar..."
                continue
            fi

            echo "Localizando ejecutables de EA Desktop..."
            EA_BASE="$PREFIX/drive_c/Program Files/Electronic Arts/EA Desktop"
            INJECTED_COUNT=0

            if [ -d "$EA_BASE" ]; then
                cp -v "$UNLOCKER_DLL" "$EA_BASE/version.dll" 2>/dev/null && ((INJECTED_COUNT++))
                
                while read -r target_dir; do
                    if [ -d "$target_dir" ]; then
                        echo "Inyectando en: $target_dir"
                        cp -v "$UNLOCKER_DLL" "$target_dir/version.dll"
                        ((INJECTED_COUNT++))
                    fi
                done < <(find "$EA_BASE" -type f \( -iname "EADesktop.exe" -o -iname "EABackgroundService.exe" \) -exec dirname {} \; | sort -u)
            else
                echo -e "\e[33mAviso: No se encontró la carpeta estándar de EA Desktop. Buscando en drive_c...\e[0m"
                while read -r target_dir; do
                    echo "Inyectando en: $target_dir"
                    cp -v "$UNLOCKER_DLL" "$target_dir/version.dll"
                    ((INJECTED_COUNT++))
                done < <(find "$PREFIX/drive_c" -type f \( -iname "EADesktop.exe" -o -iname "EABackgroundService.exe" \) -exec dirname {} \; | sort -u)
            fi

            echo -e "\e[32m✔ version.dll inyectado en $INJECTED_COUNT ubicaciones.\e[0m"

            echo "Copiando configuraciones del Unlocker a AppData..."
            USERS_DIR="$PREFIX/drive_c/users"
            if [ -d "$USERS_DIR" ]; then
                for u in "$USERS_DIR"/*; do
                    if [ -d "$u" ] && [ "$(basename "$u")" != "Public" ]; then
                        TARGET_CONF="$u/AppData/Roaming/anadius/EA DLC Unlocker v2"
                        mkdir -p "$TARGET_CONF"
                        cp -v "$UNLOCKER_INI" "$TARGET_CONF/config.ini"
                        cp -v "$UNLOCKER_GAME_INI" "$TARGET_CONF/g_LOS SIMS 4.ini"
                    fi
                done
            fi

            aplicar_dll_override "$USER_REG"

            echo "Limpiando cachés de EA App..."
            rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Electronic\ Arts/EA\ Desktop 2>/dev/null
            rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/EADesktop 2>/dev/null
            rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Origin 2>/dev/null
            
            echo -e "\n\e[1;32m====================================================\e[0m"
            echo -e "\e[1;32m ¡DLCs Y UNLOCKER ACTIVADOS CON ÉXITO PARA STEAM!   \e[0m"
            echo -e "\e[1;32m====================================================\e[0m"
            echo "Ya puedes iniciar Los Sims 4 desde Steam normalmente."
            read -p "Presiona Enter para continuar..."
            ;;

        3)
            echo -e "\n\e[1;31m[Aniquilando procesos fantasma...]\e[0m"
            pkill -9 -u "$USER" -f "steam-runtime-reaper" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "steam-launch-wrapper" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "EABackgroundService" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "EADesktop.exe" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "TS4_x64.exe" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "Link2EA.exe" > /dev/null 2>&1
            echo -e "\e[1;32m¡Limpieza completada! El botón de Steam debería reaccionar.\e[0m"
            read -p "Presiona Enter para continuar..."
            ;;
            
        4)
            configurar_rutas
            source "$CONFIG_FILE"
            SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
            PREFIX="$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx"
            USER_REG="$PREFIX/user.reg"
            ;;

        5)
            echo "¡Que disfrutes jugando Los Sims 4!"
            exit 0
            ;;
            
        *)
            echo -e "\e[31mOpción no válida.\e[0m"
            sleep 1
            ;;
    esac
done
