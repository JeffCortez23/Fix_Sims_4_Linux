#!/usr/bin/env bash

# ==========================================
#   Gestor de Los Sims 4 (Linux Edition)
# ==========================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$HOME/.config/sims4_gestor.conf"

# --- FUNCIÓN DE CONFIGURACIÓN INICIAL ---
configurar_rutas() {
    clear
    echo -e "\e[36m==========================================\e[0m"
    echo -e "\e[1;33m      Configuración Inicial de Rutas      \e[0m"
    echo -e "\e[36m==========================================\e[0m"
    echo "Buscando bibliotecas de Steam en tu sistema..."
    sleep 1

    VDF_NATIVO="$HOME/.local/share/Steam/steamapps/libraryfolders.vdf"
    VDF_FLATPAK="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf"
    
    DETECTED_LIBS=()
    if [ -f "$VDF_NATIVO" ]; then
        while read -r path; do
            DETECTED_LIBS+=("$path")
        done < <(grep -i '"path"' "$VDF_NATIVO" | awk -F '"' '{print $4}')
    elif [ -f "$VDF_FLATPAK" ]; then
        while read -r path; do
            DETECTED_LIBS+=("$path")
        done < <(grep -i '"path"' "$VDF_FLATPAK" | awk -F '"' '{print $4}')
    fi

    if [ ${#DETECTED_LIBS[@]} -gt 0 ]; then
        echo -e "\n\e[1;32m¡Se encontraron estas carpetas de Steam!\e[0m"
        echo "¿En cuál de ellas está instalado Los Sims 4?"
        for i in "${!DETECTED_LIBS[@]}"; do
            echo "$((i+1)). ${DETECTED_LIBS[$i]}"
        done
        echo "$(( ${#DETECTED_LIBS[@]} + 1 )). No está ahí / Introducir ruta manualmente"
        
        read -p "Elige una opción (1-$(( ${#DETECTED_LIBS[@]} + 1 ))): " opcion_lib
        
        if [ "$opcion_lib" -le "${#DETECTED_LIBS[@]}" ] 2>/dev/null; then
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
    echo -e "\e[1;34m💡 PRO-TIP:\e[0m Arrastra el archivo (.zip/.rar) o la CARPETA con tus DLCs hacia esta ventana."
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
    sleep 2
}

# --- CARGA DE CONFIGURACIÓN ---
if [ ! -f "$CONFIG_FILE" ]; then
    configurar_rutas
fi

source "$CONFIG_FILE"

SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
PREFIX="$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx"
EA_DIR="$PREFIX/drive_c/Program Files/Electronic Arts/EA Desktop"
CONFIG_DIR="$PREFIX/drive_c/users/steamuser/AppData/Roaming/anadius/EA DLC Unlocker v2"
CACHE_DIR="$PREFIX/drive_c/users/steamuser/AppData/Local/Electronic Arts/EA Desktop"

# --- MENÚ INTERACTIVO ---
while true; do
    clear
    echo -e "\e[36m==========================================\e[0m"
    echo -e "\e[1;32m    Gestor de Los Sims 4 (Linux Edition)  \e[0m"
    echo -e "\e[36m==========================================\e[0m"
    echo "1) Instalar DLCs (Desde archivo ZIP/RAR o Carpeta)"
    echo "2) Reactivar DLCs (Inyección EA App)"
    echo "3) Forzar cierre de procesos colgados (Fix Sims)"
    echo "4) Reconfigurar rutas del script"
    echo "5) Salir"
    echo -e "\e[36m==========================================\e[0m"
    read -p "Elige una opción (1-5): " opcion

    case $opcion in
        1)
            echo -e "\n\e[1;33m[Iniciando instalación de DLCs...]\e[0m"
            
            if [ -d "$DLC_SOURCE" ]; then
                echo "Modo Carpeta detectado. Copiando archivos..."
                cp -av "$DLC_SOURCE/"* "$SIMS_DIR/"
                echo -e "\n\e[1;32m¡Archivos copiados con éxito!\e[0m"
                
            elif [ -f "$DLC_SOURCE" ]; then
                if ! command -v 7z &> /dev/null; then
                    echo -e "\e[31m¡Error! No tienes '7z' instalado en tu sistema.\e[0m"
                    read -p "Presiona Enter para continuar..."
                    continue
                fi
                echo "Modo Archivo detectado. Descomprimiendo (Esto tomará tiempo)..."
                7z x "$DLC_SOURCE" -o"$SIMS_DIR" -y
                echo -e "\n\e[1;32m¡Extracción terminada!\e[0m"
                
            else
                echo -e "\e[31m¡Error! No se encontró la ruta o archivo: $DLC_SOURCE\e[0m"
                echo "Ve a la opción 4 para reconfigurar la ruta."
            fi
            
            read -p "Presiona Enter para continuar..."
            ;;
            
        2)
            echo -e "\n\e[1;34m[Arrancando inyección de DLCs Unlocker...]\e[0m"
            if [ ! -f "$SCRIPT_DIR/ea_app/version.dll" ] || [ ! -f "$SCRIPT_DIR/config.ini" ]; then
                echo -e "\e[31m¡Error! Faltan archivos.\e[0m"
                echo "Asegúrate de que este script esté en la misma carpeta que el EA DLC Unlocker."
                read -p "Presiona Enter para continuar..."
                continue
            fi

            echo "Inyectando version.dll en EA Desktop..."
            find "$EA_DIR" -type d -name "EA Desktop" -exec cp -v "$SCRIPT_DIR/ea_app/version.dll" {} \;
            mkdir -p "$CONFIG_DIR"
            cp "$SCRIPT_DIR/config.ini" "$CONFIG_DIR/"
            cp "$SCRIPT_DIR/g_LOS SIMS 4.ini" "$CONFIG_DIR/"
            rm -rf "$CACHE_DIR"
            
            echo -e "\n\e[1;32m¡DLCs activados en la EA App!\e[0m"
            read -p "Presiona Enter para continuar..."
            ;;

        3)
            echo -e "\n\e[1;31m[Aniquilando procesos fantasma...]\e[0m"
            pkill -9 -u "$USER" -f "steam-runtime-reaper" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "steam-launch-wrapper" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "EABackgroundService" > /dev/null 2>&1
            echo -e "\e[1;32m¡Limpieza completada! El botón de Steam debería reaccionar.\e[0m"
            read -p "Presiona Enter para continuar..."
            ;;
            
        4)
            configurar_rutas
            source "$CONFIG_FILE"
            SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
            PREFIX="$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx"
            EA_DIR="$PREFIX/drive_c/Program Files/Electronic Arts/EA Desktop"
            CONFIG_DIR="$PREFIX/drive_c/users/steamuser/AppData/Roaming/anadius/EA DLC Unlocker v2"
            CACHE_DIR="$PREFIX/drive_c/users/steamuser/AppData/Local/Electronic Arts/EA Desktop"
            ;;

        5)
            echo "Saliendo..."
            exit 0
            ;;
            
        *)
            echo -e "\e[31mOpción no válida.\e[0m"
            sleep 1
            ;;
    esac
done
