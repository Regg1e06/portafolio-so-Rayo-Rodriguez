#!/usr/bin/env bash
# Deber 4 · Verificador de entorno · Sistemas Operativos GR1 · EPN
# Autores: Miguel Rayo e Italo Rodríguez
# Fecha: 2026-11-15
# Uso de IA: ChatGPT/Codex apoyó la implementación, adaptación a Ubuntu y pruebas.
# Uso: bash verificador_entorno.sh. Guarda el informe en el directorio actual.
# Salida: 0 si están todas las herramientas, 1 si falta alguna o falla el informe.

set -u
export LC_ALL=C
equipo=$(hostname -s 2>/dev/null || printf equipo)
salida=$(mktemp -- "./verificador_${equipo}_$(date +%Y%m%d_%H%M%S)_XXXXXX.txt") || exit 1
requeridas=(git curl python3 jq strace tree)
faltan=()
declare -A rutas=()
gestor=''
[[ -r /etc/os-release ]] && . /etc/os-release
if command -v dnf >/dev/null && command -v rpm >/dev/null; then
    gestor=dnf
elif command -v dpkg-query >/dev/null; then
    gestor=apt
fi

titulo() { printf '\n=== %s ===\n' "$1"; }

# 1. Identifica el sistema, su núcleo y el intérprete actual.
seccion1() {
    titulo '1 · Sistema y shell'
    printf 'Sistema: %s\nNúcleo: %s\nBash: %s\nUsuario: %s\n' \
        "${PRETTY_NAME:-Linux}" "$(uname -r)" "$BASH_VERSION" "$(id -un)"
}

# 2. Localiza cada ejecutable y verifica que puede devolver su versión.
seccion2() {
    titulo '2 · Herramientas requeridas'
    printf '%-10s %-8s %-24s %s\n' Comando Estado Ruta Versión
    local comando ruta version opcion
    for comando in "${requeridas[@]}"; do
        opcion=--version
        [[ $comando == strace ]] && opcion=-V
        if ruta=$(type -P "$comando"); then
            rutas[$comando]=$ruta
            if version=$("$ruta" "$opcion" 2>&1); then
                printf '%-10s %-8s %-24s %s\n' "$comando" OK "$ruta" "${version%%$'\n'*}"
                continue
            fi
            printf '%-10s %-8s %-24s %s\n' "$comando" FALTA "$ruta" 'Falló la consulta de versión'
        else
            printf '%-10s %-8s %s\n' "$comando" FALTA 'Fuera del PATH'
        fi
        faltan+=("$comando")
    done
}

# 3. Consulta paquetes, repositorios y el dueño de cada ejecutable.
seccion3() {
    titulo '3 · Paquetes y orígenes'
    local comando ruta paquete registro origen
    case "$gestor" in
        dnf)
            printf 'Paquetes RPM instalados: '
            rpm -qa | wc -l
            dnf -q -C repolist --enabled || printf 'AVISO: repositorios DNF no disponibles.\n'
            ;;
        apt)
            printf 'Paquetes dpkg instalados: '
            dpkg-query -W -f='${db:Status-Status}\n' | awk '$1 == "installed" {n++} END {print n+0}'
            printf 'Orígenes visibles en caché de APT:\n'
            apt-cache policy | awk '/^Pinned packages:/{exit} {print}'
            ;;
        *)
            printf 'AVISO: no se encontró DNF/RPM ni APT/dpkg.\n'
            return
            ;;
    esac
    printf '\nPropietarios de los ejecutables detectados:\n'
    for comando in "${requeridas[@]}"; do
        ruta=${rutas[$comando]:-}
        [[ -n $ruta ]] || continue
        if [[ $gestor == dnf ]]; then
            if paquete=$(rpm -qf --qf '%{NAME}\n' "$ruta" 2>/dev/null); then
                printf '%s → %s\n' "$comando" "$paquete"
                origen=$(dnf -q -C info --installed "$paquete" 2>/dev/null |
                    awk '/^From repo[[:space:]]*:/{print}')
                printf '  %s\n' "${origen:-Origen sin registro disponible}"
            else
                printf '%s → sin propietario RPM para %s\n' "$comando" "$ruta"
            fi
        else
            if registro=$(dpkg-query -S "$ruta" 2>/dev/null) ||
               registro=$(dpkg-query -S "$(readlink -f "$ruta")" 2>/dev/null); then
                paquete=${registro%%: *}
                printf '%s → %s\n' "$comando" "$paquete"
                # La política indica las fuentes disponibles para cada versión.
                apt-cache policy "$paquete" | sed 's/^/  /'
            else
                printf '%s → sin propietario dpkg para %s\n' "$comando" "$ruta"
            fi
        fi
    done
}

