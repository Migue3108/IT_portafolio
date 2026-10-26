#!/usr/bin/env bash
# ==============================================================================
# Script: 17_deteccion_mitigacion_rootkits.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Detección y Mitigación de Rootkits en Linux
# Descripción:
#   Implementa el flujo completo de la práctica de seguridad defensiva:
#   1. Instalación de herramientas: rkhunter, chkrootkit, lynis y auditd.
#   2. Simulación controlada de Indicadores de Compromiso (IoCs):
#      - Usuario oculto sin directorio home ('backdooruser').
#      - Archivo oculto en /tmp ('/tmp/.hidden_process').
#      - Proceso sospechoso persistente en segundo plano ('nohup sleep 5000 &').
#   3. Escaneo automatizado con chkrootkit, rkhunter y lynis.
#   4. Análisis forense básico (/etc/passwd, ps aux, /tmp, journalctl).
#   5. Mitigación, limpieza de IoCs y endurecimiento de permisos + auditd.
# Uso:
#   chmod +x 17_deteccion_mitigacion_rootkits.sh
#   sudo ./17_deteccion_mitigacion_rootkits.sh [--instalar | --simular-ioc | --escanear | --forense | --mitigar]
# ==============================================================================

set -euo pipefail

requerir_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Este script requiere privilegios de superusuario (sudo)."
        exit 1
    fi
}

instalar_herramientas() {
    requerir_root
    echo "=== Instalando rkhunter, chkrootkit, lynis y auditd ==="
    apt-get update
    apt-get install -y rkhunter chkrootkit lynis auditd
    rkhunter --version || true
    chkrootkit -V || true
}

simular_ioc() {
    requerir_root
    echo "=== Simulando Indicadores de Compromiso (IoCs) en entorno controlado ==="
    if ! id backdooruser &>/dev/null; then
        useradd -M -s /bin/bash backdooruser
        echo "[+] Usuario sin directorio home 'backdooruser' creado."
    fi

    touch /tmp/.hidden_process
    echo "[+] Archivo oculto '/tmp/.hidden_process' creado."

    nohup sleep 5000 >/dev/null 2>&1 &
    echo "[+] Proceso sospechoso en segundo plano iniciado (PID: $!)."
}

ejecutar_escaneo() {
    requerir_root
    echo "=== 1. Ejecutando chkrootkit ==="
    chkrootkit || true

    echo
    echo "=== 2. Actualizando y ejecutando rkhunter ==="
    rkhunter --update || true
    rkhunter --check --sk || true

    echo
    echo "=== 3. Auditoría de endurecimiento del sistema con Lynis ==="
    lynis audit system --quick || true
}

analisis_forense() {
    requerir_root
    echo "============================================================"
    echo " Análisis Forense Básico del Sistema"
    echo "============================================================"
    echo "[+] 1. Usuarios con shell interactivo en /etc/passwd:"
    grep -E "/bin/(bash|sh|zsh)" /etc/passwd
    echo
    echo "[+] 2. Procesos sospechosos (sleep / backdoor):"
    ps aux | grep -E "sleep 5000|backdoor" | grep -v grep || echo "  (Ninguno detectado)"
    echo
    echo "[+] 3. Archivos ocultos en /tmp (ls -la /tmp):"
    ls -la /tmp
    echo
    echo "[+] 4. Últimos eventos críticos del sistema (journalctl -xe):"
    journalctl -xe -n 25 --no-pager
}

mitigar_y_endurecer() {
    requerir_root
    echo "=== Aplicando Mitigación y Endurecimiento (Hardening) ==="
    if id backdooruser &>/dev/null; then
        userdel backdooruser
        echo "[OK] Usuario 'backdooruser' eliminado."
    fi

    if [[ -f /tmp/.hidden_process ]]; then
        rm -f /tmp/.hidden_process
        echo "[OK] Archivo oculto '/tmp/.hidden_process' eliminado."
    fi

    pkill -f "sleep 5000" && echo "[OK] Proceso 'sleep 5000' terminado." || true

    chmod 644 /etc/passwd
    chmod 600 /etc/shadow
    echo "[OK] Permisos seguros aplicados: /etc/passwd (644) y /etc/shadow (600)."

    systemctl enable --now auditd
    systemctl status auditd --no-pager | head -n 10
}

case "${1:---forense}" in
    --instalar)    instalar_herramientas ;;
    --simular-ioc) simular_ioc ;;
    --escanear)    ejecutar_escaneo ;;
    --forense)     analisis_forense ;;
    --mitigar)     mitigar_y_endurecer ;;
    *)
        echo "Uso: sudo $0 [--instalar | --simular-ioc | --escanear | --forense | --mitigar]"
        exit 1
        ;;
esac

