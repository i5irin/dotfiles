---
name: constraint-first-review
description: Evaluate substantial, hard-to-reverse technical decisions by checking constraints that could invalidate the proposal before large PoCs or implementation. Use for architecture, external service/API adoption, important dependencies, persistence or data design, security/identity/tenancy boundaries, or questions about whether an external platform is viable, supported, or allowed for an intended role. Do not use for typo fixes, formatting, obvious localized bug fixes, or other small reversible changes.
---

# Constraint-first review

Evaluate a proposal from the constraints that could invalidate it.

Do not treat this as a fixed checklist. Investigate only the constraints that are material to the current decision, and prefer upstream constraints with high invalidation potential, broad impact, or high cost of later change.

## 1. Define the decision

State briefly:

- the proposal or question being evaluated;
- its intended role in the system;
- what would become canonical, authoritative, security-sensitive, or otherwise hard to reverse, when relevant;
- what "working" or "acceptable" must mean for this decision.

Then ask:

> What fact could invalidate this proposal entirely or force a major redesign?

Identify the important assumptions behind the proposal before proving lower-level implementation details.

## 2. Select the material constraints

Choose only lenses that could materially affect this decision.

Possible lenses include:

- Legal / Terms / Developer Policy / acceptable use / licensing
- Platform support status / lifecycle / deprecation / intended use
- Security / privacy / data ownership / compliance
- Permission / account / tenant / identity boundaries
- Product requirements / user mental model / UX
- Data portability / interoperability / vendor lock-in
- Consistency / durability / recovery / failure semantics
- Architecture / operational complexity
- API / protocol technical feasibility
- Performance / capacity / quota / cost
- Low-level implementation / optimization

This is not a required order.

Prefer constraints that:

- can reject the proposal;
- have a large blast radius;
- are expensive or difficult to change later;
- would make substantial downstream investigation wasteful if unresolved.

Skip a lens when resolving it cannot materially change the decision.

## 3. Verify mutable external constraints

When a material assumption depends on an external service, platform, API, policy, lifecycle, support status, quota, or similar information that may change, verify the current state using official or primary sources whenever reasonably available.

Secondary sources can help discover issues, but do not pass a material gate based only on:

- model memory;
- previous conversations;
- blogs or social posts;
- Stack Overflow or forums;
- another model's answer;
- an old experiment performed under materially different conditions.

For Terms, policies, licensing, or similarly interpretive material, do not convert ambiguous wording into definitive legal advice.

If authoritative material does not clearly resolve the intended use, classify the issue as ambiguous and identify the smallest authoritative clarification needed.

## 4. Maintain evidence discipline

Assign evidence states where the distinction matters:

- **Officially specified / permitted / supported** — current authoritative material directly establishes the claim.
- **Proven in real environment** — observed under materially representative real-world conditions.
- **Proven only locally / fake / simulation** — established only in a local, mocked, emulated, test, or otherwise non-equivalent environment.
- **Inferred** — reasonably derived from evidence but not directly established.
- **Partially proven** — some material parts are established while others remain open.
- **Refuted** — available evidence contradicts the assumption.
- **Not tested / not verified** — adequate evidence has not yet been obtained.
- **Ambiguous / requires authoritative clarification** — authoritative information exists but does not clearly resolve the relevant interpretation.

Do not upgrade an evidence state through wording or confidence alone.

Keep these distinctions explicit:

technical feasibility != officially supported use

documented API behavior != permission for every intended use

local or simulated success != production-equivalent proof

absence of a documented prohibition != confirmed permission

## 5. Apply the decision gate

Surface the gate explicitly when an upstream constraint reveals:

- a clear incompatibility;
- a material unsupported, deprecated, or out-of-intended-use condition;
- an unresolved assumption capable of invalidating the architecture;
- a material Terms, policy, or licensing ambiguity;
- another high-impact issue that could make substantial downstream work wasteful.

When such a gate is open, do not continue automatically into a large lower-level PoC or implementation merely because it was originally planned.

Instead, identify the smallest useful next action that could resolve or materially reduce the uncertainty.

Examples:

- verify one authoritative document;
- confirm one account, permission, or tenancy model;
- obtain authoritative provider clarification;
- run one narrowly scoped real-environment test;
- compare one alternative that removes the blocking constraint.

Do not block work for every uncertainty.

Judge whether a gate matters using:

- impact;
- invalidation potential;
- reversibility;
- cost of changing course later;
- cost of verification.

Low-impact or easily reversible uncertainty can remain open while normal work proceeds.

## 6. Move downward deliberately

After the material upstream gates are sufficiently resolved, continue toward narrower technical questions.

Prefer the smallest experiment that discriminates between meaningful alternatives.

Do not:

- prove properties that the decision does not yet require;
- optimize an implementation whose architecture is still materially gated;
- turn a broad uncertainty into a large PoC when a smaller test would answer it.

## Output

Keep the result proportional to the decision.

Normally make these points easy to identify:

**Decision / proposal being evaluated**

What is being considered and what "working" means.

**High-impact constraints checked**

Only the material constraints actually investigated.

**Blocking findings**

Findings that currently reject or materially gate the proposal.

Do not claim that no blocker exists beyond the scope actually checked.

**Important uncertainties**

Material assumptions whose evidence remains insufficient or ambiguous.

**What is already proven**

State both the conclusion and its evidence level.

**Smallest next gate / experiment**

The lowest-cost useful action that most reduces decision uncertainty.

**What should NOT be implemented yet**

Include this only when unresolved upstream constraints make substantial downstream work premature.

Use an evidence matrix, formal decision record, or longer report only when the complexity or consequences of the decision justify it.

## Boundaries

- Do not hard-code provider-specific Terms, policies, limits, or interpretations into this global skill.
- Do not copy project-specific product requirements or canonical project knowledge into this skill.
- Read repository-specific instructions and canonical sources when they are relevant to the decision.
- Do not invoke this review merely because a task involves code.
- Do not create scripts, reference documents, or additional artifacts unless a recurring concrete need justifies them.
- Do not treat this workflow as legal, compliance, or security authority; use authoritative sources and qualified human review where the decision requires it.
