#!/bin/sh
set -e
## POSIX-compliant setup script, common dependencies I need
TPM_VERSION="v3.1.0"
NERD_FONT_VERSION="v3.4.0"
NERD_FONTS="BigBlueTerminal D2Coding"
CURRENT_SHELL="$(basename "$SHELL")"
tmpdir=$(mktemp -d)

# Check prerequisiets
for prereq in curl zsh; do
    if ! command -v $prereq >/dev/null 2>&1; then
        echo "Error: $prereq is not installed. Please install $prereq first."
        exit 1
    fi
done

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Error: zsh is not your default shell (current: $CURRENT_SHELL)."
    echo "Run: chsh -s \$(which zsh)"
    exit 1
fi

# Install oh my zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed, skipping."
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://install.ohmyz.sh)" "" --unattended
fi


# Install tmux plugin manager
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    echo "TPM is already installed, skipping."
else
    echo "Installing TPM..."
    mkdir -p "$TPM_DIR"
    curl -fsSL "https://github.com/tmux-plugins/tpm/archive/refs/tags/$TPM_VERSION.tar.gz" -o "$tmpdir/tpm.tar.gz"
    tar -xvzf "$tmpdir/tpm.tar.gz" --strip-components 1 -C "$TPM_DIR"
fi

# Install fonts
case "$(uname -s)" in
    Darwin) FONT_DIR="$HOME/Library/Fonts";;
    *) FONT_DIR="$HOME/.local/share/fonts";;
esac
mkdir -p "$FONT_DIR"

install_font() {
    name="$1"      # display name
    glob="$2"      # glob pattern to check if installed
    url="$3"       # download URL

    if ls "$FONT_DIR"/$glob >/dev/null 2>&1; then
        echo "$name font is already installed, skipping."
    else
        echo "Installing $name font..."
        curl -fsSL -L "$url" -o "$tmpdir/$name.tar.xz"
        tar -xJvf "$tmpdir/$name.tar.xz" -C "$tmpdir"
        find "$tmpdir" -iname "*.ttf" -exec cp {} "$FONT_DIR/" \;
    fi
}

for font in $NERD_FONTS; do
    install_font $font "$font*" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VERSION/$font.tar.xz"
done

# Rebuild font cache on Linux

# Link .zshrc
printf "Link $HOME/.config/zsh/.zshrc to $HOME/.zshrc? This will overwrite $HOME/.zshrc. [y/N] "
read -r answer
case "$answer" in
    [yY]) ln -sf "$HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
        echo "Linked $HOME/.zshrc -> $HOME/.config/zsh/.zshrc" ;;
    *) echo "Skipping zshrc link." ;;
esac

# Link tmux config
printf "Link $HOME/.config/.tmux.conf to $HOME/.tmux.conf? This will overwrite $HOME/.tmux.conf. [y/N] "
read -r answer
case "$answer" in
    [yY]) ln -sf "$HOME/.config/.tmux.conf" "$HOME/.tmux.conf"
        echo "Linked $HOME/.tmux.conf -> $HOME/.config/.tmux.conf" ;;
    *) echo "Skipping tmux.conf link." ;;
esac

# Clean up
rm -rf "$tmpdir"

echo "Done."
