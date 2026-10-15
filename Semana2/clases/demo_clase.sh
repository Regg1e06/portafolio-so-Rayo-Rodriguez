#!/usr/bin/env bash
# Un solo script para datos, volcado hex, ensamblador y matriz. Linux/WSL.
set -uo pipefail
export LC_ALL=C
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
destino=${1:-"$base/../reportes/linux"}
mkdir -p -- "$destino" "$base/generados" || exit 1
estado=0
{
    echo 'DEMO DE CLASE - LINUX'
    date --iso-8601=seconds
    if command -v python3 >/dev/null 2>&1; then
        python3 "$base/datos.py" "$base/generados" || estado=1
    else echo 'PENDIENTE: falta python3 para la demo de datos.'; estado=1; fi
    echo '== Volcados de los archivos creados =='
    if command -v xxd >/dev/null 2>&1; then
        for nombre in t.txt n.bin datos.bin; do
            echo "xxd $nombre"
            if [[ -f "$base/generados/$nombre" ]]; then xxd "$base/generados/$nombre" || estado=1; fi
        done
    else echo 'PENDIENTE: falta xxd.'; estado=1; fi
    if command -v gcc >/dev/null 2>&1; then
        echo '== Ensamblador generado para suma.c =='
        gcc --version | head -n 1
        # -masm=intel solo se admite en x86; ARM genera su sintaxis nativa.
        opciones=()
        case $(uname -m) in x86_64|i?86) opciones=(-masm=intel);; esac
        if gcc -S -O0 "${opciones[@]}" "$base/suma.c" -o "$base/generados/suma_O0.s"; then
            cat "$base/generados/suma_O0.s"
        else estado=1; fi
        echo '== Matriz por filas y por columnas =='
        echo 'gcc -std=c11 -Wall -Wextra -O0 matriz.c -o matriz'
        if gcc -std=c11 -Wall -Wextra -O0 "$base/matriz.c" -o "$base/generados/matriz"; then
            "$base/generados/matriz" || estado=1
            "$base/generados/matriz" c || estado=1
        else estado=1; fi
        echo 'Clock mide tiempo de CPU en Linux. Una muestra no demuestra una proporcion fija.'
    else echo 'PENDIENTE: falta gcc para ensamblador y matriz.'; estado=1; fi
    echo "Estado de demos: $estado (0=completas; 1=revisar dependencias o errores)"
    exit "$estado"
} 2>&1 | tee "$destino/salida_clase_linux.txt"
estados=("${PIPESTATUS[@]}")
((estados[1]==0)) || exit "${estados[1]}"
exit "${estados[0]}"
