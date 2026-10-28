#!/usr/bin/env bash
# Autores: Miguel Rayo, Italo Rodriguez | 2026-10-27
# IA: ChatGPT/Codex para automatizar la captura de resultados.
set -u
BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$BASE/reportes/linux" || exit 1
equipo="$(hostname)"; equipo="${equipo//[^a-zA-Z0-9_.-]/_}"
log="$BASE/reportes/linux/talleres_${equipo}_$(date +%Y%m%d_%H%M%S_%N).txt"
bash "$BASE/informe_arranque.sh" || exit 1
bash "$BASE/talleres_linux.sh" >"$log" 2>&1
estado=$?
cat "$log"
echo "Resultados de talleres: $log"
exit "$estado"
