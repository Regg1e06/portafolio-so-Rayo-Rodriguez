#!/usr/bin/env bash
# =============================================================================
#  Deber 3 · Informe de arranque (Linux)             ESQUELETO COMPLETADO
#  Sistemas Operativos · EPN · Semana 3
# -----------------------------------------------------------------------------
#  Autores:   Miguel Rayo, Italo Rodriguez
#  Fecha:     2026-10-27
#  Uso de IA: ChatGPT/Codex para explicar comandos, completar y depurar los scripts.
# -----------------------------------------------------------------------------
#  Qué debe hacer: reunir en un archivo de texto cómo arrancó esta máquina.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte D).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       chmod +x informe_arranque.sh && ./informe_arranque.sh
#             (no debe necesitar sudo)
#  Entrega:   guárdalo como semana03/informe_arranque.sh en el repositorio
#             de la pareja y súbelo a GitHub (instrucciones al final).
#
#  Cómo completar: reemplaza cada línea «echo "PENDIENTE ..."» por los comandos
#  que piden las pistas. Ejecuta el script después de cada sección.
# =============================================================================

set -u

BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DIRECTORIO="${1:-$BASE/reportes/linux}"
mkdir -p -- "$DIRECTORIO" || exit 1
EQUIPO="$(hostname -s 2>/dev/null || echo equipo)"
EQUIPO="${EQUIPO//[^a-zA-Z0-9_.-]/_}"
SALIDA="$DIRECTORIO/informe_arranque_${EQUIPO}_$(date +%Y%m%d_%H%M%S_%N).txt"
consulta() {
    if ! tiene "$1"; then printf 'AVISO: no está disponible %s\n' "$1"; return 0; fi
    "$@" 2>&1 || printf 'AVISO: consulta sin datos o sin permiso (estado %s).\n' "$?"
}

titulo() {
    printf '\n=== %s ===\n' "$1"
}

tiene() {
    command -v "$1" >/dev/null 2>&1
}

# --- 1 · SO, versión y núcleo ------------------------- (Taller 2) ----------
seccion1() {
    titulo "1 · Sistema operativo, versión y núcleo"
    # Pista: el archivo /etc/os-release tiene la variable PRETTY_NAME.
    #        Puedes cargarlo con «. /etc/os-release» y luego usar $PRETTY_NAME.
    # Pista: «uname -r» da la versión del núcleo y «uname -m» la arquitectura.
    # 1. Distribución, núcleo y arquitectura reales.
    if [[ -r /etc/os-release ]]; then ( . /etc/os-release; printf 'Sistema: %s\n' "${PRETTY_NAME:-no disponible}" ); else echo 'AVISO: falta /etc/os-release'; fi
    consulta uname -r; consulta uname -m
}

# --- 2 · Último arranque y uptime --------------------- (Taller 2) ----------
seccion2() {
    titulo "2 · Último arranque y tiempo encendido"
    # Pista: «uptime -s» da la fecha y hora del arranque; «uptime -p», cuánto
    #        tiempo lleva encendida en palabras.
    # 2. Fecha del arranque y tiempo encendido.
    consulta uptime -s; consulta uptime -p
}

# --- 3 · Desglose del arranque ------------------------ (Taller 2) ----------
seccion3() {
    titulo "3 · Desglose del arranque (systemd-analyze)"
    # Pista: «systemd-analyze time» imprime una línea con el tiempo de cada
    #        etapa (kernel, initrd, userspace). Muestra esa línea.
    # Reto:  si systemd-analyze no existe (usa la función «tiene»), muestra un
    #        aviso en lugar de fallar.
    # 3. Desglose; en una VM firmware y loader pueden no estar expuestos.
    consulta systemd-analyze time
}

# --- 4 · Cinco unidades más lentas -------------------- (en casa) -----------
seccion4() {
    titulo "4 · Las 5 unidades que más tardaron en arrancar"
    # Pista: «systemd-analyze blame --no-pager» ordena las unidades de la más
    #        lenta a la más rápida. Quédate con las 5 primeras (head).
    # 4. Los cinco primeros son tiempo de activación, no prueba de causalidad.
    consulta systemd-analyze blame --no-pager | head -n 5
    echo 'Cadena crítica (complementa blame):'
    consulta systemd-analyze critical-chain --no-pager
}

# --- 5 · Módulos del núcleo --------------------------- (en casa) -----------
seccion5() {
    titulo "5 · Módulos del núcleo cargados"
    # Pista: «lsmod» lista los módulos; la primera línea es el encabezado.
    #        Cuenta los módulos (tail -n +2, wc -l) y muestra los 5 de mayor
    #        tamaño (columna 2: sort -k2,2 -n -r).
    # 5. Contar solo filas de módulos, excluyendo la cabecera de lsmod.
    if tiene lsmod; then
        modulos="$(lsmod 2>&1)"; estado=$?
        if (( estado == 0 )); then
            printf '%s\n' "$modulos" | awk 'END {print "Total de módulos: " NR-1}'
            echo 'Cinco más grandes por tamaño declarado (bytes):'
            printf '%s\n' "$modulos" | head -n 1
            printf '%s\n' "$modulos" | tail -n +2 | sort -k2,2nr | head -n 5
        else printf 'AVISO lsmod: %s\n' "$modulos"; fi
    else echo 'AVISO: lsmod no disponible (paquete kmod).'; fi
}

# --- 6 · Target por defecto y servicios fallidos ------ (en casa) -----------
seccion6() {
    titulo "6 · Target por defecto y servicios fallidos"
    # Pista: «systemctl get-default» da el target con el que arranca.
    #        «systemctl --failed --no-legend --plain» lista los servicios que
    #        fallaron. Si no hay ninguno, escribe «ninguno».
    # 6. Target predeterminado y unidades fallidas; no modifica servicios.
    consulta systemctl get-default
    if tiene systemctl; then
        fallidos="$(systemctl --failed --no-legend --plain --no-pager 2>&1)"; estado=$?
        if (( estado != 0 )); then printf 'AVISO: %s\n' "$fallidos"
        elif [[ -z "$fallidos" ]]; then echo 'Servicios fallidos: ninguno'
        else printf '%s\n' "$fallidos"; fi
    else echo 'AVISO: systemctl no disponible.'; fi
}

{
    echo "Informe de arranque · $EQUIPO · $(date '+%Y-%m-%d %H:%M')"
    echo "Autores: Miguel Rayo, Italo Rodriguez | IA: ChatGPT/Codex para completar y depurar scripts."
    seccion1
    seccion2
    seccion3
    seccion4
    seccion5
    seccion6
} | tee "$SALIDA"

echo
echo "Informe guardado en: $SALIDA"

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana03/informe_arranque.sh
#    git commit -m "Semana 3: informe de arranque (Linux), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------
