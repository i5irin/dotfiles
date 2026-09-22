# Working agreements

- Work autonomously inside the current workspace and prefer completing the requested task end-to-end.
- You may create, edit, rename, and delete files inside the workspace when needed for the task.
- You may install dependencies and download public assets when needed.

## Approval gates

Ask before the following unless the user has explicitly authorized that exact action and scope:

- deleting large numbers of files
- forceful or broad operations such as `rm -rf`, `sudo`, broad `chmod` / `chown`, or disk / system changes
- destructive Git operations such as `git reset --hard`, `git clean -fd`, or force push
- editing files outside the current workspace
- accessing secrets, keychains, SSH config, shell profiles, or system settings

## Git

- Do not create commits, branches, tags, pull requests, or push to remotes unless explicitly asked.

## Constraint-first decision making

For substantial, hard-to-reverse decisions involving architecture, external services or APIs, new dependencies, data or persistence design, or security / identity / tenancy boundaries:

- Identify plausible constraints that could invalidate the proposal or force a major redesign before investing in detailed implementation or a large PoC.
- Check broad, high-impact, hard-to-change constraints before narrow implementation details.
- Do not proceed with substantial downstream work while a plausible higher-level blocker remains materially unresolved.
- For external facts that may change, verify current official or primary sources instead of relying on memory.
- Keep evidence levels distinct. Do not conflate officially specified / permitted / supported behavior, real-environment proof, local or simulated proof, inference, and unverified or ambiguous assumptions.
- Use the `constraint-first-review` skill for substantial decisions of this kind.

Apply the review proportionally. Do not invoke it for typo fixes, formatting changes, obvious localized bug fixes, or other small and readily reversible changes with no material architecture, integration, dependency, data, persistence, or security impact.

Repository-specific product rules and canonical sources remain in the repository or workspace that owns them; do not duplicate them into global instructions.

## Delivery

- After changes, run the minimum relevant checks that can reasonably verify the work.
- Summarize what changed, what was verified, and any remaining uncertainty or blocker.

## Communication and maintenance

- Respond in the language explicitly requested by the user. Otherwise use the main language of the conversation, then an available interface preference, then English.
- Write code comments and committed repository documentation in English unless the user explicitly requests another language.
- Prefer readable, direct code and stable tools. Add dependencies only when their lasting value outweighs their maintenance cost.
- Let code explain mechanics; use comments for reasons, constraints, and non-obvious tradeoffs.
