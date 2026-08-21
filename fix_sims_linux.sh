#!/usr/bin/env bash

# ==============================================================================
#   Gestor de Los Sims 4 (Linux Edition) v2.1
#   Soporta Steam, Steam Deck, Lutris, Bottles, Heroic & Wine
#   Compatible con nuevas versiones de EA App
#   Desarrollado por Jeff Cortez (github.com/JeffCortez23)
# ==============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$HOME/.config/sims4_gestor.conf"
UNLOCKER_STORE="$HOME/.local/share/sims4_unlocker"
ICON_PATH="$HOME/.local/share/icons/fix-sims-4.svg"
VERSION="2.1"

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

# --- MAPA MAESTRO DE TODOS LOS DLCS DISPONIBLES EN LOS SIMS 4 ---
obtener_nombre_dlc() {
    local code="$1"
    case "$code" in
        # Packs de Expansión (EP)
        EP01) echo "¡A Trabajar! (Get to Work)" ;;
        EP02) echo "¿Quedamos? (Get Together)" ;;
        EP03) echo "Urbanitas (City Living)" ;;
        EP04) echo "Perros y Gatos (Cats & Dogs)" ;;
        EP05) echo "Y Las Cuatro Estaciones (Seasons)" ;;
        EP06) echo "¡Rumbo a la Fama! (Get Famous)" ;;
        EP07) echo "Vida Isleña (Island Living)" ;;
        EP08) echo "Días de Universidad (Discover University)" ;;
        EP09) echo "Vida Ecológica (Eco Lifestyle)" ;;
        EP10) echo "Escapada en la Nieve (Snowy Escape)" ;;
        EP11) echo "Vida en el Pueblo (Cottage Living)" ;;
        EP12) echo "Años High School (High School Years)" ;;
        EP13) echo "Creciendo en Familia (Growing Together)" ;;
        EP14) echo "Rancho de Caballos (Horse Ranch)" ;;
        EP15) echo "Se Alquila (For Rent)" ;;
        EP16) echo "¡Viva el Amor! (Lovestruck)" ;;
        EP17) echo "Vida y Más Allá (Life & Death)" ;;
        EP18) echo "Pack de Expansión 18" ;;
        EP19) echo "Pack de Expansión 19" ;;
        EP20) echo "Pack de Expansión 20" ;;
        EP21) echo "Pack de Expansión 21" ;;
        
        # Packs de Contenido (GP)
        GP01) echo "De Acampada (Outdoor Retreat)" ;;
        GP02) echo "Día de Spa (Spa Day)" ;;
        GP03) echo "Escapada Gourmet (Dine Out)" ;;
        GP04) echo "Vampiros (Vampires)" ;;
        GP05) echo "Papás y Mamás (Parenthood)" ;;
        GP06) echo "Aventura en la Selva (Jungle Adventure)" ;;
        GP07) echo "StrangerVille" ;;
        GP08) echo "Y el Reino de la Magia (Realm of Magic)" ;;
        GP09) echo "Star Wars: Viaje a Batuu" ;;
        GP10) echo "¡Sí, Quiero! (My Wedding Stories)" ;;
        GP11) echo "Licántropos (Werewolves)" ;;
        GP12) echo "Pack de Contenido 12" ;;
        
        # Packs de Accesorios y Kits (SP)
        SP01) echo "Fiesta Glamurosa (Luxury Party)" ;;
        SP02) echo "Patio de Ensueño (Perfect Patio)" ;;
        SP03) echo "Cocina Divina (Cool Kitchen)" ;;
        SP04) echo "Escalofriante (Spooky)" ;;
        SP05) echo "Noche de Cine (Movie Hangout)" ;;
        SP06) echo "Jardín Romántico (Romantic Garden)" ;;
        SP07) echo "Cuarto de Niños (Kids Room)" ;;
        SP08) echo "Diversión en el Patio (Backyard)" ;;
        SP09) echo "Glamour Vintage (Vintage Glamour)" ;;
        SP10) echo "Noche de Bolos (Bowling Night)" ;;
        SP11) echo "Fitness (Fitness)" ;;
        SP12) echo "Infantes (Toddler)" ;;
        SP13) echo "Día de Colada (Laundry Day)" ;;
        SP14) echo "Mi Primera Mascota (My First Pet)" ;;
        SP15) echo "Moschino (Moschino)" ;;
        SP16) echo "Minicasas (Tiny Living)" ;;
        SP17) echo "Portentos del Punto (Nifty Knitting)" ;;
        SP18) echo "Fenómenos Paranormales (Paranormal)" ;;
        SP20) echo "Zafarrancho de Limpieza (Kit)" ;;
        SP21) echo "Cocina Campestre (Kit)" ;;
        SP22) echo "Moda Retró (Kit)" ;;
        SP23) echo "Oasis en el Desierto (Kit)" ;;
        SP24) echo "Loft Industrial (Kit)" ;;
        SP25) echo "Moda Masculina (Kit)" ;;
        SP26) echo "Decoración Carnavalesca (Kit)" ;;
        SP28) echo "Maximalismo (Kit)" ;;
        SP29) echo "Noche Chic (Kit)" ;;
        SP30) echo "Tiendita de Campaña (Kit)" ;;
        SP31) echo "Primeros Pasos (Kit)" ;;
        SP32) echo "Oasis en el Desierto (Kit)" ;;
        SP33) echo "Pastel Pop (Kit)" ;;
        SP34) echo "Desorden Cotidiano (Kit)" ;;
        SP35) echo "Ropa Interior (Kit)" ;;
        SP36) echo "Objetos de Baño (Kit)" ;;
        SP37) echo "Invernadero Idílico (Kit)" ;;
        SP38) echo "Tesoros del Sótano (Kit)" ;;
        SP39) echo "Rincón de Lectura (Kit)" ;;
        SP40) echo "Vuelta al Grunge (Kit)" ;;
        SP41) echo "Piscina Junto a la Piscina (Kit)" ;;
        SP42) echo "Chef de Casa (Stuff Pack)" ;;
        SP43) echo "Lujo Nocturno (Kit)" ;;
        SP44) echo "Creaciones de Cristal (Stuff Pack)" ;;
        SP45) echo "Castillos Modernos (Kit)" ;;
        SP46) echo "Gótico Urbano (Kit)" ;;
        SP47) echo "Homenaje a la Rivera (Kit)" ;;
        SP48) echo "Bistro Acogedor (Kit)" ;;
        SP49) echo "Retiro en la Rivera (Kit)" ;;
        SP50) echo "Habitación Infantil Encantadora (Kit)" ;;
        SP51) echo "Estudio de Artista (Kit)" ;;
        SP52) echo "Salón de Cuentos (Kit)" ;;
        SP53) echo "Kit 53" ;;
        SP54) echo "Kit 54" ;;
        SP55) echo "Kit 55" ;;
        SP56) echo "Kit 56" ;;
        SP57) echo "Kit 57" ;;
        SP58) echo "Kit 58" ;;
        SP59) echo "Kit 59" ;;
        SP60) echo "Kit 60" ;;
        SP61) echo "Kit 61" ;;
        SP62) echo "Kit 62" ;;
        SP63) echo "Kit 63" ;;
        SP64) echo "Kit 64" ;;
        SP65) echo "Kit 65" ;;
        SP66) echo "Kit 66" ;;
        SP67) echo "Kit 67" ;;
        SP68) echo "Kit 68" ;;
        SP69) echo "Kit 69" ;;
        SP70) echo "Kit 70" ;;
        SP71) echo "Kit 71" ;;
        SP72) echo "Kit 72" ;;
        SP73) echo "Kit 73" ;;
        SP74) echo "Kit 74" ;;
        SP75) echo "Kit 75" ;;
        SP76) echo "Kit 76" ;;
        SP77) echo "Kit 77" ;;
        SP78) echo "Kit 78" ;;
        SP79) echo "Kit 79" ;;
        SP80) echo "Kit 80" ;;
        SP81) echo "Kit 81" ;;
        SP82) echo "Kit 82" ;;
        
        # Festivos / Packs Gratuitos (FP)
        FP01) echo "Pack Felices Fiestas (Holiday Celebration)" ;;
        
        *) echo "Pack / Kit ($code)" ;;
    esac
}

