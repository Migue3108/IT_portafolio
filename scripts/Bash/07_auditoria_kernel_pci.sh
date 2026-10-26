#!/usr/bin/env bash
# ==============================================================================
# Script: 07_auditoria_kernel_pci.sh
# Curso: Administración de Redes
# Práctica: Práctica 9 - Módulos del Kernel y Buses PCI
# Descripción:
#   Inspecciona dispositivos PCI (especialmente adaptadores de red Ethernet),
#   particiones en /proc/partitions, versiones de kernel en /lib/modules,
#   módulos cargados en memoria (lsmod) e información detallada del driver de
#   red (modinfo, modprobe --show-depends).
# Uso:
#   chmod +x 07_auditoria_kernel_pci.sh
#   ./07_auditoria_kernel_pci.sh [nombre_modulo]
# ==============================================================================

set -u

MODULO="${1:-e1000}"

echo "============================================================"
echo " 1. Dispositivos PCI y Controladores de Red (lspci)"
echo "============================================================"
if command -v lspci &>/dev/null; then
    lspci
    echo
    echo "[+] Detalle de controladoras Ethernet (lspci -v):"
    ETH_SLOT=$(lspci | grep -i "Ethernet" | awk '{print $1}' | head -n 1)
    if [[ -n "$ETH_SLOT" ]]; then
        lspci -s "$ETH_SLOT" -v
    fi
else
    echo "[WARN] 'lspci' no encontrado (instala pciutils)."
fi

echo
echo "============================================================"
echo " 2. Tabla de Particiones Reconocidas (/proc/partitions)"
echo "============================================================"
cat /proc/partitions

echo
echo "============================================================"
echo " 3. Versión del Kernel y Directorios en /lib/modules"
echo "============================================================"
echo "[+] Kernel activo (uname -r): $(uname -r)"
echo "[+] Versiones disponibles en /lib/modules:"
ls -1 /lib/modules
echo
echo "[+] Archivos de dependencias del kernel actual (/lib/modules/$(uname -r)):"
ls /lib/modules/"$(uname -r)"

echo
echo "============================================================"
echo " 4. Módulos Cargados (lsmod - primeros 20)"
echo "============================================================"
lsmod | head -n 20

echo
echo "============================================================"
echo " 5. Información del Módulo de Red ($MODULO / e100)"
echo "============================================================"
if modinfo "$MODULO" &>/dev/null; then
    modinfo "$MODULO"
    echo
    echo "[+] Dependencias del módulo ($MODULO):"
    modprobe --show-depends "$MODULO" 2>/dev/null || true
elif modinfo e100 &>/dev/null; then
    modinfo e100
else
    echo "[INFO] Módulo '$MODULO' no disponible en este kernel."
fi

cat << 'EOF'

============================================================
 Referencia de Comandos de Gestión de Módulos del Kernel
============================================================
  lsmod                          -> Lista módulos cargados actualmente.
  modinfo <módulo>               -> Muestra información detallada de un módulo.
  sudo modprobe <módulo>         -> Carga un módulo y sus dependencias.
  sudo modprobe -r <módulo>      -> Descarga un módulo y dependencias sin uso.
  modprobe --show-depends <mód>  -> Lista las dependencias del módulo.
  sudo insmod <ruta/módulo.ko>   -> Inserta un módulo directamente sin resolver deps.
  sudo rmmod <módulo>            -> Elimina un módulo cargado del kernel.
============================================================
EOF
