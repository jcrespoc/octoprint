# Lightweight OctoPrint & Raspberry Pi Camera Streamer

[![Docker Image](https://img.shields.io/badge/docker-jcrespoc311%2Foctoprint-blue?logo=docker)](https://hub.docker.com/r/jcrespoc311/octoprint)
[![Python Version](https://img.shields.io/badge/python-3.12--slim--bookworm-blue?logo=python)](https://www.python.org/)
[![Base OS](https://img.shields.io/badge/debian-12%20bookworm-red?logo=debian)](https://www.debian.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

[English](#english) | [Español](#español)

---

<a name="english"></a>
## English

### 🎯 Motivation & Why This Image?

The official OctoPrint Docker image ships an older Python version (3.10.18) and is very heavy (~1.8 GB).

This repository provides an optimized, production-ready stack specifically tailored for Raspberry Pi:

1. **Ultra-Lightweight & Clean Multi-Stage Build**:
   - Compilers and build dependencies (`gcc`, `libc6-dev`) are isolated to the build stage.
   - The final runtime is based on `python:3.12-slim-bookworm` with only minimal runtime packages (`gosu` for privilege dropping and static `ffmpeg` for timelapse rendering).
   - Eliminates unnecessary background daemons; a lightweight supervisor script manages OctoPrint process lifecycles.
2. **Modern Python 3.12 Runtime**:
   - Runs on modern **Python 3.12**, offering improved performance, lower memory usage, and modern security patches.
   - Persistent plugin storage: OctoPrint plugins are installed inside the persistent volume (`/octoprint/plugins`), preventing plugin losses across container updates.
3. **High-Performance Raspberry Pi `camera-streamer`**:
   - Replaces high-CPU MJPEG streaming with [ayufan/camera-streamer](https://github.com/ayufan/camera-streamer) via `libcamera`.
   - Native hardware acceleration on Raspberry Pi, low CPU footprint, low latency, and support for WebRTC, H.264, and MJPEG.
4. **Secure Non-Root Execution with Smart Permissions**:
   - Runs as an unprivileged user (`octoprint`, UID 1000).
   - Dynamically inspects the GID of serial devices (e.g. `/dev/ttyUSB0`) on startup and grants the container user serial access automatically.

---

### 📦 Services & Architecture

| Service | Image | Ports | Description |
| :--- | :--- | :--- | :--- |
| **octoprint** | `jcrespoc311/octoprint` | `80:5000` | OctoPrint server with timelapse support via static ffmpeg |
| **camera-streamer** | `jcrespoc311/camera-streamer` | `8080` (host) | High-performance `libcamera` video streaming for Raspberry Pi |

---

### 🚀 Getting Started

#### Option A: Run Pre-Built Images from Docker Hub (Recommended)

You can launch the stack immediately using the pre-built images published on Docker Hub under the `jcrespoc311` namespace.

1. Create a `docker-compose.yml` file:
   ```yaml
   services:
     octoprint:
       image: jcrespoc311/octoprint:latest
       container_name: octoprint
       restart: unless-stopped
       ports:
         - "80:5000"
       devices:
         - /dev/ttyUSB0:/dev/ttyUSB0
       volumes:
         - octoprint:/octoprint
       extra_hosts:
         - "host.docker.internal:host-gateway"
       environment:
         - TZ=Europe/Madrid

     camera-streamer:
       image: jcrespoc311/camera-streamer:latest
       container_name: camera-streamer
       restart: unless-stopped
       privileged: true
       network_mode: host
       volumes:
         - /run/udev:/run/udev:ro
         - /dev/video0:/dev/video0
       tmpfs:
         - /dev/shm:exec
       environment:
         - TZ=Europe/Madrid

   volumes:
     octoprint:
   ```

2. Pull images and start the services:
   ```bash
   docker compose up -d
   ```

3. Open your browser and navigate to:
   - OctoPrint Web UI: `http://<raspberry-pi-ip>`
   - Camera Streamer Interface: `http://<raspberry-pi-ip>:8080`

---

#### Option B: Build from Source

If you prefer building the images locally:

1. Clone this repository:
   ```bash
   git clone https://github.com/jcrespoc/octoprint.git
   cd octoprint
   ```

2. Build and run using Docker Compose:
   ```bash
   docker compose build
   docker compose up -d
   ```

Or build each image manually:

```bash
# Build OctoPrint
docker build -t jcrespoc311/octoprint:latest ./octoprint

# Build Camera Streamer (Raspberry Pi ARM64)
docker build -t jcrespoc311/camera-streamer:latest ./camera-streamer
```

---

#### Option C: Standalone `docker run` Commands

If you do not use Docker Compose, run the containers individually:

```bash
# 1. Create a volume for persistent OctoPrint data
docker volume create octoprint_data

# 2. Run OctoPrint
docker run -d \
  --name octoprint \
  --restart unless-stopped \
  -p 80:5000 \
  --device /dev/ttyUSB0:/dev/ttyUSB0 \
  -v octoprint_data:/octoprint \
  -e TZ=Europe/Madrid \
  jcrespoc311/octoprint:latest

# 3. Run Camera Streamer (Raspberry Pi camera)
docker run -d \
  --name camera-streamer \
  --restart unless-stopped \
  --privileged \
  --network host \
  -v /run/udev:/run/udev:ro \
  -v /dev/video0:/dev/video0 \
  --tmpfs /dev/shm:exec \
  -e TZ=Europe/Madrid \
  jcrespoc311/camera-streamer:latest
```

---

### ⚙️ OctoPrint Webcam Settings

After completing the initial OctoPrint wizard, configure the camera in **Settings -> Webcam & Timelapse**:

- **Stream URL**: `http://<raspberry-pi-ip>:8080/stream` (or WebRTC: `http://<raspberry-pi-ip>:8080/webrtc`)
- **Snapshot URL**: `http://<raspberry-pi-ip>:8080/snapshot`
- **FFmpeg path**: `/usr/bin/ffmpeg` (pre-installed and symlinked)

---

### 📄 License

Distributed under the MIT License. See `LICENSE` for details.

---

<br>
<hr>
<br>

<a name="español"></a>
## Español

### 🎯 Motivación y Justificación del Repositorio

La imagen Docker oficial de OctoPrint empaqueta una versión antigua de Python (3.10.18) y es muy pesada (~1.8 GB).

Este repositorio proporciona un entorno optimizado y ligero para placas Raspberry Pi:

1. **Contenedor Ultraligero (Multi-Stage Build)**:
   - Las herramientas de compilación (`gcc`, cabeceras C) solo residen en la etapa intermedia de construcción.
   - La imagen final se basa en `python:3.12-slim-bookworm` e incluye únicamente las dependencias de ejecución esenciales: `gosu` (gestión de privilegios) y binario estático de `ffmpeg` (para timelapses).
   - Sin demonios pesados en segundo plano: un bucle supervisor mínimo gestiona el ciclo de vida del servicio.
2. **Python 3.12 Actualizado**:
   - Utiliza **Python 3.12** sobre Debian Bookworm, garantizando mejor rendimiento, menor uso de memoria y actualizaciones de seguridad al día.
   - Directorio persistente de plugins en `/octoprint/plugins`, lo que evita la pérdida de extensiones al recrear el contenedor.
3. **Streamer de Cámara de Alto Rendimiento (`camera-streamer`)**:
   - Utiliza [ayufan/camera-streamer](https://github.com/ayufan/camera-streamer) a través de `libcamera`.
   - Aceleración por hardware nativa en Raspberry Pi, bajísima latencia y soporte moderno para WebRTC, H.264 y MJPEG.
4. **Ejecución Segura sin Root y Permisos Dinámicos**:
   - El proceso se ejecuta con un usuario sin privilegios (`octoprint`, UID 1000).
   - En el arranque detecta automáticamente el GID del dispositivo serie (`/dev/ttyUSB0`) y concede acceso al usuario sin necesidad de ejecutar como root.

---

### 📦 Servicios y Arquitectura

| Servicio | Imagen | Puertos | Descripción |
| :--- | :--- | :--- | :--- |
| **octoprint** | `jcrespoc311/octoprint` | `80:5000` | Servidor OctoPrint con soporte de timelapse (ffmpeg estático) |
| **camera-streamer** | `jcrespoc311/camera-streamer` | `8080` (host) | Servidor de streaming `libcamera` de alto rendimiento |

---

### 🚀 Instrucciones de Arranque

#### Opción A: Despliegue con Imágenes Precompiladas de Docker Hub

Las imágenes listas para usar están disponibles en Docker Hub bajo la cuenta `jcrespoc311`.

1. Crea o utiliza el archivo `docker-compose.yml`:
   ```yaml
   services:
     octoprint:
       image: jcrespoc311/octoprint:latest
       container_name: octoprint
       restart: unless-stopped
       ports:
         - "80:5000"
       devices:
         - /dev/ttyUSB0:/dev/ttyUSB0
       volumes:
         - octoprint:/octoprint
       extra_hosts:
         - "host.docker.internal:host-gateway"
       environment:
         - TZ=Europe/Madrid

     camera-streamer:
       image: jcrespoc311/camera-streamer:latest
       container_name: camera-streamer
       restart: unless-stopped
       privileged: true
       network_mode: host
       volumes:
         - /run/udev:/run/udev:ro
         - /dev/video0:/dev/video0
       tmpfs:
         - /dev/shm:exec
       environment:
         - TZ=Europe/Madrid

   volumes:
     octoprint:
   ```

2. Descarga las imágenes e inicia los contenedores:
   ```bash
   docker compose pull
   docker compose up -d
   ```

3. Accede desde tu navegador:
   - Panel web de OctoPrint: `http://<ip-de-tu-raspberry>`
   - Vista de camera-streamer: `http://<ip-de-tu-raspberry>:8080`

---

#### Opción B: Construcción Local desde el Código Fuente (Build)

Si prefieres compilar las imágenes en tu propio equipo:

1. Clona el repositorio:
   ```bash
   git clone https://github.com/jcrespoc/octoprint.git
   cd octoprint
   ```

2. Construye y arranca con Docker Compose:
   ```bash
   docker compose build
   docker compose up -d
   ```

O compila cada imagen de forma independiente:

```bash
# Compilar OctoPrint
docker build -t jcrespoc311/octoprint:latest ./octoprint

# Compilar Camera Streamer (Raspberry Pi ARM64)
docker build -t jcrespoc311/camera-streamer:latest ./camera-streamer
```

---

#### Opción C: Ejecución Directa con `docker run`

Si no utilizas Docker Compose, puedes iniciar los contenedores individualmente:

```bash
# 1. Crear volumen para datos persistentes
docker volume create octoprint_data

# 2. Iniciar OctoPrint
docker run -d \
  --name octoprint \
  --restart unless-stopped \
  -p 80:5000 \
  --device /dev/ttyUSB0:/dev/ttyUSB0 \
  -v octoprint_data:/octoprint \
  -e TZ=Europe/Madrid \
  jcrespoc311/octoprint:latest

# 3. Iniciar Camera Streamer (Cámara de Raspberry Pi)
docker run -d \
  --name camera-streamer \
  --restart unless-stopped \
  --privileged \
  --network host \
  -v /run/udev:/run/udev:ro \
  -v /dev/video0:/dev/video0 \
  --tmpfs /dev/shm:exec \
  -e TZ=Europe/Madrid \
  jcrespoc311/camera-streamer:latest
```

---

### ⚙️ Configuración de la Cámara en OctoPrint

Una vez completado el asistente inicial de OctoPrint, accede a **Settings -> Webcam & Timelapse** (Ajustes -> Cámara web y Timelapse):

- **Stream URL (URL del stream)**: `http://<ip-de-tu-raspberry>:8080/stream` (o WebRTC: `http://<ip-de-tu-raspberry>:8080/webrtc`)
- **Snapshot URL (URL de captura instantánea)**: `http://<ip-de-tu-raspberry>:8080/snapshot`
- **FFmpeg path (Ruta de FFmpeg)**: `/usr/bin/ffmpeg` (preinstalado y enlazado en el sistema)

---

### 📄 Licencia

Distribuido bajo la licencia MIT. Consulta `LICENSE` para más detalles.
