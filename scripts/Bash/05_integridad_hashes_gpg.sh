#!/usr/bin/env bash
# ==============================================================================
# Script: 05_integridad_hashes_gpg.sh
# Curso: Administración de Redes
# Práctica: Práctica MD5 y SHA (Integridad vs Confidencialidad con GPG)
# Descripción:
#   Permite calcular y verificar resúmenes criptográficos de integridad
#   (MD5, SHA-1, SHA-256, SHA-512) de cualquier archivo y cifrarlo/descifrarlo
#   simétricamente con GPG (AES-256).
# Uso:
#   chmod +x 05_integridad_hashes_gpg.sh
#   ./05_integridad_hashes_gpg.sh --hashes <archivo>
#   ./05_integridad_hashes_gpg.sh --verificar <archivo.sha256>
#   ./05_integridad_hashes_gpg.sh --cifrar <archivo>
#   ./05_integridad_hashes_gpg.sh --descifrar <archivo.gpg>
# ==============================================================================

set -euo pipefail

uso() {
    cat << EOF
Uso: $0 <opción> [archivo]

Opciones:
  --hashes <archivo>          Calcula MD5, SHA1, SHA256 y SHA512 y genera <archivo>.sha256
  --verificar <archivo.sha256> Verifica la integridad usando sha256sum -c
  --cifrar <archivo>          Cifra simétricamente el archivo con 'gpg -c' (crea .gpg)
  --descifrar <archivo.gpg>   Descifra un archivo .gpg con 'gpg'
  --demo                      Ejecuta una prueba completa con un archivo temporal
EOF
}

calcular_hashes() {
    local archivo="$1"
    if [[ ! -f "$archivo" ]]; then
        echo "[ERROR] El archivo '$archivo' no existe."
        exit 1
    fi

    echo "============================================================"
    echo " Reporte de Hashes de Integridad para: $archivo"
    echo "============================================================"
    echo "[+] MD5 (128 bits / 32 hex):"
    md5sum "$archivo"
    echo
    echo "[+] SHA-1 (160 bits / 40 hex):"
    sha1sum "$archivo"
    echo
    echo "[+] SHA-256 (256 bits / 64 hex):"
    sha256sum "$archivo" | tee "${archivo}.sha256"
    echo
    echo "[+] SHA-512 (512 bits / 128 hex):"
    sha512sum "$archivo"
    echo
    echo "[OK] Manifiesto SHA-256 guardado en: ${archivo}.sha256"
}

verificar_hash() {
    local manifiesto="$1"
    echo "[+] Verificando integridad con sha256sum -c '$manifiesto'..."
    sha256sum -c "$manifiesto"
}

cifrar_gpg() {
    local archivo="$1"
    echo "[+] Cifrando '$archivo' con GPG simétrico (gpg -c)..."
    gpg -c "$archivo"
    echo "[OK] Archivo cifrado generado: ${archivo}.gpg"
}

descifrar_gpg() {
    local archivo_gpg="$1"
    echo "[+] Descifrando '$archivo_gpg' con GPG..."
    gpg "$archivo_gpg"
}

demo_practica() {
    local archivo_demo="miarchivo_demo.txt"
    echo "Práctica de integridad MD5/SHA y cifrado GPG - Miguel Angel De La Cruz Espinosa" > "$archivo_demo"
    calcular_hashes "$archivo_demo"
    echo
    verificar_hash "${archivo_demo}.sha256"
    rm -f "$archivo_demo" "${archivo_demo}.sha256"
}

case "${1:-}" in
    --hashes)    calcular_hashes "${2:-}" ;;
    --verificar) verificar_hash "${2:-}" ;;
    --cifrar)    cifrar_gpg "${2:-}" ;;
    --descifrar) descifrar_gpg "${2:-}" ;;
    --demo)      demo_practica ;;
    *)           uso ;;
esac
