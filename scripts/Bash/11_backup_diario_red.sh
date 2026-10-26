#!/usr/bin/env bash
# ==============================================================================
# Script: 11_backup_diario_red.sh
# Curso: Administración de Redes
# Práctica: Proyecto Final - Administración Integral de una Red Linux Segura
#           (/usr/local/bin/backup_diario.sh)
# Descripción:
#   Script de respaldo automatizado que comprime el directorio /mnt/datos en
#   un archivo .tar.gz con marca de tiempo, registra el evento en el Syslog del
#   sistema mediante 'logger' y permite transferir las copias de seguridad a un
#   nodo remoto vía SCP o registrar la tarea en crontab.
# Uso:
#   chmod +x 11_backup_diario_red.sh
#   ./11_backup_diario_red.sh [--ejecutar | --instalar-cron | --enviar-scp <user@ip:/ruta>]
# ==============================================================================

set -euo pipefail

FECHA=$(date +"%Y-%m-%d_%H-%M")
ORIGEN="${ORIGEN_BACKUP:-/mnt/datos}"
DESTINO="${DESTINO_BACKUP:-$HOME/backups}"
NOMBRE_ARCHIVO="respaldo_datos_${FECHA}.tar.gz"

ejecutar_respaldo() {
    echo "=== Ejecutando Respaldo Automatizado ==="
    mkdir -p "$DESTINO"

    if [[ ! -d "$ORIGEN" ]]; then
        echo "[WARN] El directorio origen '$ORIGEN' no existe. Creando directorio de prueba..."
        sudo mkdir -p "$ORIGEN"
    fi

    tar -czf "${DESTINO}/${NOMBRE_ARCHIVO}" "$ORIGEN" 2>/dev/null || sudo tar -czf "${DESTINO}/${NOMBRE_ARCHIVO}" "$ORIGEN"
    logger "respaldo de sistema completado: ${NOMBRE_ARCHIVO}"

    echo "[OK] Respaldo creado en: ${DESTINO}/${NOMBRE_ARCHIVO}"
    echo "[OK] Evento registrado en Syslog. Verificando con grep en /var/log/syslog:"
    sudo grep "respaldo de sistema" /var/log/syslog | tail -n 5 2>/dev/null || journalctl -t "${USER:-root}" -n 5 --no-pager
}

instalar_en_cron() {
    local ruta_instalacion="/usr/local/bin/backup_diario.sh"
    sudo cp "$0" "$ruta_instalacion"
    sudo chmod +x "$ruta_instalacion"

    # Programa ejecución diaria a las 02:00 AM (o cada minuto en entorno de laboratorio)
    local cron_entry="0 2 * * * $ruta_instalacion --ejecutar"
    (sudo crontab -l 2>/dev/null | grep -v "$ruta_instalacion"; echo "$cron_entry") | sudo crontab -
    echo "[OK] Script instalado en '$ruta_instalacion' y programado en crontab:"
    sudo crontab -l
}

enviar_por_scp() {
    local destino_remoto="${1:-migue31@192.168.50.20:/home/migue31/}"
    echo "=== Enviando respaldos por SCP hacia $destino_remoto ==="
    scp "${DESTINO}"/respaldo_datos_*.tar.gz "$destino_remoto"
    echo "[OK] Transferencia SCP completada."
}

case "${1:-}" in
    --ejecutar)      ejecutar_respaldo ;;
    --instalar-cron) instalar_en_cron ;;
    --enviar-scp)    enviar_por_scp "${2:-migue31@192.168.50.20:/home/migue31/}" ;;
    *)
        ejecutar_respaldo
        ;;
esac
