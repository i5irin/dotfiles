# Development Environment

> Status: 2026-09  
> Scope: Personal development on macOS, including web/API development, bots, quantitative workloads, and local AI.

## 1. Goals

The development environment should remain lightweight, fast, understandable, and reconstructable.

The target properties are:

- day-to-day development is simple and fast
- each repository declares the runtime and dependencies it needs
- a new machine can reconstruct the environment from version-controlled declarations
- Apple Silicon CPU, GPU, and Unified Memory remain directly usable where valuable
- AI coding agents are not coupled to a vendor-specific development environment
- the same development host can be reached from iPad or iPhone
- individual tools can be replaced without redesigning the whole workflow
- the responsibility boundary between host and containers stays obvious

The environment itself should not become an oversized product.

---

## 2. Core Principles

### 2.1 Repository-centered environment definition

Do not try to move the entire development machine between computers.

Instead, keep the declarations required to reconstruct a project in its repository.

A repository should normally contain, where applicable:

- language / runtime version
- dependency manifest
- lockfile
- build and test commands
- external service definition
- coding-agent instructions
- environment-variable samples

Do not commit machine-local runtime state such as:

- runtime binaries
- `node_modules`
- Python `.venv`
- build caches
- database data
- credentials
- personal agent sessions or memory

The target state is:

> clone the repository, provide standard bootstrap tooling, and reconstruct an equivalent environment from declarations.

Exact byte-for-byte replication is less important than reproducing an equivalent environment appropriate for the target OS and architecture.

### 2.2 Prefer vendor-neutral boundaries

The important part is not making every tool vendor-neutral.

The important part is choosing standard protocols, files, and conventions at the boundaries between tools.

Examples:

| Purpose | Preferred boundary |
| --- | --- |
| Remote shell | SSH |
| Private network | IP network / WireGuard-style overlay |
| Source control | Git |
| Containers | OCI images / Compose-style definitions |
| Node version | `.node-version` or equivalent repository declaration |
| Python | `pyproject.toml`, `.python-version` |
| Go | `go.mod`, `go.work` |
| Rust | `Cargo.toml`, `rust-toolchain.toml` |

Changing Termius should not require changing SSH.

Changing Tailscale should not require changing the remote-shell workflow above it.

Changing Codex to another coding agent should not require changing the repository, shell, Git, or compiler.

Design the replaceable boundary first, then choose the most useful implementation for the current environment.

### 2.3 Prefer common and replaceable tools

When selecting shared tooling, prefer:

1. broad adoption
2. standard formats or protocols
3. viable alternatives
4. text-based configuration
5. CLI / automation / agent friendliness
6. the ability to remove the tool without breaking the repository model

Do not optimize for having one tool manage everything.

When an ecosystem already has a mature standard mechanism, prefer respecting that ecosystem.

### 2.4 Host-first, container-when-useful

Do not make a development container the default home for the entire development environment.

Tools directly used by the developer, editor, coding agent, or compiler normally run on the host.

Containers are preferred when they provide concrete value, for example:

- MySQL / PostgreSQL
- Redis
- Elasticsearch
- Kafka and similar services
- production-like Linux runtime verification
- final container images for ECS or similar deployments
- CI build / test
- repositories that genuinely require Linux
- disposable integration-test environments

A useful mental model is:

> Host = Development Plane  
> Container = Infrastructure / Runtime Compatibility Plane

Dev Containers are not prohibited. They are an exception selected per repository when the repository itself benefits from a containerized development environment.

### 2.5 Do not unnecessarily abstract machine capability

Use native macOS / Apple Silicon execution when the workload benefits from it.

Examples include:

- MLX
- Metal workloads
- Core ML
- local LLMs
- memory-intensive analysis
- quantitative backtesting
- bots and workers
- long-running CPU / GPU workloads

Portability and native machine capability are separate concerns. Preserve portable declarations while intentionally allowing machine-native execution where valuable.

---

## 3. Responsibility Model

```text
iPad / iPhone
    │
    │ Termius
    │ SSH
    ▼
Private Overlay Network
    │
    │ Tailscale
    ▼
────────────────────────────────────
macOS Development Host
────────────────────────────────────

Remote / Session
    OpenSSH
    tmux

Human Interface
    Ghostty
    VS Code

AI Agents
    Codex CLI
    Claude Code
    Other Agent CLIs

Common CLI
    git / gh
    rg / fd / jq
    AWS CLI etc.

Language Toolchains
    Node.js → fnm
    Python  → uv
    Go      → Go toolchain
    Rust    → rustup

Repository
    Source
    Runtime declaration
    Dependency declaration
    Lockfile
    AGENTS.md etc.

External Infrastructure
    Container Runtime
        ├ MySQL / PostgreSQL
        ├ Redis
        ├ Elasticsearch
        └ Other Services

Machine-native Compute
    CPU / GPU / Unified Memory
    MLX / Metal / Core ML etc.

────────────────────────────────────
              │
              ▼
             CI
              │
       Test / Build / Image
              │
              ▼
          Production
```

