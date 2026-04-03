# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal infrastructure-as-code repository managing Linux systems and a home server. It uses:
- **Ansible** — Docker service management on Raspberry Pi servers and desktop distro setup
- **NixOS/Home Manager** — Declarative system configs for several hosts
- **Bash** — Backup orchestration scripts

## Common Commands

### Ansible — Pi Server (Docker services)

Secrets are stored per host in `host_vars/<host>/vault.yml` (Ansible Vault-encrypted). Plain vars in `host_vars/<host>/vars.yml` reference them as `{{ vault_* }}`. Decrypt at run time with `--vault-password-file`.

To target a single host, pass it as an ad-hoc inventory with a trailing comma instead of using `inventory.ini`:

```bash
cd ansible/pi-server

# Run all roles against one host
ansible-playbook -i piuk, --vault-password-file ~/.ansible-vault-pass docker.yml

# Run a specific role (tag) against one host
ansible-playbook -i truenas, --vault-password-file ~/.ansible-vault-pass --tags <role> docker.yml

# Dry run
ansible-playbook -i piuk, --vault-password-file ~/.ansible-vault-pass --check docker.yml
```

### Ansible — Desktop Setup

```bash
cd ansible/archlinux
ansible-playbook --ask-become-pass archlinux.yml   # Requires python + ansible-aur collection

cd ansible/fedora
ansible-playbook --ask-become-pass fedora.yml       # Requires python
```

### NixOS — Rebuild (run on target host)
```bash
# NixOS hosts — if the machine's hostname matches the flake output name, the #<name> can be omitted:
sudo nixos-rebuild switch --flake nixos/nixos-desktop/#amdesktop
sudo nixos-rebuild switch --flake nixos/nixos-server/#mininixos
sudo nixos-rebuild switch --flake nixos/nixos-rpi/#pi3nixos

# Non-NixOS home-manager (Arch, Fedora) — from nixos/nix/:
home-manager switch --flake .#rogervn-desktop   # desktop machine (Hyprland, window manager)
home-manager switch --flake .#rogervn-headless  # headless machine (zsh, nvim only)
```

## Architecture

### Ansible Pi-Server (`ansible/pi-server/`)

Each self-hosted service is an Ansible role under `roles/`. Roles follow the standard structure: `tasks/main.yml`, `vars/main.yml`, `templates/`. The main playbook is `docker.yml`; inventory targets `piuk.localdomain` and `truenas.localdomain`.

Secrets are stored as Ansible Vault-encrypted `host_vars/<host>/vault.yml` files. Plain `host_vars/<host>/vars.yml` files reference vault values via `{{ vault_* }}` variables. Role-level `vars/main.yml` files may contain `<CHANGEME>` placeholders for values not yet vaulted.

Services managed: Docker runtime, Cloudflare Tunnel, WireGuard, Tailscale, Pi-hole, Home Assistant, Nextcloud, Vaultwarden, Immich, Paperless-ngx, Joplin, Authelia, Authentik, MariaDB, Redis, Mosquitto, Borg backup, rclone.

### NixOS (`nixos/`)

There are four separate flakes, each targeting a different class of host:

| Flake | Path | Hosts | nixpkgs |
|-------|------|-------|---------|
| `nix/flake.nix` | `nixos/nix/` | Non-NixOS distros (Arch, Fedora) — home-manager only, no system config | unstable |
| `nixos-desktop/flake.nix` | `nixos/nixos-desktop/` | `amdesktop`, `thinknixos`, `nixos-vm` | unstable |
| `nixos-server/flake.nix` | `nixos/nixos-server/` | `backupbox`, `mininixos` | unstable |
| `nixos-rpi/flake.nix` | `nixos/nixos-rpi/` | `pi3nixos`, `pi02nixos` | stable (25.11) |

**Key directories:**
- `hosts/<hostname>/` — Per-host config: `configuration.nix` (system), `hardware-configuration.nix` (auto-generated), `home.nix` (home-manager imports for that host)
- `home/` — Reusable home-manager modules imported by both NixOS hosts and the non-NixOS flake
- `modules/` — Reusable NixOS system modules (system-level only; never home-manager config)

**Package placement:**
- `modules/` sets `environment.systemPackages` — NixOS hosts only
- `home/` sets `home.packages` — used in all environments; on non-NixOS every package must be user-level since there is no system package manager
- `home/hyprland.nix` — shared Hyprland home-manager config (cursor, GTK theme, XDG portals, polkit agent); imported by NixOS desktop `hosts/*/home.nix` files and by `home/window_manager.nix` (non-NixOS)
