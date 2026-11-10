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

EXPOSE 8080

ENTRYPOINT ["camera-streamer"]
CMD [ \
    "--camera-type=libcamera", \
    "--camera-format=YUV420", \
    "--camera-width=1280", \
    "--camera-height=720", \
    "--camera-fps=30", \
    "--camera-stream.height=720", \
    "--camera-snapshot.height=720", \
    "--http-listen=0.0.0.0", \
    "--http-port=8080" \
]
