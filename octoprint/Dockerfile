ARG PYTHON_VERSION=3.12-slim-bookworm

# -------------------------------------------------------------------
# Stage 1: Builder (compile netifaces and install OctoPrint)
# -------------------------------------------------------------------
FROM python:${PYTHON_VERSION} AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install minimal compiler dependencies for compiling netifaces C extension
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

ARG OCTOPRINT_VERSION=""
RUN if [ -z "$OCTOPRINT_VERSION" ]; then \
      pip install --no-cache-dir pyyaml octoprint; \
    else \
      pip install --no-cache-dir pyyaml "octoprint==${OCTOPRINT_VERSION}"; \
    fi

# -------------------------------------------------------------------
# Stage 2: Ultra-lightweight and clean final runtime
# -------------------------------------------------------------------
FROM python:${PYTHON_VERSION}

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Minimal system runtime dependencies:
# - gosu: clean privilege drop from root to octoprint user
RUN apt-get update && apt-get install -y --no-install-recommends \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# - ffmpeg: render timelapses (.mp4)
COPY --from=mwader/static-ffmpeg:latest /ffmpeg /usr/local/bin/ffmpeg
RUN ln -s /usr/local/bin/ffmpeg /usr/bin/ffmpeg

# Copy installed python packages and binaries from builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Create unprivileged octoprint user with dialout and tty groups
RUN groupadd -g 1000 octoprint \
    && useradd -u 1000 -g octoprint -G dialout,tty -m -s /bin/bash octoprint \
    && mkdir -p /octoprint/octoprint /octoprint/plugins \
    && chown -R octoprint:octoprint /octoprint

# Configure persistent plugin paths (system binaries take precedence over plugins/bin)
ENV PYTHONUSERBASE=/octoprint/plugins
ENV PATH="/usr/local/bin:${PATH}:${PYTHONUSERBASE}/bin"

# Copy lifecycle management scripts
COPY setup-config.py /usr/local/bin/setup-config.py
COPY restart-octoprint.sh /usr/local/bin/restart-octoprint
COPY octoprint-loop.sh /usr/local/bin/octoprint-loop.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x \
    /usr/local/bin/setup-config.py \
    /usr/local/bin/restart-octoprint \
    /usr/local/bin/octoprint-loop.sh \
    /usr/local/bin/entrypoint.sh

WORKDIR /octoprint
EXPOSE 5000
VOLUME ["/octoprint"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