---

## 4. Current Recommended Tooling

### macOS / shared tools

| Role | Current choice | Notes |
| --- | --- | --- |
| Package bootstrap | Homebrew | Primarily OS-level bootstrap and common CLI |
| Terminal | Ghostty | Replaceable |
| Editor | VS Code | Kept separate from terminal choice |
| Shell | zsh | macOS standard |
| Source control | Git / `gh` | Git remains the core boundary |
| Session persistence | tmux | Separates network disconnects from process lifetime |
| AI coding agents | Codex CLI / Claude Code | Run on the host |
| Remote client | Termius | Used from iPad / iPhone |
| Remote protocol | SSH | Primary replaceable boundary |
| Private network | Tailscale | Avoid exposing SSH directly to the public Internet |
| Container runtime | Docker-compatible environment | Implementation should remain replaceable |

Homebrew should not become the package manager for every project dependency.

Avoid installing project-specific Node, Python dependencies, databases, and similar runtime state globally through Homebrew without a clear reason.

---

## 5. Language Environments

### 5.1 Node.js

Separate runtime selection from project dependency management.

```text
fnm
 └─ Node.js runtime

pnpm
 └─ packages / dependencies
```

Typical repository:

```text
project/
├── .node-version
├── package.json
├── pnpm-lock.yaml
└── node_modules/       # not committed
```

Use `.node-version` to declare the development Node.js version and let `fnm` select the runtime when entering the repository.

Use `package.json` for application-level requirements, including compatible Node ranges and package-manager metadata where appropriate.

Avoid accumulating global npm packages. Prefer project dependencies for project-specific tools.

### 5.2 Python

Use `uv` as the primary Python environment tool.

```text
project/
├── .python-version
├── pyproject.toml
├── uv.lock
└── .venv/             # not committed
```

`uv` may cover:

- Python runtime management
- virtual environment creation
- dependency resolution
- locking
- command execution

Do not install project dependencies into a shared global Python environment.

Apple Silicon-specific libraries such as MLX should remain usable from the native Python environment.

### 5.3 Go

Use Go's native toolchain and module model.

```text
project/
├── go.mod
├── go.sum
└── go.work             # when needed
```

Declare version / toolchain requirements in repository-level Go files.

Shared module download caches are acceptable.

Keep logical dependency state repository-scoped while allowing machine-scoped download caches, following Go's normal model.

### 5.4 Rust

Use the standard Rust ecosystem.

```text
project/
├── rust-toolchain.toml
├── Cargo.toml
├── Cargo.lock
└── target/             # not committed
```

Roles:

```text
rustup
 └─ Rust toolchain

cargo
 ├─ dependencies
 ├─ build
 └─ test
```

Prefer Rust's own mature tooling rather than introducing a general-purpose version manager solely for Rust.

---

## 6. External Services

Databases, caches, search engines, brokers, and similar services normally run in containers.

Example:

```text
project/
├── compose.yaml
├── src/
└── ...
```

```text
Native Application
    │
    ├─ localhost → MySQL Container
    ├─ localhost → Redis Container
    └─ localhost → Elasticsearch Container
```

Benefits include:

- version pinning
- easy initialization and reset
- service-scoped lifecycle
- closer production approximation
- less host pollution

Different repositories can use different service versions without installing several host daemons.

The application itself does not need to be containerized merely because its external services are.

---

## 7. Remote Development

Do not make a coding-agent-specific remote feature the center of remote development.

The normal path is:

```text
iPad / iPhone
        │
     Termius
        │
      SSH
        │
    Tailscale
        │
        ▼
      macOS
        │
       tmux
        │
 ┌──────┼────────┐
Codex  Claude    Shell
                Git
```

### 7.1 Tailscale

Tailscale provides private-network reachability.

It does not replace SSH.

Do not expose the Mac's SSH port directly to the public Internet when Tailnet access is available.

A future WireGuard-style replacement should not require redesigning the SSH workflow above it.

### 7.2 OpenSSH

Use SSH as the standard remote-shell protocol.

Use macOS Remote Login / OpenSSH Server on the host.

Prefer separate SSH keys per iPad / iPhone device rather than reusing a single private key everywhere.

### 7.3 Termius

Termius is the current SSH client on iPad / iPhone.

Keep dependence on Termius-specific features low so another standard SSH client can replace it.

### 7.4 tmux

