#!/usr/bin/env bash
# ==============================================================================
# Script: 04_enlaces_inodos_demo.sh
# Curso: Administración de Redes
# Práctica: Práctica - Enlaces (Hard Links, Symbolic Links e Inodos)
# Descripción:
#   Reproduce paso a paso la práctica de asociación de archivos e inodos:
#   - Creación de enlaces duros (ln) y enlaces simbólicos (ln -s).
#   - Verificación de números de inodo y contador de enlaces (ls -li).
#   - Comportamiento al eliminar el archivo original (enlace simbólico roto vs
#     enlace duro funcional que conserva el inodo).
#   - Resolución de rutas relativas al mover enlaces simbólicos entre carpetas.
# Uso:
#   chmod +x 04_enlaces_inodos_demo.sh
#   ./04_enlaces_inodos_demo.sh [--limpiar]
# ==============================================================================

set -euo pipefail

LAB_DIR="${PWD}/enlaces_lab"

if [[ "${1:-}" == "--limpiar" ]]; then
    rm -rf "$LAB_DIR"
    echo "[OK] Directorio de laboratorio '$LAB_DIR' eliminado."
    exit 0
fi

mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

echo "=== 1. Creación de archivo base, enlaces duros y simbólicos ==="
echo "Miguel Angel De La Cruz Espinosa" > ej0
ln ej0 hard1
ln ej0 hard2
ln -s ej0 sym1
mkdir -p dir1
ln -s dir1 dir2

echo "[+] Listado con números de inodo (ls -li):"
ls -li

echo
echo "=== 2. Modificación a través de un enlace duro (hard1) ==="
echo "DNI: Práctica Enlaces" >> hard1
echo "[+] Contenido leído desde ej0:"
cat ej0

echo
echo "=== 3. Eliminación de ej0: enlace simbólico vs enlace duro ==="
rm ej0
echo "[+] Intentando leer sym1 (enlace simbólico queda huérfano):"
cat sym1 2>&1 || true
echo "[+] Leyendo hard1 (enlace duro sigue apuntando al mismo inodo):"
cat hard1
ls -li

echo
echo "=== 4. Restauración de ej0 renombrando hard2 ==="
mv hard2 ej0
echo "[+] sym1 vuelve a funcionar automáticamente:"
cat sym1
ls -li

echo
echo "=== 5. Movimiento de enlace simbólico relativo a subdirectorio ==="
mv sym1 dir1/
echo "[+] Intentando leer dir1/sym1 antes de mover ej0 (ruta relativa rota):"
cat dir1/sym1 2>&1 || true

echo "[+] Moviendo ej0 hacia dir2/ (que apunta a dir1/):"
mv ej0 dir2/
echo "[+] Leyendo dir1/sym1 ahora que ej0 está en dir1/:"
cat dir1/sym1

echo
echo "[OK] Demostración completada en: $LAB_DIR"
echo "     Para limpiar el entorno ejecuta: $0 --limpiar"