# 4. Muestra las cinco transacciones DNF o eventos de instalación dpkg más recientes.
seccion4() {
    titulo '4 · Últimas 5 instalaciones de paquetes'
    local historial registro
    case "$gestor" in
        dnf)
            if historial=$(dnf -q -C history list 2>&1); then
                printf '%s\n' "$historial" | awk -F '|' '
                    $1 ~ /^[[:space:]]*[0-9]+[[:space:]]*$/ {
                        if (tolower($4) ~ /install|(^|[ ,])i([ ,]|$)/) {
                            print
                            if (++n == 5) exit
                        }
                        next
                    }
                    { print }
                    END { if (!n) print "Sin instalaciones visibles en el historial." }
                '
            else
                printf 'AVISO: historial DNF no disponible.\n%s\n' "$historial"
            fi
            ;;
        apt)
            historial=$(
                for registro in /var/log/dpkg.log /var/log/dpkg.log.[0-9]*; do
                    [[ -r $registro ]] || continue
                    case "$registro" in
                        *.gz) gzip -cd -- "$registro" 2>/dev/null ;;
                        *) cat -- "$registro" ;;
                    esac
                done | awk '$3 == "install"' | sort -r | head -n 5
            )
            printf '%s\n' "${historial:-Sin eventos de instalación visibles en dpkg.}"
            ;;
        *) printf 'AVISO: historial no disponible sin un gestor compatible.\n' ;;
    esac
}

# 5. Propone un solo comando para instalar todas las herramientas faltantes.
seccion5() {
    titulo '5 · Qué falta y cómo instalarlo'
    if (( ${#faltan[@]} == 0 )); then
        printf 'Todas las herramientas requeridas están disponibles.\n'
        return
    fi
    printf 'Herramientas faltantes: %s\n' "${faltan[*]}"
    case "$gestor" in
        dnf) printf 'sudo dnf install -y %s\n' "${faltan[*]}" ;;
        apt) printf 'sudo apt install -y %s\n' "${faltan[*]}" ;;
        *) printf 'Busca estos paquetes en el gestor de tu distribución: %s\n' "${faltan[*]}" ;;
    esac
}

# 6. Devuelve un estado que puede comprobar el shell que lo ejecutó.
seccion6() {
    titulo '6 · Resultado'
    local codigo=0
    (( ${#faltan[@]} > 0 )) && codigo=1
    printf 'Herramientas listas: %d de %d\nCódigo de salida: %d\n' \
        "$(( ${#requeridas[@]} - ${#faltan[@]} ))" "${#requeridas[@]}" "$codigo"
    return "$codigo"
}

principal() {
    printf 'Verificador de entorno · %s · %s\n' "$equipo" "$(date '+%Y-%m-%d %H:%M:%S %z')"
    seccion1
    seccion2
    seccion3
    seccion4
    seccion5
    seccion6
}

principal 2>&1 | tee -- "$salida"
estados=("${PIPESTATUS[@]}")
if (( estados[1] != 0 )); then
    printf 'AVISO: no se pudo completar el informe %s.\n' "$salida" >&2
    exit 1
fi
printf '\nInforme guardado en: %s\n' "$salida"
exit "${estados[0]}"
