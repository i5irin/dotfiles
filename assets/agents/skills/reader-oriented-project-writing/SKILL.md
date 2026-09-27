---
name: reader-oriented-project-writing
description: Draft or rewrite substantial project-facing text so it reads as intentional human communication rather than agent output. Use for canonical project documents, GitHub Issue bodies and checkpoints, PR summaries, review packages, handoffs, and agent-to-human project updates when wording, structure, repetition, terminology, or internal workflow language makes the result hard to read. Do not use for trivial chat replies, code comments, or tasks whose main challenge is teaching a difficult technical concept rather than shaping the artifact.
---

# Reader-oriented project writing

Write for the person who must understand, decide, maintain, or resume the work.

The source material may come from agents, research, verification, diffs, or earlier documents. Its structure is input, not the required output structure.

## 1. Reconstruct instead of relaying

Do not preserve the sentence order, headings, labels, or vocabulary of upstream agent reports merely because they are accurate.

Before writing, identify:

- what the reader needs to understand;
- what changed;
- what is currently true;
- what action or decision, if any, is required;
- what detail is evidence rather than the main message.

Then write from that model.

For human-facing summaries, a useful default order is:

1. outcome or current state;
2. the small number of changes that matter;
3. why they matter;
4. required action or next step;
5. supporting detail only where needed.

## 2. Plain language before compressed terminology

Do not introduce a workflow, product, or technical concept only through a compact label.

Explain the meaning first when the reader may not already share the term.

Prefer:

> September is counted differently for pension and health insurance, so they must be calculated separately.

before:

> The shared month rule was superseded.

After the meaning is established, a concise term may be used if it genuinely helps later references.

## 3. Use natural language, not translated internal language

When writing in a language other than English:

- reconstruct the sentence naturally in that language;
- avoid mixing English workflow labels into ordinary prose when a clear native expression exists;
- do not translate internal agent prose sentence by sentence;
- keep an established English technical term only when it is the normal term for the audience or precision would otherwise be lost.

Internal labels such as `checkpoint`, `blocking`, `conditional scenario`, `component`, or `superseded` should not leak into human-facing prose merely because the source report used them.

## 4. Separate current state from history

For mutable work items such as GitHub Issues:

- the Issue body should describe the current work contract: current goal, scope, acceptance criteria, constraints, and current state when useful;
- comments should preserve material decisions, evidence, and changes over time;
- when a decision changes current scope or acceptance criteria, update the Issue body instead of forcing future readers to reconstruct the current state from a comment chain;
- do not erase useful decision history merely to keep the body current.

For checkpoints, record the delta since the previous durable state. Do not restate the entire project or repeat research that is already durably referenced.

## 5. Keep canonical documents responsibility-oriented

Each durable document should have a clear job.

- Put product intent in the document that owns product intent.
- Put detailed rules and observable semantics in the requirements that own them.
- Put implementation choices in design or implementation artifacts.
- Keep process history in work items rather than copying it into canonical product documents.

Define a shared rule once in the most appropriate section. Later sections should refer to or apply it instead of re-explaining the full rule unless repetition is necessary for independent understanding.

## 6. Compress repetition, not meaning

When a document becomes long, first look for repeated:

- caveats;
- negative guardrails;
- evidence explanations;
- status language;
- definitions;
- scenario setup;
- source rationale.

Consolidate them before deleting useful domain semantics.

Worked examples and specification checks should usually contain:

- the facts that differ from the shared setup;
- the expected result;
- the interaction or boundary the example verifies.

They should not repeat the full rule text already defined earlier unless the example would otherwise be ambiguous.

## 7. Make state and action obvious

For reviews, handoffs, and issue updates, the reader should be able to answer quickly:

- What is true now?
- What changed?
- Is anything blocked?
- Do I need to decide or do something?
- What happens next?

If no human action is required, say so plainly rather than presenting a decision-shaped report.

## 8. Keep evidence proportional

Evidence should support the statement it justifies without overwhelming the main message.

Prefer a concise finding plus a durable source reference over pasting an entire research transcript.

Preserve uncertainty accurately, but do not make uncertainty vocabulary the organizing structure of the document unless uncertainty itself is the subject.

## Relationship to readable technical explanation

Use `readable-technical-explanation` when the primary problem is helping the reader understand a difficult technical concept or mental model.

Use this skill when the primary problem is shaping a project artifact or human-facing project communication so that it is readable, current, concise, and written from the reader's perspective.

Both can apply to the same task, but do not load both mechanically when one is sufficient.

## Boundaries

- Preserve material meaning while rewriting structure and wording.
- Do not hide uncertainty, disagreement, or incomplete work for the sake of smooth prose.
- Do not convert a proposal into a decision through wording.
- Do not remove required traceability or safety constraints merely to shorten a document.
- Do not create new project terminology unless it earns its maintenance cost.
- Follow repository-specific ownership and canonical-source rules.
