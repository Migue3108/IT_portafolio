#!/usr/bin/env bash
# ==============================================================================
# Script: 10_lvm_cuotas_disco.sh
# Curso: Administración de Redes
# Práctica: Proyecto Final - Administración Integral de una Red Linux Segura
# Descripción:
#   Automatiza la configuración de almacenamiento avanzado con LVM y cuotas de
#   disco implementada en el proyecto final:
#   1. Inicializa un volumen físico (pvcreate), grupo de volúmenes (vgcreate)
#      y volumen lógico de 3 GB (lvcreate).
#   2. Formatea en ext4 y monta persistentemente en /mnt/datos con soporte para
#      cuotas de usuario y grupo (usrquota,grpquota) en /etc/fstab.
#   3. Inicializa las tablas de cuotas (quotacheck, quotaon) y asigna un límite
#      de 100 MB (soft) y 110 MB (hard) al usuario indicado (ej. Emiliano).
# Uso:
#   chmod +x 10_lvm_cuotas_disco.sh
#   sudo ./10_lvm_cuotas_disco.sh [dispositivo_disco] [usuario_cuota]
#   Ejemplo: sudo ./10_lvm_cuotas_disco.sh /dev/sdb Emiliano
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere privilegios root (sudo)."
    exit 1
fi

DISCO="${1:-/dev/sdb}"
USUARIO_CUOTA="${2:-Emiliano}"
VG_NAME="datos-vg"
LV_NAME="proyectos-lv"
LV_SIZE="3G"
PUNTO_MONTAJE="/mnt/datos"
DEV_LV="/dev/${VG_NAME}/${LV_NAME}"

echo "=== 1. Verificando disco disponible ($DISCO) ==="
lsblk
if [[ ! -b "$DISCO" ]]; then
    echo "[ERROR] No se encontró el dispositivo de bloques '$DISCO'."
    echo "        Especifica un disco secundario libre, ej.: sudo $0 /dev/sdb Emiliano"
    exit 1
fi

echo "=== 2. Creando estructura LVM (PV -> VG -> LV) ==="
pvcreate "$DISCO"
vgcreate "$VG_NAME" "$DISCO"
lvcreate -L "$LV_SIZE" -n "$LV_NAME" "$VG_NAME"

echo "=== 3. Formateando $DEV_LV con sistema de archivos ext4 ==="
mkfs.ext4 "$DEV_LV"

echo "=== 4. Configurando punto de montaje $PUNTO_MONTAJE y /etc/fstab ==="
mkdir -p "$PUNTO_MONTAJE"
cp /etc/fstab "/etc/fstab.bak_$(date +%F_%H%M%S)"

if ! grep -q "$DEV_LV" /etc/fstab; then
    echo "$DEV_LV $PUNTO_MONTAJE ext4 defaults,usrquota,grpquota 0 2" >> /etc/fstab
fi

mount -a
mount -o remount "$PUNTO_MONTAJE"
df -h | grep "$PUNTO_MONTAJE"

echo "=== 5. Instalando y activando cuotas de disco (quota) ==="
apt-get update && apt-get install -y quota
quotacheck -ugm "$PUNTO_MONTAJE"
quotaon -v "$PUNTO_MONTAJE"

echo "=== 6. Asignando cuota (100M soft / 110M hard) al usuario '$USUARIO_CUOTA' ==="
if id "$USUARIO_CUOTA" &>/dev/null; then
    setquota -u "$USUARIO_CUOTA" 100M 110M 0 0 "$PUNTO_MONTAJE"
    echo "[OK] Cuota asignada a '$USUARIO_CUOTA'."
else
    echo "[WARN] El usuario '$USUARIO_CUOTA' no existe aún. Créalo y ejecuta:"
    echo "       sudo setquota -u $USUARIO_CUOTA 100M 110M 0 0 $PUNTO_MONTAJE"
fi

echo "=== 7. Reporte actual de cuotas en $PUNTO_MONTAJE ==="
repquota -s "$PUNTO_MONTAJE"