tmux separates the lifetime of development processes from the lifetime of the network connection.

```text
SSH disconnected
      X

tmux
 ├ Codex
 ├ Claude
 ├ Server
 └ Logs
      │
      └─ continues on the Mac
```

Reconnect and attach to the existing session.

Do not add Mosh or another layer until mobile network switching or reconnect latency becomes a concrete problem.

---

## 8. AI Coding Agents

Run Codex CLI, Claude Code, and similar agents on the host.

```text
Codex
Claude
Other Agents
     │
     ▼
Same Repository
Same Git
Same Runtime
Same Shell
Same Credentials
```

Do not create a separate development environment for each agent.

Treat an agent as a replaceable client that operates on the repository.

Persistent project-specific agent rules belong in repository-visible files such as:

```text
AGENTS.md
other project-local agent configuration
```

Personal sessions, memories, and credentials stay outside the repository.

Where appropriate, use an explicit authority boundary such as:

```text
Agent
  read
  edit
  test
  lint
  git status
  git diff

Human
  git add
  git commit
  git push
  merge / rebase
```

The exact boundary may vary by repository, but it should be intentional.

---

## 9. What Portability Means

Portability does not mean copying a development machine disk image.

The target model is:

```text
Repository
       +
Bootstrap Tools
       +
Credentials / Secrets
       ↓
Development Environment
```

For example, on a new Mac:

```text
git clone
   ↓
.node-version        → Node runtime
.python-version      → Python runtime
go.mod               → Go toolchain
rust-toolchain.toml  → Rust toolchain

lockfiles
   ↓
Dependencies

compose.yaml
   ↓
External Services
```

Machine-local caches and virtual environments do not need to move with the repository.

---

## 10. Daily Workflow

### Local

```text
Ghostty / VS Code
       ↓
cd Repository
       ↓
Select runtime from repository declaration
       ↓
Start container services if needed
       ↓
Codex / Claude / Human use the same environment
```

### Remote

```text
iPad / iPhone
       ↓
Tailscale
       ↓
Termius / SSH
       ↓
tmux
       ↓
Same macOS Development Host
```

Do not create a second "remote development environment".

The development environment remains the same Mac regardless of where it is operated from.

---

## 11. Decision Rules

Before adding a new tool or environment layer, ask:

1. Can the requirement be solved by a repository declaration?
2. Can the language's standard ecosystem solve it?
3. Is this a development tool that belongs on the host?
4. Is this an external service or compatibility runtime that benefits from containers?
5. Should it run natively to use machine-specific capabilities?
6. Can a standard boundary be used instead of a vendor-specific one?
7. If the tool is replaced, will the repository and workflow still work?

Be cautious about adding a common abstraction merely because it looks convenient.

Introduce abstractions when several concrete use cases actually need them.

---

## 12. Priorities

The environment prioritizes:

**Simplicity**
- it should be obvious where each process runs

**Reproducibility**
- repositories should contain enough declarations to rebuild their environment

**Portability**
- machines and tools can change without rewriting the project model

**Performance**
- macOS / Apple Silicon capability should not be unnecessarily hidden behind virtualization

**Interoperability**
- prefer widely used boundaries such as SSH, Git, and OCI

**Replaceability**
- Codex, Claude, Termius, Tailscale, and similar components should remain replaceable

**Isolation**
- use containers where isolation has clear value

**Explicitness**
- runtime versions, dependencies, and agent rules should be declared rather than implied by machine state

---

## 13. Current Standard Layout

```text
MacBook Pro / macOS
│
├── Homebrew
│    └─ Bootstrap / Common CLI
│
├── Ghostty
├── VS Code
├── zsh
├── tmux
│
├── Git / gh
│
├── Codex CLI
├── Claude Code
│
├── Node.js
│    ├─ fnm
│    └─ pnpm
│
├── Python
│    └─ uv
│
├── Go
│    └─ Go native toolchain management
│
├── Rust
│    └─ rustup / Cargo
│
├── Native Compute
│    └─ MLX / Metal / Core ML etc.
│
└── Container Runtime
     ├─ MySQL / PostgreSQL
     ├─ Redis
     ├─ Elasticsearch
     ├─ Kafka etc.
     └─ Production-like Build / Runtime

Remote
│
├── Tailscale
├── macOS OpenSSH
├── tmux
│
└── iPad / iPhone
     └─ Termius
```

This exact tool selection is not intended to be permanent.

The durable design is:

> declare project requirements in repositories  
> use standard boundaries  
> keep host and container responsibilities explicit  
> use machine capability intentionally  
> use the same host remotely  
> treat coding agents as replaceable clients

Individual tools may be replaced whenever a better implementation preserves these properties.
