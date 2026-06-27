#!/usr/bin/env zsh
# ==============================================================================
# Password Generator Utility (Zsh Version)
# Generates cryptographically secure passwords of various types.
#
# Can be sourced to load the functions into your Zsh shell, or run directly:
#   chmod +x pgen.zsh
#   ./pgen.zsh -t secure -l 24 -c 3
# ==============================================================================

# Common words fallback for memorable passwords (Spanish and English mixed)
readonly FALLBACK_WORDS=(
    "agua" "arbol" "arena" "barco" "brisa" "cielo" "cueva" "disco" "duna" "fuego"
    "gato" "globo" "hoja" "humo" "isla" "lago" "lluvia" "luna" "mapa" "monte"
    "nieve" "nube" "onda" "papel" "piedra" "pino" "pluma" "rayo" "rio" "roca"
    "selva" "sol" "suelo" "tierra" "torre" "viento" "vuelo" "valle" "verde" "vida"
    "azul" "rojo" "claro" "oscuro" "fuerte" "suave" "rapido" "lento" "alto" "bajo"
    "acid" "apex" "atom" "bark" "beam" "bolt" "brisk" "calm" "clay" "coal"
    "dawn" "deep" "dusk" "echo" "fade" "flow" "flux" "glen" "glow" "halo"
    "haze" "iron" "jade" "lava" "leaf" "lime" "mist" "neon" "nova" "opal"
    "path" "pure" "rain" "reef" "rift" "rust" "sand" "shadow" "silk" "silt"
    "snow" "star" "surf" "tide" "vale" "vast" "wave" "wild" "wind" "zinc"
)

# Detect if the script is run directly or sourced
if [[ "${ZSH_EVAL_CONTEXT:-}" = "toplevel" ]]; then
    RUNNING_AS_SCRIPT=true
else
    RUNNING_AS_SCRIPT=false
fi

# ==============================================================================
# SECURE RANDOMNESS HELPERS
# ==============================================================================

# Generates a cryptographically secure random integer between min and max (inclusive).
# Uses /dev/urandom via the 'od' command-line utility.
#
# Arguments:
#   $1 - min: Minimum value of the range
#   $2 - max: Maximum value of the range
get_secure_random_int() {
    local min=$1
    local max=$2
    local range=$((max - min + 1))
    
    # Read 4 bytes from /dev/urandom and convert to an unsigned decimal number
    local rand_val
    rand_val=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
    
    # Apply modulo to project into the range, then offset by min
    local result=$(( (rand_val % range) + min ))
    echo "$result"
}

# ==============================================================================
# PASSWORD GENERATION FUNCTIONS
# ==============================================================================

