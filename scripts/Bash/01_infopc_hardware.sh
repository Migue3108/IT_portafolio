#!/usr/bin/env bash
# ==============================================================================
# Script: 01_infopc_hardware.sh
# Curso: Administración de Redes
# Práctica: Práctica 1 - Comandos de parada del sistema e información de hardware
# Descripción:
#   Recopila las características técnicas del procesador (/proc/cpuinfo),
#   versión del kernel, nivel de ejecución (runlevel), uso de disco por
#   directorio y tabla de particiones. Incluye referencia de comandos de parada.
# Uso:
#   chmod +x 01_infopc_hardware.sh
#   ./01_infopc_hardware.sh [--resumen | --parada-help]
# ==============================================================================

set -u

mostrar_info_cpu() {
    echo "============================================================"
    echo " Script para verificar las características técnicas del CPU"
    echo "============================================================"
    echo
    echo "[+] Core ID:"
    grep 'core id' /proc/cpuinfo || echo "  (No disponible en este entorno virtual)"
    echo
    echo "[+] Model Name:"
    grep 'model name' /proc/cpuinfo
    echo
    echo "[+] CPU MHz:"
    grep 'cpu MHz' /proc/cpuinfo || lscpu | grep -i "MHz"
    echo
}

mostrar_info_sistema() {
    echo "============================================================"
    echo " Información del Kernel, Runlevel y Almacenamiento"
    echo "============================================================"
    echo "[+] Directorio actual (pwd): $(pwd)"
    echo "[+] Versión del Kernel (uname -r): $(uname -r)"
    echo "[+] Nivel de ejecución (runlevel): $(runlevel 2>/dev/null || systemctl get-default 2>/dev/null)"
    echo
    echo "[+] Procesos de la sesión actual (ps):"
    ps
    echo
    echo "[+] Uso de espacio en disco en raíz (du -sxh /* 2>/dev/null):"
    sudo du -sxh /* 2>/dev/null || du -sxh ./* 2>/dev/null
    echo
    echo "[+] Tabla de particiones y discos (fdisk -l / lsblk):"
    if [[ $EUID -eq 0 ]]; then
        fdisk -l
    else
        lsblk
        echo "  (Nota: ejecuta con 'sudo' para ver la salida completa de 'fdisk -l')"
    fi
}

mostrar_referencia_parada() {
    cat << 'EOF'
============================================================
 Referencia de Comandos de Parada y Reinicio del Sistema
============================================================
  halt            -> Detiene el sistema inmediatamente.
  halt -p         -> Detiene el sistema y apaga la fuente de energía (poweroff).
  halt -f         -> Fuerza el apagado sin invocar a shutdown.
  halt -d         -> Detiene el sistema sin escribir registro en /var/log/wtmp.

  shutdown -h now   -> Apaga el sistema de forma inmediata y segura.
  shutdown -h 03:25 -> Programa el apagado del sistema a las 03:25 AM.
  shutdown -r now   -> Reinicia el sistema de inmediato.
  shutdown -r 22:00 -> Programa el reinicio del sistema a las 22:00 hrs.
  reboot            -> Reinicia el sistema (equivalente a shutdown -r now).
============================================================
EOF
}

case "${1:-}" in
    --parada-help)
        mostrar_referencia_parada
        ;;
    --resumen)
        mostrar_info_cpu
        mostrar_info_sistema
        ;;
    *)
        clear
        mostrar_info_cpu
        mostrar_info_sistema
        echo
        mostrar_referencia_parada
        read -r -p "Presione Enter para finalizar..." _
        ;;
esac
