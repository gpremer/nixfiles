# Nixfiles

This is my repo for sharing my nix/home-manager config between machines.

## How to use

### Install nix & home-manager

#### Nix

When on non-NixOs Linux:

See the installation instructions at the [nix site](https://nix.dev/tutorials/install-nix).

In essence, this means executing `sh <(curl -L https://nixos.org/nix/install) --daemon`

#### home-manager

See the official [standalone installation instructions](https://nix-community.github.io/home-manager/index.html#sec-install-standalone)

When on Nix 22.05

```{bash}
nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
```

### Setup configuration files

Assuming this repo is cloned to `~/nixfiles`:

```
rm -rf ~/.config/nix
rm -rf ~/.config/nixpkgs

ln -s ~/nixfiles/nix ~/.config/nix
ln -s ~/nixfiles/nixpkgs ~/.config/nixpkgs

home-manager switch
```

## Beware

I'm just starting out with this, so if you stumble upon this, don't assume that I know what I'm doing.
