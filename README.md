# dotfiles

Maintainable dotfiles for Apple Silicon macOS, Windows, and Linux CLI environments.

## Platform Positioning

- macOS is the primary target and daily-driver environment.
- Windows is a secondary environment for VM validation, WSL, gaming, and Windows-native workflows.
- Linux is a secondary CLI environment for WSL, SSH targets, and disposable development environments.

## Supported Platforms

- Apple Silicon macOS only
- Windows with PowerShell and optional WSL2
- Ubuntu/Debian-oriented Linux CLI environments

## Entry Points

- macOS: [bootstrap/macos.sh](bootstrap/macos.sh)
- Windows: [bootstrap/windows.ps1](bootstrap/windows.ps1)
- Linux: [bootstrap/linux.sh](bootstrap/linux.sh)

## Quick Start

Before your first full run:

- optional packages are disabled by default on all platforms
  - macOS: `DOTFILES_INCLUDE_MACOS_OPTIONAL_PACKAGES=1`
  - Windows: `DOTFILES_INCLUDE_WINDOWS_OPTIONAL_PACKAGES=1`
  - Linux: `DOTFILES_INCLUDE_LINUX_OPTIONAL_PACKAGES=1`
- if you want extra apps on the first run, use local overrides instead of editing the tracked baseline
  - macOS: [modules/macos/packages/local.Brewfile.sample](modules/macos/packages/local.Brewfile.sample)
  - Windows: [modules/windows/packages/local.Winget.json.sample](modules/windows/packages/local.Winget.json.sample)
  - Linux: [modules/linux/packages/local.apt.txt.sample](modules/linux/packages/local.apt.txt.sample)

### macOS

1. Copy [config/macos.env.sample](config/macos.env.sample) to `config/macos.env`.
2. Set:
   - `DOTFILES_MAC_MACHINE_NAME`
   - `DOTFILES_GIT_USER_NAME`
   - `DOTFILES_GIT_USER_EMAIL`
3. Run:

```bash
./bootstrap/macos.sh
```

### Windows

1. Copy [config/windows.env.sample](config/windows.env.sample) to `config/windows.env`.
2. Set:
   - `DOTFILES_GIT_USER_NAME`
   - `DOTFILES_GIT_USER_EMAIL`
   - `DOTFILES_WINDOWS_ENABLE_WSL=1` only if you want WSL
3. Install `FiraCode Nerd Font Mono` manually before expecting the final terminal look.
   - Download: `https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip`
4. Run an Administrator PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\bootstrap\windows.ps1
```

If PowerShell profile loading later fails with a signing or downloaded-file block, run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
Get-ChildItem -Recurse -File | Unblock-File
```

If you enable WSL, rerun the same Windows bootstrap after any required reboot. Then initialize the distro manually and run the Linux bootstrap inside it.

### Linux

1. Copy [config/linux.env.sample](config/linux.env.sample) to `config/linux.env`.
2. Set:
   - `DOTFILES_GIT_USER_NAME`
   - `DOTFILES_GIT_USER_EMAIL`
3. Run:

```bash
./bootstrap/linux.sh
```

Linux is CLI-focused. It does not install GUI terminal fonts. Terminal fonts, ligatures, and Nerd Font glyph rendering are handled by the terminal client that connects to Linux, such as Ghostty, Windows Terminal, or VS Code terminal.

Local override rules:

- keep local overrides untracked
- use them only for additive machine-specific package additions
- do not put package removals or repo-wide defaults in local overrides

## Setup Model

Each platform supports the same execution model.

- `bootstrap`
  - run the full setup flow
- `install-apps`
  - install packages and install-side prerequisites
  - do not deploy settings
- `configure-shell`
  - deploy shell profiles, rc files, completions, and prompt hooks
- `apply-preferences`
  - apply OS-native preferences
- `register-update-job`
  - register the scheduled update job
- `configure-apps`
  - configure already-installed apps and tools
  - skip missing apps instead of failing

The thin rerun wrappers are:

- macOS
  - `./modules/macos/rerun/install-apps.sh`
  - `./modules/macos/rerun/configure-shell.sh`
  - `./modules/macos/rerun/apply-preferences.sh`
  - `./modules/macos/rerun/register-update-job.sh`
  - `./modules/macos/rerun/configure-apps.sh`
- Linux
  - `./modules/linux/rerun/install-apps.sh`
  - `./modules/linux/rerun/configure-shell.sh`
  - `./modules/linux/rerun/apply-preferences.sh`
  - `./modules/linux/rerun/register-update-job.sh`
  - `./modules/linux/rerun/configure-apps.sh`
- Windows
  - `.\modules\windows\rerun\Install-Apps.ps1`
  - `.\modules\windows\rerun\Configure-Shell.ps1`
  - `.\modules\windows\rerun\Apply-Preferences.ps1`
  - `.\modules\windows\rerun\Register-UpdateJob.ps1`
  - `.\modules\windows\rerun\Configure-Apps.ps1`

You can also run the same steps through the main entry points with `--only` or `-Only`.

## Package Layers

Each platform uses the same package layering model:

- `base`
  - tracked packages that define the baseline
- `optional`
  - tracked packages that are disabled by default
- `local override`
  - untracked, additive-only machine-specific package additions

## Terminal and Editor Baseline

- macOS terminal: Ghostty
- Windows terminal: Windows Terminal
- Linux terminal rendering: provided by the client terminal, not by Linux bootstrap
- prompt: Starship
- multiplexer: tmux on macOS and Linux
- editor baseline: VS Code on macOS and Windows, lightweight Neovim everywhere
- terminal font target: `FiraCode Nerd Font Mono`
- editor font target: `Fira Code`

Windows terminal fonts are manual by design. macOS can auto-install fonts. Linux does not manage host terminal fonts.

## Package Catalogs

Use the tracked catalog files as the source of truth for the current package set.

- macOS
  - base: [modules/macos/packages/Brewfile.base](modules/macos/packages/Brewfile.base)
  - optional: [modules/macos/packages/Brewfile.optional](modules/macos/packages/Brewfile.optional)
- Windows
  - base: [modules/windows/packages/Winget.base.json](modules/windows/packages/Winget.base.json)
  - optional: [modules/windows/packages/Winget.optional.json](modules/windows/packages/Winget.optional.json)
- Linux
  - base: [modules/linux/packages/apt.base.txt](modules/linux/packages/apt.base.txt)
  - optional: [modules/linux/packages/apt.optional.txt](modules/linux/packages/apt.optional.txt)

## Repository Layout

- `bootstrap/`
  - user-facing entry points
- `config/`
  - bootstrap config samples
- `modules/`
  - executable implementation
- `assets/`
  - tracked static configuration assets
- `testenv/`
  - static and environment validation helpers

## Maintenance

Maintenance notes live in [MAINTENANCE.md](MAINTENANCE.md).
