#!/usr/bin/env bash
# ==============================================================================
# Script: 19_redteam_blueteam_hardening_monitor.sh
# Curso: Intercomunicación y Seguridad en Redes
# Proyecto: Proyecto Final Red Team vs Blue Team - Ataque y Defensa en Linux
# Descripción:
#   Reúne los mecanismos de defensa, hardening y monitoreo implementados por el
#   Blue Team en el proyecto final:
#   1. Script de monitoreo en tiempo real de intentos fallidos SSH (monitor.sh).
#   2. Hardening del servicio SSH (/etc/ssh/sshd_config: Puerto 2222,
#      PermitRootLogin no, MaxAuthTries 3).
#   3. Configuración de Firewall UFW y protección contra fuerza bruta Fail2ban.
#   4. Verificación de estado de servicios defensivos (UFW, Fail2ban, Suricata,
#      Wazuh y puertos en escucha).
# Uso:
#   chmod +x 19_redteam_blueteam_hardening_monitor.sh
#   sudo ./19_redteam_blueteam_hardening_monitor.sh [--monitor | --hardening-ssh | --firewall-fail2ban | --estado]
# ==============================================================================

set -euo pipefail

LOG_AUTH="/var/log/auth.log"

monitorear_ataques_ssh() {
    echo "============================================================"
    echo " Monitoreo de Intentos Fallidos SSH en Tiempo Real (monitor.sh)"
    echo "============================================================"
    if [[ ! -f "$LOG_AUTH" ]]; then
        echo "[INFO] $LOG_AUTH no encontrado. Monitoreando con journalctl -u ssh..."
        sudo journalctl -u ssh -f | while read -r linea; do
            if echo "$linea" | grep -q "Failed password"; then
                echo "[ALERTA BLUE TEAM] Intento fallido detectado: $linea"
            fi
        done
    else
        echo "[+] Escuchando eventos en $LOG_AUTH (Presiona Ctrl+C para salir)..."
        sudo tail -Fn0 "$LOG_AUTH" | while read -r linea; do
            if echo "$linea" | grep -q "Failed password"; then
                echo "[ALERTA BLUE TEAM] Intento de fuerza bruta SSH: $linea"
            fi
        done
    fi
}

aplicar_hardening_ssh() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Ejecuta con sudo para modificar /etc/ssh/sshd_config"
        exit 1
    fi

    local sshd_conf="/etc/ssh/sshd_config"
    cp "$sshd_conf" "${sshd_conf}.bak_$(date +%F_%H%M%S)"

    echo "=== Aplicando Hardening SSH (Puerto 2222, Root deshabilitado, MaxAuthTries 3) ==="
    sed -i 's/^#\?Port .*/Port 2222/' "$sshd_conf"
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' "$sshd_conf"
    sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' "$sshd_conf"

    grep -q "^Port 2222" "$sshd_conf" || echo "Port 2222" >> "$sshd_conf"
    grep -q "^PermitRootLogin no" "$sshd_conf" || echo "PermitRootLogin no" >> "$sshd_conf"
    grep -q "^MaxAuthTries 3" "$sshd_conf" || echo "MaxAuthTries 3" >> "$sshd_conf"

    sshd -t
    systemctl restart ssh
    echo "[OK] Servicio SSH endurecido y reiniciado en el puerto 2222."
}

configurar_firewall_y_fail2ban() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Ejecuta con sudo para configurar UFW y Fail2ban."
        exit 1
    fi

    echo "=== 1. Configurando Firewall UFW ==="
    apt-get update
    apt-get install -y ufw fail2ban
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 2222/tcp comment 'SSH Hardened Port'
    ufw allow 21/tcp comment 'FTP Lab Service'
    ufw --force enable
    ufw status verbose

    echo
    echo "=== 2. Configurando Jail de Fail2ban para SSH (Puerto 2222) ==="
    cat << 'EOF' > /etc/fail2ban/jail.local
[DEFAULT]
bantime  = 600
findtime = 600
maxretry = 3

[sshd]
enabled  = true
port     = 2222
logpath  = %(sshd_log)s
backend  = %(sshd_backend)s
EOF

    systemctl enable --now fail2ban
    systemctl restart fail2ban
    fail2ban-client status sshd || true
}

verificar_estado_defensas() {
    echo "============================================================"
    echo " Resumen de Estado de Defensas (Blue Team)"
    echo "============================================================"
    echo "[+] 1. Puertos activos en escucha (ss -tulnp):"
    sudo ss -tulnp
    echo
    echo "[+] 2. Estado del Firewall UFW:"
    sudo ufw status numbered || true
    echo
    echo "[+] 3. Estado de Fail2ban (Jail sshd):"
    sudo fail2ban-client status sshd 2>/dev/null || echo "  (Fail2ban no activo)"
    echo
    echo "[+] 4. Estado de Suricata IDS/IPS y Wazuh:"
    systemctl is-active suricata 2>/dev/null && echo "  - Suricata: ACTIVO" || echo "  - Suricata: no instalado/inactivo"
    systemctl is-active wazuh-agent 2>/dev/null && echo "  - Wazuh Agent: ACTIVO" || echo "  - Wazuh Agent: no instalado/inactivo"
    systemctl is-active wazuh-manager 2>/dev/null && echo "  - Wazuh Manager: ACTIVO" || echo "  - Wazuh Manager: no instalado/inactivo"
}

case "${1:---estado}" in
    --monitor)           monitorear_ataques_ssh ;;
    --hardening-ssh)     aplicar_hardening_ssh ;;
    --firewall-fail2ban) configurar_firewall_y_fail2ban ;;
    --estado)            verificar_estado_defensas ;;
    *)
        echo "Uso: sudo $0 [--monitor | --hardening-ssh | --firewall-fail2ban | --estado]"
        exit 1
        ;;
esac

