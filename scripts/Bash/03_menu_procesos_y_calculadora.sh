#!/usr/bin/env bash
# ==============================================================================
# Script: 03_menu_procesos_y_calculadora.sh
# Curso: Administración de Redes
# Práctica: Ejercicios de Scripts - Menú de procesos (root) y Calculadora (expr)
# Descripción:
#   Incluye los dos scripts desarrollados en la práctica:
#   1. Menú exclusivo para usuario root (ps, pstree, ls > archivo.txt).
#   2. Calculadora aritmética en terminal usando 'expr' con validación de
#      división entre cero.
# Uso:
#   chmod +x 03_menu_procesos_y_calculadora.sh
#   sudo ./03_menu_procesos_y_calculadora.sh --menu-root
#   ./03_menu_procesos_y_calculadora.sh --calculadora
# ==============================================================================

set -u

menu_procesos_root() {
    if [[ "$(whoami)" == "root" ]]; then
        while [[ "$(whoami)" == "root" ]]; do
            echo "=========================================="
            echo " Menú de Administración (Usuario: root)"
            echo "=========================================="
            echo "1) Ver procesos en ejecución (ps)"
            echo "2) Ver procesos en forma de árbol (pstree)"
            echo "3) Guardar listado del directorio en archivo.txt"
            echo "4) Salir"
            read -r -p "Introduce un número entre el 1 y 4: " num

            case "$num" in
                1)
                    echo "Procesos en ejecución:"
                    ps
                    ;;
                2)
                    echo "Procesos en forma de árbol:"
                    pstree
                    ;;
                3)
                    ls > archivo.txt
                    echo "Contenido guardado en archivo.txt"
                    ;;
                4)
                    echo "Salir"
                    break
                    ;;
                *)
                    echo "Valor no reconocido"
                    ;;
            esac
            echo
        done
    else
        echo "[ERROR] Usuario no root. Ejecuta este modo con: sudo $0 --menu-root"
        return 1
    fi
}

calculadora_expr() {
    echo "=========================================="
    echo " Calculadora Básica en Bash (usando expr)"
    echo "=========================================="
    read -r -p "Dame el primer número entero: " num1
    read -r -p "Dame el segundo número entero: " num2
    echo "Operaciones disponibles:"
    echo "  1) Suma (+)"
    echo "  2) Resta (-)"
    echo "  3) Multiplicación (*)"
    echo "  4) División (/)"
    read -r -p "Introduce un número para la operación a realizar (1-4): " opc

    case "$opc" in
        1)
            echo "El valor de la suma es:"
            expr "$num1" + "$num2"
            ;;
        2)
            echo "El valor de la resta es:"
            expr "$num1" - "$num2"
            ;;
        3)
            echo "El valor de la multiplicación es:"
            expr "$num1" \* "$num2"
            ;;
        4)
            if [[ "$num2" -eq 0 ]]; then
                echo "[ERROR] División entre cero no permitida."
                return 1
            fi
            echo "El valor de la división es:"
            expr "$num1" / "$num2"
            ;;
        *)
            echo "Valor no reconocido"
            ;;
    esac
}

case "${1:-}" in
    --menu-root)
        menu_procesos_root
        ;;
    --calculadora)
        calculadora_expr
        ;;
    *)
        echo "Selecciona qué ejercicio deseas ejecutar:"
        echo "  1) Ejercicio 1: Menú de procesos (requiere root)"
        echo "  2) Ejercicio 2: Calculadora con expr"
        read -r -p "Opción [1-2]: " eleccion
        case "$eleccion" in
            1) menu_procesos_root ;;
            2) calculadora_expr ;;
            *) echo "Opción inválida. Uso: $0 [--menu-root | --calculadora]" ;;
        esac
        ;;
esac
