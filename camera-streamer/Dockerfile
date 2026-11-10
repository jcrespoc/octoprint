FROM debian:bookworm-slim

# Install basic tools for keyrings and downloads
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add Raspberry Pi Bookworm repository (stable and verified for camera-streamer)
RUN wget -qO- https://archive.raspberrypi.com/debian/raspberrypi.gpg.key | gpg --dearmor > /usr/share/keyrings/raspberrypi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/raspberrypi-archive-keyring.gpg] http://archive.raspberrypi.com/debian/ bookworm main" > /etc/apt/sources.list.d/raspi.list \
    && apt-get update \
    && wget -q "https://github.com/ayufan/camera-streamer/releases/download/v0.4.2/camera-streamer-raspi_0.4.2.bookworm_arm64.deb" \
    && apt-get install -y --no-install-recommends ./camera-streamer-raspi_0.4.2.bookworm_arm64.deb \
    && rm -f camera-streamer-raspi_0.4.2.bookworm_arm64.deb \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
