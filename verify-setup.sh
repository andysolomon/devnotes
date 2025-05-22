#!/usr/bin/env bash
set -eo pipefail

# colored output
OK="\033[32mOK\033[0m"
MISS="\033[31mMISSING\033[0m"

echo "🔍 Verifying core commands…"
core_cmds=(brew git openssl rcm ag tmux watchman zsh fzf bat exa jq httpie nvim)
for cmd in "${core_cmds[@]}"; do
  printf "%-12s: " "$cmd"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "%b\n" "$OK"
  else
    printf "%b\n" "$MISS"
  fi
done

echo
echo "🖥️  Verifying GUI apps…"
gui_names=(iTerm2 Brave Obsidian LICEcap Tower Aseprite OBS TunnelBear Calibre Insomnia IINA Mactracker OmniOutliner ChatGPT Ollama Docker RStudio)
gui_paths=(
  "/Applications/iTerm.app"
  "/Applications/Brave Browser.app"
  "/Applications/Obsidian.app"
  "/Applications/LICEcap.app"
  "/Applications/Tower.app"
  "/Applications/Aseprite.app"
  "/Applications/OBS Studio.app"
  "/Applications/TunnelBear.app"
  "/Applications/calibre.app"
  "/Applications/Insomnia.app"
  "/Applications/IINA.app"
  "/Applications/Mactracker.app"
  "/Applications/OmniOutliner.app"
  "/Applications/ChatGPT.app"
  "/Applications/Ollama.app"
  "/Applications/Docker.app"
  "/Applications/RStudio.app"
)

for i in "${!gui_names[@]}"; do
  name=${gui_names[i]}
  path=${gui_paths[i]}
  printf "%-12s: " "$name"
  [[ -d "$path" ]] && printf "%b\n" "$OK" || printf "%b\n" "$MISS"
done

echo
echo "📦 Verifying language/tool chains…"
tool_names=(node npm typescript eslint prettier bun next jest vitest R python pipx poetry pyenv lua luarocks heroku parity gh sf psql redis magick)
tool_cmds=(node npm tsc eslint prettier bun next jest vitest R python3 pipx poetry pyenv lua luarocks heroku parity gh sf psql redis-server magick)

for i in "${!tool_names[@]}"; do
  name=${tool_names[i]}
  cmd=${tool_cmds[i]}
  printf "%-12s: " "$name"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "%b\n" "$OK"
  else
    printf "%b\n" "$MISS"
  fi
done

echo
echo "🎉 Verification complete!"
