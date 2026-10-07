#!/usr/bin/env bash
#==============
# Default applications for code/config files -> Zed
# Requires duti (see Brewfile). The bare "all" role silently
# no-ops on recent macOS, so set the editor + viewer roles explicitly.
#==============
set -euo pipefail

ZED="dev.zed.Zed"

for uti in public.json net.daringfireball.markdown public.yaml; do
  duti -s "$ZED" "$uti" editor
  duti -s "$ZED" "$uti" viewer
done

echo "Set Zed as default for .json, .md/.markdown, .yaml/.yml"

#==============
# Zen: .html file association, and a nudge about the default browser
#
# Two different settings get confused here, so to be explicit:
#
#   public.html / public.xhtml  the app that opens a .html FILE. Scriptable,
#                               and set below.
#   http / https URL schemes    the actual "default browser", i.e. what opens
#                               when you click a link. NOT scriptable. macOS
#                               reserves this for an interactive confirmation
#                               and duti fails with error -54 (verified on
#                               macOS 26.5).
#
# So the scheme calls below are best-effort only, and the default browser has
# to be finished by hand from inside Zen. Note that `duti -x html` reporting
# "Zen" only confirms the file association, NOT the default browser.
#
# Guarded with `|| true` because this script runs under `set -e`: a refused
# default browser must not abort the rest of bootstrap.
#==============
ZEN="app.zen-browser.zen"

if [ -d "/Applications/Zen.app" ]; then
  for uti in public.html public.xhtml; do
    duti -s "$ZEN" "$uti" viewer || true
  done
  for scheme in http https; do
    duti -s "$ZEN" "$scheme" 2> /dev/null || true
  done
  echo "Set Zen as the handler for .html/.xhtml files."
  echo "Default browser is NOT set by this script; macOS does not allow it."
  echo "  finish in Zen: Settings > General > Set as Default Browser"
else
  echo "skip, not installed: /Applications/Zen.app"
fi
