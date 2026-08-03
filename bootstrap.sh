#!/usr/bin/env bash
#==============
# Resolve where this repo is cloned so symlinks work from any location
#==============
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYMLINKS=()

#==============
# oh-my-zsh paths.
# ZSH_CUSTOM is normally set by oh-my-zsh itself, but only inside an
# interactive session. In this script it is unset, so it must be defined here:
# without it "$ZSH_CUSTOM/themes/..." expands to "/themes/..." and the clones
# below try to write to the filesystem root.
#==============
ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

#==============
# Clone a git repo only if it isn't already there, and complain loudly if the
# clone fails. This script does not use `set -e` (brew doctor legitimately
# exits non-zero), so failures have to be reported explicitly or they pass
# silently.
#==============
clone_if_missing() {
  local repo="$1" dest="$2"
  if [ -d "$dest" ]; then
    echo "already present, skipping: $dest"
    return 0
  fi
  if ! git clone --depth=1 "$repo" "$dest"; then
    echo "ERROR: failed to clone $repo into $dest" >&2
    return 1
  fi
}

#==============
# Install all the packages
#==============
sudo chown -R $(whoami):admin /usr/local
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
export PATH=/opt/homebrew/bin:$PATH
brew doctor
brew update

#==============
# Remove old dot flies
#==============
sudo rm -rf ~/.vimrc > /dev/null 2>&1
sudo rm -rf ~/.bashrc > /dev/null 2>&1
sudo rm -rf ~/.zshrc > /dev/null 2>&1
sudo rm -rf ~/.gitconfig > /dev/null 2>&1
sudo rm -rf ~/.gitignore > /dev/null 2>&1
sudo rm -rf ~/.config > /dev/null 2>&1
sudo rm -rf ~/Brewfile > /dev/null 2>&1

#==============
# Install oh-my-zsh
#
# This MUST run before the symlinks below. The installer moves any existing
# ~/.zshrc to ~/.zshrc.pre-oh-my-zsh and writes its own template in its place,
# which silently destroyed our symlink when this ran last. It also ends with
# `exec zsh -l`, replacing this script's process, so every step after it was
# skipped entirely.
#   --unattended  sets RUNZSH=no and CHSH=no, so no exec and no chsh prompt
#   --keep-zshrc  leaves an existing ~/.zshrc alone on re-runs
#==============
if [ ! -d "$ZSH" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
else
  echo "oh-my-zsh already installed, skipping"
fi

#==============
# Spaceship theme and zsh-autosuggestions.
# Both live under ZSH_CUSTOM, so they need oh-my-zsh in place first.
#==============
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"
clone_if_missing https://github.com/spaceship-prompt/spaceship-prompt.git \
  "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -sfn "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" \
  "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

#==============
# Homebrew's nvm needs this to exist before nvm.sh is sourced
#==============
mkdir -p ~/.nvm

#==============
# Create symlinks in the home folder
# Allow overriding with files of matching names in the custom-configs dir
#==============
ln -sf "$DOTFILES_DIR/vim/.vimrc" ~/.vimrc
SYMLINKS+=('.vimrc')
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
SYMLINKS+=('.zshrc')

#==============
# Supporting zsh config, sourced by .zshrc. These were never symlinked before,
# so the aliases and functions in them had never actually loaded.
# .inputrc is readline config rather than zsh, and zsh ignores it, but it is
# still linked because psql, the python REPL and friends do read it. Its zsh
# counterpart is .keybindings.
#==============
for zshfile in .env .functions .alias .keybindings .inputrc; do
  ln -sf "$DOTFILES_DIR/zsh/$zshfile" "$HOME/$zshfile"
  SYMLINKS+=("$zshfile")
done

ln -sf "$DOTFILES_DIR/homebrew/Brewfile" ~/Brewfile
SYMLINKS+=('Brewfile')
ln -sf "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
SYMLINKS+=('.gitconfig')
ln -sf "$DOTFILES_DIR/git/.gitignore" ~/.gitignore
SYMLINKS+=('.gitignore')
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sf "$DOTFILES_DIR/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
SYMLINKS+=('config.ghostty')

#==============
# Claude Code config (CLAUDE.md, skills, settings)
# Only touch the specific files/dir -- never the whole ~/.claude,
# which holds runtime state (history, sessions, cache, plugins).
# CLAUDE.md and skills are symlinked so the repo stays the source of
# truth (edits flow back automatically). Use -n on the skills dir so we
# replace it rather than linking inside it. settings.json is copied (not
# symlinked) and only when absent, so an existing settings.json is left
# untouched.
#==============
mkdir -p ~/.claude
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
SYMLINKS+=('CLAUDE.md')
ln -sfn "$DOTFILES_DIR/claude/skills" ~/.claude/skills
SYMLINKS+=('skills')
[ -f ~/.claude/settings.json ] || cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json

echo ${SYMLINKS[@]}

cd ~
brew bundle
cd -

#==============
# macOS defaults (file associations)
#==============
"$DOTFILES_DIR/macos/defaults.sh"

#==============
# Set zsh as the default shell
# oh-my-zsh was installed with --unattended above, which skips its own chsh.
#==============
chsh -s /bin/zsh

#==============
# Install fzf
# --no-update-rc matters: ~/.zshrc is a symlink into this repo, so letting the
# installer append its source line would edit the tracked file. .zshrc already
# sources ~/.fzf.zsh. The flags also keep it non-interactive; a bare `install`
# prompts and would stall the rest of this script.
#==============
/opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc

#==============
# Install vim-plug and plugins
#==============
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qall

#==============
# And we are done
#==============
echo -e "\n====== All Done!! ======\n"
echo
