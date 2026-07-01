# dotfiles

Sindre Magnussen Flo's dotfiles.

## Install (new machine)

```sh
git clone https://github.com/sindrma/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

`bootstrap.sh` resolves its own location, so the clone path above is just a
convention, it works from wherever you put the repo. It will:

- install Homebrew and the packages in `homebrew/Brewfile`
- symlink the configs into your home folder (`.zshrc`, `.gitconfig`, `.vimrc`,
  `Brewfile`, the Ghostty config, and the Claude Code `CLAUDE.md` and `skills/`
  under `~/.claude`; `~/.claude/settings.json` is seeded from
  `claude/settings.json` only if it doesn't already exist)
- set macOS file-association defaults (`macos/defaults.sh`)
- set up zsh, oh-my-zsh, fzf, and the vim plugins

Because the configs are symlinks back into this repo, editing e.g. `~/.zshrc`
edits the tracked file directly.
