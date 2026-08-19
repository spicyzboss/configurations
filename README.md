# Nix Dotfiles

macOS and NixOS configuration with [nix-darwin](https://github.com/LnL7/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew).

## Table of Contents

- [Fresh Mac Setup (Apple Silicon)](#fresh-mac-setup-apple-silicon)
- [NixOS Setup (x86_64)](#nixos-setup-x86_64)
- [Customization](#customization)
- [Linking Configs](#linking-configs)
- [Claude Config](#claude-config)
- [Fish Config](#fish-config)
- [kitty Config](#kitty-config)
- [starship Config](#starship-config)
- [tmux Config](#tmux-config)
- [zellij Config](#zellij-config)
- [Helix Config](#helix-config)
- [btop Config](#btop-config)
- [Warp Config](#warp-config)
- [yazi Config](#yazi-config)
- [Commands](#commands)
- [Structure](#structure)

---

## Fresh Mac Setup (Apple Silicon)

Follow these steps on a new Mac. First run takes ~15–30 minutes.

### Step 1: Install Xcode Command Line Tools

Open Terminal (Cmd+Space → type "Terminal" → Enter) and run:

```bash
xcode-select --install
```

Click **Install** when the dialog appears. Wait for it to finish.

### Step 2: Install Nix

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Use the default options (press Enter). When done, **quit Terminal and open it again**.

### Step 3: Enable flakes and nix-command

Flakes and nix-command are not enabled by default. Choose one:

**Option A — Add to `~/.config/nix/nix.conf`** (create the file if it doesn't exist):

```
experimental-features = nix-command flakes
```

**Option B — Use the flag with each command below:**

```bash
nix --extra-experimental-features 'nix-command flakes' run .#<command>
```

### Step 4: Clone this repo

Use HTTPS (you don't have SSH keys yet):

```bash
mkdir -p ~/.local/share/src
cd ~/.local/share/src
git clone https://github.com/spicyzboss/configurations.git
cd configurations
```

### Step 5: Apply the config

From inside the `configurations` folder:

```bash
nix run .#apps.aarch64-darwin.build-switch
```

If you skipped the nix.conf step, use: `nix --extra-experimental-features 'nix-command flakes' run .#apps.aarch64-darwin.build-switch`

Enter your Mac password when asked. This step will:

- Set up nix-darwin and Home Manager
- Install packages: helix, kitty, fish, starship, gh, lazygit, etc.
- Install apps via Homebrew: 1Password, Cursor, Chrome, Raycast, Slack, etc.
- Apply macOS defaults (dock, trackpad, key repeat)

### Step 6: Finish setup

1. **SSH keys** — Home Manager generates `~/.ssh/spicyzboss` and `~/.ssh/boss-spicyz100x` on first switch if they do not exist. Add the matching `.pub` files to the matching GitHub accounts as SSH authentication and signing keys.

2. **Use SSH for git** (optional) — `git remote set-url origin git@github.com:spicyzboss/configurations.git`

---

## NixOS Setup (x86_64)

For an existing NixOS system (x86_64). The config includes hardware-specific settings (GPU, disk) — you may need to adapt `hosts/nixos/default.nix` for your machine.

### Step 1: Clone this repo

```bash
mkdir -p ~/.local/share/src
cd ~/.local/share/src
git clone https://github.com/spicyzboss/configurations.git
cd configurations
```

### Step 2: Enable flakes and nix-command

Flakes and nix-command are not enabled by default. Choose one:

**Option A — Add to `~/.config/nix/nix.conf`** (create the file if it doesn't exist):

```
experimental-features = nix-command flakes
```

**Option B — Use the flag with each command below:**

```bash
nix --extra-experimental-features 'nix-command flakes' run .#<command>
```

### Step 3: Apply the config

```bash
nix run .#apps.x86_64-linux.build-switch
```

If you skipped the nix.conf step, use: `nix --extra-experimental-features 'nix-command flakes' run .#apps.x86_64-linux.build-switch`

Enter your password when asked. This will:

- Configure the system via NixOS
- Install Home Manager packages (helix, kitty, fish, starship, etc.)
- Apply KDE Plasma config

### Step 4: Finish setup

1. **SSH keys** — Home Manager generates `~/.ssh/spicyzboss` and `~/.ssh/boss-spicyz100x` on first switch if they do not exist. Add the matching `.pub` files to the matching GitHub accounts as SSH authentication and signing keys.

2. **Use SSH for git** (optional) — `git remote set-url origin git@github.com:spicyzboss/configurations.git`

---

## Customization

The config uses username `spicyz`. For a different user:

- **macOS**: Change `user` in `flake.nix` and `hosts/darwin/default.nix`
- **NixOS**: Change `user` in `flake.nix` and `hosts/nixos/default.nix`

---

## Linking Configs

Every `custom/` config is linked by its own script under `scripts/`. To run them all at once:

```bash
./scripts/link-all
```

It runs each `scripts/link-*` script in turn, keeps going when one fails, and exits non-zero with a summary of what failed. Pass `--force` to forward that flag to every script, or name specific configs to link only those:

```bash
./scripts/link-all --force
./scripts/link-all tmux zellij
```

New `scripts/link-<tool>` scripts are picked up automatically; no edit to `link-all` is needed.

---

## Claude Config

Claude config is tracked in this repo as a shared custom config for macOS and Linux, but it is not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-claude
```

Tracked files live under `custom/claude/`:

- `settings.json`
- `commands/`
- `skills/`
- `hooks/` when needed

The link command creates symlinks into `~/.claude`. If a non-symlink file already exists, it refuses to replace it. Use `--force` to move the existing file or directory aside with a timestamped `.bak` suffix.

```bash
./scripts/link-claude --force
```

---

## Fish Config

Fish is installed by Nix, while user Fish files are tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-fish
```

Tracked files live under `custom/fish/`:

- `config.fish`
- `functions/`
- `completions/`

Themes are not tracked here. They come from the `catppuccin/fish` plugin listed in `~/.config/fish/fish_plugins`; run `fisher update` to install them. The link command applies `catppuccin-mocha` once the plugin has provided it.

The link command creates symlinks into `~/.config/fish` and leaves mutable Fish state like `fish_variables` alone. If a non-symlink file or directory already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-fish --force
```

---

## kitty Config

kitty is installed by Nix, while the user kitty config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-kitty
```

Tracked files live under `custom/kitty/`:

- `kitty.conf`
- `dark-theme.auto.conf` (Catppuccin Mocha)
- `light-theme.auto.conf` (Catppuccin Latte)

kitty picks `dark-theme.auto.conf` or `light-theme.auto.conf` on its own, following the OS appearance, and those colors replace whatever `kitty.conf` sets rather than layering on top. `kitty.conf` includes the dark file directly so there is still a theme when the OS reports no preference. To change a theme, edit these files; to change which theme is used for an appearance, swap the file contents.

`~/.config/kitty/current-theme.conf` is written by `kitten themes` and is not tracked here.

The link command creates symlinks at `~/.config/kitty/kitty.conf`, `dark-theme.auto.conf`, and `light-theme.auto.conf`. If a non-symlink path already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-kitty --force
```

---

## starship Config

starship is installed by Nix, while the prompt config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-starship
```

Tracked files live under `custom/starship/`:

- `dark.toml` (Catppuccin Mocha)
- `light.toml` (Catppuccin Latte)

Both palettes are written out in the files themselves rather than injected by the catppuccin module, so editing the prompt no longer needs a rebuild.

### Following the OS appearance

starship has no native light/dark palette switching ([starship#6991](https://github.com/starship/starship/issues/6991)), so `config.fish` installs a `fish_prompt` handler that points `STARSHIP_CONFIG` at `dark.toml` or `light.toml`. It reads a cached appearance without forking and refreshes that cache in the background, which costs a prompt about 0.5ms rather than the ~5ms a synchronous `defaults read` would add. The trade is that an appearance change lands on the next prompt rather than the current one. The cache is written through a temp file, so a half-finished refresh is never read as light.

This is macOS-only; elsewhere the prompt falls back to `~/.config/starship.toml`, which is linked to `dark.toml`.

The same handler exports `BAT_THEME`, which covers two more tools: bat uses it directly, and delta infers both its syntax theme and its light/dark diff colors from it. bat is also configured with `--theme=auto` plus `--theme-dark`/`--theme-light` in Nix, so it stays correct in shells that never run this handler.

Tools that follow the appearance on their own need nothing here: kitty, zellij, helix, yazi, Warp and fish all resolve a dark and a light theme themselves.

Use `theme` to inspect or override it:

```bash
theme          # show the active palette and whether it is following the OS
theme light    # pin this shell to light
theme dark     # pin this shell to dark
theme auto     # follow the OS again
```

The link command creates symlinks at `~/.config/starship/dark.toml`, `~/.config/starship/light.toml`, and `~/.config/starship.toml`. If a non-symlink file already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-starship --force
```

---

## tmux Config

tmux is installed by Nix, while the user tmux config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-tmux
```

Tracked files live under `custom/tmux/`:

- `tmux.conf`

The link command creates a symlink at `~/.config/tmux/tmux.conf`. If a non-symlink file already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-tmux --force
```

---

## zellij Config

zellij is installed by Nix, while the user zellij config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-zellij
```

Tracked files live under `custom/zellij/`:

- `config.kdl`

The link command creates a symlink at `~/.config/zellij/config.kdl`. If a non-symlink file already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-zellij --force
```

---

## Helix Config

Helix is installed by Nix, while the user Helix config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-helix
```

Tracked files live under `custom/helix/`:

- `config.toml`
- `themes/`

The link command creates symlinks at `~/.config/helix/config.toml` and `~/.config/helix/themes`. If a non-symlink file or directory already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-helix --force
```

---

## btop Config

btop is installed by Nix, while the user btop config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-btop
```

Tracked files live under `custom/btop/`:

- `btop.conf`
- `themes/` (`catppuccin_mocha.theme`, `catppuccin_latte.theme`)

`btop.conf` points `color_theme` at `~/.config/btop/current.theme`, a machine-local symlink the fish appearance handler flips between the two themes. The handler then sends `SIGUSR2`, which btop handles by re-reading its config and re-applying the theme, so a running btop switches live rather than waiting for a relaunch. The link command seeds the symlink if it is missing.

Note that btop rewrites `btop.conf` when it exits. Since that path is a symlink into this repo, quitting btop can show up as an uncommitted change here.

The link command creates symlinks at `~/.config/btop/btop.conf` and `~/.config/btop/themes`. If a non-symlink file or directory already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-btop --force
```

---

## Warp Config

Warp is installed via Homebrew (cask), while the user Warp config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-warp
```

Tracked files live under `custom/warp/`:

- `settings.toml`
- `themes/`

The link command creates symlinks at `~/.warp/settings.toml` and `~/.warp/themes`. If a non-symlink file or directory already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-warp --force
```

---

## yazi Config

yazi is installed by Nix, while the user yazi config is tracked in this repo as shared custom config and not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-yazi
```

Tracked files live under `custom/yazi/`:

- `yazi.toml`
- `theme.toml`
- `Catppuccin-mocha.tmTheme`

The link command creates symlinks for each file into `~/.config/yazi/`. If a non-symlink file already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-yazi --force
```

---

## Commands

If flakes are not in nix.conf, prefix with `nix --extra-experimental-features 'nix-command flakes' run` instead of `nix run`.

### macOS

| Command | Description |
| --------------------------------------- | ------------------- |
| `nix run .#apps.aarch64-darwin.build-switch` | Apply config changes |
| `nix run .#apps.aarch64-darwin.build` | Build only (no switch) |
| `nix run .#apps.aarch64-darwin.rollback` | Revert to previous config |

### NixOS

| Command | Description |
| --------------------------------------- | ------------------- |
| `nix run .#apps.x86_64-linux.build-switch` | Apply config changes |

### Both

| Command | Description |
| ------------------- | ------------------- |
| `nix flake update` | Update dependencies |

---

## Structure

```text
hosts/darwin/     macOS system config
hosts/nixos/      NixOS system config
custom/           Repo-tracked configs not linked by Home Manager
modules/darwin/   Darwin modules (casks, dock)
modules/nixos/    NixOS modules (KDE, packages)
modules/shared/   Shared config (git, ssh, kitty)
```
