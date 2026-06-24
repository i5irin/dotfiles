# Maintenance

This file is for repository maintenance and design intent. User-facing setup instructions belong in [README.md](README.md).

## Source of Truth

- `README.md`
  - user-facing setup and rerun usage
- `MAINTENANCE.md`
  - repository maintenance policy and design notes
- tracked assets and modules
  - executable source of truth for actual behavior

## Documentation Sync

- keep `README.md` aligned with the current bootstrap behavior
- keep `MAINTENANCE.md` aligned with the current maintenance policy
- when maintaining localized copies, update them in the same change set when practical

## Design Principles

- prefer stable, OS-native setup mechanisms
- keep bootstrap flows idempotent where practical
- keep package catalogs lean
- keep Windows native and Unix-style CLI concerns separate
- keep Linux focused on CLI behavior, not GUI terminal rendering
- keep machine-specific additions in untracked local override files
- keep `modules/cli` and `assets/cli` limited to true CLI tools
- keep GUI app/editor integrations under `modules/apps` and `assets/apps`

## Setup Responsibilities

- `install-apps`
  - install packages and install-side prerequisites
- `configure-shell`
  - deploy shell rc/profile/completion/prompt wiring
- `apply-preferences`
  - apply OS-native settings
- `register-update-job`
  - register recurring update jobs
- `configure-apps`
  - configure already-installed apps and tools
  - skip missing apps

`install-apps` must not silently deploy app settings. `configure-apps` must not silently install missing apps.

## Package Catalog Policy

- `base`
  - minimum tracked baseline for that platform
- `optional`
  - tracked packages that are useful but disabled by default
- `local override`
  - untracked, additive-only machine-specific additions

Optional packages are disabled by default on all platforms.

- macOS: `DOTFILES_INCLUDE_MACOS_OPTIONAL_PACKAGES=1`
- Windows: `DOTFILES_INCLUDE_WINDOWS_OPTIONAL_PACKAGES=1`
- Linux: `DOTFILES_INCLUDE_LINUX_OPTIONAL_PACKAGES=1`

When considering a new tracked package:

1. ask whether it is required for the platform baseline
2. if not required, prefer `optional`
3. if it is highly personal or low-maintenance value, prefer `local override`

## Local Override Files

- macOS
  - `modules/macos/packages/local.Brewfile`
- Windows
  - `modules/windows/packages/local.Winget.json`
- Linux
  - `modules/linux/packages/local.apt.txt`
- shell-local files
  - `modules/shell/zsh/.zshrc.local`
  - `modules/shell/bash/.bashrc.local`
  - `modules/shell/powershell/Microsoft.PowerShell_profile.local.ps1`

Tracked sample files document the format. Actual override files should remain untracked.

## Terminal Baseline

- macOS
  - Ghostty
  - fonts can be auto-installed
- Windows
  - Windows Terminal
  - fonts are manual by design
- Linux
  - bootstrap does not manage GUI terminal fonts
  - glyphs, ligatures, and font rendering depend on the client terminal

Prompt generation still belongs to the target OS environment. That is why Linux still installs Starship even though font rendering is client-side.

## Validation Expectations

- macOS
  - validate on Apple Silicon macOS
- Windows
  - validate in a VM
- Linux
  - validate in a disposable Ubuntu/Debian-style environment or WSL

Validation flow:

1. run static checks on the host
2. run `bootstrap/* --dry-run` in the target environment
3. run the full bootstrap
4. record any manual setup that still remains

Validation targets:

- macOS and Windows
  - prefer VM-based validation
- Linux
  - prefer a disposable Ubuntu/Debian-style environment, WSL, or a container smoke test

Static checks:

```bash
./testenv/validation/run-static-checks.sh
```

Prefer updating static checks when changing:

- package composition
- bootstrap entry points
- rerun wrappers
- generated terminal assets

## When Updating README

Update `README.md` when any of the following changes:

- package layering or defaults
- bootstrap entry points or step names
- manual setup requirements
- local override paths
- terminal/editor baseline expectations

Keep `README.md` user-facing. Push design detail here instead of expanding README indefinitely.
