#!/bin/bash

# Print usage
usage() {
    echo "Usage: $0 [install|remove]"
    echo "  install    Install filemerger script and create aliases"
    echo "  remove     Remove filemerger script and clean up aliases"
    exit 1
}

# Determine shell configuration file
get_shell_rc() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo "$HOME/.bashrc"
    else
        echo "Unsupported shell. Please manually add/remove the alias to your shell configuration."
        exit 1
    fi
}

# Install filemerger
install_filemerger() {
    local SHELL_RC=$(get_shell_rc)
    
    echo "Installing filemerger..."
    
    # Create bin directory and copy script
    mkdir -p ~/bin
    cp filemerger.sh ~/bin/filemerger
    chmod +x ~/bin/filemerger

    # Add to PATH if not already there
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_RC"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
    fi

    # Add alias if not already there
    if ! grep -q 'alias fmerge="filemerger"' "$SHELL_RC"; then
        echo 'alias fmerge="filemerger"' >> "$SHELL_RC"
    fi

    echo "Installation complete! Please restart your terminal or run:"
    echo "source $SHELL_RC"
}

# Remove filemerger
remove_filemerger() {
    local SHELL_RC=$(get_shell_rc)
    
    echo "Removing filemerger..."
    
    # Remove the script
    if [ -f ~/bin/filemerger ]; then
        rm ~/bin/filemerger
        echo "Removed script from ~/bin/filemerger"
    fi

    # Remove the alias from shell configuration
    if grep -q 'alias fmerge="filemerger"' "$SHELL_RC"; then
        sed -i.bak '/alias fmerge="filemerger"/d' "$SHELL_RC"
        echo "Removed alias from $SHELL_RC"
    fi

    # Only remove PATH if ~/bin is empty
    if [ -d ~/bin ] && [ -z "$(ls -A ~/bin)" ]; then
        rm -r ~/bin
        sed -i.bak '/export PATH="$HOME\/bin:\$PATH"/d' "$SHELL_RC"
        echo "Removed empty bin directory and PATH export"
    fi

    # Remove backup files created by sed
    rm -f "$SHELL_RC.bak"

    echo "Removal complete! Please restart your terminal or run:"
    echo "source $SHELL_RC"
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    "install")
        install_filemerger
        ;;
    "remove")
        remove_filemerger
        ;;
    *)
        usage
        ;;
esac