#!/usr/bin/env bash
# ==============================================================================
# Script: 15_mecanismos_seguridad_openssl.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Práctica Guiada - Mecanismos de Seguridad en Linux (OpenSSL)
# Descripción:
#   Ejecuta de forma automatizada las 4 fases de la práctica de criptografía:
#   - Parte 1: Cifrado simétrico por bloques (AES-256-CBC) y por flujo (RC4).
#   - Parte 2: Funciones Hash (SHA-256 y MD5) y código MAC (HMAC-SHA256).
#   - Parte 3: Cifrado asimétrico RSA (par de llaves 2048 bits, pkeyutl).
#   - Parte 4: Firma digital y verificación con RSA + SHA-256.
# Uso:
#   chmod +x 15_mecanismos_seguridad_openssl.sh
#   ./15_mecanismos_seguridad_openssl.sh [--ejecutar | --limpiar]
# ==============================================================================

set -euo pipefail

LAB_DIR="${PWD}/openssl_crypto_lab"
PASS_DEMO="1234"
HMAC_KEY="clave_secreta"

if [[ "${1:-}" == "--limpiar" ]]; then
    rm -rf "$LAB_DIR"
    echo "[OK] Directorio de laboratorio '$LAB_DIR' eliminado."
    exit 0
fi

mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

echo "La seguridad es esencial en redes modernas." > mensaje.txt
echo "[+] Archivo base creado: $LAB_DIR/mensaje.txt"
cat mensaje.txt
echo

echo "============================================================"
echo " Parte 1: Cifrado Simétrico (AES-256-CBC)"
echo "============================================================"
openssl enc -aes-256-cbc -pbkdf2 -in mensaje.txt -out mensaje_cifrado.bin -pass "pass:${PASS_DEMO}"
openssl enc -aes-256-cbc -pbkdf2 -d -in mensaje_cifrado.bin -out mensaje_descifrado.txt -pass "pass:${PASS_DEMO}"
echo "[+] Texto descifrado con AES-256-CBC:"
cat mensaje_descifrado.txt
echo

echo "============================================================"
echo " Parte 2: Funciones Hash (SHA-256, MD5) y MAC (HMAC-SHA256)"
echo "============================================================"
echo "[+] Resumen SHA-256:"
openssl dgst -sha256 mensaje.txt
echo "[+] Resumen MD5:"
openssl dgst -md5 mensaje.txt
echo "[+] Código de Autenticación de Mensajes (HMAC-SHA256):"
openssl dgst -sha256 -hmac "$HMAC_KEY" mensaje.txt
echo

echo "============================================================"
echo " Parte 3: Cifrado Asimétrico con RSA (2048 bits)"
echo "============================================================"
openssl genrsa -out privada.pem 2048 2>/dev/null
openssl rsa -in privada.pem -pubout -out publica.pem 2>/dev/null
chmod 600 privada.pem

openssl pkeyutl -encrypt -inkey publica.pem -pubin -in mensaje.txt -out mensaje_cifrado_rsa.bin
openssl pkeyutl -decrypt -inkey privada.pem -in mensaje_cifrado_rsa.bin -out mensaje_descifrado_rsa.txt

echo "[+] Texto descifrado con llave privada RSA:"
cat mensaje_descifrado_rsa.txt
echo

echo "============================================================"
echo " Parte 4: Firma Digital y Verificación (RSA + SHA-256)"
echo "============================================================"
openssl dgst -sha256 -sign privada.pem -out firma.bin mensaje.txt
echo "[+] Resultado de verificación de la firma digital:"
openssl dgst -sha256 -verify publica.pem -signature firma.bin mensaje.txt

echo
echo "[OK] Todos los archivos generados se encuentran en: $LAB_DIR"
ls -lh "$LAB_DIR"

