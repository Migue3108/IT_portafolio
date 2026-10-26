#!/usr/bin/env bash
# ==============================================================================
# Script: 16_auditoria_enumeracion_red.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Enumeración en Auditoría de Ciberseguridad
# Descripción:
#   Automatiza las fases de reconocimiento y enumeración no intrusiva sobre un
#   objetivo autorizado de laboratorio (ej. 192.168.1.99):
#   - Fase 1: Descubrimiento de hosts y escaneo de puertos/servicios con Nmap.
#   - Fase 2: Enumeración SMB (enum4linux, smbclient) y sesiones nulas RPC.
#   - Fase 3: Enumeración de servicios Web (whatweb, nikto, gobuster).
#   - Fase 4: Obtención de banners (Banner Grabbing con netcat y curl -I).
# Uso:
#   chmod +x 16_auditoria_enumeracion_red.sh
#   sudo ./16_auditoria_enumeracion_red.sh <ip_objetivo> [red_cidr]
#   Ejemplo: sudo ./16_auditoria_enumeracion_red.sh 192.168.1.99 192.168.1.0/24
# ==============================================================================

set -u

TARGET_IP="${1:-192.168.1.99}"
SUBNET="${2:-192.168.1.0/24}"
REPORT_DIR="${PWD}/reporte_enumeracion_${TARGET_IP}_$(date +%F_%H%M)"

mkdir -p "$REPORT_DIR"
echo "[+] Guardando evidencias de auditoría en: $REPORT_DIR"

echo "============================================================"
echo " Fase 1: Reconocimiento y Escaneo con Nmap"
echo "============================================================"
if command -v nmap &>/dev/null; then
    echo "[1.1] Descubrimiento de hosts activos en $SUBNET (nmap -sn)..."
    nmap -sn "$SUBNET" | tee "${REPORT_DIR}/01_nmap_hosts.txt"

    echo "[1.2] Escaneo SYN de puertos abiertos en $TARGET_IP..."
    sudo nmap -sS -p- -T4 "$TARGET_IP" | tee "${REPORT_DIR}/02_nmap_puertos.txt"

    echo "[1.3] Detección de versiones, scripts por defecto y SO (nmap -sV -sC -O)..."
    sudo nmap -sV -sC -O "$TARGET_IP" | tee "${REPORT_DIR}/03_nmap_servicios_so.txt"
else
    echo "[WARN] 'nmap' no está instalado."
fi

echo
echo "============================================================"
echo " Fase 2: Enumeración SMB (Puertos 139/445) y RPC"
echo "============================================================"
if command -v smbclient &>/dev/null; then
    echo "[2.1] Listando recursos compartidos con sesión nula (smbclient -L):"
    smbclient -L "//${TARGET_IP}" -N | tee "${REPORT_DIR}/04_smbclient_shares.txt" || true
fi

if command -v rpcclient &>/dev/null; then
    echo "[2.2] Enumerando usuarios de dominio vía RPC Null Session (enumdomusers):"
    rpcclient -U "" -N "$TARGET_IP" -c "enumdomusers" | tee "${REPORT_DIR}/05_rpcclient_users.txt" || true
fi

if command -v enum4linux &>/dev/null; then
    echo "[2.3] Ejecutando auditoría completa con enum4linux -a:"
    enum4linux -a "$TARGET_IP" | tee "${REPORT_DIR}/06_enum4linux.txt" || true
fi

echo
echo "============================================================"
echo " Fase 3: Enumeración Web (HTTP/HTTPS)"
echo "============================================================"
if command -v whatweb &>/dev/null; then
    echo "[3.1] Identificando tecnologías web (whatweb):"
    whatweb "http://${TARGET_IP}" | tee "${REPORT_DIR}/07_whatweb.txt" || true
fi

if command -v nikto &>/dev/null; then
    echo "[3.2] Escaneo básico de servidor web con Nikto:"
    nikto -h "http://${TARGET_IP}" -maxtime 60s | tee "${REPORT_DIR}/08_nikto.txt" || true
fi

if command -v gobuster &>/dev/null && [[ -f /usr/share/wordlists/dirb/common.txt ]]; then
    echo "[3.3] Descubrimiento de directorios con Gobuster:"
    gobuster dir -u "http://${TARGET_IP}" -w /usr/share/wordlists/dirb/common.txt -q | tee "${REPORT_DIR}/09_gobuster.txt" || true
fi

echo
echo "============================================================"
echo " Fase 4: Obtención de Banners (Banner Grabbing)"
echo "============================================================"
echo "[4.1] Cabeceras HTTP (curl -I):"
curl -I -s --max-time 5 "http://${TARGET_IP}" | tee "${REPORT_DIR}/10_http_headers.txt" || true

echo "[4.2] Banner en puertos 21 (FTP) y 22 (SSH) con Netcat:"
for port in 21 22; do
    echo "--- Puerto $port ---"
    nc -v -n -w 3 "$TARGET_IP" "$port" </dev/null 2>&1 | tee -a "${REPORT_DIR}/11_banners_nc.txt" || true
done

echo
echo "[OK] Auditoría de enumeración finalizada. Reportes en: $REPORT_DIR"

