#!/usr/bin/env bash

# ==============================================================================
#   💎 Fix Sims 4 Linux (Edición Comunitaria) v2.1
#   Soporta Steam, Steam Deck, Lutris, Bottles, Heroic & Wine
#   Compatible con nuevas versiones de EA App
#   Desarrollado por Jeff Cortez (github.com/JeffCortez23)
# ==============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$HOME/.config/sims4_gestor.conf"
UNLOCKER_STORE="$HOME/.local/share/sims4_unlocker"
ICON_PATH="$HOME/.local/share/icons/fix-sims-4.svg"
VERSION="2.1"

# --- UTILIDADES DE CENTRADO Y ESTILO TUI ---
WIDTH=64

obtener_padding() {
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    [ "$cols" -lt "$WIDTH" ] && cols="$WIDTH"
    local pad=$(( (cols - WIDTH) / 2 ))
    printf '%*s' "$pad" ''
}

# Lista de ubicaciones comunes de Steam
STEAM_PATHS=(
    "$HOME/.local/share/Steam"
    "$HOME/.steam/steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
    "$HOME/snap/steam/common/.local/share/Steam"
)

# Lista de rutas de Lutris, Bottles y Heroic
LUTRIS_PATHS=(
    "$HOME/Games"
    "$HOME/.local/share/lutris/runners/wine"
)

BOTTLES_PATHS=(
    "$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles"
    "$HOME/.local/share/bottles/bottles"
)

HEROIC_PATHS=(
    "$HOME/Games/Heroic/Prefixes"
    "$HOME/.var/app/com.heroicgameslauncher.hgl/data/heroic/prefixes"
)

# --- BASE DE DATOS OFICIAL DE DLCS (LOS SIMS 4) ---
obtener_nombre_dlc() {
    local code="$1"
    case "$code" in
        # Packs de Expansión (EP)
        EP01) echo "¡A Trabajar!" ;;
        EP02) echo "¿Quedamos?" ;;
        EP03) echo "Urbanitas" ;;
        EP04) echo "Perros y Gatos" ;;
        EP05) echo "Las 4 Estaciones" ;;
        EP06) echo "¡Rumbo a la Fama!" ;;
        EP07) echo "Vida Isleña" ;;
        EP08) echo "Días de Universidad" ;;
        EP09) echo "Vida Ecológica" ;;
        EP10) echo "Escapada en la Nieve" ;;
        EP11) echo "Vida en el Pueblo" ;;
        EP12) echo "Años High School" ;;
        EP13) echo "Creciendo en Familia" ;;
        EP14) echo "Rancho de Caballos" ;;
        EP15) echo "Se Alquila" ;;
        EP16) echo "¡Viva el Amor!" ;;
        EP17) echo "Vida y Más Allá" ;;
        EP18) echo "Ocio y Negocio" ;;
        EP19) echo "Naturaleza Encantada" ;;
        EP20) echo "¡A la Aventura!" ;;
        EP21) echo "Dinastías y Linajes" ;;
        
        # Packs de Contenido (GP)
        GP01) echo "De Acampada" ;;
        GP02) echo "Día de Spa" ;;
        GP03) echo "Escapada Gourmet" ;;
        GP04) echo "Vampiros" ;;
        GP05) echo "Papás y Mamás" ;;
        GP06) echo "Aventura en la Selva" ;;
        GP07) echo "StrangerVille" ;;
        GP08) echo "El Reino de la Magia" ;;
        GP09) echo "Star Wars: Viaje a Batuu" ;;
        GP10) echo "Interiorismo" ;;
        GP11) echo "¡Sí, Quiero!" ;;
        GP12) echo "Licántropos" ;;
        
        # Packs de Accesorios (SP)
        SP01) echo "Fiesta Glamurosa" ;;
        SP02) echo "Patio de Ensueño" ;;
        SP03) echo "Cocina Divina" ;;
        SP04) echo "Escalofriante" ;;
        SP05) echo "Noche de Cine" ;;
        SP06) echo "Jardín Romántico" ;;
        SP07) echo "Cuarto de Niños" ;;
        SP08) echo "Diversión en el Patio" ;;
        SP09) echo "Glamour Vintage" ;;
        SP10) echo "Noche de Bolos" ;;
        SP11) echo "Fitness" ;;
        SP12) echo "Infantes" ;;
        SP13) echo "Día de Colada" ;;
        SP14) echo "Mi Primera Mascota" ;;
        SP15) echo "Moschino" ;;
        SP16) echo "Minicasas" ;;
        SP17) echo "Portentos del Punto" ;;
        SP18) echo "Fenómenos Paranormales" ;;
        SP46) echo "Chef de Casa" ;;
        SP49) echo "Creaciones Cristalinas" ;;

        # Kits (SP) & Festivos (FP)
        FP01) echo "Felices Fiestas" ;;
        SP20) echo "Moda Retro" ;;
        SP21) echo "Cocina Campestre" ;;
        SP22) echo "Zafarrancho de Limpieza" ;;
        SP23) echo "Oasis en el Patio" ;;
        SP24) echo "Fashion Street" ;;
        SP25) echo "Loft Industrial" ;;
        SP26) echo "Moda de Aeropuerto" ;;
        SP28) echo "Moda Masculina Moderna" ;;
        SP29) echo "Decoración Vegetal" ;;
        SP30) echo "Colores de Carnaval" ;;
        SP31) echo "Decoración Maximalista" ;;
        SP32) echo "Noches Chic" ;;
        SP33) echo "Minicampistas" ;;
        SP34) echo "Moda Mini" ;;
        SP35) echo "Oasis de Lujo" ;;
        SP36) echo "Pastel Pop" ;;
        SP37) echo "Desorden Decorativo" ;;
        SP38) echo "Moda Íntima" ;;
        SP39) echo "Objetos para el Baño" ;;
        SP40) echo "Invernadero Idílico" ;;
        SP41) echo "Tesoros del Sótano" ;;
        SP42) echo "Vuelta al Grunge" ;;
        SP43) echo "Rincón de Lectura" ;;
        SP44) echo "¡Al Agua, Patos!" ;;
        SP45) echo "Lujo Moderno" ;;
        SP47) echo "Castillo con Clase" ;;
        SP48) echo "Gusto Gótico" ;;
        SP50) echo "Homenaje Urbano" ;;
        SP51) echo "Decoración Festiva" ;;
        SP52) echo "Retiro en la Riviera" ;;
        SP53) echo "Bistró Acogedor" ;;
        SP54) echo "Estudio de Arte" ;;
        SP55) echo "Cuarto de Cuentos" ;;
        SP56) echo "Fiesta de Pijamas" ;;
        SP57) echo "Caprichos Kitsch" ;;
        SP58) echo "Rincón Gamer" ;;
        SP59) echo "Santuario Secreto" ;;
        SP60) echo "Cuarto de Casanova" ;;
        SP61) echo "Salón Sofisticado" ;;
        SP62) echo "Elegancia Ejecutiva" ;;
        SP63) echo "Baño Elegante" ;;
        SP64) echo "Estilo Encantador" ;;
        SP65) echo "Taller de Restauración" ;;
        SP66) echo "Años Dorados" ;;
        SP67) echo "Menaje de Cocina" ;;
        SP68) echo "Casa de Bob Esponja" ;;
        SP69) echo "Moda de Otoño" ;;
        SP70) echo "Cuarto Infantil de Bob Esponja" ;;
        SP71) echo "Recibidor Rural" ;;
        SP72) echo "Maquillaje con Glamour" ;;
        SP73) echo "Retiro Moderno" ;;
        SP74) echo "De la Huerta a la Mesa" ;;
        SP75) echo "Cuarto de las Maravillas" ;;
        SP76) echo "Estilo de Cine Clásico" ;;
        SP77) echo "Hora del Té" ;;
        SP78) echo "Salón de Baile de Máscaras de LB" ;;
        SP79) echo "Galas de Baile de Máscaras de LB" ;;
        SP80) echo "Sala de Música" ;;
        SP81) echo "Sueños Silvestres" ;;
        SP82) echo "El Patio de mi Casa" ;;
        
        *) echo "Pack / Kit ($code)" ;;
    esac
}

