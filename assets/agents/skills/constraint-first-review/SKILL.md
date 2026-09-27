---
name: constraint-first-review
description: Evaluate substantial, hard-to-reverse technical decisions by checking constraints that could invalidate or materially reshape the proposal before large PoCs or implementation. Use for architecture, external service/API adoption, important dependencies, persistence or data design, security/identity/tenancy boundaries, or questions about whether an external platform is viable, supported, or allowed for an intended role. The goal is to find the conditions for proceeding safely and efficiently, not to maximize caution or choose the most conservative possible outcome. Do not use for typo fixes, formatting, obvious localized bug fixes, or other small reversible changes.
---

# Constraint-first review

Evaluate a proposal from the constraints that could invalidate it, materially reshape it, or make later change unnecessarily expensive.

The purpose of this review is to **enable informed progress**, not to maximize caution.

> Check the constraints that can change the decision, then continue once they are understood well enough.

A constraint is not automatically a blocker.

Uncertainty is not automatically a reason to reject a proposal.

The most conservative interpretation is not automatically the safest or best decision.

Do not treat this as a fixed checklist. Investigate only the constraints that are material to the current decision, and prefer upstream constraints with high invalidation potential, broad impact, or high cost of later change.

## 1. Define the decision

State briefly:

- the proposal or question being evaluated;
- its intended role in the system;
- what would become canonical, authoritative, security-sensitive, or otherwise hard to reverse, when relevant;
- what "working" or "acceptable" must mean for this decision.

Then ask:

> What fact could invalidate this proposal entirely, force a major redesign, or materially change how it should be used?

Identify the important assumptions behind the proposal before proving lower-level implementation details.

Also identify what does **not** need to be known yet.

Do not require implementation-level certainty for a decision that can safely proceed with bounded uncertainty.

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

- can reject or materially reshape the proposal;
- have a large blast radius;
- are expensive or difficult to change later;
- would make substantial downstream investigation wasteful if unresolved.

Skip a lens when resolving it cannot materially change the decision.

Do not expand the review merely because more things could theoretically be checked.

## 3. Separate constraints from conservative choices

Finding a constraint does not by itself determine the most conservative product or engineering behavior.

For each material constraint, distinguish its actual effect.

A useful classification is:

- **Invalidating** — available evidence shows that the proposal cannot reasonably satisfy a required condition in its current form.
- **Must resolve before an irreversible step** — uncertainty is acceptable for exploration, but not before a specific costly, security-sensitive, contractual, or hard-to-reverse action.
- **Bounded uncertainty** — the uncertainty can be represented, isolated, monitored, configured, tested later, or otherwise managed without invalidating the current direction.
- **Non-blocking** — the issue is real but does not materially affect the current decision.
- **Not material to this decision** — further investigation would not change what should be done now.

Do not turn:

- incomplete evidence into a rejection;
- an edge case into a universal restriction;
- inability to prove the strongest claim into inability to make a weaker useful claim;
- one uncertain component into a reason to discard unrelated established behavior;
- a reversible implementation choice into an architecture gate;
- a possible risk into a mandatory redesign without considering likelihood, impact, and available mitigation.

When several interpretations remain plausible, ask whether the system can honestly support the uncertainty through:

- a narrower claim;
- a conditional path;
- a range;
- explicit configuration;
- a replaceable boundary;
- a small follow-up experiment;
- deferred commitment;
- another bounded representation.

Use the least restrictive representation that remains accurate enough for the decision and its consequences.

Do not choose a more conservative behavior merely because it is easier to justify.

## 4. Verify mutable external constraints

When a material assumption depends on an external service, platform, API, policy, lifecycle, support status, quota, or similar information that may change, verify the current state using official or primary sources whenever reasonably available.

Secondary sources can help discover issues, but do not pass a material gate based only on:

- model memory;
- previous conversations;
- blogs or social posts;
- Stack Overflow or forums;
- another model's answer;
- an old experiment performed under materially different conditions.

For Terms, policies, licensing, or similarly interpretive material, do not convert ambiguous wording into definitive legal advice.

If authoritative material does not clearly resolve the intended use, state what remains ambiguous.

Then determine whether that ambiguity:

- must be resolved before the current decision;
- only matters before a later irreversible action; or
- can remain open while current work proceeds.

Seek authoritative clarification only when the unresolved interpretation is material enough to justify delaying the affected action.

## 5. Maintain evidence discipline

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

Also do not confuse **evidence strength** with **decision impact**.

A fact may be unverified but non-blocking.

A well-documented constraint may be real but irrelevant to the current use case.

A partially proven approach may still be appropriate for a reversible experiment.

Keep these distinctions explicit:

technical feasibility != officially supported use

documented API behavior != permission for every intended use

local or simulated success != production-equivalent proof

absence of a documented prohibition != confirmed permission

