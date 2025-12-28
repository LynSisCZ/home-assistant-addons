#!/bin/bash

# Claude Session Picker - Interactive menu for choosing Claude session type
# Uses CLAUDE_CMD env var for proper command (includes --dangerously-skip-permissions if enabled)

# Get Claude command (from env or default)
get_claude_cmd() {
    if [ -n "$CLAUDE_CMD" ]; then
        echo "$CLAUDE_CMD"
    else
        echo "node $(which claude)"
    fi
}

show_banner() {
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Claude Terminal                           ║"
    echo "║                 Interactive Session Picker                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Show if bypass mode is enabled
    if [[ "$CLAUDE_CMD" == *"--dangerously-skip-permissions"* ]]; then
        echo "  [!] Permission bypass ENABLED"
        echo ""
    fi
}

show_menu() {
    echo "Choose your Claude session type:"
    echo ""
    echo "  1) New interactive session (default)"
    echo "  2) Continue most recent conversation (-c)"
    echo "  3) Resume from conversation list (-r)"
    echo "  4) Custom Claude command"
    echo "  5) Authentication helper"
    echo "  6) Drop to bash shell"
    echo "  7) System info (psql, git, python versions)"
    echo "  8) Exit"
    echo ""
}

get_user_choice() {
    local choice
    printf "Enter your choice [1-8] (default: 1): " >&2
    read -r choice

    if [ -z "$choice" ]; then
        choice=1
    fi

    echo "$choice" | tr -d '[:space:]'
}

launch_claude_new() {
    echo "Starting new Claude session..."
    sleep 0.5
    local cmd
    cmd=$(get_claude_cmd)
    exec $cmd
}

launch_claude_continue() {
    echo "Continuing most recent conversation..."
    sleep 0.5
    local cmd
    cmd=$(get_claude_cmd)
    exec $cmd -c
}

launch_claude_resume() {
    echo "Opening conversation list..."
    sleep 0.5
    local cmd
    cmd=$(get_claude_cmd)
    exec $cmd -r
}

launch_claude_custom() {
    echo ""
    echo "Enter additional Claude flags (e.g., '--help' or '-p \"hello\"'):"
    echo "Base command: $(get_claude_cmd)"
    echo -n "> "
    read -r custom_args

    if [ -z "$custom_args" ]; then
        launch_claude_new
    else
        echo "Running: $(get_claude_cmd) $custom_args"
        sleep 0.5
        local cmd
        cmd=$(get_claude_cmd)
        eval "exec $cmd $custom_args"
    fi
}

launch_auth_helper() {
    echo "Starting authentication helper..."
    sleep 0.5
    if [ -f /opt/scripts/claude-auth-helper.sh ]; then
        exec /opt/scripts/claude-auth-helper.sh
    else
        echo "Auth helper not found. Run 'claude' to authenticate."
        sleep 2
        launch_claude_new
    fi
}

launch_bash_shell() {
    echo "Dropping to bash shell..."
    echo ""
    echo "Available tools:"
    echo "  - claude    : Claude Code CLI"
    echo "  - psql      : PostgreSQL client"
    echo "  - git       : Version control"
    echo "  - python3   : Python interpreter"
    echo "  - pip       : Python package manager"
    echo ""
    sleep 0.5
    exec bash
}

show_system_info() {
    echo ""
    echo "=== System Info ==="
    echo ""
    echo "Claude Code:"
    claude --version 2>/dev/null || echo "  Not found"
    echo ""
    echo "PostgreSQL client:"
    psql --version 2>/dev/null || echo "  Not found"
    echo ""
    echo "Git:"
    git --version 2>/dev/null || echo "  Not found"
    echo ""
    echo "Python:"
    python3 --version 2>/dev/null || echo "  Not found"
    echo ""
    echo "Node.js:"
    node --version 2>/dev/null || echo "  Not found"
    echo ""
    printf "Press Enter to continue..." >&2
    read -r
}

exit_picker() {
    echo "Goodbye!"
    exit 0
}

# Main execution flow
main() {
    while true; do
        show_banner
        show_menu
        choice=$(get_user_choice)

        case "$choice" in
            1) launch_claude_new ;;
            2) launch_claude_continue ;;
            3) launch_claude_resume ;;
            4) launch_claude_custom ;;
            5) launch_auth_helper ;;
            6) launch_bash_shell ;;
            7) show_system_info ;;
            8) exit_picker ;;
            *)
                echo ""
                echo "Invalid choice: '$choice'"
                echo "Please select 1-8"
                sleep 1
                ;;
        esac
    done
}

trap 'exit_picker' EXIT INT TERM
main "$@"
