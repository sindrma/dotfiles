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
- set macOS file-association defaults (`macos/defaults.sh`): Zed for `.json`, `.md` and
  `.yaml`, Zen for `.html`. The default *browser* is a manual step, see below
- rebuild the Dock from `macos/dock.sh`: the pinned apps, the Downloads stack,
  and the icon size
- set zsh as the login shell, and set up fzf and the vim plugins

`zsh/.inputrc` is readline config, not zsh. zsh never reads it, but it is
linked anyway because readline-based tools (`psql`, the python REPL) do. Its
zsh counterpart is `zsh/.keybindings`.

Because the configs are symlinks back into this repo, editing e.g. `~/.zshrc`
edits the tracked file directly.

## The Dock

`macos/dock.sh` is declarative. It removes every pinned item and rebuilds the
Dock from the lists in the script, so re-running `bootstrap.sh` will discard any
Dock changes you made by hand. To change what is pinned, or the icon size, edit
`macos/dock.sh` rather than dragging things around. Run it on its own with:

```sh
./macos/dock.sh
```

## The browser

Zen is the default browser. `bootstrap.sh` installs it, but it does **not** manage the Zen
profile, so a fresh machine gets an empty browser: no bookmarks, no add-ons. That is
deliberate. The declarative Firefox mechanisms for pinning extensions (`policies.json`) and
seeding bookmarks have to live inside the app bundle, and Zen replaces its own bundle on
every self-update, so anything built on them rots silently. Use Zen's built-in sync to carry
profile state between machines, and see the manual steps below for a first-time setup.

## Manual steps

Not everything can be automated:

- **Magnet** has no Homebrew cask, so install it from the Mac App Store.
- **1Password CLI** needs to be enabled from within the 1Password app
  (Settings, Developer) before `op` will connect.
- **Default browser.** macOS does not let a script set this: the `http`/`https` URL scheme
  handlers are reserved for an interactive confirmation, and `duti` fails on them with error
  `-54`. `macos/defaults.sh` sets the `.html` *file* association to Zen and leaves the rest
  to you: Zen, Settings, General, Set as Default Browser. Beware that `duti -x html`
  reporting "Zen" only confirms the file association, not the default browser.
- **Zen add-ons** have to be installed by hand from addons.mozilla.org:
  - [ColorZilla](https://addons.mozilla.org/en-US/firefox/addon/colorzilla/)
  - [Vimium](https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/)
  - [1Password](https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/),
    which then needs unlocking once against the desktop app
- **No Claude extension in Zen.** Claude in Chrome is Chrome-only and is explicitly
  unsupported on non-Chrome browsers, so there is no Gecko build to install. A community
  Firefox port exists but wants full browser-automation permissions, which is not a
  reasonable trade on a primary browser. Use the Claude desktop app or claude.ai instead.
