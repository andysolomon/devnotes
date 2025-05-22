#!/usr/bin/env bash
set -euo pipefail

echo "####################################"
echo "# Andy Laptop Setup Script"
echo "####################################"

##### macOS tools #####
echo "🔧 Installing macOS tools…"

# Rosetta 2
if softwareupdate --history | grep -q "Rosetta 2"; then
  echo "→ Rosetta 2 already installed, skipping."
else
  softwareupdate --install-rosetta --agree-to-license >/dev/null 2>&1 || true
  echo "→ Rosetta 2 installed."
fi

# Xcode Command Line Tools
if xcode-select -p >/dev/null 2>&1; then
  echo "→ Xcode Command Line Tools present, skipping."
else
  echo "→ Installing Xcode Command Line Tools…"
  xcode-select --install
  echo "  Please complete the install dialog, then re-run this script."
  exit 1
fi

# Verify CLT toolchain
if xcrun clang --version >/dev/null 2>&1; then
  echo "→ Xcode CLT compiler functional."
else
  echo "⚠️  Swift compiler not working. Run: softwareupdate --all --install --force"
  exit 1
fi

# Homebrew
if command -v brew >/dev/null 2>&1; then
  echo "→ Homebrew already installed, skipping."
else
  echo "→ Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew update || true

##### unix tools #####
echo "👨‍💻 Installing UNIX tools…"
for pkg in universal-ctags git openssl rcm the_silver_searcher tmux watchman zsh fzf bat eza jq httpie neovim; do
  if brew list --formula | grep -qx "$pkg"; then
    echo "→ $pkg already installed, skipping."
  else
    brew install "$pkg" || echo "⚠️  Failed to install $pkg, continuing."
  fi
done

# alias exa → eza
if grep -qxF "alias exa='eza'" ~/.zshrc; then
  echo "→ exa alias already set."
else
  echo "alias exa='eza'" >> ~/.zshrc
fi

##### terminal #####
echo "🖥️ Installing terminal tools…"
if [ -d "/Applications/iTerm.app" ] || [ -d "/Applications/iTerm2.app" ]; then
  echo "→ iTerm2 already installed, skipping."
else
  brew install --cask iterm2 || echo "⚠️  iTerm2 install failed, continuing."
fi

##### programming fonts #####
echo "✒️ Installing programming fonts…"
for font in font-jetbrains-mono font-fira-code font-hack-nerd-font font-cascadia-code; do
  if brew list --cask | grep -qx "$font"; then
    echo "→ $font already installed, skipping."
  else
    brew install --cask "$font" || echo "⚠️  Failed to install $font, continuing."
  fi
done

##### heroku tools #####
echo "☁️ Installing Heroku CLI & Parity…"
brew tap heroku/brew >/dev/null 2>&1 || true
for pkg in heroku parity; do
  if brew list --formula | grep -qx "$pkg"; then
    echo "→ $pkg already installed, skipping."
  else
    brew install "$pkg" || echo "⚠️  Failed to install $pkg, continuing."
  fi
done

##### github tools #####
echo "🌐 Installing GitHub CLI…"
if brew list --formula | grep -qx gh; then
  echo "→ gh already installed, skipping."
else
  brew install gh || echo "⚠️  Failed to install gh, continuing."
fi

##### image tools #####
echo "🖼️ Installing ImageMagick…"
if brew list --formula | grep -qx imagemagick; then
  echo "→ ImageMagick already installed, skipping."
else
  brew install imagemagick || echo "⚠️  Failed to install ImageMagick, continuing."
fi

##### ai tools #####
echo "🤖 Installing AI tools…"
if command -v chatgpt >/dev/null 2>&1 && [ -d "/Applications/ChatGPT.app" ]; then
  echo "→ ChatGPT Desktop already installed, skipping."
else
  brew install --cask chatgpt || echo "⚠️  ChatGPT install failed, continuing."
fi

if command -v ollama >/dev/null 2>&1; then
  echo "→ Ollama already installed, skipping."
else
  brew install --cask ollama || echo "⚠️  Ollama install failed, continuing."
fi

echo "  • Claude Desktop & Claude Code: manual download from Anthropic."
echo "  • Cursor: manual download from https://cursor.io"
echo "  • Open WebUI: see https://github.com/oobabooga/text-generation-webui"

##### programming languages & pkg managers #####
echo "🛠️ Installing languages & package managers…"

# Node.js + JS toolchain
if brew list --formula | grep -qx node; then
  echo "→ Node already installed, skipping."
else
  brew install node || echo "⚠️  Failed to install Node, continuing."
