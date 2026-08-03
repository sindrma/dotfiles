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
- install oh-my-zsh, the spaceship theme, and zsh-autosuggestions. This happens
  *before* the symlinks below, because the oh-my-zsh installer replaces any
  existing `~/.zshrc` with its own template and then `exec`s a new shell
- symlink the configs into your home folder (`.zshrc` plus the `.env`,
  `.functions`, `.alias`, `.keybindings` and `.inputrc` files it sources,
  `.gitconfig`, `.vimrc`, `Brewfile`, the Ghostty config, and the Claude Code
  `CLAUDE.md` and `skills/` under `~/.claude`; `~/.claude/settings.json` is
  seeded from `claude/settings.json` only if it doesn't already exist)
- set macOS file-association defaults (`macos/defaults.sh`)
- set zsh as the login shell, and set up fzf and the vim plugins

`zsh/.inputrc` is readline config, not zsh. zsh never reads it, but it is
linked anyway because readline-based tools (`psql`, the python REPL) do. Its
zsh counterpart is `zsh/.keybindings`.

Because the configs are symlinks back into this repo, editing e.g. `~/.zshrc`
edits the tracked file directly.
