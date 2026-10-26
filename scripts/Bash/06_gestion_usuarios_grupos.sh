#!/usr/bin/env bash
# ==============================================================================
# Script: 06_gestion_usuarios_grupos.sh
# Curso: Administración de Redes
# Práctica: Práctica Gestión de Usuarios (useradd, usermod, chage, groupadd, pwck)
# Descripción:
#   Script de referencia y automatización de los ejercicios de gestión de
#   usuarios y grupos en Linux:
#   - Creación de usuarios con home personalizado y fecha de expiración.
#   - Bloqueo de cuentas y políticas de envejecimiento de contraseñas (chage).
#   - Creación de grupos (alumnos, Basico, Profesional) y asignación.
#   - Modificación de comentarios GECOS, UID, migración de directorio home.
#   - Verificación de integridad de /etc/passwd y /etc/shadow con 'pwck'.
# Uso:
#   chmod +x 06_gestion_usuarios_grupos.sh
#   sudo ./06_gestion_usuarios_grupos.sh [--crear-lab | --auditar | --limpiar-lab]
# ==============================================================================

set -euo pipefail

requerir_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "[ERROR] Este script requiere privilegios de superusuario (sudo)."
        exit 1
    fi
}

crear_laboratorio_usuarios() {
    requerir_root
    echo "=== 1. Creación de usuarios 'marcos' y 'juan' ==="
    id marcos &>/dev/null || useradd -m marcos
    id juan &>/dev/null   || useradd -d /home/juanito -m -e 2026-10-06 juan

    echo "[+] Modificando expiración de 'juan' y bloqueando cuenta (-L):"
    usermod -e 2026-12-06 -L juan

    echo "=== 2. Políticas de caducidad con chage para 'marcos' ==="
    chage -M 60 marcos
    chage -l marcos

    echo "=== 3. Creación de grupo 'alumnos' y asignación de 'marcos' ==="
    getent group alumnos >/dev/null || groupadd alumnos
    usermod -g alumnos marcos

    echo "=== 4. Creación de usuarios Matematica, Estadistica e Investigacion ==="
    for usr in Matematica Estadistica Investigacion; do
        if ! id "$usr" &>/dev/null; then
            useradd -m -s /bin/bash "$usr"
            echo "[+] Usuario '$usr' creado."
        fi
    done

    echo "=== 5. Creación de grupos 'Basico' y 'Profesional' ==="
    getent group Basico >/dev/null      || groupadd Basico
    getent group Profesional >/dev/null || groupadd Profesional

    usermod -aG Basico Matematica
    usermod -aG Basico Estadistica
    usermod -aG Profesional Estadistica

    echo "=== 6. Modificación de comentario GECOS, UID y directorio Home ==="
    usermod -c "Usuario de departamento de Matematicas" Matematica
    usermod -u 1050 Matematica 2>/dev/null || true
    if [[ ! -d /home/nuevo ]]; then
        usermod -d /home/nuevo -m Investigacion
    fi

    echo "=== 7. Eliminación de grupo 'Profesional' y usuario 'Estadistica' ==="
    groupdel Profesional 2>/dev/null || true
    userdel -r Estadistica 2>/dev/null || true

    echo "[OK] Laboratorio de gestión de usuarios configurado."
}

auditar_usuarios() {
    echo "=== Auditoría de Usuarios y Grupos del Sistema ==="
    echo "[+] Verificando consistencia de /etc/passwd y /etc/shadow (pwck -r):"
    sudo pwck -r || true
    echo
    echo "[+] Identificadores (UID/GID):"
    for u in root marcos juan Matematica Investigacion; do
        if id "$u" &>/dev/null; then
            id "$u"
        fi
    done
    echo
    echo "[+] Últimas 5 entradas en /etc/passwd:"
    tail -n 5 /etc/passwd
}

limpiar_laboratorio() {
    requerir_root
    echo "=== Limpiando usuarios y grupos de la práctica ==="
    for u in marcos juan Matematica Estadistica Investigacion; do
        userdel -r "$u" 2>/dev/null && echo "[-] Usuario '$u' eliminado." || true
    done
    rm -rf /home/juanito /home/nuevo
    for g in alumnos Basico Profesional; do
        groupdel "$g" 2>/dev/null && echo "[-] Grupo '$g' eliminado." || true
    done
    echo "[OK] Limpieza completada."
}

case "${1:-}" in
    --crear-lab)   crear_laboratorio_usuarios ;;
    --auditar)     auditar_usuarios ;;
    --limpiar-lab) limpiar_laboratorio ;;
    *)
        echo "Uso: sudo $0 [--crear-lab | --auditar | --limpiar-lab]"
        auditar_usuarios
        ;;
esac