fi
npm list -g typescript eslint prettier bun next jest vitest >/dev/null 2>&1 || {
  npm install -g typescript eslint prettier bun next jest vitest || echo "⚠️  npm global install failed, continuing."
}

# R + RStudio
if brew list --formula | grep -qx r; then
  echo "→ R already installed, skipping."
else
  brew install r || echo "⚠️  Failed to install R, continuing."
fi
if [ -d "/Applications/RStudio.app" ]; then
  echo "→ RStudio already installed, skipping."
else
  brew install --cask rstudio || echo "⚠️  RStudio install failed, continuing."
fi

# Python: pyenv, virtualenvs, pipx, poetry
for pkg in pyenv pyenv-virtualenv pipx poetry; do
  if brew list --formula | grep -qx "$pkg"; then
    echo "→ $pkg already installed, skipping."
  else
    brew install "$pkg" || echo "⚠️  Failed to install $pkg, continuing."
  fi
done

if ! grep -q 'pyenv init' ~/.zprofile; then
  cat << 'EOF' >> ~/.zprofile
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
EOF
fi
LATEST_PY="$(pyenv install --list | grep -E '^\s*3\.' | tail -1 | tr -d ' ')"
pyenv install -s "$LATEST_PY" >/dev/null 2>&1 || true
pyenv global "$LATEST_PY" >/dev/null 2>&1 || true
pipx ensurepath >/dev/null 2>&1 || true
for tool in black flake8 mypy pytest pandas numpy matplotlib jupyter; do
  pipx list | grep -q "$tool" || pipx install "$tool" || echo "⚠️  pipx install $tool failed, continuing."
done

# Lua + tooling
if brew list --formula | grep -qx lua; then
  echo "→ Lua already installed, skipping."
else
  brew install lua || echo "⚠️  Failed to install Lua, continuing."
fi
if brew list --formula | grep -qx luarocks; then
  echo "→ LuaRocks already installed, skipping."
else
  brew install luarocks || echo "⚠️  Failed to install LuaRocks, continuing."
fi
for rock in luacheck busted moonscript; do
  luarocks list | grep -q "$rock" || luarocks install "$rock" || echo "⚠️  luarocks install $rock failed, continuing."
done

# Salesforce CLI + SFDX tools
npm list -g @salesforce/cli force-cli salesforce-alm >/dev/null 2>&1 || {
  npm install -g @salesforce/cli force-cli salesforce-alm || echo "⚠️  Salesforce CLI install failed, continuing."
}

##### databases #####
echo "🗄️ Installing databases…"
for db in postgresql redis; do
  if brew list --formula | grep -qx "$db"; then
    echo "→ $db already installed, skipping."
  else
    brew install "$db" || echo "⚠️  Failed to install $db, continuing."
  fi
done

##### Productivity Applications #####
echo "🚀 Installing productivity apps…"
apps=(
  brave-browser
  obsidian
  licecap
  tower
  aseprite
  obs-studio     # correct cask for OBS Studio
  tunnelbear
  calibre
  insomnia
  iina
  mactracker
  omnioutliner
)

for app in "${apps[@]}"; do
  if brew list --cask | grep -qx "$app"; then
    echo "→ $app already installed, skipping."
  else
    if brew info --cask "$app" >/dev/null 2>&1; then
      brew install --cask "$app" || echo "⚠️  Failed to install $app, continuing."
    else
      echo "⚠️  Cask '$app' not found, skipping."
    fi
  fi
done

##### Docker & Containerization #####
echo "🐳 Installing Docker…"
if [ -d "/Applications/Docker.app" ]; then
  echo "→ Docker Desktop already installed, skipping."
else
  brew install --cask docker || echo "⚠️  Docker install failed, continuing."
fi

##### Dotfiles #####
echo "📂 Pulling and applying dotfiles via RCM…"
if [ ! -d "$HOME/dotfiles" ]; then
  git clone https://github.com/andysolomon/dotfiles.git "$HOME/dotfiles"
else
  echo "→ Dotfiles repo already present, pulling updates."
  git -C "$HOME/dotfiles" pull --ff-only || true
fi
export RCRC="$HOME/dotfiles/rcrc"
rcup -v || echo "⚠️  rcm apply failed, continuing."

##### macOS defaults #####
echo "⚙️ Applying macOS defaults…"
defaults write com.apple.finder AppleShowAllFiles -bool true || true
killall Finder || true

# Remap Caps Lock → Control
hidutil property --set '{
  "UserKeyMapping":[
    {
      "HIDKeyboardModifierMappingSrc":0x700000039,
      "HIDKeyboardModifierMappingDst":0x7000000E0
    }
  ]
}' || true

echo "✅ Setup complete! Restart your terminal (or log out/in) to apply changes."