# Generates a vehicle-plate-like password: 4 digits + 3 consonants (e.g. 1234BCD).
# Vowels are excluded to avoid creating real words.
# Multiple blocks can be generated and are joined by hyphens.
#
# Arguments:
#   $1 - qty: Number of blocks to generate (default: 1)
generate_matricula() {
    local qty=${1:-1}
    local consonants="BCDFGHJKLMNPQRSTVWXYZ"
    local digits="0123456789"
    local -a results
    typeset -A generated
    
    while (( ${#results[@]} < qty )); do
        local num=""
        local letPart=""
        local i
        
        # Select 4 random digits
        for (( i=0; i<4; i++ )); do
            local rand_idx=$(get_secure_random_int 1 10)
            num="${num}${digits[$rand_idx]}"
        done
        
        # Select 3 random consonants
        for (( i=0; i<3; i++ )); do
            local rand_idx=$(get_secure_random_int 1 21)
            letPart="${letPart}${consonants[$rand_idx]}"
        done
        
        local plate="${num}${letPart}"
        
        # Ensure uniqueness across the generated blocks
        if [[ -z "${generated[$plate]}" ]]; then
            generated[$plate]=1
            results+=("$plate")
        fi
    done
    
    # Join array elements with hyphens
    echo ${(j:-:)results}
}

# Generates a highly secure password containing lowercase, uppercase, digits, and symbols.
# Guarantees that at least one of each class is present (for lengths >= 4).
#
# Arguments:
#   $1 - length: Total length of the password (default: 16)
generate_secure() {
    local length=${1:-16}
    local lowercase="abcdefghijklmnopqrstuvwxyz"
    local uppercase="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local digits="0123456789"
    local symbols='!@#$%^&*()_+-=[]{}|;:,.<>?'
    local all_chars="${lowercase}${uppercase}${digits}${symbols}"
    local all_chars_len=${#all_chars}
    
    # For very short passwords, generate without strict composition checks
    if (( length < 4 )); then
        local res=""
        local i
        for (( i=0; i<length; i++ )); do
            local rand_idx=$(get_secure_random_int 1 $all_chars_len)
            res="${res}${all_chars[$rand_idx]}"
        done
        echo "$res"
        return
    fi
    
    # Keep generating until composition criteria are met
    while true; do
        local pwd=""
        local i
        for (( i=0; i<length; i++ )); do
            local rand_idx=$(get_secure_random_int 1 $all_chars_len)
            pwd="${pwd}${all_chars[$rand_idx]}"
        done
        
        local has_lower=0
        local has_upper=0
        local has_digit=0
        local has_symbol=0
        
        [[ "$pwd" == *[a-z]* ]] && has_lower=1
        [[ "$pwd" == *[A-Z]* ]] && has_upper=1
        [[ "$pwd" == *[0-9]* ]] && has_digit=1
        # If it contains a non-alphanumeric character, it must be a symbol
        [[ "$pwd" == *[^a-zA-Z0-9]* ]] && has_symbol=1
        
        if (( has_lower && has_upper && has_digit && has_symbol )); then
            echo "$pwd"
            return
        fi
    done
}

# Generates an alphanumeric password (lowercase + uppercase + digits).
# Guarantees that at least one of each class is present (for lengths >= 3).
#
# Arguments:
#   $1 - length: Total length of the password (default: 16)
generate_alphanumeric() {
    local length=${1:-16}
    local lowercase="abcdefghijklmnopqrstuvwxyz"
    local uppercase="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local digits="0123456789"
    local all_chars="${lowercase}${uppercase}${digits}"
    local all_chars_len=${#all_chars}
    
    if (( length < 3 )); then
        local res=""
        local i
        for (( i=0; i<length; i++ )); do
            local rand_idx=$(get_secure_random_int 1 $all_chars_len)
            res="${res}${all_chars[$rand_idx]}"
        done
        echo "$res"
        return
    fi
    
    while true; do
        local pwd=""
        local i
        for (( i=0; i<length; i++ )); do
            local rand_idx=$(get_secure_random_int 1 $all_chars_len)
            pwd="${pwd}${all_chars[$rand_idx]}"
        done
        
        local has_lower=0
        local has_upper=0
        local has_digit=0
        
        [[ "$pwd" == *[a-z]* ]] && has_lower=1
        [[ "$pwd" == *[A-Z]* ]] && has_upper=1
        [[ "$pwd" == *[0-9]* ]] && has_digit=1
        
        if (( has_lower && has_upper && has_digit )); then
            echo "$pwd"
            return
        fi
    done
}

# Generates a numeric PIN / password.
#
# Arguments:
#   $1 - length: Total length of the password (default: 16)
generate_numeric() {
    local length=${1:-16}
    local digits="0123456789"
    local res=""
    local i
    for (( i=0; i<length; i++ )); do
        local rand_idx=$(get_secure_random_int 1 10)
        res="${res}${digits[$rand_idx]}"
    done
    echo "$res"
}

# Generates a memorable xkcd-style password: lowercase words joined by hyphens.
# Attempts to load system dictionaries and falls back to hardcoded words if unavailable.
#
# Arguments:
#   $1 - qty: Number of words to join (default: 4)
generate_memorable() {
    local qty=${1:-4}
    local -a words
    local paths=( '/usr/share/dict/words' '/etc/dictionaries-common/words' '/usr/dict/words' )
    local p
    local loaded=0
    
    # Find and load the first matching system dictionary
    for p in "${paths[@]}"; do
        if [[ -f "$p" ]]; then
            # Read and filter: lowercase only, length 4 to 8, strip carriage returns (CRLF)
            words=( ${(f)"$(awk '/^[a-z]{4,8}\r?$/ {sub(/\r/, ""); print}' "$p" 2>/dev/null)"} )
            if (( ${#words[@]} > 0 )); then
                loaded=1
                break
            fi
        fi
    done
    
    if [[ $loaded -eq 0 ]]; then
        words=( "${FALLBACK_WORDS[@]}" )
    fi
    
    local words_len=${#words[@]}
    local -a selected
    local i
    
    if (( words_len >= qty )); then
        # Select unique random words (without replacement)
        typeset -A picked
        while (( ${#selected[@]} < qty )); do
            local rand_idx=$(get_secure_random_int 1 $words_len)
            local word="${words[$rand_idx]}"
            if [[ -z "${picked[$word]}" ]]; then
                picked[$word]=1
                selected+=("$word")
            fi
        done
    else
        # Fallback to choices with replacement if pool is smaller than requested qty
        for (( i=0; i<qty; i++ )); do
            local rand_idx=$(get_secure_random_int 1 $words_len)
            selected+=("${words[$rand_idx]}")
        done
    fi
    
    # Join words with hyphens
    echo ${(j:-:)selected}
}

# Dispatches the generation to the matching password type function.
#
# Arguments:
#   $1 - type: Type of password: 'matricula', 'secure', 'alphanumeric', 'numeric', 'memorable'
#   $2 - length: Length of the password (for secure, alphanumeric, numeric; default: 16)
#   $3 - qty: Number of blocks/words (for matricula, memorable; default: 1 or 4)
generate_password() {
    local type="$1"
    local length="${2:-16}"
    local qty="${3:-1}"
    
    case "$type" in
        matricula)
            generate_matricula "$qty"
            ;;
        secure)
            generate_secure "$length"
            ;;
        alphanumeric)
            generate_alphanumeric "$length"
            ;;
        numeric)
            generate_numeric "$length"
            ;;
        memorable)
            generate_memorable "$qty"
            ;;
        *)
            echo "Error: Unknown password type '$type'" >&2
            return 1
            ;;
    esac
}

# ==============================================================================
# CLI EXECUTION ENTRY POINT
# ==============================================================================

show_help() {
    cat << EOF
Cryptographically Secure Password Generator (Zsh Version)
Usage: ./pgen.zsh [options]

Options:
  -t, --type <type>      Password type: matricula, secure, alphanumeric, numeric, memorable (default: secure)
  -l, --length <len>     Length of password for secure/alphanumeric/numeric (default: 16, or 6 for numeric)
  -q, --qty <qty>        Number of blocks/words for matricula/memorable (default: 1 for matricula, 4 for memorable)
  -c, --count <count>    Number of passwords to generate (default: 1)
  -h, --help             Show this help message
EOF
}

main() {
    local type="secure"
    local length=""
    local qty=""
    local count=1
    
    # Parse arguments manually
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--type)
                type="$2"
                shift 2
                ;;
            -l|--length)
                length="$2"
                shift 2
                ;;
            -q|--qty)
                qty="$2"
                shift 2
                ;;
            -c|--count)
                count="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Error: Unknown argument '$1'" >&2
                show_help >&2
                exit 1
                ;;
        esac
    done
    
    # Validate type
    if [[ "$type" != "matricula" && "$type" != "secure" && "$type" != "alphanumeric" && "$type" != "numeric" && "$type" != "memorable" ]]; then
        echo "Error: Type must be matricula, secure, alphanumeric, numeric, or memorable." >&2
        exit 1
    fi
    
    # Resolve dynamic defaults
    if [[ -z "$length" ]]; then
        if [[ "$type" = "numeric" ]]; then
            length=6
        else
            length=16
        fi
    fi
    
    if [[ -z "$qty" ]]; then
        if [[ "$type" = "memorable" ]]; then
            qty=4
        else
            qty=1
        fi
    fi
    
    # Generate requested passwords
    local i
    for (( i=0; i<count; i++ )); do
        generate_password "$type" "$length" "$qty"
    done
}

# Only execute if run directly as a script
if [[ "$RUNNING_AS_SCRIPT" = true ]]; then
    main "$@"
fi
