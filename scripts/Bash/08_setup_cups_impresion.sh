#!/usr/bin/env bash
# ==============================================================================
# Script: 08_setup_cups_impresion.sh
# Curso: Administración de Redes
# Práctica: Práctica CUPS (Servidor de Impresión y cups-pdf)
# Descripción:
#   Automatiza la instalación y configuración de CUPS y cups-pdf en Linux:
#   - Instala paquetes 'cups' y 'printer-driver-cups-pdf' (o 'cups-pdf').
#   - Inicia y habilita el servicio systemd 'cups'.
#   - Agrega al usuario especificado al grupo 'lpadmin'.
#   - Modifica /etc/cups/cupsd.conf cambiando 'JobPrivateValues default' a
#     'JobPrivateValues none' para visualizar el usuario que envía trabajos en
#     http://localhost:631/jobs.
#   - Envía una impresión de prueba por consola con 'lp'.
# Uso:
#   chmod +x 08_setup_cups_impresion.sh
#   sudo ./08_setup_cups_impresion.sh [usuario_lpadmin]
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Ejecuta este script con privilegios root: sudo $0 [usuario]"
    exit 1
fi

USUARIO_ADMIN="${1:-${SUDO_USER:-root}}"
CUPS_CONF="/etc/cups/cupsd.conf"

echo "=== 1. Instalando CUPS y controlador de impresión virtual PDF ==="
apt-get update
apt-get install -y cups printer-driver-cups-pdf || apt-get install -y cups cups-pdf

echo "=== 2. Iniciando y habilitando el servicio CUPS ==="
systemctl start cups
systemctl enable cups

echo "=== 3. Agregando usuario '$USUARIO_ADMIN' al grupo 'lpadmin' ==="
usermod -aG lpadmin "$USUARIO_ADMIN"

echo "=== 4. Configurando visibilidad de usuarios en trabajos (JobPrivateValues none) ==="
if [[ -f "$CUPS_CONF" ]]; then
    cp "$CUPS_CONF" "${CUPS_CONF}.bak_$(date +%F_%H%M%S)"
    sed -i 's/JobPrivateValues default/JobPrivateValues none/g' "$CUPS_CONF"
    echo "[OK] Directiva 'JobPrivateValues none' aplicada en $CUPS_CONF"
fi

echo "=== 5. Reiniciando servicio CUPS y verificando estado ==="
systemctl restart cups
systemctl status cups --no-pager

echo "=== 6. Impresoras disponibles y envío de prueba ==="
lpstat -p -d || true
IMPRESORA_PDF=$(lpstat -p 2>/dev/null | awk '{print $2}' | grep -i "PDF" | head -n 1 || true)
if [[ -n "$IMPRESORA_PDF" ]]; then
    echo "[+] Enviando trabajo de prueba (/etc/hosts) a '$IMPRESORA_PDF'..."
    lp -d "$IMPRESORA_PDF" /etc/hosts
    echo "[OK] Verifica el trabajo y el nombre de usuario en: http://localhost:631/jobs"
else
    echo "[INFO] Abre http://localhost:631/admin para agregar la impresora Virtual_PDF_Printer"
    echo "       y luego prueba con: lp -d Virtual_PDF_Printer /etc/hosts"
fi
