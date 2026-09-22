# Repository guidance

This repository manages dotfiles for Apple Silicon macOS, Windows, and Linux CLI hosts. Read `README.md` for setup, `MAINTENANCE.md` for invariants and validation, and `docs/development-environment.md` for architecture rationale.

- Preserve the host-first architecture, package layers, bootstrap responsibility boundaries, and human-owned authentication and enrollment.
- Use zsh for macOS-specific executables, Bash for Linux-specific executables, PowerShell for Windows, and POSIX sh only for genuinely shared portable code. Source-only libraries have no shebang or executable bit.
- Follow the Google Shell Style Guide where it does not conflict with the dialect boundary. Follow The Unofficial PowerShell Best Practices and Style Guide for PowerShell.
- Keep code comments and committed documentation in English. Explain reasons and constraints in comments, not obvious mechanics.
- Run `./testenv/validation/run-static-checks.sh` after changes. Validate platform bootstrap flows in representative environments when available.
- Keep cross-project agent instructions and reusable skills in `assets/agents/`; repository knowledge belongs in code and the canonical documentation above.
