#!/usr/bin/env bash
# ==============================================================================
# Script: 09_setup_samba_server.sh
# Curso: Administración de Redes / Intercomunicación y Seguridad en Redes
# Práctica: Práctica Instalación y Configuración del Servicio Samba en Linux
# Descripción:
#   Despliega un servidor de archivos SMB/CIFS con Samba:
#   - Instala 'samba' y 'smbclient'.
#   - Crea el grupo 'smb_users' y el directorio '/srv/samba/practica_samba'
#     con permisos SGID (2775).
#   - Crea un usuario de sistema sin login interactivo ('alumno1') y lo añade
#     a 'smb_users'.
#   - Respalda /etc/samba/smb.conf y configura el recurso '[IngenieriaShare]'.
#   - Valida sintaxis con 'testparm', abre el firewall UFW y reinicia 'smbd'.
# Uso:
#   chmod +x 09_setup_samba_server.sh
#   sudo ./09_setup_samba_server.sh [usuario_smb]
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script debe ejecutarse con sudo: sudo $0 [usuario_smb]"
    exit 1
fi

SMB_USER="${1:-alumno1}"
SMB_GROUP="smb_users"
SHARE_NAME="IngenieriaShare"
SHARE_PATH="/srv/samba/practica_samba"
SMB_CONF="/etc/samba/smb.conf"

echo "=== 1. Instalando paquetes Samba y cliente SMB ==="
apt-get update
apt-get install -y samba smbclient

echo "=== 2. Creando grupo '$SMB_GROUP' y directorio compartido '$SHARE_PATH' ==="
getent group "$SMB_GROUP" >/dev/null || groupadd "$SMB_GROUP"
mkdir -p "$SHARE_PATH"
chown :"$SMB_GROUP" "$SHARE_PATH"
chmod 2775 "$SHARE_PATH"
ls -ld "$SHARE_PATH"

echo "=== 3. Configurando usuario Samba '$SMB_USER' ==="
if ! id "$SMB_USER" &>/dev/null; then
    useradd -m -s /sbin/nologin "$SMB_USER"
fi
usermod -aG "$SMB_GROUP" "$SMB_USER"

echo "[+] Establece la contraseña SMB para el usuario '$SMB_USER':"
smbpasswd -a "$SMB_USER"

echo "=== 4. Configurando $SMB_CONF ==="
cp "$SMB_CONF" "${SMB_CONF}.backup_$(date +%F_%H%M%S)"

if ! grep -q "\[${SHARE_NAME}\]" "$SMB_CONF"; then
    cat >> "$SMB_CONF" << EOF

[${SHARE_NAME}]
   comment = Compartido de Practica de Ingenieria
   path = ${SHARE_PATH}
   browseable = yes
   writable = yes
   guest ok = no
   valid users = @${SMB_GROUP}
   read only = no
   create mask = 0664
   directory mask = 2775
EOF
    echo "[OK] Recurso [${SHARE_NAME}] añadido a $SMB_CONF"
else
    echo "[INFO] El recurso [${SHARE_NAME}] ya existe en $SMB_CONF"
fi

echo "=== 5. Validando sintaxis con testparm ==="
testparm -s

echo "=== 6. Reiniciando servicio smbd y configurando Firewall ==="
systemctl restart smbd
systemctl enable smbd

if command -v ufw &>/dev/null; then
    ufw allow 'Samba' || true
fi

IP_SERVIDOR=$(hostname -I | awk '{print $1}')
echo "============================================================"
echo "[OK] Servidor Samba activo."
echo "  - Prueba desde Linux:   smbclient //localhost/${SHARE_NAME} -U ${SMB_USER}"
echo "  - Prueba desde Windows: \\\\${IP_SERVIDOR}\\${SHARE_NAME}"
echo "============================================================"
