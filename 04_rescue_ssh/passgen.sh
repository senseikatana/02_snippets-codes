#!/usr/bin/env zsh

pgen() {
    local -a FW=("agua" "arbol" "arena" "barco" "brisa" "cielo" "cueva" "disco" "duna" "fuego" "gato" "globo" "hoja" "humo" "isla" "lago" "lluvia" "luna" "mapa" "monte" "nieve" "nube" "onda" "papel" "piedra" "pino" "pluma" "rayo" "rio" "roca" "selva" "sol" "suelo" "tierra" "torre" "viento" "vuelo" "valle" "verde" "vida" "azul" "rojo" "claro" "oscuro" "fuerte" "suave" "rapido" "lento" "alto" "bajo" "acid" "apex" "atom" "bark" "beam" "bolt" "brisk" "calm" "clay" "coal" "dawn" "deep" "dusk" "echo" "fade" "flow" "flux" "glen" "glow" "halo" "haze" "iron" "jade" "lava" "leaf" "lime" "mist" "neon" "nova" "opal" "path" "pure" "rain" "reef" "rift" "rust" "sand" "shadow" "silk" "silt" "snow" "star" "surf" "tide" "vale" "vast" "wave" "wild" "wind" "zinc")
    local t="secure" l="" c="" q=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -S) t="secure";; -M) t="matricula";; -A) t="alphanumeric";;
            -N) t="numeric";; -X) t="memorable";;
            -h) echo "Uso: pgen [longitud] [cantidad] [qty] [-S|-M|-A|-N|-X|-h]"; return 0;;
            -*) echo "Flag inválido: $1" >&2; return 1;;
            *) [[ -z "$l" ]] && l="$1" || { [[ -z "$c" ]] && c="$1" || q="$1"; };;
        esac; shift
    done

    [[ -z "$l" ]] && l=$(( t == "numeric" ? 6 : 16 ))
    [[ -z "$c" ]] && c=1
    [[ -z "$q" ]] && q=$(( t == "memorable" ? 4 : 1 ))

    local i j
    for (( i=0; i<c; i++ )); do
        case "$t" in
            matricula)
                local res="" cons="BCDFGHJKLMNPQRSTVWXYZ" digs="0123456789"
                for (( j=0; j<4; j++ )); do res+="${digs[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % 10 + 1 ))]}"; done
                for (( j=0; j<3; j++ )); do res+="${cons[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % 21 + 1 ))]}"; done
                echo "$res" ;;
            secure|alphanumeric|numeric)
                local low="abcdefghijklmnopqrstuvwxyz" up="ABCDEFGHIJKLMNOPQRSTUVWXYZ" num="0123456789"
                local sym='!@#$%^&*()_+-=[]{}|;:,.<>?' pool=""
                [[ "$t" == "numeric" ]] && pool="$num" || pool="${low}${up}${num}"
                [[ "$t" == "secure" ]] && pool+="$sym"
                local plen=${#pool} pwd="" hl=0 hu=0 hn=0 hs=0
                while true; do
                    pwd="" hl=0 hu=0 hn=0 hs=0
                    for (( j=0; j<l; j++ )); do
                        local ch="${pool[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % plen + 1 ))]}"
                        pwd+="$ch"
                        [[ "$ch" == [a-z] ]] && hl=1; [[ "$ch" == [A-Z] ]] && hu=1
                        [[ "$ch" == [0-9] ]] && hn=1; [[ "$ch" == [^a-zA-Z0-9] ]] && hs=1
                    done
                    if [[ "$t" == "numeric" ]] || \
                       { [[ "$t" == "alphanumeric" ]] && (( hl && hu && hn )); } || \
                       { [[ "$t" == "secure" ]] && (( hl && hu && hn && hs )); }; then
                        echo "$pwd"; break
                    fi
                done ;;
            memorable)
                local -a words=() p
                for p in /usr/share/dict/words /etc/dictionaries-common/words /usr/dict/words; do
                    [[ -f "$p" ]] && words=( ${(f)"$(awk '/^[a-z]{4,8}\r?$/ {sub(/\r/, ""); print}' "$p" 2>/dev/null)"} ) && (( ${#words[@]} > 0 )) && break
                done
                (( ${#words[@]} == 0 )) && words=( "${FW[@]}" )
                local wlen=${#words[@]} -a sel=()
                typeset -A picked
                while (( ${#sel[@]} < q )); do
                    local w="${words[$(( $(od -An -N4 -tu4 /dev/urandom | tr -d ' ') % wlen + 1 ))]}"
                    [[ -z "${picked[$w]}" ]] && { picked[$w]=1; sel+=("$w"); }
                done
                echo ${(j:-:)sel} ;;
        esac
    done
}