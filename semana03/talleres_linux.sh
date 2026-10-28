#!/usr/bin/env bash
# Autores: Miguel Rayo, Italo Rodriguez | 2026-10-27
# IA: ChatGPT/Codex para adaptar los comandos a una ejecución en Ubuntu.
set -u
paso() { printf '\n=== %s ===\n' "$1"; shift; "$@" 2>&1 || echo "AVISO: consulta no disponible, estado $?"; }
echo "TALLERES LINUX | $(date --iso-8601=seconds) | $(hostname)"
paso 'A1 · Proceso 1' ps -p 1 -o pid,comm
paso 'A1 · Árbol' bash -c 'pstree -p | head -n 12'
paso 'A1 · CPU' nproc
paso 'A1 · Total de procesos' bash -c 'ps -e --no-headers | wc -l'
paso 'A2 · Servicios' bash -c 'systemctl list-units --type=service --state=running --no-pager | head -n 8; systemctl list-units --type=service --state=running --no-legend --no-pager | wc -l'
paso 'A3 · Memoria' free -h
paso 'A3 · Discos' lsblk
paso 'A4 · CPU' grep -m1 'model name' /proc/cpuinfo
paso 'A4 · Memoria del núcleo' head -n 3 /proc/meminfo
paso 'A4 · Uptime del núcleo' cat /proc/uptime
paso 'A4 · /proc' bash -c 'ls /proc | head'
paso 'A5 · Dispositivos' bash -c 'ls -l /dev/null /dev/tty; lsblk -dpno NAME | head -n 1 | xargs -r ls -l'
paso 'A6 · Ocio y espera de E/S (leer segunda muestra)' vmstat 1 2
echo; echo '=== B · Mediciones real / user / sys (segundos) ==='
TIMEFORMAT='real=%R user=%U sys=%S'
echo 'Espera automática: sleep 2 (sustituto identificado; no es evidencia del read manual).'
time sleep 2
echo 'Cálculo: bucle de 2 millones de iteraciones.'
time (for ((i=0;i<2000000;i++)); do :; done)
echo 'Lectura: find /usr -name *.conf (también depende de la caché y permisos).'
time find /usr -name '*.conf' >/dev/null 2>&1
echo 'Para cada medición: p=1-(user+sys)/real; n=ceil(log(0.1)/log(p)) si 0<p<1.'
paso 'Taller 2 · Registro del arranque' journalctl -b -p warning --no-pager -n 20
paso 'Taller 2 · Ficha del módulo dummy' bash -c 'modinfo dummy | head -n 4'
paso 'Taller 2 · Interfaces actuales' ip -brief link
echo 'Carga/descarga de dummy, read y programar/cancelar reinicio: PENDIENTE MANUAL; ver Practicas_manuales.md.'