not verified != refuted

uncertain != unusable

constraint != blocker

## 6. Apply the decision gate proportionally

Pause substantial downstream work when an upstream constraint reveals:

- a clear incompatibility with a required condition;
- a material unsupported, deprecated, or out-of-intended-use condition that affects the proposed role;
- an unresolved assumption capable of invalidating the architecture before an expensive commitment;
- a material Terms, policy, licensing, security, privacy, or identity ambiguity that must be resolved before the affected action;
- another high-impact issue for which continuing now would make substantial work likely to be discarded.

Do not open a gate merely because uncertainty exists.

Before stopping work, ask:

1. Could this issue actually change the current decision?
2. Does it need to be resolved now, or only before a later commitment?
3. Can the uncertainty be isolated or represented honestly?
4. Is the next work reversible?
5. What is the cost of proceeding compared with the cost of verification?
6. Would stopping materially reduce useful progress, learning, or approved product value?

Judge the gate using:

- impact;
- invalidation potential;
- reversibility;
- cost of changing course later;
- cost of verification;
- ability to contain the uncertainty;
- value of the work that can safely proceed.

Low-impact, isolated, or easily reversible uncertainty can remain open while normal work proceeds.

If a gate is genuinely open, identify the smallest useful next action that could resolve or materially reduce the uncertainty.

Examples:

- verify one authoritative document;
- confirm one account, permission, or tenancy model;
- obtain authoritative provider clarification;
- run one narrowly scoped real-environment test;
- compare one alternative that removes the blocking constraint.

Do not turn a bounded question into a large research project.

## 7. Preserve intended value while handling constraints

A constraint-first review should protect the intended outcome from expensive invalid assumptions.

It should not silently replace the intended outcome with the safest-looking but least useful version.

When a constraint conflicts with expected product or engineering value:

- identify the actual conflict;
- preserve unaffected value;
- look for an accurate bounded representation;
- compare viable alternatives;
- surface a genuine trade-off when one remains.

If multiple valid options make materially different usefulness-versus-risk, usefulness-versus-precision, or flexibility-versus-complexity trade-offs, do not resolve the choice merely by selecting the most conservative option.

Use the repository's decision authority model. Escalate the trade-off when it genuinely requires product, business, security, legal, or other human judgment.

Safety, security, legal requirements, and explicit hard constraints still take precedence where they actually apply.

The point is not to weaken constraints. The point is to apply each constraint only as far as the evidence and consequences justify.

## 8. Move downward deliberately

After the material upstream constraints are sufficiently resolved, continue toward narrower technical questions.

"Sufficiently resolved" does not require perfect certainty.

It means the remaining uncertainty no longer justifies delaying the next planned level of work.

Prefer the smallest experiment that discriminates between meaningful alternatives.

Do not:

- prove properties that the decision does not yet require;
- optimize an implementation whose architecture is still materially gated;
- turn a broad uncertainty into a large PoC when a smaller test would answer it;
- keep reopening already resolved upstream questions without new evidence;
- continue constraint discovery after the remaining findings no longer affect the current decision.

Constraint review has a stopping condition.

Once the decision can responsibly proceed, proceed.

## Output

Keep the result proportional to the decision.

Normally make these points easy to identify:

**Decision / proposal being evaluated**

What is being considered and what "working" means.

**Material constraints checked**

Only the constraints that could meaningfully affect the decision.

**Effect of the findings**

Distinguish:

- invalidating constraints;
- constraints that must be resolved before a later irreversible step;
- bounded uncertainty;
- non-blocking findings.

Do not group every uncertainty under "blockers".

**What is already supported**

State both the useful conclusion and its evidence level.

**What can proceed now**

State the work or decision that can safely continue despite remaining uncertainty.

**Smallest unresolved question / experiment**

Include this only when further verification would materially improve the decision.

**What should wait**

Include this only when a specific unresolved constraint makes a specific downstream action premature.

Do not claim that no relevant constraint exists beyond the scope actually checked.

Use an evidence matrix, formal decision record, or longer report only when the complexity or consequences of the decision justify it.

## Boundaries

- Do not hard-code provider-specific Terms, policies, limits, or interpretations into this global skill.
- Do not copy project-specific product requirements or canonical project knowledge into this skill.
- Read repository-specific instructions and canonical sources when they are relevant to the decision.
- Do not invoke this review merely because a task involves code.
- Do not optimize for finding reasons to reject a proposal.
- Do not equate uncertainty with prohibition.
- Do not equate a constraint with a blocker.
- Do not automatically prefer the most conservative interpretation when multiple accurate and responsible options exist.
- Do not create scripts, reference documents, or additional artifacts unless a recurring concrete need justifies them.
- Do not treat this workflow as legal, compliance, or security authority; use authoritative sources and qualified human review where the decision requires it.
