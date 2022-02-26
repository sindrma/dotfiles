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
ln -sf ~/.dotfiles/.vimrc ~/.vimrc
SYMLINKS+=('.vimrc')
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
SYMLINKS+=('.zshrc')
ln -sf ~/.dotfiles/homebrew/Brewfile ~/Brewfile
SYMLINKS+=('Brewfile')
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
SYMLINKS+=('.gitconfig')
ln -s ~/.dotfiles/git/.gitignore ~/.gitignore
SYMLINKS+=('.gitignore')

echo ${SYMLINKS[@]}

cd ~
brew bundle
cd -

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
# Initialise Vundle plugins
#==============
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
 
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
