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
- allow platform package baselines to differ according to their responsibilities; do not expand Windows or Linux merely to mirror macOS
- treat the macOS base layer as the tracked baseline for the primary daily Development Host
- keep Rosetta disabled by default and use it only as an explicit compatibility option for Intel-only software
- add modules or bootstrap steps only when an existing responsibility cannot express a concrete requirement

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

Keep installation, configuration, and validation separate. Package installation belongs to `install-apps`, shell wiring belongs to `configure-shell`, application settings belong to `configure-apps`, and declarative repository checks belong under `testenv/validation`.

## Runtime and Toolchain Policy

- Homebrew owns machine-level manager and bootstrap executables on macOS: `fnm`, `pnpm`, `uv`, Go, and `rustup`.
- Language-native managers own language runtimes and toolchains. Homebrew must not also provide baseline Node.js or Rust compiler installations that compete with `fnm` or `rustup`.
- Project repositories own runtime declarations, dependency manifests, and lockfiles. Dotfiles must not install project dependencies.
- Shell configuration owns only stable manager initialization and required `PATH` entries. Installers must not edit dotfiles-managed shell files.
- Runtime downloads, virtual environments, package stores, build output, and caches are machine-local state and must remain untracked.
- A project dependency manager must not silently replace its runtime manager. In particular, retain a `pnpm` installation method that does not introduce Homebrew Node.js.
- Leave Go's standard `GOTOOLCHAIN=auto` behavior intact and do not set `GOROOT` or `GOPATH` without a concrete need.
- Do not set global default Node.js, Python, or Rust versions solely for bootstrap convenience; repository declarations remain the normal selection boundary.

## Container Runtime Policy

- Keep Docker CLI, OCI images, `Dockerfile`, and Compose definitions as the project-facing interfaces.
- Treat Colima as the current macOS backend implementation, not as a project-level dependency.
- Keep backend lifecycle separate from project definitions. Bootstrap installs and configures CLI wiring but never starts the Colima VM.
- Keep Colima VM state, images, volumes, Docker contexts, registry credentials, authentication state, and runtime caches machine-local and untracked.
- Do not manage or replace `~/.docker/config.json`; Docker Compose plugin discovery uses a dedicated symlink under `~/.docker/cli-plugins`.
- Do not keep Docker Desktop and Colima together in the tracked package baseline. Machine-specific alternatives belong in an untracked local override.
- Kubernetes and backend-specific container tooling are not baseline requirements.

## AI Coding Tool Policy

- Treat Codex CLI and Claude Code as replaceable machine-level host clients, not as separate development environments.
- Install and update the tracked clients through Homebrew. Do not add a second agent-specific update mechanism alongside Homebrew ownership.
- Bootstrap must not authenticate to OpenAI or Anthropic.
- Keep credentials, API keys, OAuth tokens, sessions, conversation history, memory, machine identity, and caches machine-local and untracked. Do not symlink agent state into this repository.
- Keep project-specific instructions such as `AGENTS.md`, `CLAUDE.md`, and other project-local agent configuration in the project repository that owns them.
- Do not add global agent configuration, wrappers, daemons, or bootstrap steps without a concrete shared requirement.

## Package Catalog Policy

- `base`
  - tracked baseline required for that platform's intended role
- `optional`
  - tracked packages that are useful but disabled by default
- `local override`
  - untracked, additive-only machine-specific additions

Optional packages are disabled by default on all platforms.

- macOS: `DOTFILES_INCLUDE_MACOS_OPTIONAL_PACKAGES=1`
- Windows: `DOTFILES_INCLUDE_WINDOWS_OPTIONAL_PACKAGES=1`
- Linux: `DOTFILES_INCLUDE_LINUX_OPTIONAL_PACKAGES=1`

The macOS base is intentionally broader because macOS is the primary Development Host. Workload-specific compilers, runtimes, and applications should remain optional unless they are required across the standard host workflow.

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

Container runtime validation on Apple Silicon macOS is split by virtualization capability:

- macOS VM
  - validate fresh bootstrap and any required Full Disk Access flow
  - validate the second bootstrap plus `install-apps` and `configure-apps` reruns
  - validate package presence, Docker Compose plugin wiring, and that bootstrap does not start Colima
  - do not require Colima runtime capability when the VM environment does not provide nested virtualization
- physical Apple Silicon Mac
  - validate Colima VZ startup with VirtioFS
  - validate Docker daemon connectivity, `docker run`, Docker Compose, and localhost-to-container integration

Physical-host runtime acceptance should avoid disturbing an existing Docker environment. Use an isolated named Colima profile, `--activate=false`, an explicit Docker context, and a temporary `DOCKER_CONFIG`; keep all resulting runtime state machine-local and clean up the test profile afterward.

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
