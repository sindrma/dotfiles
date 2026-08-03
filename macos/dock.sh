#!/usr/bin/env bash
#==============
# Dock: pinned items and icon size.
#
# Declarative. Every persistent item is removed and rebuilt from the lists
# below, so this repo stays the single source of truth. That means re-running
# this discards Dock changes made by hand: to make a change stick, edit the
# lists here.
#
# Requires dockutil (see Brewfile).
#==============
set -euo pipefail

# Dock icon size. macOS default is 48.
TILESIZE=27

DOCK_APPS=(
  "/System/Applications/Apps.app"
  "/System/Applications/Photos.app"
  "/System/Applications/Notes.app"
  "/System/Applications/App Store.app"
  "/System/Applications/System Settings.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/cmux.app"
  "/Applications/Arc.app"
  "/Applications/Ghostty.app"
  "/Applications/Slack.app"
)

DOCK_FOLDERS=(
  "$HOME/Downloads"
)

# Folder tile appearance, matching what com.apple.dock already had:
#   showas = 1      -> --view fan      (0 auto, 1 fan, 2 grid, 3 list)
#   displayas = 0   -> --display stack (0 stack, 1 folder)
#   arrangement = 2 -> --sort dateadded
FOLDER_OPTS=(--view fan --display stack --sort dateadded)

if ! command -v dockutil > /dev/null 2>&1; then
  echo "ERROR: dockutil not found. Run 'brew bundle' first." >&2
  exit 1
fi

# --no-restart throughout, then one killall at the end, so the Dock does not
# flicker through every intermediate state.
dockutil --remove all --no-restart

for app in "${DOCK_APPS[@]}"; do
  # Guarded because the wipe above has already happened. Without this, one
  # not-yet-installed app would abort the script under set -e and leave an
  # empty Dock behind.
  if [ -d "$app" ]; then
    dockutil --add "$app" --no-restart
  else
    echo "skip, not installed: $app"
  fi
done

for folder in "${DOCK_FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    dockutil --add "$folder" "${FOLDER_OPTS[@]}" --no-restart
  else
    echo "skip, missing: $folder"
  fi
done

defaults write com.apple.dock tilesize -int "$TILESIZE"

killall Dock

echo "Dock rebuilt: ${#DOCK_APPS[@]} apps, ${#DOCK_FOLDERS[@]} folders, tilesize $TILESIZE"