# Listas maestras de códigos oficiales
LISTA_EP=(EP01 EP02 EP03 EP04 EP05 EP06 EP07 EP08 EP09 EP10 EP11 EP12 EP13 EP14 EP15 EP16 EP17 EP18 EP19 EP20 EP21)
LISTA_GP=(GP01 GP02 GP03 GP04 GP05 GP06 GP07 GP08 GP09 GP10 GP11 GP12)
LISTA_SP_ACC=(SP01 SP02 SP03 SP04 SP05 SP06 SP07 SP08 SP09 SP10 SP11 SP12 SP13 SP14 SP15 SP16 SP17 SP18 SP46 SP49)
LISTA_KITS=(
    FP01 SP20 SP21 SP22 SP23 SP24 SP25 SP26 SP28 SP29 SP30 SP31 SP32 SP33 SP34 SP35 SP36 SP37 SP38
    SP39 SP40 SP41 SP42 SP43 SP44 SP45 SP47 SP48 SP50 SP51 SP52 SP53 SP54 SP55 SP56 SP57 SP58
    SP59 SP60 SP61 SP62 SP63 SP64 SP65 SP66 SP67 SP68 SP69 SP70 SP71 SP72 SP73 SP74 SP75 SP76
    SP77 SP78 SP79 SP80 SP81 SP82
)

