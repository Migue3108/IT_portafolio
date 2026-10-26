# 🛡️ Portafolio de Infraestructura TI, Redes y Ciberseguridad

**Autor:** Miguel Ángel De La Cruz Espinosa ([@Migue3108](https://github.com/Migue3108))

Repositorio de proyectos prácticos, laboratorios técnicos y scripts de automatización enfocados en **Administración de Sistemas Linux/Windows**, **Infraestructura de Redes**, **Servicios de Red** y **Ciberseguridad (Red Team / Blue Team)**.

---

## 📂 Estructura del Repositorio

```text
IT_portafolio/
├── Informe_Final_RedTeam_BlueTeam_Linux_COMPLETO.pdf   # Proyecto: Ataque y defensa de infraestructura Linux
├── proyecto_linux_administracion_de_una_red.pdf        # Proyecto: Administración integral de una red Linux segura
├── Test_IT_MiguelAngelDeLaCruzEspinosa.pdf             # Evaluación técnica de Infraestructura TI (Windows/Redes/VM)
├── curso_Administracion_de_redes_practicas/            # Prácticas de administración de sistemas y redes en Linux
├── curso_intercomunicacion_y_seguridad_en_redes/       # Prácticas de servicios DNS, criptografía, auditoría y seguridad
└── scripts/
    ├── Bash/                                           # 19 scripts de automatización, redes y seguridad en Linux
    ├── PowerShell/                                     # Scripts de automatización Windows Server, CIM/WMI y VirtualBox
    └── sourcefolder/                                   # Documentos fuente y recursos de prueba para respaldos
```

---

## 🚀 Proyectos Principales

| Proyecto | Documento | Tecnologías y Alcance |
| :--- | :--- | :--- |
| **1. Red Team vs Blue Team en Infraestructura Linux** | [`Informe_Final_RedTeam_BlueTeam_Linux_COMPLETO.pdf`](./Informe_Final_RedTeam_BlueTeam_Linux_COMPLETO.pdf) | Diseño de red multi-segmento con **Netplan**, despliegue de servicios (SSH, FTP, DNS), reconocimiento con **Nmap**, pruebas de fuerza bruta controlada y defensa activa con **Hardening SSH (puerto 2222)**, **UFW**, **Fail2ban**, **Suricata IDS/IPS** y **Wazuh SIEM**. |
| **2. Administración Integral de una Red Linux Segura** | [`proyecto_linux_administracion_de_una_red.pdf`](./proyecto_linux_administracion_de_una_red.pdf) | Arquitectura Servidor-Cliente en **Ubuntu Server**, direccionamiento estático con **Netplan**, control de acceso y permisos por grupos (`/opt/proyectos`), volúmenes lógicos **LVM** (`pvcreate`, `vgcreate`, `lvcreate`), cuotas de disco (`quota`), respaldos automatizados con **Cron + Syslog + SCP** y firewall **UFW**. |
| **3. IT Infrastructure Assessment (PolyWorks)** | [`Test_IT_MiguelAngelDeLaCruzEspinosa.pdf`](./Test_IT_MiguelAngelDeLaCruzEspinosa.pdf) | Automatización de respaldos con política de retención en **PowerShell**, monitoreo de métricas del sistema vía **CIM/WMI**, cálculo de **Subnetting IPv4** (`172.17.0.0/16` a `/21`), aprovisionamiento desatendido de máquinas virtuales con **VBoxManage + Task Scheduler** y diseño de **Active Directory (`acme.local`)**. |

---

## 🐧 Catálogo de Scripts en Bash (`scripts/Bash/`)

Scripts desarrollados como referencia ejecutable y caja de herramientas a partir de las prácticas de laboratorio y proyectos finales:

### Administración de Sistemas y Redes
| Script | Descripción | Práctica / Proyecto Relacionado |
| :--- | :--- | :--- |
| [`01_infopc_hardware.sh`](./scripts/Bash/01_infopc_hardware.sh) | Inspección de CPU (`/proc/cpuinfo`), kernel (`uname -r`), `runlevel`, uso de disco y comandos de parada del sistema (`shutdown`, `halt`, `reboot`, `init`). | Práctica 1 - Comandos de parada e info de hardware |
| [`02_datos_usuario_sistema.sh`](./scripts/Bash/02_datos_usuario_sistema.sh) | Captura interactiva de datos de usuario + `/etc/passwd`, auditoría de bloques e inodos (`df -h`, `df -i`), listado de procesos y estado de Apache2. | Práctica 2 - Linux Administración de Redes |
| [`03_menu_procesos_y_calculadora.sh`](./scripts/Bash/03_menu_procesos_y_calculadora.sh) | Menú administrativo con validación de usuario `root` (`ps`, `pstree`, redirección) y calculadora aritmética en CLI usando `expr`. | Ejercicios de Scripts: Menú y Calculadora |
| [`04_enlaces_inodos_demo.sh`](./scripts/Bash/04_enlaces_inodos_demo.sh) | Demostración práctica de enlaces duros (`ln`), enlaces simbólicos (`ln -s`), persistencia de inodos (`ls -li`) y resolución de rutas relativas. | Práctica - Enlaces |
| [`05_integridad_hashes_gpg.sh`](./scripts/Bash/05_integridad_hashes_gpg.sh) | Generación y verificación de resúmenes criptográficos (`MD5`, `SHA-1`, `SHA-256`, `SHA-512`) y cifrado simétrico de archivos con `gpg -c`. | Práctica MD5 y SHA |
| [`06_gestion_usuarios_grupos.sh`](./scripts/Bash/06_gestion_usuarios_grupos.sh) | Automatización de `useradd`, `usermod`, políticas de caducidad con `chage`, gestión de grupos (`groupadd`) y auditoría con `pwck`. | Práctica Gestión de Usuarios |
| [`07_auditoria_kernel_pci.sh`](./scripts/Bash/07_auditoria_kernel_pci.sh) | Auditoría de buses PCI (`lspci -v`), `/proc/partitions` y gestión de módulos del kernel (`lsmod`, `modinfo`, `modprobe`). | Práctica 9 - Módulos del Kernel |
| [`08_setup_cups_impresion.sh`](./scripts/Bash/08_setup_cups_impresion.sh) | Instalación y configuración del servidor de impresión **CUPS** y `cups-pdf`, permisos `lpadmin` y visibilidad de trabajos (`JobPrivateValues none`). | Práctica CUPS |
| [`09_setup_samba_server.sh`](./scripts/Bash/09_setup_samba_server.sh) | Despliegue de servidor de archivos **Samba SMB/CIFS** (`[IngenieriaShare]`), permisos SGID (`2775`), validación `testparm` y reglas UFW. | Práctica Servicio Samba |
| [`10_lvm_cuotas_disco.sh`](./scripts/Bash/10_lvm_cuotas_disco.sh) | Creación de volúmenes físicos, grupos y volúmenes lógicos **LVM**, montaje persistente en `/etc/fstab` y asignación de cuotas por usuario (`setquota`). | Proyecto Final Administración de Red Linux |
| [`11_backup_diario_red.sh`](./scripts/Bash/11_backup_diario_red.sh) | Respaldo comprimido `.tar.gz` con marca de tiempo, registro de eventos en `/var/log/syslog` (`logger`), tarea en `cron` y transferencia por `scp`. | Proyecto Final Administración de Red Linux |

### Servicios de Red, Criptografía y Ciberseguridad
| Script | Descripción | Práctica / Proyecto Relacionado |
| :--- | :--- | :--- |
| [`12_servicio_universal_ssh_web.sh`](./scripts/Bash/12_servicio_universal_ssh_web.sh) | Aprovisionamiento de acceso remoto **OpenSSH Server** y servidor web **Apache2** con segmentación en firewall **UFW**. | Práctica 1 - Servicio Universal |
| [`13_diagnostico_dns_cli.sh`](./scripts/Bash/13_diagnostico_dns_cli.sh) | Diagnóstico DNS completo (`dig`, `host`, `nslookup`, `whois`, `traceroute`, `dig +trace`), auditoría SPF/DMARC, propagación global y captura en puerto `53` con `tcpdump`. | Prácticas 2 y 3 - Herramientas y Comandos DNS |
| [`14_setup_bind9_apache_vhost.sh`](./scripts/Bash/14_setup_bind9_apache_vhost.sh) | Configuración automatizada de **BIND9** con zona directa (`lab.local`) e inversa (`in-addr.arpa`) integrada con VirtualHost en **Apache2**. | Práctica DNS con BIND |
| [`15_mecanismos_seguridad_openssl.sh`](./scripts/Bash/15_mecanismos_seguridad_openssl.sh) | Suite práctica con **OpenSSL**: cifrado simétrico `AES-256-CBC`, funciones hash, `HMAC-SHA256`, llaves asimétricas `RSA 2048` y firma digital. | Práctica Mecanismos de Seguridad en Linux |
| [`16_auditoria_enumeracion_red.sh`](./scripts/Bash/16_auditoria_enumeracion_red.sh) | Pipeline de reconocimiento y enumeración con `nmap`, `smbclient`, `rpcclient` (null session), `enum4linux`, `whatweb`, `nikto`, `gobuster` y banner grabbing. | Práctica Enumeración en Ciberseguridad |
| [`17_deteccion_mitigacion_rootkits.sh`](./scripts/Bash/17_deteccion_mitigacion_rootkits.sh) | Detección de rootkits y auditoría defensiva con `chkrootkit`, `rkhunter` y `lynis`, análisis forense básico y mitigación con `auditd`. | Práctica Detección y Mitigación de Rootkits |
| [`18_calculadora_ipv6_prefijos.sh`](./scripts/Bash/18_calculadora_ipv6_prefijos.sh) | Expansión y compresión de direcciones IPv6, cálculo de prefijos CIDR y resolución de los ejercicios de laboratorio IPv6. | Ejercicios IPv6 |
| [`19_redteam_blueteam_hardening_monitor.sh`](./scripts/Bash/19_redteam_blueteam_hardening_monitor.sh) | Monitoreo en tiempo real de fuerza bruta SSH (`monitor.sh`), hardening de `sshd_config` (puerto `2222`), firewall `UFW`, `Fail2ban` y estado de `Suricata`/`Wazuh`. | Proyecto Final Red Team vs Blue Team |

---

## 💻 Scripts en PowerShell (`scripts/PowerShell/`)

| Script | Descripción |
| :--- | :--- |
| [`Q1_backup_SourceFolder.ps1`](./scripts/PowerShell/Q1_backup_SourceFolder.ps1) | Respaldo automatizado de directorios con marca de tiempo, registro automático de tarea programada diaria (`02:00 AM`) como `SYSTEM` y política de retención de las 10 copias más recientes. |
| [`Q2_SystemInfo.ps1`](./scripts/PowerShell/Q2_SystemInfo.ps1) | Recolección de métricas de rendimiento en Windows (uso de CPU, memoria RAM total/libre/usada y espacio en disco `C:`) mediante **CIM/WMI** (`Get-CimInstance`) exportadas a reporte `.txt`. |
| [`Q4_Init_PolyWorksVM.ps1`](./scripts/PowerShell/Q4_Init_PolyWorksVM.ps1) | Creación y configuración automatizada de máquina virtual en **VirtualBox** (`VBoxManage.exe`), disco virtual `.vdi`, controlador SATA y programación de encendido headless (`09:00`) y apagado (`23:00`). |
| [`erasingVM.ps1`](./scripts/PowerShell/erasingVM.ps1) | Script de limpieza para eliminar las tareas programadas de Windows, apagar la máquina virtual y eliminar sus discos asociados en VirtualBox. |

---

## 📚 Documentación de Prácticas por Curso

### 1. [`curso_Administracion_de_redes_practicas/`](./curso_Administracion_de_redes_practicas/)
- **Práctica 1:** Comandos de parada del sistema (`shutdown`, `init`, `runlevel`) y script `infopc.sh`.
- **Práctica 2:** Administración en Linux, manejo de archivos, inodos (`df -i`), procesos y servicio Apache.
- **Ejercicios de Scripts:** Menú de procesos para `root` y calculadora en Bash.
- **Práctica Enlaces:** Enlaces duros (`ln`), simbólicos (`ln -s`) y comportamiento de inodos.
- **Práctica MD5 y SHA:** Verificación de integridad con funciones hash y cifrado con GPG.
- **Práctica Gestión de Usuarios:** Administración de cuentas, grupos, expiración (`chage`) y `pwck`.
- **Práctica 9 - Módulos del Kernel:** Inspección de dispositivos PCI (`lspci`) y módulos (`lsmod`, `modinfo`, `modprobe`).
- **Práctica CUPS:** Servidor de impresión en Linux e impresora virtual PDF.
- **Práctica Servicio Samba:** Recursos compartidos SMB/CIFS y control de acceso por grupos.

### 2. [`curso_intercomunicacion_y_seguridad_en_redes/`](./curso_intercomunicacion_y_seguridad_en_redes/)
- **Práctica 1 - Servicio Universal:** Despliegue de OpenSSH Server, Apache2 y firewall UFW.
- **Práctica 2 - Herramientas DNS:** Análisis WHOIS, registros MX/SPF/DMARC y propagación global (Anycast vs Estático).
- **Práctica 3 - Comandos DNS en Linux:** Diagnóstico con `dig`, `host`, `nslookup`, `traceroute`, `dig +trace` y captura con `tcpdump`.
- **Práctica DNS con BIND:** Zonas directa e inversa en BIND9 e integración con VirtualHost en Apache2.
- **Ejercicios IPv6:** Expansión, compresión y cálculo de prefijos de red IPv6.
- **Práctica Mecanismos de Seguridad en Linux:** Cifrado simétrico, asimétrico (RSA), hashes, HMAC y firmas digitales con OpenSSL.
- **Práctica Servicio Samba:** Configuración segura de compartición de archivos en red.
- **Práctica Enumeración:** Reconocimiento y enumeración de servicios con Nmap, Enum4linux, SMBClient, RPCClient, Nikto y Gobuster.
- **Práctica Rootkits:** Simulación de IoCs, detección con RKHunter/Chkrootkit/Lynis, análisis forense y remediación con Auditd.
- **Presentación OWASP:** [`Encrytpion fail.pptx`](./curso_intercomunicacion_y_seguridad_en_redes/Encrytpion%20fail.pptx) — Análisis de fallos criptográficos, herramientas de detección (TruffleHog, Gitleaks, Testssl.sh, Semgrep) y buenas prácticas Zero Trust.
