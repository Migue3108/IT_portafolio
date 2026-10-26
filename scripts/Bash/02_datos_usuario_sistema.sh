#!/usr/bin/env bash
# ==============================================================================
# Script: 02_datos_usuario_sistema.sh
# Curso: Administración de Redes
# Práctica: Práctica 2 - Linux Administración de Redes (datos.sh, inodos, apache2)
# Descripción:
#   1. Solicita datos del usuario (nombre, edad, domicilio) y los guarda junto
#      con el contenido de /etc/passwd en datos.txt (versión corregida con >>).
#   2. Muestra uso de bloques e inodos del sistema (df -h, df -i, df /boot).
#   3. Guarda listado de procesos activos (ps -e > procesos.txt).
#   4. Verifica el estado del servidor web Apache (apache2 / httpd).
# Uso:
#   chmod +x 02_datos_usuario_sistema.sh
#   ./02_datos_usuario_sistema.sh [--datos | --disco | --procesos | --apache]
# ==============================================================================

set -u

capturar_datos_usuario() {
    local archivo_salida="datos.txt"
    echo "=== Captura de Datos de Usuario (datos.sh) ==="
    read -r -p "Ingresa tu nombre: " nombre
    read -r -p "Ingresa tu edad: " edad
    read -r -p "Ingresa tu domicilio: " domicilio

    {
        echo "nombre: $nombre"
        echo "edad: $edad"
        echo "domicilio: $domicilio"
        echo "----------------------------------------"
        cat /etc/passwd
    } > "$archivo_salida"

    echo "[OK] Información guardada exitosamente en '$archivo_salida'."
    echo "Primeras 5 líneas de $archivo_salida:"
    head -n 5 "$archivo_salida"
    echo "Últimas 5 líneas de $archivo_salida:"
    tail -n 5 "$archivo_salida"
}

reporte_disco_inodos() {
    echo "=== Reporte de Espacio en Disco e Inodos ==="
    echo "[+] Uso en /boot (df /boot):"
    df /boot 2>/dev/null || df /
    echo
    echo "[+] Uso en Kilobytes (df -k):"
    df -k
    echo
    echo "[+] Uso legible para humanos (df -h):"
    df -h
    echo
    echo "[+] Uso de Inodos (df -i):"
    df -i
}

guardar_procesos() {
    local archivo_proc="procesos.txt"
    ps -e > "$archivo_proc"
    echo "[OK] Procesos del sistema exportados a '$archivo_proc' ($(wc -l < "$archivo_proc") líneas)."
}

verificar_apache() {
    echo "=== Estado del Servicio Web Apache ==="
    if systemctl list-unit-files | grep -q "apache2.service"; then
        systemctl status apache2 --no-pager
    elif systemctl list-unit-files | grep -q "httpd.service"; then
        systemctl status httpd --no-pager
    else
        echo "[INFO] Apache no está instalado. Puedes instalarlo con:"
        echo "       sudo apt install apache2 -y   # Debian/Ubuntu"
        echo "       sudo dnf install httpd -y     # RHEL/CentOS/Fedora"
    fi
}

case "${1:-}" in
    --datos)    capturar_datos_usuario ;;
    --disco)    reporte_disco_inodos ;;
    --procesos) guardar_procesos ;;
    --apache)   verificar_apache ;;
    *)
        capturar_datos_usuario
        echo
        reporte_disco_inodos
        echo
        guardar_procesos
        echo
        verificar_apache
        ;;
esac
