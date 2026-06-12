#!/usr/bin/env bash
#==============
# Default applications for code/config files -> VS Code
# Requires duti (see Brewfile). The bare "all" role silently
# no-ops on recent macOS, so set the editor + viewer roles explicitly.
#==============
set -euo pipefail

VSCODE="com.microsoft.VSCode"

for uti in public.json net.daringfireball.markdown public.yaml; do
  duti -s "$VSCODE" "$uti" editor
  duti -s "$VSCODE" "$uti" viewer
done

echo "Set VS Code as default for .json, .md/.markdown, .yaml/.yml"
