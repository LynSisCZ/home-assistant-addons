ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install all required packages in single layer
RUN apk add --no-cache \
    # Core
    nodejs \
    npm \
    bash \
    curl \
    # Python & Libraries
    python3 \
    py3-pip \
    py3-requests \
    py3-aiohttp \
    py3-yaml \
    py3-beautifulsoup4 \
    # Development Tools
    git \
    vim \
    nano \
    openssh-client \
    # Database
    postgresql-client \
    # Network Utilities
    wget \
    netcat-openbsd \
    # Productivity Tools
    jq \
    tree \
    # Terminal
    ttyd \
    && npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retries 3 \
    && npm config set fetch-timeout 300000 \
    && for i in 1 2 3; do \
        echo "Attempt $i: Installing Claude Code CLI..." && \
        npm install -g @anthropic-ai/claude-code@latest && \
        echo "Successfully installed Claude Code CLI" && \
        break || \
        (echo "Attempt $i failed, retrying..." && sleep 10); \
    done \
    && npm cache clean --force

# Create directories
RUN mkdir -p /config/claude-config /data/.config/claude

WORKDIR /config

# Copy startup scripts and custom HTML
COPY run.sh /run.sh
COPY scripts/ /opt/scripts/
COPY html/ /opt/html/
RUN chmod +x /run.sh /opt/scripts/*.sh

CMD ["/run.sh"]
