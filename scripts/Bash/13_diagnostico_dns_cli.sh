#!/usr/bin/env bash
# ==============================================================================
# Script: 13_diagnostico_dns_cli.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Práctica 2 (Herramientas de consulta y propagación DNS) y
#           Práctica 3 (Uso de Comandos DNS en Linux)
# Descripción:
#   Reúne las pruebas de diagnóstico, resolución jerárquica, auditoría de correo
#   (MX, SPF, DMARC), consulta WHOIS, comparación de propagación global (Anycast
#   vs Estático) y captura de tráfico DNS en puerto 53 con tcpdump.
# Uso:
#   chmod +x 13_diagnostico_dns_cli.sh
#   ./13_diagnostico_dns_cli.sh [dominio] [--completo | --propagacion | --trace | --captura]
#   Ejemplo: ./13_diagnostico_dns_cli.sh buap.mx --completo
# ==============================================================================

set -u

DOMINIO="${1:-google.com}"
MODO="${2:---completo}"

consultas_basicas() {
    echo "============================================================"
    echo " 1. Consultas DNS Básicas para: $DOMINIO (dig, host, nslookup)"
    echo "============================================================"
    echo "[+] Registro A / AAAA con dig:"
    dig "$DOMINIO" A +noall +answer
    dig "$DOMINIO" AAAA +noall +answer
    echo
    echo "[+] Servidores de Correo (MX) y Políticas SPF/DMARC:"
    dig "$DOMINIO" MX +noall +answer
    dig "$DOMINIO" TXT +noall +answer
    dig "_dmarc.${DOMINIO}" TXT +noall +answer
    echo
    echo "[+] Consulta con 'host':"
    host "$DOMINIO" || true
    echo
    echo "[+] Consulta con 'nslookup':"
    nslookup "$DOMINIO" || true
}

consulta_whois_resumen() {
    echo
    echo "============================================================"
    echo " 2. Información de Registro (WHOIS): $DOMINIO"
    echo "============================================================"
    if command -v whois &>/dev/null; then
        whois "$DOMINIO" | grep -Ei "Domain Name|Registrar:|Creation Date|Expir|Name Server|Registrant" | head -n 20
    else
        echo "[WARN] El comando 'whois' no está instalado (sudo apt install whois)."
    fi
}

conectividad_y_ruta() {
    echo
    echo "============================================================"
    echo " 3. Diagnóstico de Conectividad (ping y traceroute)"
    echo "============================================================"
    echo "[+] Ping (4 paquetes):"
    ping -c 4 "$DOMINIO" || true
    echo
    echo "[+] Ruta de paquetes (traceroute):"
    if command -v traceroute &>/dev/null; then
        traceroute -m 15 "$DOMINIO" || true
    else
        echo "[WARN] 'traceroute' no encontrado (sudo apt install traceroute)."
    fi
}

resolucion_jerarquica() {
    echo
    echo "============================================================"
    echo " 4. Resolución Paso a Paso desde Servidores Raíz (dig +trace)"
    echo "============================================================"
    dig +trace "$DOMINIO"
}

comparar_propagacion_dns() {
    echo
    echo "============================================================"
    echo " 5. Verificación de Propagación Global DNS (Estático vs CDN/Anycast)"
    echo "============================================================"
    declare -A RESOLVERS=(
        ["Google_Public_DNS"]="8.8.8.8"
        ["Cloudflare_DNS"]="1.1.1.1"
        ["Quad9_Security_DNS"]="9.9.9.9"
        ["OpenDNS_Cisco"]="208.67.222.222"
    )

    for nombre in "${!RESOLVERS[@]}"; do
        ip_dns="${RESOLVERS[$nombre]}"
        respuesta=$(dig @"$ip_dns" "$DOMINIO" A +short | tr '\n' ' ')
        printf "  %-22s (%-15s) -> %s\n" "$nombre" "$ip_dns" "${respuesta:-Sin respuesta}"
    done
}

capturar_trafico_dns() {
    echo
    echo "============================================================"
    echo " 6. Captura de Tráfico DNS en Vivo (Puerto 53 - tcpdump)"
    echo "============================================================"
    echo "[INFO] Capturando 15 paquetes en el puerto 53 (presiona Ctrl+C para detener)..."
    sudo tcpdump -i any port 53 -nn -c 15
}

case "$MODO" in
    --completo)
        consultas_basicas
        consulta_whois_resumen
        conectividad_y_ruta
        comparar_propagacion_dns
        ;;
    --propagacion)
        comparar_propagacion_dns
        ;;
    --trace)
        resolucion_jerarquica
        ;;
    --captura)
        capturar_trafico_dns
        ;;
    *)
        echo "Uso: $0 [dominio] [--completo | --propagacion | --trace | --captura]"
        exit 1
        ;;
esac

