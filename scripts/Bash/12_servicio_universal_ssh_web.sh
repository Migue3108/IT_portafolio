#!/usr/bin/env bash
# ==============================================================================
# Script: 12_servicio_universal_ssh_web.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Práctica 1 - Concepto de Servicio Universal (OpenSSH y Apache2)
# Descripción:
#   Despliega y verifica los servicios básicos de acceso universal en red local:
#   1. Verifica conectividad a Internet (ping -c 4 google.com).
#   2. Instala y activa OpenSSH Server (openssh-server) y Apache HTTP (apache2).
#   3. Configura el firewall UFW permitiendo 'ssh' y 'Apache'.
#   4. Muestra las direcciones IP de la máquina e instrucciones de prueba desde
#      clientes remotos.
# Uso:
#   chmod +x 12_servicio_universal_ssh_web.sh
#   sudo ./12_servicio_universal_ssh_web.sh
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Ejecuta este script con sudo: sudo $0"
    exit 1
fi

echo "=== Paso 1: Verificando conectividad de red ==="
ping -c 4 google.com || echo "[WARN] Sin salida a Internet, continuando en red local..."

echo
echo "=== Paso 2: Instalando servicios de red (OpenSSH Server y Apache2) ==="
apt-get update
apt-get install -y openssh-server apache2 ufw

echo
echo "=== Paso 3: Iniciando y verificando estado de los servicios ==="
systemctl enable --now ssh
systemctl enable --now apache2
systemctl status ssh --no-pager | head -n 12
echo
systemctl status apache2 --no-pager | head -n 12

echo
echo "=== Paso 4: Configurando Firewall (UFW) ==="
ufw allow ssh
ufw allow 'Apache'
ufw --force enable
ufw status verbose

echo
echo "=== Paso 5: Direcciones IP del Servidor (ip a) ==="
ip -br a

IP_LAN=$(hostname -I | awk '{print $1}')
USUARIO_ACTUAL="${SUDO_USER:-usuario}"

echo
echo "============================================================"
echo " Paso 6: Pruebas desde el Cliente en la Red Local"
echo "============================================================"
echo "  - Acceso por SSH:       ssh ${USUARIO_ACTUAL}@${IP_LAN}"
echo "  - Acceso por Navegador: http://${IP_LAN}"
echo "============================================================"
