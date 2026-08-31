#!/usr/bin/env python3
"""
💎 Descargador Inteligente de DLCs de Telegram para Los Sims 4 en Linux
Compara con tu instalación local de Los Sims 4 y SOLO descarga los packs que realmente te faltan.
Requiere: telethon (ejecutar con: uv run --with telethon python3 descargar_telegram.py)
"""

import os
import sys
import re
import asyncio
from pathlib import Path

try:
    from telethon import TelegramClient
    from telethon.tl.types import MessageMediaDocument, DocumentAttributeFilename
except ImportError:
    print("\n\033[1;31m[Error] La librería 'telethon' no está instalada.\033[0m")
    print("\nPuedes ejecutar este script fácilmente con:")
    print("  \033[1;32muv run --with telethon python3 descargar_telegram.py\033[0m\n")
    sys.exit(1)

# Configuración predeterminada
DEFAULT_API_ID = 38972472
DEFAULT_API_HASH = "5388070139a9ca5261da9f8c5e624bda"
DEFAULT_CHAT_ID = -1003910223807  # ID numérico de https://t.me/c/3910223807
DEFAULT_TOPIC_ID = 9              # Tema / Topic 9
DEFAULT_OUTPUT_DIR = Path.home() / "Downloads" / "Sims4_Telegram_DLCs"
CONFIG_FILE = Path.home() / ".config" / "sims4_gestor.conf"

def obtener_ruta_juego() -> Path:
    """Lee la ruta del juego desde sims4_gestor.conf o busca la ruta por defecto."""
    if CONFIG_FILE.is_file():
        for line in CONFIG_FILE.read_text().splitlines():
            if line.startswith("STEAM_LIBRARY="):
                lib_str = line.split("=", 1)[1].strip().strip('"').strip("'")
                lib_path = Path(lib_str)
                sims_cand = lib_path / "steamapps" / "common" / "The Sims 4"
                if sims_cand.is_dir():
                    return sims_cand
                if lib_path.is_dir() and ("The Sims 4" in lib_path.name or "Los Sims 4" in lib_path.name):
                    return lib_path
                return sims_cand

    default_candidates = [
        Path.home() / ".local/share/Steam/steamapps/common/The Sims 4",
        Path.home() / ".steam/steam/steamapps/common/The Sims 4",
        Path.home() / ".var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/The Sims 4"
    ]
    for cand in default_candidates:
        if cand.is_dir():
            return cand
    return default_candidates[0]

def extraer_codigo_dlc(filename: str) -> str:
    """Extrae el código de pack (EP01, GP05, SP12, FP01) del nombre de archivo."""
    match = re.search(r'\b(EP\d{2}|GP\d{2}|SP\d{2}|FP\d{2})\b', filename, re.IGNORECASE)
    if match:
        return match.group(1).upper()
    return ""

def format_size(size_bytes: int) -> str:
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.2f} TB"

