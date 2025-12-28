#!/usr/bin/with-contenv bashio

set -e
set -o pipefail

# ============================================================================
# Claude Terminal - Main startup script
# ============================================================================

# Initialize environment
init_environment() {
    local data_home="/data/home"
    local config_dir="/data/.config"
    local claude_config="/data/.config/claude"

    bashio::log.info "Initializing Claude environment..."

    mkdir -p "$data_home" "$config_dir/claude" "/data/.cache" "/data/.local/share"
    chmod 755 "$data_home" "$config_dir" "$claude_config"

    export HOME="$data_home"
    export XDG_CONFIG_HOME="$config_dir"
    export XDG_CACHE_HOME="/data/.cache"
    export XDG_DATA_HOME="/data/.local/share"
    export ANTHROPIC_CONFIG_DIR="$claude_config"

    # Git config
    git config --global --add safe.directory '*' 2>/dev/null || true

    bashio::log.info "Environment ready: HOME=$HOME"
}

# Build Claude launch command based on config
get_claude_command() {
    local cmd="node $(which claude)"

    # Check skip_permissions setting
    if bashio::config.true 'skip_permissions'; then
        cmd="$cmd --dangerously-skip-permissions"
        bashio::log.warning "Running Claude with --dangerously-skip-permissions"
    fi

    echo "$cmd"
}

# Get launch command (auto-launch or session picker)
get_launch_command() {
    local claude_cmd
    claude_cmd=$(get_claude_command)

    if bashio::config.true 'auto_launch_claude'; then
        echo "clear && echo 'Starting Claude Terminal...' && sleep 0.5 && $claude_cmd"
    else
        if [ -f /usr/local/bin/claude-session-picker ]; then
            echo "clear && CLAUDE_CMD='$claude_cmd' /usr/local/bin/claude-session-picker"
        else
            echo "clear && $claude_cmd"
        fi
    fi
}

# Setup scripts
setup_scripts() {
    if [ -f "/opt/scripts/claude-session-picker.sh" ]; then
        cp /opt/scripts/claude-session-picker.sh /usr/local/bin/claude-session-picker
        chmod +x /usr/local/bin/claude-session-picker
    fi
}

# Start web terminal with auto-scroll
start_terminal() {
    local port=7681
    local launch_cmd
    launch_cmd=$(get_launch_command)

    bashio::log.info "Starting web terminal on port $port"
    bashio::log.info "Skip permissions: $(bashio::config 'skip_permissions' 'false')"
    bashio::log.info "Auto-launch: $(bashio::config 'auto_launch_claude' 'true')"

    # Use ttyd with enhanced options
    exec ttyd \
        --port "$port" \
        --interface 0.0.0.0 \
        --writable \
        --client-option fontSize=14 \
        --client-option fontFamily="'JetBrains Mono', 'Fira Code', Menlo, Monaco, monospace" \
        --client-option scrollback=50000 \
        --client-option cursorBlink=true \
        --client-option cursorStyle=bar \
        --client-option theme='{"background":"#1e1e2e","foreground":"#cdd6f4","cursor":"#f5e0dc","selection":"#45475a","black":"#45475a","red":"#f38ba8","green":"#a6e3a1","yellow":"#f9e2af","blue":"#89b4fa","magenta":"#f5c2e7","cyan":"#94e2d5","white":"#bac2de"}' \
        bash -c "$launch_cmd"
}

# Main
main() {
    bashio::log.info "=== Claude Terminal v1.5.1 ==="

    init_environment
    setup_scripts
    start_terminal
}

main "$@"
