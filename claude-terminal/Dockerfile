ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install all required packages in single layer
# Includes: Node.js, PostgreSQL client, Git, terminal tools
RUN apk add --no-cache \
    nodejs \
    npm \
    bash \
    curl \
    nano \
    git \
    openssh-client \
    postgresql-client \
    ttyd \
    jq \
    python3 \
    py3-pip \
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
