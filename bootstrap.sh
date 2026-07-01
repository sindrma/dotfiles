#!/usr/bin/env bash
#==============
# Resolve where this repo is cloned so symlinks work from any location
#==============
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
# Create symlinks in the home folder
# Allow overriding with files of matching names in the custom-configs dir
#==============
ln -sf "$DOTFILES_DIR/vim/.vimrc" ~/.vimrc
SYMLINKS+=('.vimrc')
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
SYMLINKS+=('.zshrc')
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
#==============
chsh -s /bin/zsh

#==============
# Install oh-my-zsh
#==============
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#==============
# Install fzf
#==============
/opt/homebrew/opt/fzf/install

#==============
# Install vim-plug and plugins
#==============
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qall
 
#==============
# Spaceship theme
#==============
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

#==============
# zsh autosuggestions
#==============
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

#==============
# And we are done
#==============
echo -e "\n====== All Done!! ======\n"
echo
