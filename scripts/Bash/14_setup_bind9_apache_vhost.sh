#!/usr/bin/env bash
# ==============================================================================
# Script: 14_setup_bind9_apache_vhost.sh
# Curso: Intercomunicación y Seguridad en Redes
# Práctica: Práctica DNS con BIND (Zonas Directa e Inversa + Apache VirtualHost)
# Descripción:
#   Automatiza la instalación y configuración integrada de:
#   1. Servidor DNS BIND9 con zona directa (lab.local) y zona inversa
#      (in-addr.arpa) validando sintaxis con named-checkconf y named-checkzone.
#   2. Servidor Web Apache2 con VirtualHost para lab.local / www.lab.local
#      sirviendo contenido desde /var/www/lab.local.
#   3. Pruebas de resolución directa, inversa (PTR) y petición HTTP con curl.
# Uso:
#   chmod +x 14_setup_bind9_apache_vhost.sh
#   sudo ./14_setup_bind9_apache_vhost.sh [dominio] [ip_servidor]
#   Ejemplo: sudo ./14_setup_bind9_apache_vhost.sh lab.local 192.168.50.20
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere privilegios root (sudo)."
    exit 1
fi

DOMINIO="${1:-lab.local}"
IP_SERVIDOR="${2:-192.168.50.20}"

# Extraer octetos de la IP para construir la zona inversa automáticamente
IFS='.' read -r OCT1 OCT2 OCT3 OCT4 <<< "$IP_SERVIDOR"
ZONA_INVERSA="${OCT3}.${OCT2}.${OCT1}.in-addr.arpa"
ARCHIVO_DIRECTA="/etc/bind/db.${DOMINIO}"
ARCHIVO_INVERSA="/etc/bind/db.${OCT1}.${OCT2}.${OCT3}"
SERIAL=$(date +"%Y%m%d01")

echo "=== 1. Instalando BIND9, utilidades DNS y Apache2 ==="
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils apache2 curl

echo "=== 2. Configurando zonas en /etc/bind/named.conf.local ==="
cp /etc/bind/named.conf.local "/etc/bind/named.conf.local.bak_$(date +%F_%H%M%S)" 2>/dev/null || true

cat << EOF > /etc/bind/named.conf.local
// Configuración generada para práctica DNS con BIND9
zone "${DOMINIO}" {
    type master;
    file "${ARCHIVO_DIRECTA}";
};

zone "${ZONA_INVERSA}" {
    type master;
    file "${ARCHIVO_INVERSA}";
};
EOF

echo "=== 3. Creando archivo de Zona Directa (${ARCHIVO_DIRECTA}) ==="
cat << EOF > "$ARCHIVO_DIRECTA"
\$TTL 604800
@   IN  SOA ns.${DOMINIO}. admin.${DOMINIO}. (
            ${SERIAL}   ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  ns.${DOMINIO}.
ns  IN  A   ${IP_SERVIDOR}
www IN  A   ${IP_SERVIDOR}
@   IN  A   ${IP_SERVIDOR}
EOF

echo "=== 4. Creando archivo de Zona Inversa (${ARCHIVO_INVERSA}) ==="
cat << EOF > "$ARCHIVO_INVERSA"
\$TTL 604800
@   IN  SOA ns.${DOMINIO}. admin.${DOMINIO}. (
            ${SERIAL}   ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@       IN  NS  ns.${DOMINIO}.
${OCT4} IN  PTR www.${DOMINIO}.
EOF

echo "=== 5. Validando sintaxis de BIND9 y reiniciando servicio ==="
named-checkconf
named-checkzone "$DOMINIO" "$ARCHIVO_DIRECTA"
named-checkzone "$ZONA_INVERSA" "$ARCHIVO_INVERSA"
systemctl restart bind9
systemctl enable bind9

echo "=== 6. Configurando VirtualHost de Apache2 para ${DOMINIO} ==="
WEB_ROOT="/var/www/${DOMINIO}"
mkdir -p "$WEB_ROOT"

cat << EOF > "${WEB_ROOT}/index.html"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>${DOMINIO}</title>
</head>
<body>
    <h1>Servidor Web ${DOMINIO}</h1>
    <p>El dominio se resolvió correctamente mediante DNS (BIND9) en ${IP_SERVIDOR}.</p>
</body>
</html>
EOF

chown -R www-data:www-data "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"

cat << EOF > "/etc/apache2/sites-available/${DOMINIO}.conf"
<VirtualHost *:80>
    ServerName ${DOMINIO}
    ServerAlias www.${DOMINIO}
    DocumentRoot ${WEB_ROOT}

    <Directory ${WEB_ROOT}>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${DOMINIO}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMINIO}_access.log combined
</VirtualHost>
EOF

a2ensite "${DOMINIO}.conf"
a2dissite 000-default.conf || true
apachectl configtest
systemctl reload apache2

echo "=== 7. Verificando resolución DNS directa e inversa contra ${IP_SERVIDOR} ==="
dig @"$IP_SERVIDOR" "www.${DOMINIO}" +short
dig @"$IP_SERVIDOR" -x "$IP_SERVIDOR" +short

echo "=== 8. Probando respuesta HTTP del VirtualHost ==="
curl -s -H "Host: www.${DOMINIO}" "http://127.0.0.1"
echo
echo "[OK] Laboratorio BIND9 + Apache2 configurado exitosamente."

