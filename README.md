# Nix Dotfiles

macOS and NixOS configuration with [nix-darwin](https://github.com/LnL7/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew).

## Table of Contents

- [Fresh Mac Setup (Apple Silicon)](#fresh-mac-setup-apple-silicon)
- [NixOS Setup (x86_64)](#nixos-setup-x86_64)
- [Customization](#customization)
- [Claude Config](#claude-config)
- [Fish Config](#fish-config)
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

1. **1Password** — Open 1Password, sign in, then in **Settings → Developer** enable:
   - **Use the SSH Agent** — Git signing and SSH use 1Password
   - **Integrate with 1Password CLI** — For `op` commands (e.g. `op inject`). Quick open: `open "onepassword://settings/developers"`

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

1. **1Password** — Install and sign in. Git signing uses 1Password SSH agent.

2. **Use SSH for git** (optional) — `git remote set-url origin git@github.com:spicyzboss/configurations.git`

---

## Customization

The config uses username `spicyz`. For a different user:

- **macOS**: Change `user` in `flake.nix` and `hosts/darwin/default.nix`
- **NixOS**: Change `user` in `flake.nix` and `hosts/nixos/default.nix`

---

## Claude Config

Claude config is tracked in this repo as a shared custom config for macOS and Linux, but it is not linked by Home Manager. Link it after applying the Nix config:

```bash
./scripts/link-claude
```

Tracked files live under `custom/claude/`:

- `settings.json`
- `commands/`
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
- `themes/`

The link command creates symlinks into `~/.config/fish` and leaves mutable Fish state like `fish_variables` alone. If a non-symlink file or directory already exists, it refuses to replace it. Use `--force` to move the existing path aside with a timestamped `.bak` suffix.

```bash
./scripts/link-fish --force
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
modules/shared/   Shared config (git, ssh, helix, kitty, fish)
```
