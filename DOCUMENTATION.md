# Documentación del Repositorio

## Estructura General

```
/
├── .directory              # Icono de carpeta (KDE) — sin cambios
├── .gitignore              # Ignora node_modules/ y .env* — sin cambios
├── LICENSE                 # Apache License 2.0 — sin cambios
├── README.md               # README principal — sin cambios
├── DOCUMENTATION.md        # Este archivo — sin cambios
│
├── 01_disk_utilities/      # Utilidades ejecutables para gestión de discos e ISOs
│   ├── 00_iso-flasher.sh   # Graba ISOs en USB/disco con verificación
│   ├── 02_disk-formatter.sh # Formatea unidades (fat32, ext4, btrfs, etc.)
│   └── 04_iso-hybrid-writer.sh # Limpieza profunda + grabación ISO rápida
│
├── 02_os_installers/       # Scripts de post-instalación por distro, guías y actualizaciones
│   ├── arch/               # Scripts y guías específicas para Arch Linux
│   │   ├── dms-installer.sh # Instala Dank Material Shell en Arch
│   │   ├── endeavouros-guide.md # Guía post-instalación de EndeavourOS
│   │   ├── manjaro-guide.md # Guía post-instalación de Manjaro KDE
│   │   ├── pkg-installer.sh # Instalación masiva de paquetes (pacman + AUR)
│   │   ├── pkg-list.sh      # Lista de paquetes de Arch (referencia)
│   │   ├── update-automate.sh # Actualización automática completa para Arch/Manjaro
│   │   └── wireguard-gen.sh # Generador de configuración WireGuard en Arch
│   │
│   └── debian/             # Scripts específicos para Debian/Ubuntu
│       ├── dms-installer.sh # Instala DMS en Debian 13/Ubuntu
│       ├── pkg-installer.sh # Instalación de paquetes en Debian (apt + flatpak)
│       ├── update-automate.sh # Actualización automática completa para Debian/Ubuntu
│       └── wireguard-gen.sh # Generador de configuración WireGuard en Debian
│
├── 03_network_vpn/         # Configuraciones y tutoriales de red y VPN
│   ├── 26_wireguard-server.conf # Configuración modelo del servidor WireGuard
│   ├── 27_wireguard-deb-walkthrough.sh # Tutorial completo de WireGuard en Debian
│   └── 29_wireguard-auto-setup.sh # Configuración automática de servidor WireGuard
│
├── 04_rescue_ssh/          # Herramientas de rescate de sistema, SSH y utilidades varias
│   ├── 22_pgen.py              # Generador de contraseñas (CLI + Servicio HTTP Daemon)
│   ├── install-service.sh      # Script de instalación para el demonio systemd
│   ├── pgen.service            # Archivo de servicio systemd
│   ├── 24_ubuntu-macos-theme.sh # Transforma Ubuntu Cinnamon al estilo visual de macOS
│   ├── 31_system-rescue.sh     # Sistema de diagnóstico y recuperación de emergencia
│   ├── 33_ssh-multi-account.sh # Configuración SSH automática para múltiples cuentas Git
│   └── 35_lambda-utils.ts      # Utilidad TypeScript tipo "Excel" (Math, Text, Date, etc.)
│
└── 05_shell_configs/       # Configuraciones y funciones para la shell (Zsh/Bash)
    ├── .zshrc              # Configuración principal de Zsh cargada en el sistema
    ├── 36_zsh-config       # Detalles de aliases, shortcuts y entorno de Zsh
    ├── 37_bash-config      # Entorno equivalente para Bash
    └── 38_zsh-functions    # Funciones avanzadas de Zsh (Git, QEMU, descargas, hashes)
```

---

## Archivos Raíz (sin cambios)

### `.directory`
- **Tipo**: Configuración KDE
- **Propósito**: Define el icono de la carpeta como `folder-yellow` para navegadores de archivos compatibles.

### `.gitignore`
- **Tipo**: Configuración Git
- **Propósito**: Evita la inclusión de directorios temporales, dependencias (`node_modules/`) y archivos de configuración sensibles (`.env*`).

### LICENSE
- **Tipo**: Licencia
- **Propósito**: Licencia Apache 2.0.

