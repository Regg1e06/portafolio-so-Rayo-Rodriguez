#!/usr/bin/env bash
# Desde Linux/WSL, una sola ejecucion guarda memoria y todas las demos.
set -uo pipefail
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
mkdir -p -- "$base/reportes/linux" || exit 1
{
    echo 'EJECUCION COMPLETA - SEMANA 2 - LINUX'
    date --iso-8601=seconds
    estado=0
    bash "$base/memoria.sh" "$base/reportes/linux" || estado=1
    bash "$base/clases/demo_clase.sh" "$base/reportes/linux" || estado=1
    echo "Estado final: $estado (0=terminado; 1=revisar el reporte)"
    exit "$estado"
} 2>&1 | tee "$base/reportes/linux/salida_todo_linux.txt"
estados=("${PIPESTATUS[@]}")
((estados[1]==0)) || exit "${estados[1]}"
exit "${estados[0]}"
