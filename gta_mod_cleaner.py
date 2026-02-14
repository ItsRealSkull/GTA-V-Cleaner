"""
GTA V Mod Cleaner - Rimuove i residui di mod grafiche (ENB, ReShade)
dalla cartella di installazione di GTA V.

Uso: python gta_mod_cleaner.py
"""

import os
import shutil
import sys

# === Blacklist ===
BLACKLIST_FILES = [
    "dxgi.dll",
    "d3d11.dll",
    "d3d9.dll",
    "enbseries.ini",
    "enblocal.ini",
    "ReShade.ini",
]

BLACKLIST_DIRS = [
    "enbseries",
    "reshade-shaders",
]


def find_targets(gta_path: str) -> tuple[list[str], list[str]]:
    """Cerca file e cartelle della blacklist nella directory indicata."""
    found_files = []
    found_dirs = []

    for name in BLACKLIST_FILES:
        full = os.path.join(gta_path, name)
        if os.path.isfile(full):
            found_files.append(full)

    for name in BLACKLIST_DIRS:
        full = os.path.join(gta_path, name)
        if os.path.isdir(full):
            found_dirs.append(full)

    return found_files, found_dirs


def display_targets(files: list[str], dirs: list[str]) -> None:
    """Stampa l'elenco di cio' che verra' rimosso."""
    print("\n--- Elementi trovati ---")
    if files:
        print("\nFile:")
        for f in files:
            print(f"  - {os.path.basename(f)}")
    if dirs:
        print("\nCartelle:")
        for d in dirs:
            print(f"  - {os.path.basename(d)}/")
    print()


def delete_targets(files: list[str], dirs: list[str]) -> tuple[list[str], list[str]]:
    """Elimina i file e le cartelle. Restituisce (rimossi, errori)."""
    removed = []
    errors = []

    for f in files:
        try:
            os.remove(f)
            removed.append(os.path.basename(f))
        except OSError as e:
            errors.append(f"{os.path.basename(f)}: {e}")

    for d in dirs:
        try:
            shutil.rmtree(d)
            removed.append(f"{os.path.basename(d)}/")
        except OSError as e:
            errors.append(f"{os.path.basename(d)}/: {e}")

    return removed, errors


def main() -> None:
    print("=" * 50)
    print("  GTA V Mod Cleaner (ENB / ReShade)")
    print("=" * 50)

    # 1. Selezione directory
    if len(sys.argv) > 1:
        gta_path = sys.argv[1]
    else:
        gta_path = input("\nIncolla il percorso della cartella GTA V: ").strip().strip('"')

    if not os.path.isdir(gta_path):
        print(f"\nErrore: la cartella '{gta_path}' non esiste.")
        sys.exit(1)

    # 2. Ricerca
    print(f"\nScansione di: {gta_path}")
    files, dirs = find_targets(gta_path)

    if not files and not dirs:
        print("\nNessun residuo di mod trovato. La cartella e' gia' pulita!")
        sys.exit(0)

    # 3. Conferma
    display_targets(files, dirs)
    total = len(files) + len(dirs)
    answer = input(f"Vuoi eliminare {total} elemento/i? (s/n): ").strip().lower()

    if answer not in ("s", "si", "y", "yes"):
        print("\nOperazione annullata.")
        sys.exit(0)

    # 4. Eliminazione e log
    removed, errors = delete_targets(files, dirs)

    print("\n--- Risultato ---")
    if removed:
        print("\nRimossi con successo:")
        for r in removed:
            print(f"  [OK] {r}")
    if errors:
        print("\nErrori:")
        for e in errors:
            print(f"  [!!] {e}")

    print(f"\nTotale rimossi: {len(removed)}/{total}")
    print("Pulizia completata.\n")


if __name__ == "__main__":
    main()
