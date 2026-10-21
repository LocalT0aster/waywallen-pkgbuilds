# Waywallen Arch packages

Source-built generic `x86_64` Arch packages for the Waywallen stack. The
monorepo pins upstream releases as Git submodules and publishes signed packages
to GitHub Releases.

## Packages

- `waywallen`
- `waywallen-display`
- `waywallen-open-wallpaper-engine`

`open-wallpaper-engine` is built after and depends on `waywallen`, which
exports the `waywallen-bridge` CMake package it consumes.

## Install

Import the repository key and configure pacman:

```sh
sudo pacman-key --add keys/waywallen-packages.asc
sudo pacman-key --lsign-key B075783531075AA59D4911C7448DCEC4307C77A0
```

Add this repository to `/etc/pacman.conf`:

```ini
[waywallen]
Server = https://github.com/LocalT0aster/waywallen-pkgbuilds/releases/download/pacman-repository
```

## Downgrade

The repository keeps a rolling window of the newest three package versions
(older `pkgbuild` rebuilds of the same version are discarded). A pacman
repository tracks one version per package by design, so the archive versions
are reachable only through the release assets:

- List what is kept:
  `https://github.com/LocalT0aster/waywallen-pkgbuilds/releases/tag/pacman-repository`
- Install an archived version directly:

  ```sh
  sudo pacman -U 'https://github.com/LocalT0aster/waywallen-pkgbuilds/releases/download/pacman-repository/waywallen-0.4.4-3-x86_64.pkg.tar.zst'
  ```

- Run the [`downgrade`](https://github.com/archlinux-downgrade/downgrade) picker
  against a temporary cache mirror of the release:

  ```sh
  gh release download pacman-repository -R LocalT0aster/waywallen-pkgbuilds -D /tmp/ww-cache
  downgrade --pacman-cache /tmp/ww-cache waywallen
  ```

Local groups: rollback sets stay self-consistent — packages from one release
cohort are built, signed, and tested against each other.

## Local maintenance

```sh
git submodule update --init --recursive
./scripts/update-upstreams.sh
./scripts/update-pkgbuilds.sh
./scripts/build-repository.sh
```

The build script expects a non-root `makepkg` user with permission to install
the just-built dependency packages through `sudo pacman -U`.

## CI signing setup

The signing fingerprint is `B075783531075AA59D4911C7448DCEC4307C77A0`.
Export the private key locally, then add its armored content as the
`PACKAGER_GPG_PRIVATE_KEY` GitHub Actions secret:

```sh
gpg --armor --export-secret-keys B075783531075AA59D4911C7448DCEC4307C77A0
```

The private key is never committed. The publish workflow uploads signed package
archives and repository metadata to the `pacman-repository` release.

CI builds and runs smoke tests on standard GitHub-hosted x86_64 runners.