# Lista maestra de todos los códigos de DLCs oficiales
TODOS_LOS_DLCS=(
    # Expansiones (17)
    EP01 EP02 EP03 EP04 EP05 EP06 EP07 EP08 EP09 EP10 EP11 EP12 EP13 EP14 EP15 EP16 EP17
    # Packs de Contenido (12)
    GP01 GP02 GP03 GP04 GP05 GP06 GP07 GP08 GP09 GP10 GP11 GP12
    # Festivos (1)
    FP01
    # Accesorios y Kits (78)
    SP01 SP02 SP03 SP04 SP05 SP06 SP07 SP08 SP09 SP10 SP11 SP12 SP13 SP14 SP15 SP16 SP17 SP18
    SP20 SP21 SP22 SP23 SP24 SP25 SP26 SP28 SP29 SP30 SP31 SP32 SP33 SP34 SP35 SP36 SP37 SP38
    SP39 SP40 SP41 SP42 SP43 SP44 SP45 SP46 SP47 SP48 SP49 SP50 SP51 SP52 SP53 SP54 SP55 SP56
    SP57 SP58 SP59 SP60 SP61 SP62 SP63 SP64 SP65 SP66 SP67 SP68 SP69 SP70 SP71 SP72 SP73 SP74
    SP75 SP76 SP77 SP78 SP79 SP80 SP81 SP82
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
        "$SCRIPT_DIR/EA DLC Unlocker v3.4"
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
                        nombre="Steam (Los Sims 4 encontrado aquí: $path)"
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
    echo -e "\e[36m====================================================\e[0m"
    echo -e "\e[1;33m      Configuración Inicial de Rutas / Lanzador     \e[0m"
    echo -e "\e[36m====================================================\e[0m"
    echo "Buscando instalaciones de Steam, Lutris, Bottles y Heroic..."
    detectar_entornos

    if [ ${#DETECTED_ENTORNOS_NOMBRES[@]} -gt 0 ]; then
        echo -e "\n\e[1;32m¡Se encontraron las siguientes instalaciones!\e[0m"
        for i in "${!DETECTED_ENTORNOS_NOMBRES[@]}"; do
            echo -e "$((i+1)). ${DETECTED_ENTORNOS_NOMBRES[$i]}"
        done
        echo "$(( ${#DETECTED_ENTORNOS_NOMBRES[@]} + 1 )). Introducir rutas manualmente"
        
        read -p "Elige una opción (1-$(( ${#DETECTED_ENTORNOS_NOMBRES[@]} + 1 ))): " opcion_env
        
        if [ "$opcion_env" -ge 1 ] && [ "$opcion_env" -le "${#DETECTED_ENTORNOS_NOMBRES[@]}" ] 2>/dev/null; then
            STEAM_LIBRARY="${DETECTED_ENTORNOS_LIBS[$((opcion_env-1))]}"
            STEAM_COMPATDATA="${DETECTED_ENTORNOS_PFX[$((opcion_env-1))]}"
        fi
    fi

    if [ -z "$STEAM_LIBRARY" ]; then
        echo -e "\n\e[1;34m💡 PRO-TIP:\e[0m Arrastra la carpeta donde instalaste tu Biblioteca de Steam / Juego"
        read -p "Ruta de la biblioteca: " input_lib
        STEAM_LIBRARY="${input_lib//\'/}"
        STEAM_LIBRARY="${STEAM_LIBRARY%"${STEAM_LIBRARY##*[![:space:]]}"}"
    fi

    if [ -z "$STEAM_COMPATDATA" ]; then
        STEAM_COMPATDATA="$STEAM_LIBRARY"
    fi

    echo -e "\n\e[1;32mExcelente.\e[0m Ahora necesitamos la ruta donde guardas tus DLCs."
    echo -e "\e[1;34m💡 PRO-TIP:\e[0m Arrastra la carpeta o archivo (.zip/.rar/.7z) de tus DLCs."
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

# --- FUNCIÓN PARA ORGANIZAR DLCS (Aplanador) ---
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

# --- AUTO-DESCARGADOR DE UNLOCKER (JARDINERA) ---
descargar_unlocker_auto() {
    echo -e "\n\e[1;36m[Conectando con el servidor para descargar EA DLC Unlocker...]\e[0m"
    mkdir -p "$UNLOCKER_STORE/ea_app"
    
    python3 -c '
import urllib.request, json, ssl, hashlib, os, sys
from pathlib import Path

store = Path(os.path.expanduser("~/.local/share/sims4_unlocker"))
manifest_url = "https://access.tiesasarchives.uk/api/unlocker/manifest?channel=stable&platform=linux&architecture=x64"
headers = {"User-Agent": "FixSimsLinux/2.1", "X-Web-Jardinera-Bootstrap-Version": "1.0.1"}

try:
    ctx = ssl.create_default_context()
    req = urllib.request.Request(manifest_url, headers=headers)
    with urllib.request.urlopen(req, context=ctx, timeout=15) as resp:
        data = json.load(resp)
    
    version = data.get("version", "3.4.0")
    print(f"✔ Publicación encontrada: v{version}")
    
    for art in data.get("artifacts", []):
        rel_path = art["path"]
        dest = store / rel_path
        dest.parent.mkdir(parents=True, exist_ok=True)
        print(f"  Descargando: {rel_path}...")
        
        art_req = urllib.request.Request(art["downloadUrl"], headers=headers)
        with urllib.request.urlopen(art_req, context=ctx, timeout=30) as d_resp:
            content = d_resp.read()
        
        if hashlib.sha256(content).hexdigest().lower() != art["sha256"].lower():
            raise ValueError(f"Error de integridad en {rel_path}")
        
        dest.write_bytes(content)
        
    print("\n\033[32m✔ ¡Archivos del Unlocker descargados y verificados con éxito!\033[0m")
except Exception as e:
    print(f"\n\033[31mError al descargar automáticamente: {e}\033[0m")
    sys.exit(1)
'

    if [ $? -eq 0 ]; then
        echo -e "\e[1;32mArchivos del Unlocker guardados en: $UNLOCKER_STORE\e[0m"
    else
        echo -e "\e[33mSi prefieres descargarlo de Telegram, está disponible en: https://t.me/c/3910223807/11\e[0m"
    fi
    read -p "Presiona Enter para continuar..."
}

# --- INSPECTOR Y DIAGNÓSTICO DE DLCS (HEALTH CHECK COMPLETO) ---
diagnosticar_dlcs() {
    clear
    echo -e "\e[36m====================================================\e[0m"
    echo -e "\e[1;33m    🔍 Inspector & Diagnóstico de DLCs (Health Check) \e[0m"
    echo -e "\e[36m====================================================\e[0m"
    echo -e "Ruta del Juego: \e[36m$SIMS_DIR\e[0m"
    echo -e "Ruta del Prefijo: \e[36m$PREFIX\e[0m\n"

    # 1. Chequeo del Unlocker en EA App & Wine
    echo -e "\e[1;34m[1. Estado de Activación e Inyección]\e[0m"
    local dll_count
    dll_count=$(find "$PREFIX/drive_c" -type f -name "version.dll" 2>/dev/null | grep -i "Electronic Arts" | wc -l)
    if [ "$dll_count" -gt 0 ]; then
        echo -e "  • Inyección de version.dll: \e[1;32m[✔ INYECTADO] ($dll_count ubicaciones)\e[0m"
    else
        echo -e "  • Inyección de version.dll: \e[1;31m[❌ NO DETECTADO]\e[0m"
    fi

    if [ -f "$USER_REG" ] && grep -q '"version"="native,builtin"' "$USER_REG"; then
        echo -e "  • Wine DllOverrides (user.reg): \e[1;32m[✔ ACTIVO ('version'='native,builtin')]\e[0m"
    else
        echo -e "  • Wine DllOverrides (user.reg): \e[1;31m[❌ FALTA CONFIGURAR]\e[0m"
    fi

    local conf_count
    conf_count=$(find "$PREFIX/drive_c/users" -type f -name "g_LOS SIMS 4.ini" 2>/dev/null | wc -l)
    if [ "$conf_count" -gt 0 ]; then
        echo -e "  • Configuración de DLCs (AppData): \e[1;32m[✔ INSTALADA]\e[0m"
    else
        echo -e "  • Configuración de DLCs (AppData): \e[1;31m[❌ FALTA CONFIG.INI]\e[0m"
    fi

    # 2. Comparar Catálogo Maestro vs Carpetas en Disco
    echo -e "\n\e[1;34m[2. Estado de Todos los DLCs Oficiales (Instalados vs Faltantes)]\e[0m"
    
    local total_conocidos=${#TODOS_LOS_DLCS[@]}
    local total_instalados=0
    local total_faltantes=0

    # Expansiones (EP)
    echo -e "\n\e[1;33m--- Packs de Expansión (EP) ---\e[0m"
    for code in EP01 EP02 EP03 EP04 EP05 EP06 EP07 EP08 EP09 EP10 EP11 EP12 EP13 EP14 EP15 EP16 EP17; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "  \e[1;31m[❌ NO INSTALADO]\e[0m \e[1;30m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    # Packs de Contenido (GP)
    echo -e "\n\e[1;33m--- Packs de Contenido (GP) ---\e[0m"
    for code in GP01 GP02 GP03 GP04 GP05 GP06 GP07 GP08 GP09 GP10 GP11 GP12; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "  \e[1;31m[❌ NO INSTALADO]\e[0m \e[1;30m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    # Packs Gratuitos (FP)
    echo -e "\n\e[1;33m--- Packs Gratuitos / Especiales (FP) ---\e[0m"
    for code in FP01; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "  \e[1;31m[❌ NO INSTALADO]\e[0m \e[1;30m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    # Accesorios y Kits (SP)
    echo -e "\n\e[1;33m--- Packs de Accesorios & Kits (SP) ---\e[0m"
    for code in SP01 SP02 SP03 SP04 SP05 SP06 SP07 SP08 SP09 SP10 SP11 SP12 SP13 SP14 SP15 SP16 SP17 SP18 \
                SP20 SP21 SP22 SP23 SP24 SP25 SP26 SP28 SP29 SP30 SP31 SP32 SP33 SP34 SP35 SP36 SP37 SP38 \
                SP39 SP40 SP41 SP42 SP43 SP44 SP45 SP46 SP47 SP48 SP49 SP50 SP51 SP52 SP53 SP54 SP55 SP56 \
                SP57 SP58 SP59 SP60 SP61 SP62 SP63 SP64 SP65 SP66 SP67 SP68 SP69 SP70 SP71 SP72 SP73 SP74 \
                SP75 SP76 SP77 SP78 SP79 SP80 SP81 SP82; do
        nombre=$(obtener_nombre_dlc "$code")
        if [ -d "$SIMS_DIR/$code" ]; then
            size=$(du -sh "$SIMS_DIR/$code" 2>/dev/null | awk '{print $1}')
            echo -e "  \e[1;32m[✔ INSTALADO]\e[0m \e[1;37m$code\e[0m: $nombre \e[36m($size)\e[0m"
            ((total_instalados++))
        else
            echo -e "  \e[1;31m[❌ NO INSTALADO]\e[0m \e[1;30m$code: $nombre\e[0m"
            ((total_faltantes++))
        fi
    done

    echo -e "\n\e[36m====================================================\e[0m"
    echo -e "\e[1;32m📊 RESUMEN GENERAL DE DLCs:\e[0m"
    echo -e "  • Total en Catálogo Oficial: \e[1;37m$total_conocidos packs\e[0m"
    echo -e "  • Instalados en tu disco:    \e[1;32m$total_instalados packs\e[0m"
    echo -e "  • Faltantes por descargar:   \e[1;31m$total_faltantes packs\e[0m"
    echo -e "\e[36m====================================================\e[0m"
    read -p "Presiona Enter para volver al menú..."
}

# --- LIMPIADOR DE CACHÉ DEL JUEGO ---
limpiar_cache_juego() {
    clear
    echo -e "\e[36m====================================================\e[0m"
    echo -e "\e[1;33m      🧹 Limpiador de Caché del Juego (TS4)         \e[0m"
    echo -e "\e[36m====================================================\e[0m"
    echo "Buscando carpetas de datos de usuario de Los Sims 4..."

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
        echo -e "\e[31mNo se encontró la carpeta de usuario de Los Sims 4.\e[0m"
        echo "Asegúrate de haber abierto el juego al menos una vez."
        read -p "Presiona Enter para continuar..."
        return
    fi

    for ts4_user in "${FOUND_DOCS[@]}"; do
        echo -e "\nLimpiando carpeta: \e[36m$ts4_user\e[0m"
        
        rm -f "$ts4_user/localthumbcache.package" 2>/dev/null && echo "  ✔ localthumbcache.package eliminado"
        rm -f "$ts4_user/avatarcache.package" 2>/dev/null && echo "  ✔ avatarcache.package eliminado"
        rm -f "$ts4_user/clientDB.package" 2>/dev/null && echo "  ✔ clientDB.package eliminado"
        rm -rf "$ts4_user/cache"/* 2>/dev/null && echo "  ✔ Contenido de /cache/ purgado"
        rm -rf "$ts4_user/cachestr"/* 2>/dev/null && echo "  ✔ Contenido de /cachestr/ purgado"
        rm -rf "$ts4_user/onlinerequestcache"/* 2>/dev/null && echo "  ✔ Contenido de /onlinerequestcache/ purgado"
        rm -rf "$ts4_user/lotcachedData"/* 2>/dev/null && echo "  ✔ Contenido de /lotcachedData/ purgado"
    done

    rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Electronic\ Arts/EA\ Desktop 2>/dev/null
    rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/EADesktop 2>/dev/null
    rm -rf "$PREFIX/drive_c/users"/*/AppData/Local/Origin 2>/dev/null

    echo -e "\n\e[1;32m¡Caché limpiada con éxito! Esto previene cargas infinitas y errores de interfaz.\e[0m"
    read -p "Presiona Enter para continuar..."
}

# --- CREADOR DE ACCESO DIRECTO (.DESKTOP) ---
crear_acceso_directo() {
    echo -e "\n\e[1;36m[Creando Acceso Directo de Escritorio y Menú de Apps...]\e[0m"
    
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

    echo -e "\e[1;32m✔ Acceso directo creado en tu menú de aplicaciones y en el Escritorio.\e[0m"
    read -p "Presiona Enter para continuar..."
}

# --- SECCIÓN ACERCA DE & CHANGELOG ---
mostrar_acerca_de() {
    clear
    echo -e "\e[36m====================================================\e[0m"
    echo -e "\e[1;32m     💎 Fix Sims 4 Linux (Edición Comunitaria)      \e[0m"
    echo -e "\e[36m====================================================\e[0m"
    echo -e " \e[1;37mVersión:\e[0m        \e[1;32mv$VERSION\e[0m"
    echo -e " \e[1;37mAutor:\e[0m          \e[1;36mJeff Cortez\e[0m"
    echo -e " \e[1;37mRepositorio:\e[0m    \e[1;34mhttps://github.com/JeffCortez23/Fix_Sims_4_Linux\e[0m"
    echo -e " \e[1;37mCompatibilidad:\e[0m \e[1;35mSteam, Steam Deck, Lutris, Bottles, Heroic, Wine\e[0m"
    echo -e "\e[36m----------------------------------------------------\e[0m"
    echo -e "\e[1;33m📜 Historial de Cambios (Changelog):\e[0m\n"
    
    echo -e "\e[1;32m[v2.1] - Nivel Dios: Diagnóstico Maestro, Caché & Multi-Lanzador\e[0m"
    echo -e "  • 🔍 \e[1;37mInspector Maestro de DLCs\e[0m: Compara el catálogo oficial completo contra tu disco (detecta instalados vs faltantes)."
    echo -e "  • 🧹 \e[1;37mLimpiador de Caché\e[0m (localthumbcache.package) para arreglar carga infinita."
    echo -e "  • 🌐 \e[1;37mAuto-descarga del Unlocker\e[0m con verificación de hash SHA-256."
    echo -e "  • 🖥️ \e[1;37mAcceso directo (.desktop)\e[0m con icono oficial Plumbob para menú y escritorio."
    echo -e "  • 🎮 \e[1;37mSoporte Multi-Lanzador\e[0m para Lutris, Bottles, Heroic Games y Wine."
    echo -e "  • ℹ️ \e[1;37mPanel 'Acerca de'\e[0m integrado en el script."
    echo ""
    echo -e "\e[1;32m[v2.0] - Soporte Nueva EA App & Extracción en Lote\e[0m"
    echo -e "  • Inyección dinámica de version.dll en subdirectorios versionados (13.xxx/EA Desktop)."
    echo -e "  • Inyección automática de Wine DllOverrides (\"version\"=\"native,builtin\") en user.reg."
    echo -e "  • Descompresión por lotes para carpetas con múltiples .zip/.rar/.7z (Telegram/Navegador)."
    echo -e "  • Aplanador automático de carpetas anidadas ('all in one', 'The Sims 4')."
    echo -e "  • Compatibilidad ampliada para Steam Flatpak, Snap y MicroSD en Steam Deck."
    echo ""
    echo -e "\e[1;32m[v1.0] - Lanzamiento Inicial\e[0m"
    echo -e "  • Instalación básica de DLCs, inyección en EA App y asesino de procesos fantasma."
    
    echo -e "\n\e[36m====================================================\e[0m"
    read -p "Presiona Enter para volver al menú principal..."
}

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    echo -e "\e[36m====================================================\e[0m"
    echo -e "\e[1;32m    Gestor de Los Sims 4 (Linux Edition) v$VERSION       \e[0m"
    echo -e "\e[36m====================================================\e[0m"
    echo "1) Instalar / Mover DLCs al juego (ZIP, RAR, Lotes)"
    echo "2) Reactivar DLCs (Inyección EA App + Wine Override)"
    echo "3) 🔍 Diagnóstico de DLCs e Inyección (Health Check)"
    echo "4) 🧹 Limpiar Caché del Juego (Solución Carga Infinita)"
    echo "5) 🌐 Descargar / Actualizar EA DLC Unlocker (Auto)"
    echo "6) 🖥️ Crear Acceso Directo (.desktop / Steam Deck)"
    echo "7) 🔪 Forzar cierre de procesos colgados (Fix Sims/EA)"
    echo "8) ⚙️ Reconfigurar rutas del script / Lanzador"
    echo "9) ℹ️ Acerca de & Changelog"
    echo "0) Salir"
    echo -e "\e[36m====================================================\e[0m"
    read -p "Elige una opción (0-9): " opcion

    case $opcion in
        1)
            echo -e "\n\e[1;33m[Iniciando instalación / organización de DLCs...]\e[0m"
            mkdir -p "$SIMS_DIR"
            
            if [ -d "$DLC_SOURCE" ]; then
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
                echo -e "\e[31m¡Error! No se encontraron los archivos del Unlocker.\e[0m"
                echo "Usa la Opción 5 para descargarlos automáticamente con un solo clic."
                read -p "Presiona Enter para continuar..."
                continue
            fi

            echo -e "Usando archivos del Unlocker desde: \e[36m$(dirname "$UNLOCKER_INI")\e[0m"

            if [ ! -d "$PREFIX" ]; then
                echo -e "\e[31m¡Error! No se encontró el prefijo de Wine/Proton en: $PREFIX\e[0m"
                echo "Asegúrate de haber iniciado el juego al menos una vez."
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
            echo -e "\e[1;32m ¡DLCs Y UNLOCKER ACTIVADOS CON ÉXITO!              \e[0m"
            echo -e "\e[1;32m====================================================\e[0m"
            echo "Ya puedes iniciar Los Sims 4 normalmente."
            read -p "Presiona Enter para continuar..."
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
            echo "¡Que disfrutes jugando Los Sims 4!"
            exit 0
            ;;
            
        *)
            echo -e "\e[31mOpción no válida.\e[0m"
            sleep 1
            ;;
    esac
done
