@echo off
setlocal enabledelayedexpansion

:: === Auto-elevazione ad amministratore ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Richiesta permessi di amministratore...
    powershell -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)

title GTA V Mod Cleaner (ENB / ReShade / FiveM)
color 0A

echo ==================================================
echo   GTA V Mod Cleaner (ENB / ReShade / FiveM)
echo ==================================================
echo.

:: 1. Selezione directory
set /p "GTAPATH=Incolla il percorso della cartella GTA V: "
set "GTAPATH=!GTAPATH:"=!"

if not exist "!GTAPATH!" (
    color 0C
    echo.
    echo Errore: la cartella "!GTAPATH!" non esiste.
    echo.
    pause
    exit /b 1
)

:: ============================================
:: FASE 1 - Pulizia mod grafiche
:: ============================================
echo.
echo Scansione mod grafiche in: !GTAPATH!
echo.

set "FOUND=0"

echo --- Mod grafiche trovate ---
echo.

:: Controlla file
for %%F in (
    dxgi.dll
    d3d11.dll
    d3d9.dll
    d3dcompiler_46e.dll
    enbseries.ini
    enblocal.ini
    enbfeeder.ini
    enbfeeder.asi
    ReShade.ini
    ReShadePreset.ini
) do (
    if exist "!GTAPATH!\%%F" (
        echo   [FILE]     %%F
        set /a FOUND+=1
    )
)

:: Controlla cartelle
for %%D in (enbseries reshade-shaders shaderinput) do (
    if exist "!GTAPATH!\%%D\" (
        echo   [CARTELLA] %%D\
        set /a FOUND+=1
    )
)

echo.

if !FOUND! equ 0 (
    echo Nessun residuo di mod grafiche trovato. Gia' pulita!
) else (
    echo Trovati !FOUND! elementi da rimuovere.
    echo.
    set /p "CONFIRM=Vuoi eliminarli? (s/n): "

    if /i "!CONFIRM!"=="s" goto :DO_CLEAN
    if /i "!CONFIRM!"=="si" goto :DO_CLEAN
    if /i "!CONFIRM!"=="y" goto :DO_CLEAN

    echo.
    echo Pulizia mod grafiche saltata.
    goto :FIVEM_SECTION
)

:DO_CLEAN
echo.
echo --- Risultato mod grafiche ---
echo.

set "REMOVED=0"
set "ERRORS=0"

:: Elimina file
for %%F in (
    dxgi.dll
    d3d11.dll
    d3d9.dll
    d3dcompiler_46e.dll
    enbseries.ini
    enblocal.ini
    enbfeeder.ini
    enbfeeder.asi
    ReShade.ini
    ReShadePreset.ini
) do (
    if exist "!GTAPATH!\%%F" (
        del /f /q "!GTAPATH!\%%F" 2>nul
        if not exist "!GTAPATH!\%%F" (
            echo   [OK] %%F
            set /a REMOVED+=1
        ) else (
            echo   [!!] %%F - impossibile eliminare
            set /a ERRORS+=1
        )
    )
)

:: Elimina cartelle
for %%D in (enbseries reshade-shaders shaderinput) do (
    if exist "!GTAPATH!\%%D\" (
        rmdir /s /q "!GTAPATH!\%%D" 2>nul
        if not exist "!GTAPATH!\%%D\" (
            echo   [OK] %%D\
            set /a REMOVED+=1
        ) else (
            echo   [!!] %%D\ - impossibile eliminare
            set /a ERRORS+=1
        )
    )
)

echo.
echo Totale rimossi: !REMOVED!/!FOUND!
if !ERRORS! gtr 0 (
    color 0E
    echo Attenzione: !ERRORS! elementi non rimossi (file in uso?^)
)

:: ============================================
:: FASE 2 - Pulizia FiveM mods e plugins
:: ============================================
:FIVEM_SECTION
echo.
echo ==================================================
echo   Pulizia FiveM (mods e plugins)
echo ==================================================
echo.

:: Cerca la cartella FiveM nei percorsi comuni
set "FIVEM_APP="

if exist "%LocalAppData%\FiveM\FiveM.app" (
    set "FIVEM_APP=%LocalAppData%\FiveM\FiveM.app"
)

if not defined FIVEM_APP (
    echo FiveM non trovato in: %LocalAppData%\FiveM
    echo.
    set /p "FIVEM_CUSTOM=Inserisci il percorso di FiveM.app (o premi INVIO per saltare): "
    set "FIVEM_CUSTOM=!FIVEM_CUSTOM:"=!"
    if "!FIVEM_CUSTOM!"=="" goto :DONE
    if exist "!FIVEM_CUSTOM!" (
        set "FIVEM_APP=!FIVEM_CUSTOM!"
    ) else (
        echo Percorso non valido, salto pulizia FiveM.
        goto :DONE
    )
)

echo Cartella FiveM trovata: !FIVEM_APP!
echo.

set "FIVEM_FOUND=0"

:: Controlla mods
if exist "!FIVEM_APP!\mods\" (
    echo   [CARTELLA] mods\
    set /a FIVEM_FOUND+=1
)

:: Controlla plugins
if exist "!FIVEM_APP!\plugins\" (
    echo   [CARTELLA] plugins\
    set /a FIVEM_FOUND+=1
)

echo.

if !FIVEM_FOUND! equ 0 (
    echo Nessuna cartella mods/plugins trovata in FiveM. Gia' pulita!
    goto :DONE
)

echo Trovate !FIVEM_FOUND! cartelle FiveM.
echo ATTENZIONE: tutto il contenuto di mods\ e plugins\ verra' eliminato!
echo.
set /p "FCONFIRM=Vuoi svuotarle? (s/n): "

if /i "!FCONFIRM!"=="s" goto :DO_FIVEM
if /i "!FCONFIRM!"=="si" goto :DO_FIVEM
if /i "!FCONFIRM!"=="y" goto :DO_FIVEM

echo.
echo Pulizia FiveM saltata.
goto :DONE

:DO_FIVEM
echo.
echo --- Risultato FiveM ---
echo.

set "FREM=0"
set "FERR=0"

:: Svuota mods
if exist "!FIVEM_APP!\mods\" (
    del /f /s /q "!FIVEM_APP!\mods\*" >nul 2>&1
    for /d %%X in ("!FIVEM_APP!\mods\*") do rmdir /s /q "%%X" 2>nul
    echo   [OK] mods\ svuotata
    set /a FREM+=1
)

:: Svuota plugins
if exist "!FIVEM_APP!\plugins\" (
    del /f /s /q "!FIVEM_APP!\plugins\*" >nul 2>&1
    for /d %%X in ("!FIVEM_APP!\plugins\*") do rmdir /s /q "%%X" 2>nul
    echo   [OK] plugins\ svuotata
    set /a FREM+=1
)

echo.
echo Cartelle FiveM svuotate: !FREM!/!FIVEM_FOUND!

:: ============================================
:: FINE
:: ============================================
:DONE
echo.
echo ==================================================
color 0A
echo   Pulizia completata!
echo ==================================================
echo.
pause
