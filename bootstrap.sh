#!/usr/bin/env bash
set -Cexuo pipefail

export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix shell nixpkgs#git --command bash -c "GIT_SSH_COMMAND=\"ssh -o StrictHostKeyChecking=accept-new\" git -C ~ clone git@github.com:orthonormalremy/dotfiles.git || git -C ~ clone https://orthonormalremy:$(curl -s -u orthonormalremy https://codeberg.org/orthonormalremy/secrets/raw/branch/main/GITHUB_READ_ACCESS_TOKEN)@github.com/orthonormalremy/dotfiles.git"
~/dotfiles/scripts/bootstrap/setup_home.sh