def progress_callback(current, total, filename):
    percent = (current / total) * 100 if total > 0 else 0
    bar_length = 30
    filled_len = int(bar_length * current // total) if total > 0 else 0
    bar = '=' * filled_len + '-' * (bar_length - filled_len)
    sys.stdout.write(f"\r  [{bar}] {percent:5.1f}% ({format_size(current)} / {format_size(total)}) - {filename[:30]}")
    sys.stdout.flush()

async def main():
    print("\033[36m╭──────────────────────────────────────────────────────────────╮\033[0m")
    print("\033[36m│\033[0m     \033[1;32m💎 DESCARGADOR INTELIGENTE DE DLCS (TELEGRAM)\033[0m            \033[36m│\033[0m")
    print("\033[36m│\033[0m          \033[2;37mSolo descarga los DLCs que faltan en tu juego\033[0m       \033[36m│\033[0m")
    print("\033[36m╰──────────────────────────────────────────────────────────────╯\033[0m\n")

    sims_dir = obtener_ruta_juego()
    print(f"📁 Carpeta del juego detectada: \033[36m{sims_dir}\033[0m")
    print(f"📥 Carpeta de descargas:       \033[36m{DEFAULT_OUTPUT_DIR}\033[0m\n")

    # Credenciales de Telegram
    api_id = int(os.environ.get("TG_API_ID", DEFAULT_API_ID))
    api_hash = os.environ.get("TG_API_HASH", DEFAULT_API_HASH)

    session_path = Path.home() / ".config" / "telegram_sims_downloader"
    session_path.mkdir(parents=True, exist_ok=True)
    session_file = str(session_path / "anon")

    client = TelegramClient(session_file, api_id, api_hash)
    await client.start()

    print("\n\033[1;32m✔ Conectado a Telegram con éxito.\033[0m")
    DEFAULT_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Escaneando archivos en el canal ({DEFAULT_CHAT_ID})...")
    try:
        chat = await client.get_entity(DEFAULT_CHAT_ID)
    except Exception as e:
        print(f"\n\033[31mError al acceder al chat ({DEFAULT_CHAT_ID}): {e}\033[0m")
        return

    messages_with_files = []
    async for message in client.iter_messages(chat, reply_to=DEFAULT_TOPIC_ID):
        if message.file:
            messages_with_files.append(message)

    if not messages_with_files:
        async for message in client.iter_messages(chat):
            if message.file:
                messages_with_files.append(message)

    if not messages_with_files:
        print("\033[33mNo se encontraron archivos en este chat/tema.\033[0m")
        return

    print(f"\n\033[1;36mTotal de archivos en Telegram:\033[0m {len(messages_with_files)}")
    print("Analizando qué packs necesitas realmente...\n")

    descargas_pendientes = []
    omitidos_instalados = 0
    omitidos_descargados = 0

    for msg in messages_with_files:
        filename = msg.file.name or f"archivo_{msg.id}"
        code = extraer_codigo_dlc(filename)
        target_path = DEFAULT_OUTPUT_DIR / filename
        filesize = msg.file.size or 0

        # 1. ¿Ya está instalado en la carpeta del juego?
        if code:
            installed_folder = sims_dir / code
            if installed_folder.is_dir() and any(installed_folder.iterdir()):
                omitidos_instalados += 1
                continue

        # 2. ¿Ya fue descargado previamente y el archivo está completo?
        if target_path.exists() and target_path.stat().st_size == filesize:
            omitidos_descargados += 1
            continue

        descargas_pendientes.append((msg, filename, filesize, target_path))

    print(f"  \033[1;32m✔\033[0m Packs ya instalados en el juego (omitidos):     \033[1;32m{omitidos_instalados}\033[0m")
    print(f"  \033[1;33m✔\033[0m Packs ya descargados en tu carpeta (omitidos): \033[1;33m{omitidos_descargados}\033[0m")
    print(f"  \033[1;36m⬇\033[0m Packs pendientes que faltan por descargar:     \033[1;36m{len(descargas_pendientes)}\033[0m\n")

    if not descargas_pendientes:
        print("\033[1;32m🎉 ¡Felicidades! Tienes todos los DLCs disponibles.\033[0m")
        print("No hay ningún pack faltante por descargar.")
        print("\nEjecuta \033[1;33mfixsims\033[0m y elige la opción 1 para instalar cualquier pack que esté pendiente en Descargas.")
        return

    for i, (msg, filename, filesize, target_path) in enumerate(descargas_pendientes, 1):
        print(f"[{i}/{len(descargas_pendientes)}] Descargando: \033[1;37m{filename}\033[0m ({format_size(filesize)})")
        await msg.download_media(
            file=str(target_path),
            progress_callback=lambda c, t: progress_callback(c, t, filename)
        )
        print("\n  \033[32m✔ Completado\033[0m")

    print("\n\033[1;32m====================================================\033[0m")
    print("¡Descargas faltantes completadas con éxito!")
    print("====================================================\033[0m")
    print("\nAhora ejecuta \033[1;33mfixsims\033[0m -> Opción 1 para instalarlos en tu juego.")

if __name__ == "__main__":
    asyncio.run(main())
