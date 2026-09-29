# Working agreements

- Work autonomously inside the current workspace and prefer completing the requested task end-to-end.
- You may create, edit, rename, and delete files inside the workspace when needed for the task.
- You may install dependencies and download public assets when needed.

## Approval gates

Ask before the following unless the user has explicitly authorized that exact action and scope:

- deleting large numbers of files
- forceful or broad operations such as `rm -rf`, `sudo`, broad `chmod` / `chown`, or disk / system changes
- destructive Git operations such as `git reset --hard`, `git clean -fd`, force push, or published-history rewriting
- editing files outside the current workspace
- accessing secrets, keychains, SSH config, shell profiles, or system settings
- entering, exposing, storing, or transmitting credentials or passphrases

## Git

- Do not create commits, branches, tags, pull requests, or push to remotes unless either:
  - the user explicitly asks for that action and scope; or
  - the current repository contains a clear user-approved standing delivery policy that explicitly delegates the action and scope.
- A repository standing delivery policy may authorize ordinary reversible work such as short-lived branch creation, coherent commits, branch pushes, Pull Request creation or updates, and Issue / PR state maintenance.
- Do not infer from a repository standing policy that you may merge Pull Requests, push directly to the default branch, force push, rewrite published history, create tags or releases, perform destructive Git cleanup, or modify credentials. Those remain separately gated unless the repository policy explicitly delegates the specific action.
- Before a Git mutation, inspect the current branch and working-tree state. Do not discard, overwrite, stage, or hide unrelated human changes.
- Before committing, stage only task-owned paths and review the staged diff when practical.
- Before pushing or creating a PR, inspect the relevant base-branch diff and commit history when practical.
- Unless the user explicitly requests another format or language, suggest commit messages in English using Conventional Commits syntax.
- Unless the user explicitly requests another format or language, write PR titles and bodies in English. PR titles need Conventional Commits syntax only when the repository requires it.
- Ground PR descriptions in the actual repository state and observed verification evidence; do not claim unsupported changes.
- If a Git or GitHub operation requires a credential, SSH passphrase, keychain unlock, account authorization, or other secret-bearing interaction, stop at that boundary. Ask the user to perform the authentication action without asking them to paste the secret into chat.

## Runtime, toolchain, and package management

- Respect repository-declared runtime, toolchain, and package-manager versions instead of relying on machine-global defaults.
- Before choosing or changing a runtime or toolchain version, inspect the repository's existing version files, manifest metadata, lockfiles, CI configuration, and development documentation.
- Do not silently replace or bypass an existing package manager, runtime manager, lockfile, or version policy.
- When the repository has no stronger constraint and a version choice is actually required, prefer the ecosystem's established standard or default tooling and a stable supported release line. Prefer LTS where the ecosystem provides and commonly uses it.
- Do not choose Current, nightly, prerelease, EOL, or a less-established alternative merely because it is newer or has more features. Deviate only for a concrete project requirement.
- When a runtime or toolchain becomes a real project dependency and the repository does not already declare it, declare the version using an appropriate repository-local mechanism rather than leaving the project dependent on the developer machine's global default.
- Keep dependency resolution reproducible with the repository's intended lockfile. Do not introduce a second package-manager lockfile.
- If existing version declarations conflict, do not silently normalize them. Identify the conflict and resolve it from the repository's documented source of truth or escalate when the intended version is materially ambiguous.

## Constraint-aware decision making

For substantial, hard-to-reverse decisions involving architecture, external services or APIs, new dependencies, data or persistence design, or security / identity / tenancy boundaries:

- Identify plausible constraints that could invalidate the proposal or force a major redesign before investing in detailed implementation or a large PoC.
- Check broad, high-impact, hard-to-change constraints before narrow implementation details.
- Do not proceed with substantial downstream work while a plausible higher-level blocker remains materially unresolved.
- For external facts that may change, verify current official or primary sources instead of relying on memory.
- Keep evidence levels distinct. Do not conflate officially specified / permitted / supported behavior, real-environment proof, local or simulated proof, inference, and unverified or ambiguous assumptions.
- Treat uncertainty proportionally. Missing proof or an unresolved detail is not by itself a blocker and is not a reason to choose the most conservative possible behavior.
- Once material invalidating constraints are sufficiently resolved, continue toward the intended outcome rather than maximizing caution.

Apply constraint review proportionally. Do not turn it into a default workflow for typo fixes, formatting changes, obvious localized bug fixes, or other small and readily reversible changes.

Repository-specific product rules and canonical sources remain in the repository or workspace that owns them; do not duplicate them into global instructions.

## Delivery

- After changes, run the minimum relevant checks that can reasonably verify the work.
- Summarize what changed, what was verified, and any remaining uncertainty or blocker.
- When a repository has a standing delivery policy, continue through its authorized delivery boundary instead of stopping merely to ask permission for an already-delegated routine step.
- Treat tool-native execution modes and planning-to-implementation prompts as harness state, not as project lifecycle or approval state. When the current repository defines roles, stages, or readiness gates, follow those instead of inferring that a tool prompt has advanced the project.
- A delegated task that is interrupted, cancelled, fails, or returns no completed result does not count as completed specialist work, review, or verification. Retry or resume from durable project state as appropriate.
- If the effective runtime capabilities contradict the configured role needed for the task, treat that as an operational blocker. Prefer reloading or restarting the correct role rather than weakening repository responsibility boundaries or converting the tool problem into a product decision.

## Communication and maintenance

- Respond in the language explicitly requested by the user. Otherwise use the main language of the conversation, then an available interface preference, then English.
- Write code comments and committed repository documentation in English unless the user explicitly requests another language.
- Write reader-facing project communication from the reader's perspective rather than relaying agent-internal wording, report order, or labels.
- When introducing a dense or unfamiliar concept, explain the meaning in plain language before relying on a concise technical term.
- In non-English communication, prefer natural expressions in that language over unnecessary English workflow labels or literal translations of internal terminology.
- In durable documents, define shared concepts once and avoid repeating the same caveat, status explanation, or evidence narrative across sections when a clear owning section can carry it.
- Treat durable documents as maintained current knowledge, not append-only records. Deleting, replacing, merging, or moving stale, duplicated, superseded, misowned, or process-only text is a normal edit; use version control and durable work items for history instead of preserving obsolete prose in the current document.
- Prefer readable, direct code and stable tools. Add dependencies only when their lasting value outweighs their maintenance cost.
- Let code explain mechanics; use comments for reasons, constraints, and non-obvious tradeoffs.