# --- AUTO-DESCARGADOR DE UNLOCKER (CON HEADERS Y VERIFICACIÓN SHA-256) ---
descargar_unlocker_auto() {
    clear
    local P
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m          \e[1;32m🌐 DESCARGA AUTOMÁTICA DEL EA DLC UNLOCKER\e[0m          \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m\n"
    echo -e "${P}Conectando con el servidor oficial (Tiesas Archives / Anadius)..."
    mkdir -p "$UNLOCKER_STORE/ea_app"
    
    PAD_LEN=${#P} python3 -c '
import urllib.request, json, ssl, hashlib, os, sys, uuid
from pathlib import Path

pad = " " * int(os.environ.get("PAD_LEN", "0"))
store = Path(os.path.expanduser("~/.local/share/sims4_unlocker"))
manifest_url = "https://access.tiesasarchives.uk/api/unlocker/manifest?channel=stable&platform=linux&architecture=x64"
device_id = str(uuid.uuid4())
headers = {
    "X-Web-Jardinera-Device-Id": device_id,
    "X-Web-Jardinera-Bootstrap-Version": "1.0.1",
    "User-Agent": "WebJardineraSecureBootstrap/1.0.1"
}

try:
    ctx = ssl.create_default_context()
    req = urllib.request.Request(manifest_url, headers=headers)
    with urllib.request.urlopen(req, context=ctx, timeout=15) as resp:
        data = json.load(resp)
    
    version = data.get("version", "3.4.0")
    print(f"{pad}  ✔ Publicación oficial encontrada: v{version}")
    
    for art in data.get("artifacts", []):
        rel_path = art["path"]
        dest = store / rel_path
        dest.parent.mkdir(parents=True, exist_ok=True)
        print(f"{pad}  ⬇ Descargando: {rel_path}...")
        
        art_req = urllib.request.Request(art["downloadUrl"], headers=headers)
        with urllib.request.urlopen(art_req, context=ctx, timeout=30) as d_resp:
            content = d_resp.read()
        
        if hashlib.sha256(content).hexdigest().lower() != art["sha256"].lower():
            raise ValueError(f"Error de integridad en {rel_path}")
        
        dest.write_bytes(content)
        
    print(f"\n{pad}  \033[1;32m✔ ¡Archivos del Unlocker descargados y verificados con éxito!\033[0m")
except Exception as e:
    print(f"\n{pad}  \033[1;31m❌ Error al descargar automáticamente: {e}\033[0m")
    sys.exit(1)
'

    if [ $? -eq 0 ]; then
        echo -e "\n${P}\e[1;32mArchivos guardados en:\e[0m $UNLOCKER_STORE"
        UNLOCKER_DLL="$UNLOCKER_STORE/ea_app/version.dll"
        UNLOCKER_INI="$UNLOCKER_STORE/config.ini"
        UNLOCKER_GAME_INI="$UNLOCKER_STORE/g_LOS SIMS 4.ini"
    else
        echo -e "\n${P}\e[33mSi prefieres descargarlo de Telegram: https://t.me/c/3910223807/11\e[0m"
    fi
    echo -ne "\n${P}Presiona Enter para continuar..."
    read -r
}

# --- BÚSQUEDA INTELIGENTE Y FLEXIBLE DE ARCHIVOS DEL UNLOCKER ---
localizar_archivos_unlocker() {
    UNLOCKER_DLL=""
    UNLOCKER_INI=""
    UNLOCKER_GAME_INI=""

    # 1. Comprobar si hay una ruta personalizada guardada en la configuración
    if [ -n "$UNLOCKER_SOURCE" ] && [ -d "$UNLOCKER_SOURCE" ]; then
        if [ -f "$UNLOCKER_SOURCE/ea_app/version.dll" ]; then
            UNLOCKER_DLL="$UNLOCKER_SOURCE/ea_app/version.dll"
        elif [ -f "$UNLOCKER_SOURCE/version.dll" ]; then
            UNLOCKER_DLL="$UNLOCKER_SOURCE/version.dll"
        fi
        [ -f "$UNLOCKER_SOURCE/config.ini" ] && UNLOCKER_INI="$UNLOCKER_SOURCE/config.ini"
        [ -f "$UNLOCKER_SOURCE/g_LOS SIMS 4.ini" ] && UNLOCKER_GAME_INI="$UNLOCKER_SOURCE/g_LOS SIMS 4.ini"
        
        if [ -n "$UNLOCKER_DLL" ] && [ -n "$UNLOCKER_INI" ] && [ -n "$UNLOCKER_GAME_INI" ]; then
            return 0
        fi
    fi

    # 2. Rutas candidatas automáticas (carpeta del script, subcarpetas, descargas, escritorio, almacén)
    CANDIDATOS=(
        "$SCRIPT_DIR"
        "$SCRIPT_DIR/EA DLC Unlocker v3.4"
        "$SCRIPT_DIR/EA DLC Unlocker v3.3"
        "$UNLOCKER_STORE"
        "$HOME/Downloads/jardinera_extracted"
        "$HOME/Downloads/EA Abono WIN 3.3/EA DLC Unlocker v3.3"
        "$HOME/Downloads/Web Jardinera Unlocker - Linux"
        "$HOME/Downloads"
        "$HOME/Desktop"
        "$HOME/Escritorio"
    )

    for dir in "${CANDIDATOS[@]}"; do
        [ -d "$dir" ] || continue
        local dll=""
        local ini=""
        local game_ini=""
        
        if [ -f "$dir/ea_app/version.dll" ]; then
            dll="$dir/ea_app/version.dll"
        elif [ -f "$dir/version.dll" ]; then
            dll="$dir/version.dll"
        fi
        [ -f "$dir/config.ini" ] && ini="$dir/config.ini"
        [ -f "$dir/g_LOS SIMS 4.ini" ] && game_ini="$dir/g_LOS SIMS 4.ini"

        if [ -n "$dll" ] && [ -n "$ini" ] && [ -n "$game_ini" ]; then
            UNLOCKER_DLL="$dll"
            UNLOCKER_INI="$ini"
            UNLOCKER_GAME_INI="$game_ini"
            return 0
        fi
    done

    # 3. Si no se encontró en ninguna parte, solicitar ruta o descargar automáticamente
    local P
    P=$(obtener_padding)
    echo -e "\n${P}\e[1;33m[Aviso: No se encontraron los archivos del Unlocker en rutas estándar]\e[0m"
    echo -e "${P}\e[1;34m💡 PRO-TIP:\e[0m Arrastra aquí la carpeta donde guardas tu Unlocker"
    echo -e "${P}(desde tu disco, pendrive, carpeta Descargas, etc.)"
    echo -e "${P}o presiona \e[1;32m[Enter]\e[0m para descargarlos automáticamente ahora mismo."
    echo -ne "${P}\e[1;37mRuta del Unlocker:\e[0m "
    read -r custom_unlocker

    custom_unlocker="${custom_unlocker//\'/}"
    custom_unlocker="${custom_unlocker%"${custom_unlocker##*[![:space:]]}"}"

    if [ -n "$custom_unlocker" ] && [ -d "$custom_unlocker" ]; then
        if [ -f "$custom_unlocker/ea_app/version.dll" ]; then
            UNLOCKER_DLL="$custom_unlocker/ea_app/version.dll"
        elif [ -f "$custom_unlocker/version.dll" ]; then
            UNLOCKER_DLL="$custom_unlocker/version.dll"
        fi
        [ -f "$custom_unlocker/config.ini" ] && UNLOCKER_INI="$custom_unlocker/config.ini"
        [ -f "$custom_unlocker/g_LOS SIMS 4.ini" ] && UNLOCKER_GAME_INI="$custom_unlocker/g_LOS SIMS 4.ini"

        if [ -n "$UNLOCKER_DLL" ] && [ -n "$UNLOCKER_INI" ] && [ -n "$UNLOCKER_GAME_INI" ]; then
            UNLOCKER_SOURCE="$custom_unlocker"
            sed -i '/UNLOCKER_SOURCE=/d' "$CONFIG_FILE" 2>/dev/null
            echo "UNLOCKER_SOURCE=\"$UNLOCKER_SOURCE\"" >> "$CONFIG_FILE"
            return 0
        else
            echo -e "\n${P}\e[31m❌ Esa carpeta no contiene los 3 archivos necesarios (version.dll, config.ini, g_LOS SIMS 4.ini).\e[0m"
        fi
    fi

    # Si presionó Enter o no fue válida, descargar automáticamente
    descargar_unlocker_auto
    if [ -f "$UNLOCKER_STORE/ea_app/version.dll" ] && [ -f "$UNLOCKER_STORE/config.ini" ]; then
        UNLOCKER_DLL="$UNLOCKER_STORE/ea_app/version.dll"
        UNLOCKER_INI="$UNLOCKER_STORE/config.ini"
        UNLOCKER_GAME_INI="$UNLOCKER_STORE/g_LOS SIMS 4.ini"
        return 0
    fi

    return 1
}

# --- BUSCADOR DE PREFIJOS MULTI-LANZADOR ---
detectar_entornos() {
    DETECTED_ENTORNOS_NOMBRES=()
    DETECTED_ENTORNOS_LIBS=()
    DETECTED_ENTORNOS_PFX=()

    # 1. Steam (Nativo, Flatpak, Snap, SD Cards)
    for base_steam in "${STEAM_PATHS[@]}"; do
        vdf="$base_steam/steamapps/libraryfolders.vdf"
        if [ -f "$vdf" ]; then
            while read -r path; do
                if [ -d "$path" ]; then
                    pfx="$path/steamapps/compatdata/1222670/pfx"
                    if [ ! -d "$pfx" ] && [ -d "$base_steam/steamapps/compatdata/1222670/pfx" ]; then
                        pfx="$base_steam/steamapps/compatdata/1222670/pfx"
                    fi
                    
                    nombre="Steam ($path)"
                    if [ -d "$path/steamapps/common/The Sims 4" ]; then
                        nombre="Steam (Los Sims 4 detectado)"
                    fi
                    
                    if [[ ! " ${DETECTED_ENTORNOS_LIBS[*]} " =~ " ${path} " ]]; then
                        DETECTED_ENTORNOS_NOMBRES+=("$nombre")
                        DETECTED_ENTORNOS_LIBS+=("$path")
                        DETECTED_ENTORNOS_PFX+=("$pfx")
                    fi
                fi
            done < <(grep -i '"path"' "$vdf" | awk -F '"' '{print $4}')
        fi
    done

    # 2. Lutris
    for l_base in "${LUTRIS_PATHS[@]}"; do
        if [ -d "$l_base" ]; then
            for p in "$l_base"/*sims* "$l_base"/*Sims*; do
                if [ -d "$p" ]; then
                    bname="$(basename "$p")"
                    DETECTED_ENTORNOS_NOMBRES+=("Lutris ($bname)")
                    DETECTED_ENTORNOS_LIBS+=("$p/drive_c/Program Files/EA Games/The Sims 4")
                    DETECTED_ENTORNOS_PFX+=("$p")
                fi
            done
        fi
    done

    # 3. Bottles
    for b_base in "${BOTTLES_PATHS[@]}"; do
        if [ -d "$b_base" ]; then
            for p in "$b_base"/*; do
                if [ -d "$p" ]; then
                    bname="$(basename "$p")"
                    DETECTED_ENTORNOS_NOMBRES+=("Bottles ($bname)")
                    DETECTED_ENTORNOS_LIBS+=("$p/drive_c/Program Files/EA Games/The Sims 4")
                    DETECTED_ENTORNOS_PFX+=("$p")
                fi
            done
        fi
    done

    # 4. Heroic
    for h_base in "${HEROIC_PATHS[@]}"; do
        if [ -d "$h_base" ]; then
            for p in "$h_base"/*; do
                if [ -d "$p" ]; then
                    bname="$(basename "$p")"
                    DETECTED_ENTORNOS_NOMBRES+=("Heroic Games ($bname)")
                    DETECTED_ENTORNOS_LIBS+=("$p/drive_c/Program Files/EA Games/The Sims 4")
                    DETECTED_ENTORNOS_PFX+=("$p")
                fi
            done
        fi
    done
}

# --- CONFIGURACIÓN INICIAL ---
configurar_rutas() {
    clear
    local P
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m            \e[1;33m⚙️  CONFIGURACIÓN DE RUTAS / LANZADOR\e[0m              \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m\n"
    echo -e "${P}Buscando instalaciones de Steam, Lutris, Bottles y Heroic..."
    detectar_entornos

    if [ ${#DETECTED_ENTORNOS_NOMBRES[@]} -gt 0 ]; then
        echo -e "\n${P}\e[1;32m¡Instalaciones detectadas en tu sistema!\e[0m"
        for i in "${!DETECTED_ENTORNOS_NOMBRES[@]}"; do
            echo -e "${P}  \e[1;33m$((i+1))\e[0m) ${DETECTED_ENTORNOS_NOMBRES[$i]}"
        done
        echo -e "${P}  \e[1;33m$(( ${#DETECTED_ENTORNOS_NOMBRES[@]} + 1 ))\e[0m) Introducir rutas manualmente"
        
        echo -ne "\n${P}\e[1;37mElige una opción (1-$(( ${#DETECTED_ENTORNOS_NOMBRES[@]} + 1 ))):\e[0m "
        read -r opcion_env
        
        if [ "$opcion_env" -ge 1 ] && [ "$opcion_env" -le "${#DETECTED_ENTORNOS_NOMBRES[@]}" ] 2>/dev/null; then
            STEAM_LIBRARY="${DETECTED_ENTORNOS_LIBS[$((opcion_env-1))]}"
            STEAM_COMPATDATA="${DETECTED_ENTORNOS_PFX[$((opcion_env-1))]}"
        fi
    fi

    if [ -z "$STEAM_LIBRARY" ]; then
        echo -e "\n${P}\e[1;34m💡 PRO-TIP:\e[0m Arrastra la carpeta donde instalaste tu Biblioteca / Juego"
        echo -ne "${P}Ruta de la biblioteca: "
        read -r input_lib
        STEAM_LIBRARY="${input_lib//\'/}"
        STEAM_LIBRARY="${STEAM_LIBRARY%"${STEAM_LIBRARY##*[![:space:]]}"}"
    fi

    if [ -z "$STEAM_COMPATDATA" ]; then
        STEAM_COMPATDATA="$STEAM_LIBRARY"
    fi

    echo -e "\n${P}\e[1;32mExcelente.\e[0m Ahora necesitamos la ruta donde guardas tus DLCs."
    echo -e "${P}\e[1;34m💡 PRO-TIP:\e[0m Arrastra la carpeta o archivo (.zip/.rar/.7z) de tus DLCs."
    echo -ne "${P}> "
    read -r input_dlc
    
    input_dlc="${input_dlc//\'/}"
    input_dlc="${input_dlc%"${input_dlc##*[![:space:]]}"}"
    DLC_SOURCE="${input_dlc}"

    echo -e "\n${P}\e[1;32mOpcional:\e[0m ¿Dónde tienes los archivos del EA DLC Unlocker?"
    echo -e "${P}\e[1;34m💡 PRO-TIP:\e[0m Arrastra tu carpeta de Unlocker o presiona \e[1;32m[Enter]\e[0m para auto-detectar/descargar."
    echo -ne "${P}> "
    read -r input_unlocker
    input_unlocker="${input_unlocker//\'/}"
    input_unlocker="${input_unlocker%"${input_unlocker##*[![:space:]]}"}"
    UNLOCKER_SOURCE="${input_unlocker}"

    mkdir -p "$HOME/.config"
    cat <<EOF > "$CONFIG_FILE"
STEAM_LIBRARY="$STEAM_LIBRARY"
STEAM_COMPATDATA="$STEAM_COMPATDATA"
DLC_SOURCE="$DLC_SOURCE"
UNLOCKER_SOURCE="$UNLOCKER_SOURCE"
EOF

    echo -e "\n${P}\e[1;32m✔ ¡Configuración guardada con éxito en $CONFIG_FILE!\e[0m"
    sleep 1
}

# --- CARGA DE CONFIGURACIÓN ---
if [ ! -f "$CONFIG_FILE" ]; then
    configurar_rutas
fi

source "$CONFIG_FILE"

# Resolver rutas según el lanzador
if [ -d "$STEAM_LIBRARY/steamapps/common/The Sims 4" ]; then
    SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
elif [ -d "$STEAM_LIBRARY" ] && [[ "$STEAM_LIBRARY" =~ (The Sims 4|Los Sims 4) ]]; then
    SIMS_DIR="$STEAM_LIBRARY"
else
    SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
fi

if [ -d "$STEAM_COMPATDATA/pfx" ]; then
    PREFIX="$STEAM_COMPATDATA/pfx"
elif [ -d "$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx" ]; then
    PREFIX="$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx"
else
    PREFIX="$STEAM_COMPATDATA"
fi

USER_REG="$PREFIX/user.reg"

# --- APLICAR OVERRIDE EN USER.REG ---
aplicar_dll_override() {
    local reg_file="$1"
    local P
    P=$(obtener_padding)
    if [ ! -f "$reg_file" ]; then
        echo -e "${P}\e[33mNo se encontró $reg_file aún. Ejecuta el juego una vez para generar el prefijo.\e[0m"
        return 1
    fi

    if grep -q '"version"="native,builtin"' "$reg_file"; then
        echo -e "${P}  \e[1;32m✔\e[0m Wine DllOverrides ya registrado (\x27version\x27=\x27native,builtin\x27)"
        return 0
    fi

    echo -e "${P}  Añadiendo DllOverride para version.dll en Wine..."
    timestamp=$(date +%s)
    cat <<EOF >> "$reg_file"

[Software\\\\Wine\\\\DllOverrides] $timestamp
"version"="native,builtin"
EOF
    echo -e "${P}  \e[1;32m✔\e[0m DllOverride añadido exitosamente a user.reg"
}

# --- ORGANIZAR DLCS (Aplanador) ---
arreglar_estructura_dlcs() {
    local sims_path="$1"
    local P
    P=$(obtener_padding)
    if [ -d "$sims_path/all in one" ]; then
        echo -e "${P}Detectada carpeta anidada 'all in one'. Moviendo DLCs a la raíz..."
        mv -n "$sims_path/all in one/"* "$sims_path/" 2>/dev/null
        rmdir "$sims_path/all in one" 2>/dev/null || true
    fi

    for sub in "$sims_path/The Sims 4" "$sims_path/Los Sims 4" "$sims_path/DLCs"; do
        if [ -d "$sub" ]; then
            echo -e "${P}Moviendo archivos desde $sub a la raíz del juego..."
            mv -n "$sub/"* "$sims_path/" 2>/dev/null
            rmdir "$sub" 2>/dev/null || true
        fi
    done
}

# --- INSPECTOR Y DIAGNÓSTICO DE DLCS ---
diagnosticar_dlcs() {
    clear
    local P
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m        \e[1;33m🔍 GUÍA DE CÓDIGOS & DIAGNÓSTICO DE DLCS (TS4)\e[0m        \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m\n"
    echo -e "${P}  \e[1;37m• Juego:\e[0m   \e[36m$SIMS_DIR\e[0m"
    echo -e "${P}  \e[1;37m• Prefijo:\e[0m \e[36m$PREFIX\e[0m\n"

    # 1. Chequeo del Unlocker en EA App & Wine
    echo -e "${P}\e[1;34m[Estado de Activación e Inyección EA App]\e[0m"
    local dll_count
    dll_count=$(find "$PREFIX/drive_c" -type f -name "version.dll" 2>/dev/null | grep -i "Electronic Arts" | wc -l)
    if [ "$dll_count" -gt 0 ]; then
        echo -e "${P}  • Inyección version.dll:     \e[1;32m[✔ INYECTADO] ($dll_count ubicaciones)\e[0m"
    else
        echo -e "${P}  • Inyección version.dll:     \e[1;31m[❌ NO DETECTADO]\e[0m"
    fi

    if [ -f "$USER_REG" ] && grep -q '"version"="native,builtin"' "$USER_REG"; then
        echo -e "${P}  • Wine DllOverrides:         \e[1;32m[✔ ACTIVO ('version'='native,builtin')]\e[0m"
    else
        echo -e "${P}  • Wine DllOverrides:         \e[1;31m[❌ FALTA CONFIGURAR]\e[0m"
    fi

    local conf_count
    conf_count=$(find "$PREFIX/drive_c/users" -type f -name "g_LOS SIMS 4.ini" 2>/dev/null | wc -l)
    if [ "$conf_count" -gt 0 ]; then
        echo -e "${P}  • Configuración AppData:     \e[1;32m[✔ INSTALADA]\e[0m"
    else
        echo -e "${P}  • Configuración AppData:     \e[1;31m[❌ FALTA CONFIG.INI]\e[0m"
    fi

    local total_instalados=0
    local total_faltantes=0

    # 2. Packs de Expansión (EP)
    echo -e "\n${P}\e[1;33m--- 📦 Packs de Expansión (EP) [Total: ${#LISTA_EP[@]}] ---\e[0m"
    for code in "${LISTA_EP[@]}"; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "${P}  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "${P}  \e[1;31m[❌ NO INSTALADO]\e[0m \e[2;37m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    # 3. Packs de Contenido (GP)
    echo -e "\n${P}\e[1;33m--- 🔮 Packs de Contenido (GP) [Total: ${#LISTA_GP[@]}] ---\e[0m"
    for code in "${LISTA_GP[@]}"; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "${P}  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "${P}  \e[1;31m[❌ NO INSTALADO]\e[0m \e[2;37m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    # 4. Packs de Accesorios (SP)
    echo -e "\n${P}\e[1;33m--- 🛋️ Packs de Accesorios (SP) [Total: ${#LISTA_SP_ACC[@]}] ---\e[0m"
    for code in "${LISTA_SP_ACC[@]}"; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "${P}  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "${P}  \e[1;31m[❌ NO INSTALADO]\e[0m \e[2;37m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    # 5. Kits & Festivos
    echo -e "\n${P}\e[1;33m--- 🎨 Lista Completa de Kits (SP) & Festivos [Total: ${#LISTA_KITS[@]}] ---\e[0m"
    for code in "${LISTA_KITS[@]}"; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "${P}  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "${P}  \e[1;31m[❌ NO INSTALADO]\e[0m \e[2;37m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    local total_general=$(( ${#LISTA_EP[@]} + ${#LISTA_GP[@]} + ${#LISTA_SP_ACC[@]} + ${#LISTA_KITS[@]} ))

    echo -e "\n${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
    echo -e "${P}\e[1;32m📊 RESUMEN GENERAL DE DLCS:\e[0m"
    echo -e "${P}  • Total en Guía Oficial:  \e[1;37m$total_general packs\e[0m"
    echo -e "${P}  • Instalados en tu disco: \e[1;32m$total_instalados packs\e[0m"
    echo -e "${P}  • Faltantes por instalar: \e[1;31m$total_faltantes packs\e[0m"
    echo -e "${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
    echo -ne "\n${P}Presiona Enter para volver al menú..."
    read -r
}

# --- LIMPIADOR DE CACHÉ DEL JUEGO ---
limpiar_cache_juego() {
    clear
    local P
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m          \e[1;33m🧹 LIMPIADOR DE CACHÉ DEL JUEGO (LOS SIMS 4)\e[0m        \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m\n"
    echo -e "${P}Buscando carpetas de datos de usuario..."

    CANDIDATOS_DOCS=(
        "$PREFIX/drive_c/users/steamuser/Documents/Electronic Arts/The Sims 4"
        "$PREFIX/drive_c/users/$USER/Documents/Electronic Arts/The Sims 4"
        "$HOME/Documents/Electronic Arts/The Sims 4"
        "$HOME/.local/share/Steam/steamapps/compatdata/1222670/pfx/drive_c/users/steamuser/Documents/Electronic Arts/The Sims 4"
    )

    FOUND_DOCS=()
    for doc in "${CANDIDATOS_DOCS[@]}"; do
        if [ -d "$doc" ] && [[ ! " ${FOUND_DOCS[*]} " =~ " ${doc} " ]]; then
            FOUND_DOCS+=("$doc")
        fi
    done

    if [ ${#FOUND_DOCS[@]} -eq 0 ]; then
        echo -e "\n${P}\e[31mNo se encontró la carpeta de usuario de Los Sims 4.\e[0m"
        echo -e "${P}Asegúrate de haber abierto el juego al menos una vez."
        echo -ne "\n${P}Presiona Enter para continuar..."
        read -r
        return
    fi

    for ts4_user in "${FOUND_DOCS[@]}"; do
        echo -e "\n${P}Limpiando carpeta: \e[36m$ts4_user\e[0m"
        
        rm -f "$ts4_user/localthumbcache.package" 2>/dev/null && echo -e "${P}  ✔ localthumbcache.package eliminado"
        rm -f "$ts4_user/avatarcache.package" 2>/dev/null && echo -e "${P}  ✔ avatarcache.package eliminado"
        rm -f "$ts4_user/clientDB.package" 2>/dev/null && echo -e "${P}  ✔ clientDB.package eliminado"
        rm -rf "$ts4_user/cache"/* 2>/dev/null && echo -e "${P}  ✔ Contenido de /cache/ purgado"
        rm -rf "$ts4_user/cachestr"/* 2>/dev/null && echo -e "${P}  ✔ Contenido de /cachestr/ purgado"
        rm -rf "$ts4_user/onlinerequestcache"/* 2>/dev/null && echo -e "${P}  ✔ Contenido de /onlinerequestcache/ purgado"
        rm -rf "$ts4_user/lotcachedData"/* 2>/dev/null && echo -e "${P}  ✔ Contenido de /lotcachedData/ purgado"
    done

    rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Electronic\ Arts/EA\ Desktop 2>/dev/null
    rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/EADesktop 2>/dev/null
    rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Origin 2>/dev/null

    echo -e "\n${P}\e[1;32m✔ ¡Caché limpiada con éxito! Esto previene cargas infinitas y errores.\e[0m"
    echo -ne "\n${P}Presiona Enter para continuar..."
    read -r
}

# --- CREADOR DE ACCESO DIRECTO (.DESKTOP) ---
crear_acceso_directo() {
    clear
    local P
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m         \e[1;32m🖥️  CREADOR DE ACCESO DIRECTO DE ESCRITORIO\e[0m          \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m\n"
    
    mkdir -p "$HOME/.local/share/icons"
    cat <<EOF_SVG > "$ICON_PATH"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="plumbobTop" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4ade80"/>
      <stop offset="100%" stop-color="#22c55e"/>
    </linearGradient>
    <linearGradient id="plumbobBottom" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#16a34a"/>
      <stop offset="100%" stop-color="#15803d"/>
    </linearGradient>
    <linearGradient id="plumbobHighlight" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#86efac"/>
      <stop offset="100%" stop-color="#22c55e"/>
    </linearGradient>
  </defs>
  <polygon points="64,12 100,56 64,68" fill="url(#plumbobTop)"/>
  <polygon points="64,12 28,56 64,68" fill="url(#plumbobHighlight)"/>
  <polygon points="64,68 100,56 64,116" fill="url(#plumbobBottom)"/>
  <polygon points="64,68 28,56 64,116" fill="url(#plumbobTop)"/>
  <line x1="64" y1="12" x2="64" y2="116" stroke="#bbf7d0" stroke-width="1.5" opacity="0.8"/>
</svg>
EOF_SVG

    DESKTOP_ENTRY="$HOME/.local/share/applications/fix-sims-4.desktop"
    mkdir -p "$HOME/.local/share/applications"

    cat <<EOF_DESK > "$DESKTOP_ENTRY"
[Desktop Entry]
Name=Fix Sims 4 Linux
Comment=Gestor y Activador de DLCs para Los Sims 4 en Linux
Exec=bash -c 'bash "$SCRIPT_DIR/fix_sims_linux.sh"'
Icon=$ICON_PATH
Terminal=true
Type=Application
Categories=Game;Utility;
Keywords=Sims;Sims4;DLC;EA;Unlocker;
EOF_DESK
    chmod +x "$DESKTOP_ENTRY"

    if [ -d "$HOME/Desktop" ]; then
        cp "$DESKTOP_ENTRY" "$HOME/Desktop/Fix Sims 4.desktop"
        chmod +x "$HOME/Desktop/Fix Sims 4.desktop"
    fi

    echo -e "${P}\e[1;32m✔ Acceso directo creado en tu menú de aplicaciones y en el Escritorio.\e[0m"
    echo -ne "\n${P}Presiona Enter para continuar..."
    read -r
}

# --- SECCIÓN ACERCA DE & CHANGELOG ---
mostrar_acerca_de() {
    clear
    local P
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m            \e[1;32m💎 FIX SIMS 4 LINUX (EDICIÓN COMUNITARIA)\e[0m         \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m│\e[0m       \e[2;37mSteam • Steam Deck • Lutris • Bottles • Heroic\e[0m         \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m\n"
    echo -e "${P}  \e[1;37m• Versión:\e[0m        \e[1;32mv$VERSION\e[0m"
    echo -e "${P}  \e[1;37m• Autor:\e[0m          \e[1;36mJeff Cortez\e[0m"
    echo -e "${P}  \e[1;37m• Repositorio:\e[0m    \e[1;34mhttps://github.com/JeffCortez23/Fix_Sims_4_Linux\e[0m"
    echo -e "${P}  \e[1;37m• Compatibilidad:\e[0m \e[1;35mSteam, Steam Deck, Lutris, Bottles, Heroic, Wine\e[0m"
    echo -e "\n${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
    echo -e "${P}\e[1;33m📜 HISTORIAL DE CAMBIOS (CHANGELOG):\e[0m\n"
    echo -e "${P}  \e[1;32m[v2.1] - Diagnóstico Maestro, Caché, TUI & Multi-Lanzador\e[0m"
    echo -e "${P}    • 🔍 \e[1;37mGuía Oficial de DLCs:\e[0m Todos los EP (1-21), GP (1-12), SP y Kits."
    echo -e "${P}    • 🧹 \e[1;37mLimpiador de Caché:\e[0m localthumbcache para cargas infinitas."
    echo -e "${P}    • 🌐 \e[1;37mAuto-descarga Unlocker:\e[0m con verificación de hash SHA-256."
    echo -e "${P}    • 🖥️  \e[1;37mAcceso Directo:\e[0m .desktop e icono temático Plumbob."
    echo -e "${P}    • 🎮 \e[1;37mSoporte Multi-Lanzador:\e[0m Lutris, Bottles, Heroic Games y Wine."
    echo -e "${P}    • 🎨 \e[1;37mInterfaz TUI:\e[0m Diseño centrado, estético y moderno.\n"
    echo -e "${P}  \e[1;32m[v2.0] - Soporte Nueva EA App & Extracción en Lote\e[0m"
    echo -e "${P}    • Inyección dinámica de version.dll en subcarpetas de EA Desktop."
    echo -e "${P}    • Inyección de DllOverrides en Wine (user.reg)."
    echo -e "${P}    • Descompresión por lotes para múltiples archivos comprimidos.\n"
    echo -e "${P}  \e[1;32m[v1.0] - Lanzamiento Inicial\e[0m"
    echo -e "${P}    • Instalación básica y asesino de procesos colgados."
    echo -e "\n${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
    echo -ne "\n${P}Presiona Enter para volver al menú principal..."
    read -r
}

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    P=$(obtener_padding)
    echo -e "\n\n"
    echo -e "${P}\e[1;36m╭──────────────────────────────────────────────────────────────╮\e[0m"
    echo -e "${P}\e[1;36m│\e[0m         \e[1;32m💎 GESTOR DE LOS SIMS 4 (LINUX EDITION) v$VERSION\e[0m         \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m│\e[0m       \e[2;37mSteam • Steam Deck • Lutris • Bottles • Heroic\e[0m         \e[1;36m│\e[0m"
    echo -e "${P}\e[1;36m╰──────────────────────────────────────────────────────────────╯\e[0m"
    echo ""
    echo -e "${P}  \e[1;33m[1]\e[0m 📦  \e[1;37mInstalar / Mover DLCs al juego\e[0m \e[2;37m(ZIP, RAR, Lotes)\e[0m"
    echo -e "${P}  \e[1;33m[2]\e[0m 🔓  \e[1;37mReactivar DLCs\e[0m \e[2;37m(Inyección EA App + Wine Override)\e[0m"
    echo -e "${P}  \e[1;33m[3]\e[0m 🔍  \e[1;37mDiagnóstico de DLCs e Inyección\e[0m \e[2;37m(Health Check)\e[0m"
    echo -e "${P}  \e[1;33m[4]\e[0m 🧹  \e[1;37mLimpiar Caché del Juego\e[0m \e[2;37m(Solución Carga Infinita)\e[0m"
    echo -e "${P}  \e[1;33m[5]\e[0m 🌐  \e[1;37mDescargar / Actualizar EA DLC Unlocker\e[0m \e[2;37m(Auto)\e[0m"
    echo -e "${P}  \e[1;33m[6]\e[0m 🖥️   \e[1;37mCrear Acceso Directo\e[0m \e[2;37m(.desktop / Steam Deck)\e[0m"
    echo -e "${P}  \e[1;33m[7]\e[0m 🔪  \e[1;37mForzar cierre de procesos colgados\e[0m \e[2;37m(Fix Sims/EA)\e[0m"
    echo -e "${P}  \e[1;33m[8]\e[0m ⚙️   \e[1;37mReconfigurar rutas del script / Lanzador\e[0m"
    echo -e "${P}  \e[1;33m[9]\e[0m ℹ️   \e[1;37mAcerca de & Changelog\e[0m"
    echo -e "${P}  \e[1;31m[0]\e[0m 🚪  \e[1;37mSalir\e[0m"
    echo ""
    echo -e "${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
    echo -ne "${P}\e[1;33m👉 Elige una opción (0-9):\e[0m "
    read -r opcion

    case $opcion in
        1)
            echo -e "\n${P}\e[1;33m[Iniciando instalación / organización de DLCs...]\e[0m"
            mkdir -p "$SIMS_DIR"
            
            if [ -d "$DLC_SOURCE" ]; then
                mapfile -t ARCHIVOS_COMPRIMIDOS < <(find "$DLC_SOURCE" -maxdepth 1 -type f \( -iname "*.zip" -o -iname "*.rar" -o -iname "*.7z" \) | sort)
                
                if [ ${#ARCHIVOS_COMPRIMIDOS[@]} -gt 0 ]; then
                    echo -e "${P}\e[1;36mSe detectaron ${#ARCHIVOS_COMPRIMIDOS[@]} archivos comprimidos en la carpeta.\e[0m"
                    echo -e "${P}Descomprimiendo cada paquete en $SIMS_DIR..."
                    
                    for i in "${!ARCHIVOS_COMPRIMIDOS[@]}"; do
                        arch="${ARCHIVOS_COMPRIMIDOS[$i]}"
                        echo -e "${P}[$((i+1))/${#ARCHIVOS_COMPRIMIDOS[@]}] Extrayendo: \e[1;37m$(basename "$arch")\e[0m..."
                        7z x "$arch" -o"$SIMS_DIR" -y > /dev/null
                    done
                fi

                echo -e "${P}Copiando y organizando carpetas y archivos directos..."
                for item in "$DLC_SOURCE"/*; do
                    [ -e "$item" ] || continue
                    case "$item" in
                        *.zip|*.rar|*.7z|*.ZIP|*.RAR|*.7Z) ;;
                        *) cp -a "$item" "$SIMS_DIR/" 2>/dev/null ;;
                    esac
                done

                arreglar_estructura_dlcs "$SIMS_DIR"
                echo -e "\n${P}\e[1;32m¡Instalación y organización de DLCs completada!\e[0m"
                
            elif [ -f "$DLC_SOURCE" ]; then
                if ! command -v 7z &> /dev/null; then
                    echo -e "\n${P}\e[31m¡Error! No tienes '7z' instalado en tu sistema.\e[0m"
                    echo -ne "\n${P}Presiona Enter para continuar..."
                    read -r
                    continue
                fi
                echo -e "${P}Modo Archivo único detectado. Descomprimiendo en $SIMS_DIR..."
                7z x "$DLC_SOURCE" -o"$SIMS_DIR" -y
                arreglar_estructura_dlcs "$SIMS_DIR"
                echo -e "\n${P}\e[1;32m¡Extracción y organización terminada!\e[0m"
                
            else
                echo -e "\n${P}\e[33mAviso: No se encontró archivo o carpeta en '$DLC_SOURCE'.\e[0m"
                echo -e "${P}Revisando y organizando DLCs ya presentes en la carpeta del juego..."
                arreglar_estructura_dlcs "$SIMS_DIR"
            fi

            COUNT=$(ls -d "$SIMS_DIR"/[EGDFS]* 2>/dev/null | grep -E '/(EP|GP|SP|FP)[0-9]+' | wc -l)
            echo -e "\n${P}\e[1;32mTotal de carpetas de DLCs listas en el juego: $COUNT\e[0m"
            echo -ne "\n${P}Presiona Enter para continuar..."
            read -r
            ;;
            
        2)
            echo -e "\n${P}\e[1;34m[Arrancando inyección de DLCs Unlocker...]\e[0m"
            
            if ! localizar_archivos_unlocker; then
                echo -e "\n${P}\e[31m¡Error! No se pudieron obtener los archivos del Unlocker.\e[0m"
                echo -ne "\n${P}Presiona Enter para continuar..."
                read -r
                continue
            fi

            echo -e "${P}  \e[1;37m• Origen del Unlocker:\e[0m \e[36m$(dirname "$UNLOCKER_INI")\e[0m"

            if [ ! -d "$PREFIX" ]; then
                echo -e "\n${P}\e[31m¡Error! No se encontró el prefijo de Wine/Proton en: $PREFIX\e[0m"
                echo -e "${P}Asegúrate de haber iniciado el juego al menos una vez."
                echo -ne "\n${P}Presiona Enter para continuar..."
                read -r
                continue
            fi

            echo -e "${P}  \e[1;37m• Localizando ejecutables de EA Desktop...\e[0m"
            EA_BASE="$PREFIX/drive_c/Program Files/Electronic Arts/EA Desktop"
            INJECTED_COUNT=0

            if [ -d "$EA_BASE" ]; then
                cp "$UNLOCKER_DLL" "$EA_BASE/version.dll" 2>/dev/null && ((INJECTED_COUNT++))
                
                while read -r target_dir; do
                    if [ -d "$target_dir" ]; then
                        cp "$UNLOCKER_DLL" "$target_dir/version.dll" 2>/dev/null
                        ((INJECTED_COUNT++))
                    fi
                done < <(find "$EA_BASE" -type f \( -iname "EADesktop.exe" -o -iname "EABackgroundService.exe" \) -exec dirname {} \; | sort -u)
            else
                while read -r target_dir; do
                    cp "$UNLOCKER_DLL" "$target_dir/version.dll" 2>/dev/null
                    ((INJECTED_COUNT++))
                done < <(find "$PREFIX/drive_c" -type f \( -iname "EADesktop.exe" -o -iname "EABackgroundService.exe" \) -exec dirname {} \; | sort -u)
            fi

            echo -e "${P}  \e[1;32m✔\e[0m version.dll inyectado en $INJECTED_COUNT ubicaciones de EA App"

            USERS_DIR="$PREFIX/drive_c/users"
            if [ -d "$USERS_DIR" ]; then
                for u in "$USERS_DIR"/*; do
                    if [ -d "$u" ] && [ "$(basename "$u")" != "Public" ]; then
                        TARGET_CONF="$u/AppData/Roaming/anadius/EA DLC Unlocker v2"
                        mkdir -p "$TARGET_CONF"
                        cp "$UNLOCKER_INI" "$TARGET_CONF/config.ini" 2>/dev/null
                        cp "$UNLOCKER_GAME_INI" "$TARGET_CONF/g_LOS SIMS 4.ini" 2>/dev/null
                    fi
                done
            fi
            echo -e "${P}  \e[1;32m✔\e[0m Configuraciones de DLCs registradas en AppData"

            aplicar_dll_override "$USER_REG"

            # Limpiar cachés
            rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Electronic\ Arts/EA\ Desktop 2>/dev/null
            rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/EADesktop 2>/dev/null
            rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Origin 2>/dev/null
            echo -e "${P}  \e[1;32m✔\e[0m Caché temporal de EA App purgada"
            
            echo -e "\n${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
            echo -e "${P}\e[1;32m             ¡DLCS Y UNLOCKER ACTIVADOS CON ÉXITO!              \e[0m"
            echo -e "${P}\e[1;36m────────────────────────────────────────────────────────────────\e[0m"
            echo -e "${P}Ya puedes iniciar Los Sims 4 normalmente."
            echo -ne "\n${P}Presiona Enter para continuar..."
            read -r
            ;;

        3)
            diagnosticar_dlcs
            ;;

        4)
            limpiar_cache_juego
            ;;

        5)
            descargar_unlocker_auto
            ;;

        6)
            crear_acceso_directo
            ;;

        7)
            echo -e "\n${P}\e[1;31m[Aniquilando procesos fantasma...]\e[0m"
            pkill -9 -u "$USER" -f "steam-runtime-reaper" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "steam-launch-wrapper" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "EABackgroundService" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "EADesktop.exe" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "TS4_x64.exe" > /dev/null 2>&1
            pkill -9 -u "$USER" -f "Link2EA.exe" > /dev/null 2>&1
            echo -e "${P}\e[1;32m✔ ¡Limpieza completada! El botón de Steam debería reaccionar.\e[0m"
            echo -ne "\n${P}Presiona Enter para continuar..."
            read -r
            ;;
            
        8)
            configurar_rutas
            source "$CONFIG_FILE"
            if [ -d "$STEAM_LIBRARY/steamapps/common/The Sims 4" ]; then
                SIMS_DIR="$STEAM_LIBRARY/steamapps/common/The Sims 4"
            else
                SIMS_DIR="$STEAM_LIBRARY"
            fi
            PREFIX="$STEAM_COMPATDATA/steamapps/compatdata/1222670/pfx"
            USER_REG="$PREFIX/user.reg"
            ;;

        9)
            mostrar_acerca_de
            ;;

        0)
            clear
            P=$(obtener_padding)
            echo -e "\n\n"
            echo -e "${P}\e[1;32m💎 ¡Que disfrutes jugando Los Sims 4 en Linux!\e[0m\n"
            exit 0
            ;;
            
        *)
            echo -e "\n${P}\e[31mOpción no válida.\e[0m"
            sleep 1
            ;;
    esac
done