### README.md
- **Tipo**: Documentación principal
- **Propósito**: Guía rápida de inicio, descripción general del repositorio y ejemplos de uso de las principales funciones de la shell.

---

## `01_disk_utilities/` — Utilidades de Disco e ISO

### `00_iso-flasher.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Graba una imagen ISO en un dispositivo de almacenamiento (USB o disco interno) con validación de integridad.
- **Banderas**:
  - `--device /dev/sdx` — Dispositivo de destino (opcional, interactivo si se omite).
  - `--file /ruta/archivo.iso` — Ruta de la imagen ISO (opcional, abre un selector zenity o pide entrada por teclado).
- **Flujo**: Verifica privilegios root → comprueba herramientas (`pv`, `eject`, `lsblk`, `wipefs`) → selecciona la ISO → selecciona el dispositivo de destino → solicita confirmación → desmonta particiones y limpia firmas previas → graba usando `dd` con barra de progreso → compara con `cmp` → expulsa si es un USB externo.

### `02_disk-formatter.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Formatea unidades de almacenamiento estableciendo una tabla de particiones GPT limpia.
- **Banderas**:
  - `--device /dev/sdx` — Dispositivo de destino.
  - `--fs <tipo>` — Sistema de archivos deseado (`fat32`, `exfat`, `ntfs`, `ext4`, `btrfs`, `xfs`, `f2fs`).
  - `--name <nombre>` — Etiqueta o etiqueta de volumen para la partición.
- **Sistemas de archivos**: Soporta restricciones específicas (como el límite de 11 caracteres para `fat32` y 12 para `xfs`).

### `04_iso-hybrid-writer.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Escribe una ISO rápidamente realizando previamente un borrado seguro de la cabecera de particiones (Zerofill).
- **Flujo**: Desmonta → borra firmas previas → escribe 20 MB de ceros con `dd` → escribe la ISO usando `dd` con sincronización forzada (`oflag=sync`). A diferencia del flasher básico, prioriza la velocidad y el borrado inicial y prescinde del comando `cmp`.

---

## `02_os_installers/` — Instaladores de Sistema Operativo y Guías

### `arch/pkg-installer.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Script de post-instalación de software para Arch Linux y derivadas.
- **Acciones**: Actualiza repositorios oficiales → instala utilidades esenciales, navegadores (Brave, Librewolf), reproductores de medios, herramientas de desarrollo (Cursor, Neovim) y de sistema (Timeshift) → compila e instala el asistente de AUR `yay` → instala paquetes de AUR de forma automatizada → limpia la caché de paquetes de pacman.

### `arch/dms-installer.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Instalador automatizado para Dank Material Shell (DMS) en entornos Wayland/Niri en Arch.
- **Acciones**: Configura repositorios y dependencias necesarias → instala DMS y el compositor Niri → aplica reglas visuales específicas (esquinas redondeadas, bordes activos).

### `arch/wireguard-gen.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Generador dinámico de perfiles de cliente WireGuard en sistemas Arch.
- **Características**: Detecta automáticamente si se ejecuta sobre el host o entornos virtualizados (Docker, Podman) → obtiene la IP pública automáticamente → calcula el direccionamiento CIDR disponible → genera par de claves y código QR → exporta a archivo zip de distribución para móviles.

### `arch/pkg-list.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Archivo de referencia rápida que lista más de 60 paquetes recomendados para sistemas Arch Linux, agrupados por categorías útiles para copiar/pegar rápidamente.

### `arch/endeavouros-guide.md`
- **Tipo**: Documentación Markdown
- **Propósito**: Guía detallada que describe pasos necesarios tras instalar EndeavourOS: configuración optimizada de mirrors, GRUB, Chaotic-AUR, Plymouth y códecs de audio/video.

### `arch/manjaro-guide.md`
- **Tipo**: Documentación Markdown
- **Propósito**: Guía de post-instalación orientada a Manjaro KDE: optimización de base-devel, habilitación limpia de Flatpak/Snap, aplicación de atajos del sistema y tematización Yaru.

### `arch/update-automate.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Mantenimiento y actualización completa en un solo comando para Arch Linux y Manjaro.
- **Acciones**: Sincroniza y actualiza paquetes oficiales → actualiza el catálogo de paquetes de AUR (mediante `yay`) → actualiza dependencias Snap y Flatpak instaladas → recopila y elimina dependencias huérfanas (`pacman -Rns`) → reduce la caché de paquetes locales dejando solo las dos versiones más recientes.

