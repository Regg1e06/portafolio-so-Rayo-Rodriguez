#!/usr/bin/env bash
# Miguel Rayo e Italo Rodríguez | Sistemas Operativos GR1 | 16/11/2026
# IA: Codex apoyó la redacción, implementación y comprobación del script.

usage() {
    printf 'Uso: %s [-m bitácora] [-u umbral] [-o informe]\n' "$0"
}

muestra=''
umbral=5
informe=''
while getopts ':m:u:o:h' opcion; do
    case "$opcion" in
        m) muestra=$OPTARG ;;
        u) umbral=$OPTARG ;;
        o) informe=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
if (( $# )) || [[ ! $umbral =~ ^[1-9][0-9]{0,8}$ ]]; then
    usage >&2
    exit 1
fi
if [[ -n $muestra && ! -f $muestra ]]; then
    printf 'Muestra inexistente: %s\n' "$muestra" >&2
    exit 1
fi
if [[ -z $informe ]]; then
    informe=$(mktemp --suffix=.txt "auditoria_linux_$(date +%Y%m%d_%H%M%S)_XXXXXX") || exit 1
fi
if [[ -n $muestra && $muestra -ef $informe ]]; then
    echo 'La muestra y el informe deben ser archivos distintos.' >&2
    exit 1
fi

llavero() {
    # Cualquier cuenta adicional con UID 0 tiene privilegios de root.
    local uid0 grupo
    uid0=$(awk -F: '$3 == 0 {print $1}' /etc/passwd) || return 1
    grupo=$(getent group wheel) || { echo 'Grupo wheel no disponible.'; return 1; }
    printf 'UID 0: %s\nGrupo: %s\n' "$(paste -sd, <<< "$uid0")" "$grupo"
    [[ $uid0 == root ]]
}

puertas() {
    # La exposición se determina por la dirección de escucha.
    local escucha riesgos
    escucha=$(ss -H -tln) || return 1
    printf 'Sockets TCP en escucha: %s\n' "$(awk 'NF {n++} END {print n+0}' <<< "$escucha")"
    awk 'NF {print "  " $4}' <<< "$escucha"
    riesgos=$(awk '$4 ~ /:(21|23|3306|3389|5900)$/ && $4 !~ /^(127\.|\[::1\]:|\[::ffff:127\.)/ {print $4}' <<< "$escucha")
    printf 'Escuchas de riesgo fuera de loopback: %s\n' "${riesgos:-ninguna}"
    [[ -z $riesgos ]]
}

portero() {
    # Se requiere firewalld activo.
    local estado
    estado=$(systemctl is-active firewalld)
    printf 'firewalld: %s\n' "${estado:-sin lectura}"
    [[ $estado == active ]]
}

fallos() {
    # Se cuentan fallos de contraseña SSH por IP, incluido usuario inválido.
    local datos resumen
    if [[ -n $muestra ]]; then
        printf 'Fuente: muestra %s\n' "$(basename -- "$muestra")"
        datos=$(cat -- "$muestra") || return 1
    else
        echo 'Fuente: journal de sshd de las últimas 24 h'
        if ! datos=$(LC_ALL=C journalctl -u sshd --since '24 hours ago' -o cat --no-pager 2>&1); then
            printf '%s\n' "$datos"
            return 1
        fi
        if [[ $datos == *'You are currently not seeing'* || $datos == *'insufficient permissions'* ]]; then
            echo 'Bitácora incompleta. Use -m para consultar una muestra.'
            return 1
        fi
    fi
    resumen=$(awk '/Failed password/ {for (i=1; i<NF-1; i++) if ($i=="from" && $(i+2)=="port") {print $(i+1); break}}' <<< "$datos" | sort | uniq -c | sort -k1,1nr -k2,2)
    printf 'Umbral: %s\nFallos por IP:\n%s\n' "$umbral" "${resumen:-ninguno}"
    awk -v limite="$umbral" '$1 >= limite {print "Alerta para " $2; alerta=1} END {exit alerta}' <<< "$resumen"
}

auditar() {
    local numero=0 estado veredicto=0 funcion
    local -a estados=()
    printf 'Auditoría de seguridad | Linux | %s\n' "$(date -Is)"
    for funcion in llavero puertas portero fallos; do
        ((numero += 1))
        printf '\n[%s] %s\n' "$numero" "$funcion"
        if "$funcion"; then estado=OK; else estado=ALERTA; veredicto=1; fi
        printf '→ Sección %s: %s\n' "$numero" "$estado"
        estados+=("$numero=$estado")
    done
    printf '\n[5] Veredicto\n%s\n' "${estados[*]}"
    if (( veredicto )); then echo 'Resultado: ALERTA'; else echo 'Resultado: OK'; fi
    printf 'Código de salida: %s\n' "$veredicto"
    return "$veredicto"
}

auditar | tee -- "$informe"
estado_pipeline=("${PIPESTATUS[@]}")
if (( estado_pipeline[1] != 0 )); then exit 1; fi
exit "${estado_pipeline[0]}"
