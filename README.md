# dotfiles

Sindre Magnussen's dotfiles.

## Install (new machine)

```sh
git clone https://github.com/sindrma/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

`bootstrap.sh` resolves its own location, so the clone path above is just a
convention — it works from wherever you put the repo. It will:

- install Homebrew and the packages in `homebrew/Brewfile`
- symlink the configs into your home folder (`.zshrc`, `.gitconfig`, `.vimrc`,
  `Brewfile`, and the Ghostty config)
- set macOS file-association defaults (`macos/defaults.sh`)
- set up zsh, oh-my-zsh, fzf, and the vim plugins

Because the configs are symlinks back into this repo, editing e.g. `~/.zshrc`
edits the tracked file directly — commit and push to share the change.
