---
name: readable-technical-explanation
description: Explain reasoning-heavy technical design, architecture, review findings, and engineering decisions without over-compressing important meaning. Use when new concepts, boundaries, lifecycle semantics, concurrency behavior, or decision state could be misunderstood if expressed only as terse technical labels. Do not use for simple localized tasks or when the reader has already established the relevant mental model.
---

# Readable technical explanation

Preserve information density while reducing cognitive load.

Do not make brevity the goal. Organize information so the reader can build the mental model needed to understand the conclusion.

> Compression is earned by prior explanation.

## When to use

Use this skill for reasoning-heavy technical communication such as:

- architecture and design discussions;
- architecture or design review;
- review findings whose implications are not obvious;
- explanations of domain models, persistence, transactions, concurrency, lifecycle, ownership, or authorization;
- technical decision documents where proposals, decisions, deferred items, and open questions could otherwise blur together.

Apply it especially when introducing:

- a new domain concept;
- a new boundary or ownership rule;
- a hard-to-reverse architecture decision;
- subtle concurrency or race behavior;
- lifecycle, retention, replacement, deletion, rollback, or undo semantics;
- terminology whose interpretation could materially change the design.

Do not invoke it mechanically for trivial implementation details, obvious localized changes, or concepts already understood in the current context.

## Core behavior

### 1. Expand before compressing

Do not introduce an important new concept only as a short technical label.

When useful, explain it in this order:

1. what it means in plain language;
2. why it is needed or what problem it solves;
3. a small concrete example;
4. how it differs from a nearby concept, if that distinction matters;
5. the concise technical term that can be used afterward.

Do not force all five steps when some add no value. The goal is understanding, not ceremony.

### 2. Build one mental model at a time

Do not pack multiple independent design decisions into one dense sentence.

When several new concepts depend on one another, introduce them in dependency order. Separate questions such as:

- what objects or components exist;
- who owns what;
- what must change together;
- where validation happens;
- where persistence or commit happens.

After the reader has the model, later references may use the shorter terminology.

### 3. Show concrete state transitions when abstraction is insufficient

For relationships, transactions, concurrency, lifecycle, replacement, rollback or undo, and authorization races, prefer a small state transition example when it materially improves understanding.

A useful shape is:

**Before -> Operation -> After**

Use the example to show what can become inconsistent, invalid, surprising, or irreversible.

Then name the technical concept.

### 4. Separate general meaning from project-specific meaning

When a term has an established general meaning and a narrower meaning in the current project, distinguish them explicitly.

For example:

- first state the conventional meaning briefly;
- then state how the current design uses the term;
- clarify when the project usage is intentionally narrower, looser, or different.

Do not let use of a term such as aggregate, repository, transaction, workspace, ownership, or boundary silently imply a larger methodology or architecture that has not actually been adopted.

### 5. Keep decision state clear

When ambiguity could cause a proposal to be mistaken for an existing decision, make the state explicit.

Distinguish, as needed:

- already decided / canonical;
- proposed;
- needs discussion now;
- can be deferred;
- implementation detail;
- specification decision required.

Do not add status labels to every paragraph. Surface the distinction only where it changes how the reader should interpret or act on the information.

### 6. Use prose before tables for new complex concepts

Do not use a table as the sole explanation of a new or complex concept.

Prefer:

**prose explanation -> concrete example -> optional table recap**

Tables are appropriate for comparison, overview, status, or recap after the underlying model has been explained.

### 7. Compress adaptively

Shorten explanations when:

- the concept has already been explained sufficiently in the current conversation or document;
- the reader explicitly indicates understanding;
- the detail is simple and implementation-local.

Do not compress on first introduction when the concept affects domain meaning, boundaries, consistency, concurrency, lifecycle, deletion, retention, ownership, or another consequential design choice.

## Documents and conversational explanations

For canonical documents, avoid turning every section into a tutorial. Leave enough context that a future reader can reconstruct what a term means, why the design exists, and what is actually decided.

For conversational explanations and review responses, provide more background, reasoning, and examples when they help the reader form the mental model.

Do not copy transient discussion detail into canonical documents merely because it was useful during explanation.

## Anti-patterns

Avoid:

- **Terminology-first explanation** — using an unexplained technical label as if it were the explanation.
- **Concept stacking** — combining several new concepts or independent design decisions into one compressed sentence.
- **Table-only architecture** — presenting a new architecture only as rows and columns.
- **Conclusion without mechanism** — stating what should be done without explaining what happens and why that leads to the conclusion.
- **General/project meaning conflation** — mixing a conventional technical definition with a project-specific interpretation.
- **Decision-state ambiguity** — presenting proposed, decided, deferred, and open matters with the same apparent certainty.
- **Tutorial over-expansion** — repeatedly re-explaining familiar concepts after the mental model has already been established.

## Example

Avoid starting with:

> Keep Position as a small aggregate, guarantee operation-level consistency with Allocation in the application service, and use Workspace as the commit boundary.

Prefer first building the model:

> A single user operation may update both Position and Allocation. If Position is saved but the related Allocation remains in its old state, the operation can leave the system inconsistent.
>
> Therefore, for operations that change both, validate the combined change and commit the required updates together in one transaction.
>
> This does not mean Position and Allocation must always become one large object. They may remain separate concepts and only participate in the same consistency scope for operations that require it.
>
> After that behavior is understood, the design can refer to this scope with a shorter project term such as **operation-level consistency boundary**.

The later compressed term is acceptable because the meaning and mechanism have already been established.

## Boundaries

- Preserve relevant technical precision; do not replace precise concepts with vague simplifications.
- Do not explain every known term by default.
- Do not invent examples that silently become project requirements.
- Do not treat illustrative terminology as canonical unless the project has actually adopted it.
- Read repository-specific instructions and canonical sources when project meaning matters.
- Keep the response proportional to the consequences and complexity of the decision.
