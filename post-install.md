# Post-Install Instructions

Once you’ve run `setup.sh` successfully, follow these steps to finish setting up your environment.

---

## 1. Restart Your Shell

```bash
# Close and re-open iTerm/Terminal, or:
exec $SHELL -l
```

This ensures:

* Your updated `~/.zprofile` (Homebrew + npm paths, pyenv init) is sourced
* Your updated `~/.zshrc` (aliases like `exa`) is loaded

---

## 2. Verify Your Installations

Run the built-in verifier:

```bash
./verify_setup.sh
```

You should see **OK** next to every tool and app. Any **MISSING** entries indicate something to re-run or install manually.

---

## 3. Start Background Services

```bash
# Start PostgreSQL and Redis as services:
brew services start postgresql
brew services start redis
```

If you prefer on-demand launches:

```bash
pg_ctl -D "$(brew --prefix)/var/postgresql@14" start
redis-server /usr/local/etc/redis.conf
```

---

## 4. Log Into Your CLIs

```bash
# Heroku CLI
eroku login

# GitHub CLI
gh auth login

# Salesforce CLI
sf login
```

Add any additional tools as needed.

---

## 5. Grant Full Disk Access

1. Open **System Settings → Privacy & Security → Full Disk Access**
2. Add **Terminal** and/or **iTerm** so tools like `rcup` and `pyenv` can modify your dotfiles

---

## 6. Customize Your Dotfiles

Your dotfiles are managed by RCM and live in `~/dotfiles`:

```bash
# Edit Zsh aliases or prompt:
code ~/.zshrc

# Edit Git configuration:
code ~/.gitconfig
```

Re-apply updates after pulling changes:

```bash
cd ~/dotfiles
git pull --ff-only
rcup -v
```

---

## 7. Troubleshooting & Updates

* If you add a new tool to `setup.sh`, also update `verify_setup.sh` and this `POST_INSTALL.md`.
* To re-run the setup for a single package, execute:

  ```bash
  ./setup.sh --package <package_name>
  ```

  *(You may implement package-specific flags as needed.)*

---

## 8. Enjoy Coding!

Your development environment is now configured—happy hacking! Feel free to submit PRs to this repo for improvements.
