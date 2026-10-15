#!/usr/bin/env bash
# Deber 2 - Miguel Rayo e Italo Rodriguez. Bash 4+, Linux o WSL.
# Consultas de lectura; no requiere sudo. Uso: bash memoria.sh [directorio_salida]
set -uo pipefail
export LC_ALL=C
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
destino=${1:-"$base/reportes/linux"}
mkdir -p -- "$destino" || exit 1
equipo=$(hostname | tr -c '[:alnum:]_.-' '_' | sed 's/_$//')
salida="$destino/memoria_${equipo}.txt"
leer() { if [[ -r $1 ]]; then cat -- "$1"; else printf 'no disponible'; fi; }
a_bytes() {
    local valor=$1
    case "$valor" in
        *K) printf '%s' "$(( ${valor%K} * 1024 ))" ;;
        *M) printf '%s' "$(( ${valor%M} * 1024 * 1024 ))" ;;
        *G) printf '%s' "$(( ${valor%G} * 1024 * 1024 * 1024 ))" ;;
        *) printf '%s' "$valor" ;;
    esac
}
{
    echo 'DEBER 2 - REPORTE DE MEMORIA - LINUX'
    echo '== 1. Equipo, sistema y fecha =='
    printf 'Equipo: %s\nFecha: %s\n' "$(hostname)" "$(date --iso-8601=seconds)"
    if [[ -r /etc/os-release ]]; then
        # Archivo del sistema operativo; PRETTY_NAME es el nombre de distribucion.
        ( . /etc/os-release; printf 'SO: %s\n' "${PRETTY_NAME:-no disponible}" )
    fi
    uname -sr
    echo '== 2. Arquitectura y orden de bytes =='
    printf 'Arquitectura: %s\n' "$(uname -m)"
    if command -v lscpu >/dev/null 2>&1; then
        lscpu | awk -F: '/Byte Order/ {gsub(/^ +/, "", $2); print "Orden de bytes: " $2; visto=1} END {if (!visto) print "Orden de bytes: no reportado por lscpu"}'
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import sys; print("Orden de bytes: " + sys.byteorder + "-endian")'
    else echo 'Orden de bytes: no disponible'; fi
    echo '== 3. Caches y conjuntos de L1d =='
    echo 'Fuente: sysfs. C es capacidad POR instancia, no suma de todos los nucleos.'
    # Los mismos directorios aparecen en varios CPU. La lista de CPU compartidos
    # identifica una instancia y evita contar varias veces una cache compartida.
    declare -A vistas=() niveles=()
    cantidad=0
    shopt -s nullglob
    for ruta in /sys/devices/system/cpu/cpu[0-9]*/cache/index[0-9]*; do
        nivel=$(leer "$ruta/level"); tipo=$(leer "$ruta/type")
        compartida=$(leer "$ruta/shared_cpu_list")
        if [[ $compartida == 'no disponible' ]]; then compartida=$ruta; fi
        clave="$nivel|$tipo|$compartida"
        [[ ${vistas[$clave]+existe} ]] && continue
        vistas[$clave]=1; niveles["$nivel|$tipo"]=1
        cantidad=$((cantidad+1))
        capacidad=$(a_bytes "$(leer "$ruta/size")")
        linea=$(leer "$ruta/coherency_line_size")
        vias=$(leer "$ruta/ways_of_associativity")
        conjuntos=$(leer "$ruta/number_of_sets")
        nombre="L$nivel $tipo"
        [[ $nivel == 1 && $tipo == Data ]] && nombre=L1d
        [[ $nivel == 1 && $tipo == Instruction ]] && nombre=L1i
        printf '%s: C=%s bytes; A=%s vias; L=%s bytes; CPU compartidos=%s\n' "$nombre" "$capacidad" "$vias" "$linea" "$compartida"
        if [[ $nivel == 1 && ( $tipo == Data || $tipo == Unified ) ]]; then
            if [[ $capacidad =~ ^[0-9]+$ && $linea =~ ^[0-9]+$ && $vias =~ ^[0-9]+$ ]] && ((capacidad>0 && linea>0 && vias>0)); then
                if ((capacidad % (linea*vias) == 0)); then
                    calculado=$((capacidad/(linea*vias)))
                    printf '  S=C/(L*A)=%s/(%s*%s)=%s conjuntos; sysfs=%s\n' "$capacidad" "$linea" "$vias" "$calculado" "$conjuntos"
                else echo '  S: geometria no divisible; revisar los datos reportados.'; fi
            else echo '  S: no calculable; faltan C, L o A.'; fi
        fi
    done
    ((cantidad>0)) || echo 'Sysfs no expone caches (puede ocurrir en WSL o maquinas virtuales). S no calculable.'
    for par in '1|Data' '1|Instruction' '2|Unified' '3|Unified'; do
        [[ ${niveles[$par]+existe} ]] || printf 'Cache %s: no expuesta en sysfs.\n' "$par"
    done
    if command -v lscpu >/dev/null 2>&1; then
        echo 'Consulta de clase: lscpu --caches (ONE-SIZE es por instancia; ALL-SIZE es agregado)'
        lscpu --caches 2>&1 || echo 'Esta version de lscpu no admite --caches.'
    fi
    if command -v getconf >/dev/null 2>&1; then
        printf 'getconf LEVEL1_DCACHE_LINESIZE: '
        getconf LEVEL1_DCACHE_LINESIZE 2>&1 || true
    fi
    echo '== 4. RAM y swap =='
    if command -v free >/dev/null 2>&1; then free -b; else echo 'free no disponible'; fi
    echo 'Detalle del kernel en KiB (MemFree es libre; MemAvailable incluye memoria recuperable):'
    if [[ -r /proc/meminfo ]]; then
        awk '/^(MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree):/' /proc/meminfo
    else echo '/proc/meminfo no disponible'; fi
    echo '== 5. Discos =='
    echo 'ROTA=0: sin rotacion reportada (SSD); ROTA=1: rotacional (HDD).'
    echo 'En WSL/VM el disco puede ser virtual: ROTA no confirma el medio fisico del anfitrion.'
    if command -v lsblk >/dev/null 2>&1; then
        lsblk -d -b -o NAME,TYPE,ROTA,SIZE,MODEL 2>&1 || echo 'lsblk no pudo consultar los dispositivos.'
    else echo 'lsblk no disponible'; fi
    echo '== Fin =='
    echo 'Lecturas del entorno Linux actual. No se inventan datos que el SO no exponga.'
} 2>&1 | tee "$salida"
estado=${PIPESTATUS[1]}
((estado==0)) || exit "$estado"
printf 'Reporte guardado: %s\n' "$salida"
