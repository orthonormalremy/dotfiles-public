# dotfiles

## New Host Setup

### Linux (not NixOS)

#### 1. Install Nix

**1.1 Choose and Run the Appropriate Installer**

First, check your init system:

```bash
ps -p 1 -o comm=
```

**For systemd-based systems:**

Perform a multi-user installation with the [Determinate Nix installer](https://zero-to-nix.com/start/install/):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
```

```bash
exit # exit and open a new shell to refresh your environment
```

> **Why Determinate Nix installer?** Enables [flakes](https://zero-to-nix.com/concepts/flakes) and [unified CLI](https://zero-to-nix.com/concepts/nix/#unified-cli) by default, plus [additional features](https://github.com/DeterminateSystems/nix-installer/blob/main/README.md#features).

**For non-systemd systems:**

Perform a single-user installation with the [official installer](https://nixos.org/download/#nix-install-linux):

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon
```

```bash
exit # exit and open a new shell to refresh your environment
```

> **Why official installer?** Determinate Systems doesn't offer a single-user installer as of 2025-06-04.

**1.2 Verify Installation**

```bash
nix --version
```

**1.3 Enable `nix-command` and `flakes`**

Test if features are already enabled (should be automatic with Determinate Nix installer):

```bash
# test nix-command
nix config show

# test flakes
nix flake metadata --extra-experimental-features nix-command
```

If not enabled, add them manually:

```bash
mkdir -p ~/.config/nix
(set -C; echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf)
```

#### 2. Bootstrap System with Home Manager

Clone this dotfiles repo (I use my home directory `~` as the parent dir):

```bash
nix shell nixpkgs#git --command bash -c "git -C /path/to/parent-dir clone https://orthonormalremy:$(curl -s -u orthonormalremy https://codeberg.org/orthonormalremy/secrets/raw/branch/main/GITHUB_READ_ACCESS_TOKEN)@github.com/orthonormalremy/dotfiles.git"
```

Use [Home Manager](https://github.com/nix-community/home-manager) to initialize `home.init.nix` (provides `home.stateVersion`):

```bash
# home-manager has a dependancy on git
[[ ! -e ~/.config/home-manager/home.init.nix ]] && nix shell nixpkgs#git --command bash -c "nix run home-manager/master -- init --no-flake" && mv ~/.config/home-manager/home.nix ~/.config/home-manager/home.init.nix
```

Select home.nix profile (e.g. work vs personal):

```bash
bash -c "cd /path/to/parent-dir/dotfiles/.config/home-manager; home.<profile>.nix home.nix"
```

Create [stow](https://www.gnu.org/software/stow/) managed symlinks:

```bash
nix shell nixpkgs#git nixpkgs#stow --command bash -c "cd /path/to/parent-dir/dotfiles && stow --no-folding -R -t ~ ."
```

Bootstrap system with Home Manager using the [flakes approach](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone):

```bash
# requires --impure because the flake uses envionment variables
nix shell nixpkgs#git --command bash -c "nix run home-manager/master -- switch --impure"
```

```bash
exit # exit and open a new shell to refresh your environment
```

<details>
<summary>Remy, for your copy-paste convenience:</summary>

```bash
(
    set -exuo pipefail
    nix shell nixpkgs#git --command bash -c "git -C ~ clone https://orthonormalremy:$(curl -s -u orthonormalremy https://codeberg.org/orthonormalremy/secrets/raw/branch/main/GITHUB_READ_ACCESS_TOKEN)@github.com/orthonormalremy/dotfiles.git"
    [[ ! -e ~/.config/home-manager/home.init.nix ]] && nix shell nixpkgs#git --command bash -c "nix run home-manager/master -- init --no-flake" && mv ~/.config/home-manager/home.nix ~/.config/home-manager/home.init.nix
    bash -c "cd ~/dotfiles/.config/home-manager; ln -s common.nix home.nix"
    nix shell nixpkgs#git nixpkgs#stow --command bash -c "cd ~/dotfiles && stow --no-folding -R -t ~ ."
    nix shell nixpkgs#git --command bash -c "nix run home-manager/master -- switch --impure -b backup"
)
# exit
```

</details>

#### 3. Init Secrets (if you're Remy)

```
nu dotfiles/scripts/nu/ensure_secrets.nu
```