### `debian/pkg-installer.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Script completo de post-instalación de software para Debian, Ubuntu y derivadas.
- **Acciones**: Actualiza APT → añade repositorios externos seguros (VS Code, Brave, Mullvad, Librewolf, Fastfetch PPA) → instala paquetes nativos de desarrollo y multimedia → inicializa Flatpak e instala aplicaciones de escritorio de uso común → descarga herramientas AppImage como Obsidian y LM Studio → configura Oh My Zsh con plugins básicos de ayuda.

### `debian/dms-installer.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Instalador de Dank Material Shell para Debian 13 (Trixie) y Ubuntu.
- **Características**: Presenta un menú interactivo configurable para realizar una instalación completa o modular (Qt6, compositor Niri, shell Noctalia) y compila Niri desde el código fuente oficial si es necesario.

### `debian/wireguard-gen.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Generador de configuraciones de cliente VPN WireGuard adaptado a entornos Debian/Ubuntu.
- **Nota**: A diferencia de la versión de Arch, usa direccionamiento estático interno predefinido para simplificar la configuración.

### `debian/update-automate.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Mantenimiento y actualización completa en un solo comando para Debian, Ubuntu y Linux Mint.
- **Acciones**: Sincroniza y realiza una actualización completa del sistema (`apt full-upgrade`) para asegurar la correcta transición de kernels y drivers → comprueba y actualiza de manera segura aplicaciones Snap y Flatpak → ejecuta una autolimpieza de dependencias residuales e inservibles en la caché local (`apt autoremove` y `autoclean`).

---

## `03_network_vpn/` — Redes y VPN (WireGuard)

### `26_wireguard-server.conf`
- **Tipo**: Configuración del servicio
- **Propósito**: Plantilla lista para producción para levantar un servidor WireGuard. Define la interfaz local `wg0` en la subred privada `10.200.0.0/24` en el puerto de escucha estándar `51820`, e incluye la plantilla preconfigurada para admitir 4 peers o clientes remotos de manera inmediata.

### `27_wireguard-deb-walkthrough.sh`
- **Shell**: `#!/usr/bin/zsh`
- **Propósito**: Guía instructiva comentada línea a línea para configurar WireGuard manualmente en Debian. Contiene ejemplos prácticos para generación de claves, enrutamiento, reenvío de puertos e indicaciones de redirección en routers domésticos ZTE F6640.

### `29_wireguard-auto-setup.sh`
- **Shell**: `#!/bin/zsh`
- **Propósito**: Despliegue inmediato y automatizado de un servidor VPN WireGuard en cualquier servidor Linux.
- **Características**: Autodetecta interfaces WAN → obtiene la IP pública exterior → ofrece soporte e integración opcional con DuckDNS → configura el firewall de red UFW → activa reenvío IP de kernel → genera perfiles móviles QR.

---

## `04_rescue_ssh/` — Rescate, SSH y Utilidades Varias

### `22_pgen.py`
- **Lenguaje**: Python 3
- **Propósito**: Generador criptográficamente seguro de contraseñas altamente configurable con soporte para múltiples tipos y modos.
- **Tipos de contraseña**:
  - `matricula`: Estilo matrícula española (4 números + 3 consonantes sin vocales, ej: `1234BCD`).
  - `secure`: Alfanumérico con caracteres especiales seguros de forma garantizada (ej: `t0VK}BV3xGY-`).
  - `alphanumeric`: Letras mayúsculas/minúsculas y dígitos sin símbolos.
  - `numeric`: PIN numérico de longitud variable.
  - `memorable`: Palabras aleatorias del diccionario unidas por guiones (estilo XKCD).
- **Modos de ejecución**:
  - **CLI**: Comando tradicional por terminal con argumentos (ej. `-t memorable -q 3`).
  - **Daemon HTTP**: Modulo servidor embebido (ej. `--serve --port 7777`) diseñado para systemd.
