#!/usr/bin/env bash
# ==============================================================================
# Script: 18_calculadora_ipv6_prefijos.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Ejercicios IPv6 (Expansión, compresión y cálculo de prefijos)
# Descripción:
#   Calcula la dirección IPv6 expandida (8 hextetos completos), la dirección
#   comprimida (::), la red/prefijo según la longitud CIDR (/80, /48, /40, /36,
#   /60, /56) y el prefijo exacto en bits.
#   Incluye la resolución automática de los 8 ejercicios de la práctica.
# Uso:
#   chmod +x 18_calculadora_ipv6_prefijos.sh
#   ./18_calculadora_ipv6_prefijos.sh --ejercicios
#   ./18_calculadora_ipv6_prefijos.sh <direccion_ipv6/prefijo>
#   Ejemplo: ./18_calculadora_ipv6_prefijos.sh 3124::DEAD:CAFE:FF:FE00:1/60
# ==============================================================================

set -euo pipefail

analizar_ipv6() {
    local entrada="$1"
    python3 - "$entrada" << 'PYEOF'
import sys
import ipaddress

cidr = sys.argv[1]
iface = ipaddress.IPv6Interface(cidr)
addr = iface.ip
net = iface.network
plen = net.prefixlen

expanded = addr.exploded
compressed = addr.compressed
net_exploded = net.network_address.exploded.replace(":", "")

# Número de caracteres hexadecimales que componen el prefijo (1 hex = 4 bits)
hex_chars = plen // 4
raw_prefix_hex = net_exploded[:hex_chars]
grupos = [raw_prefix_hex[i:i+4] for i in range(0, len(raw_prefix_hex), 4)]
prefijo_formateado = ":".join(grupos)

print(f"Entrada CIDR         : {cidr}")
print(f"Dirección Expandida  : {expanded}")
print(f"Dirección Comprimida : {compressed}")
print(f"Red IPv6 Completa    : {net}")
print(f"Prefijo ({plen} bits)   : {prefijo_formateado}")
print("-" * 60)
PYEOF
}

resolver_ejercicios_practica() {
    echo "============================================================"
    echo " Resolución de los 8 Ejercicios de la Práctica IPv6"
    echo "============================================================"
    local ejercicios=(
        "34BA:B:B:0:5555:0:6060:707/80"
        "3124::DEAD:CAFE:FF:FE00:1/80"
        "2BCD::FACE:BEFF:FEBE:CAFE/48"
        "3FED:F:E0:D00:FACE:BAFF:FE00:0/40"
        "210F:A:B:C:CCCC:B0B0:9999:9009/40"
        "34BA:B:B:0:5555:0:6060:707/36"
        "3124::DEAD:CAFE:FF:FE00:1/60"
        "2BCD::FACE:1:BEFF:FEBE:CAFE/56"
    )

    for ej in "${ejercicios[@]}"; do
        analizar_ipv6 "$ej"
    done
}

case "${1:---ejercicios}" in
    --ejercicios)
        resolver_ejercicios_practica
        ;;
    *)
        analizar_ipv6 "$1"
        ;;
esac

