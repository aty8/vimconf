#!/usr/bin/env bash
set -e

echo "🔍 Detecting OS..."

OS="$(uname -s)"

install_mac() {
    echo "🍎 macOS detected"

    if command -v brew >/dev/null && echo "Homebrew is found" || echo "Homebrew is missing. Please install it first"

    if ! command -v brew >/dev/null 2>&1; then
        echo "⚠️ Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ -d /opt/homebrew/bin ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    echo "📦 Installing Neovim and dependencies via Homebrew..."
    brew install neovim ripgrep pyright fd gdb lldb
}

install_linux() {
    echo "🐧 Linux detected"

    DEPS="neovim ripgrep clangd pyright fd gdb lldb"

    if command -v apt >/dev/null 2>&1; then
        echo "Using apt"
        sudo apt update
        sudo apt install -y $DEPS

    elif command -v dnf >/dev/null 2>&1; then
        echo "Using dnf"
        sudo dnf install -y $DEPS

    elif command -v pacman >/dev/null 2>&1; then
        echo "Using pacman"
        sudo pacman -Sy --noconfirm $DEPS

    elif command -v zypper >/dev/null 2>&1; then
        echo "Using zypper"
        sudo zypper install -y $DEPS

    else
        echo "❌ Unsupported Linux package manager"
        exit 1
    fi
}

case "$OS" in
    Darwin)
        install_mac
        ;;
    Linux)
        install_linux
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        exit 1
        ;;
esac

echo
echo "✅ Installation complete!"
echo "🔎 Versions:"
nvim --version | head -n 1 || echo "Neovim not found"
rg --version || echo "ripgrep not found"

if [ ! -d "$HOME/.config" ]; then
    mkdir $HOME/.config
fi

echo "Cloning and installing neovim config"
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/aty8/vimconf $HOME/.config/nvim
fi
echo "✅✅✅ Installed."