- **Servicio Systemd (`pgen.service` & `install-service.sh`)**:
  - Corre como microservicio de red local (`http://127.0.0.1:7777`). Instalado como `pgen`.
  - Permite generar contraseñas en cualquier parte del equipo o la red ejecutando llamadas simples como `curl http://localhost:7777` o en formato JSON con `curl "http://localhost:7777?format=json"`.
  - Configurado con hardening extremo de systemd (`DynamicUser=yes`, sandbox de kernel/home y ejecución de solo lectura).

### `24_ubuntu-macos-theme.sh`
- **Shell**: `#!/bin/bash` (anteriormente `ubuntu-macos-layout.sh`)
- **Propósito**: Transforma visualmente el escritorio Cinnamon en Ubuntu para asemejarse a la interfaz estética de macOS Big Sur o Monterey.
- **Acciones**: Instala dependencias del sistema → clona e instala de manera local los temas e iconos WhiteSur de vinceliuice → configura el buscador Rofi como Spotlight Search → establece la barra de tareas Plank inferior con un estilo minimalista transparente → aplica las claves de diseño a través de llamadas nativas de gsettings.

### `31_system-rescue.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Herramienta de recuperación y monitoreo del rendimiento de hardware en situaciones críticas de falta de respuesta.
- **Características**: Se puede instalar de manera global (`--install`) para añadir aliases rápidos. Cuenta con diagnóstico integral de memoria RAM ocupada, swap, temperatura y procesos zombie, comandos rápidos para vaciar de forma manual las cachés de memoria y un visualizador inmediato de puntuaciones de OOM (Out Of Memory) para neutralizar procesos rebeldes.

### `33_ssh-multi-account.sh`
- **Shell**: `#!/usr/bin/env zsh`
- **Propósito**: Crea de forma interactiva y configura automáticamente un gestor de identidades SSH para trabajar con múltiples cuentas en plataformas Git de manera transparente (GitHub, GitLab, servidores propios).
- **Acciones**: Genera claves separaradas e individuales usando cifrado moderno Ed25519 → escribe el archivo de configuración estructurado en `~/.ssh/config` para automatizar la selección de clave basándose en el host virtual → arranca e inyecta las credenciales en el agente SSH de forma persistente.

### `35_lambda-utils.ts`
- **Tipo**: Código TypeScript
- **Propósito**: Una biblioteca de funciones de utilidad estáticas que sirve como "navaja suiza" similar a las fórmulas de Excel para aplicaciones Node.js/TypeScript.
- **Grupos incluidos**: Métodos matemáticos avanzados (promedios, redondeos de precisión), formateo de textos (slugify, capitalización), conversión de unidades físicas y monedas (centavos a divisas visuales), solicitudes HTTP tolerantes a fallos (Axios con fallback nativo fetch), agrupamientos de arrays y validación avanzada de esquemas de datos.

---

## `05_shell_configs/` — Configuración de Shell (Zsh/Bash)

### `.zshrc`
- **Tipo**: Archivo de configuración oculto
- **Propósito**: El archivo de inicialización de Zsh completo que configura el prompt visual Powerlevel10k, carga de forma asíncrona gestores de plugins Zinit y Oh My Zsh, inicializa variables de entorno necesarias para herramientas modernas de desarrollo (como Bun, NPM, pnpm, Rust, NVM) y enlaza las definiciones complementarias.

### `36_zsh-config`
- **Tipo**: Configuración del entorno
- **Propósito**: Declara la lista enriquecida de alias del sistema de uso cotidiano (atajos de git, Docker, Docker Compose, shortcuts para eza, bat, ripgrep y zoxide) y despliega el banner dinámico interactivo mediante comandos Gum en cada inicio de terminal.

### `37_bash-config`
- **Tipo**: Configuración del entorno
- **Propósito**: Ofrece compatibilidad e igualdad de alias y funciones esenciales del sistema para terminales Bash, configurando además un histórico de comandos extendido y atajos de control ágiles de git (useGit) y validaciones criptográficas de hash.

### `38_zsh-functions`
- **Tipo**: Código de funciones Zsh
- **Propósito**: Librería modular que encapsula funciones de gran tamaño: envolturas para el uso de yt-dlp con cookies del navegador (descarga inteligente de video/música), comandos abreviados para la creación y arranque rápido de máquinas virtuales locales basadas en QEMU y utilidades git extendidas (onGitCommitPush, git branch selector).
