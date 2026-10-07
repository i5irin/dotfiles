---
name: verification-core
description: Independently verify or review a result against its explicit task contract and the cross-cutting boundaries materially relevant to that task. Use when operating as a Verifier, Reviewer, Validator, independent checker, or when explicitly asked to verify whether another result satisfies its requirements. Do not invoke automatically after ordinary task execution unless an external workflow or the user explicitly assigns a verification step.
---

# Verification core

Verify the result that was actually requested.

The purpose of verification is to detect material mismatch between the task contract and the produced result, then route to deeper guidance only when a relevant finding requires it.

> Verify narrowly first. Retrieve specialized failure knowledge only when the observed failure calls for it.

Do not turn verification into a general search for every possible problem.

## 1. Establish the task contract

Before judging the result, identify the applicable contract in this order:

1. explicit requirements and verification conditions in the current request;
2. output format, severity model, classification, or reporting rules specified by the caller;
3. applicable repository or project instructions;
4. current canonical sources required by the task;
5. cross-cutting global boundaries that materially apply.

The verifier should be able to state what successful completion means before reporting a failure.

Do not replace explicit task-specific criteria with a generic review checklist.

## 2. Verify task-specific requirements first

Check the requirements that the caller actually asked to verify.

Examples include:

- required behavior;
- acceptance criteria;
- specified invariants;
- expected files or outputs;
- test, lint, build, or runtime results;
- requested comparison criteria;
- explicit scope limitations;
- required result format.

Where deterministic verification is available, prefer actual tests, validation scripts, diffs, schemas, or other direct evidence over semantic judgment alone.

A failed deterministic check is evidence of that check's failure, not automatically proof of a broader architectural problem.

## 3. Select only relevant cross-cutting lenses

After task-specific verification, consider only the cross-cutting lenses that could materially affect the current result.

Possible lenses include:

### Task and scope

- Did the result perform the requested task?
- Did it materially expand into work that was not delegated?
- Did it modify or decide something owned elsewhere?

### Recipient context

Relevant when the result is a prompt, handoff, subagent request, reviewer request, third-party message, or similar recipient-facing artifact.

- Does it contain context the recipient does not need?
- Is required context missing?
- Does it depend on unstated private conversation or inaccessible sources?

If deeper analysis is needed, load and apply:

`assets/agents/skills/recipient-context/SKILL.md`

### Current and canonical state

- Does the result rely on superseded conversational state?
- Does it contradict a current applicable canonical source?
- Does it present an old proposal as the current decision?

### Authority

- Does the result perform or imply an action outside the delegated authority?
- Does access to information or tooling get mistaken for permission to act?

### Evidence and claims

- Are claims supported by the evidence actually inspected?
- Is uncertainty represented at the correct level?
- Is a local, simulated, inferred, or partial result presented as stronger evidence than it is?

Global privacy, persistence, credential, safety, and approval boundaries remain applicable independently of this list.

Not every lens applies to every task.

## 4. Distinguish findings from possibilities

A verifier is not required to find a failure.

Classify a concern according to the caller's required format when one exists.

When no format is specified, distinguish at least:

- **Confirmed finding** — available evidence establishes a material mismatch.
- **Potential finding** — a plausible material issue exists but the available evidence is insufficient to establish it.
- **No material finding** — the checked requirement is sufficiently supported.
- **Not verified** — the required evidence was unavailable or outside the verification scope.

Do not upgrade uncertainty into a failure merely to be cautious.

Do not downgrade an established mismatch because the overall result looks reasonable.

## 5. Route only after a material finding

When a finding can be evaluated directly from the task contract, do not load another skill.

Load specialized guidance only when the finding requires knowledge or a procedure not contained in this core verifier.

Initial routing includes:

### Recipient-context finding

For unnecessary context exposure, missing recipient context, hidden conversation dependency, or recipient-boundary ambiguity:

`assets/agents/skills/recipient-context/SKILL.md`

Use its review mode.

### Constraint-sensitive design finding

When verification reveals a substantial unresolved architecture, external-service, policy, security, identity, persistence, or other hard-to-reverse constraint that requires deeper evaluation:

`assets/agents/skills/constraint-first-review/SKILL.md`

Do not load it for routine implementation defects.

Additional failure-specific skills may be added later when repeated real failures demonstrate a distinct reusable recovery procedure.

Do not create or invoke a specialist merely because a finding can be given a category name.

## 6. Keep detection separate from recovery

Detection establishes what is wrong.

Recovery determines how to correct it.

Do not automatically broaden a verification assignment into modification or recovery unless the caller or workflow authorizes that action.

When recovery is authorized:

1. preserve the original task contract;
2. correct the smallest material cause of the finding;
3. avoid broad unrelated cleanup;
4. re-run the relevant verification.

## 7. Verify recovery

When reviewing a proposed correction or recovery:

- verify that the original finding no longer holds;
- verify the evidence required by the original task;
- check that the correction did not introduce a directly related new failure;
- do not reopen unrelated questions without new evidence.

A changed result is not evidence that recovery succeeded.

Recovery is verified only when the condition that caused the finding is no longer present or the task contract is otherwise demonstrably satisfied.

## 8. Report proportionally

Follow the caller's required output format when one exists.

Otherwise, for each material finding, make clear:

- what requirement or boundary was checked;
- what evidence was inspected;
- what failed or remains uncertain;
- why it matters to the current task;
- the smallest required correction or next verification step.

If no material finding was found, say what was checked without claiming broader correctness than the verification supports.

Do not produce a large audit report for a small task unless requested.

## Failure knowledge and promotion

This skill defines broad verification behavior, not a permanent catalog of past incidents.

When a new failure is observed:

- diagnose it before turning it into a reusable rule;
- prefer an existing invariant or skill when it already explains the failure;
- do not add a failure-specific skill after one isolated incident;
- consider specialized persistent guidance only when a reusable trigger and recovery procedure are demonstrated;
- keep detailed recovery knowledge outside this core skill when it is conditional.

The core verifier should remain small as the failure library grows.

## Boundaries

- Do not run this skill automatically after every ordinary task unless an explicit workflow requests verification.
- Do not search for failures unrelated to the assigned verification scope.
- Do not load all specialist skills preemptively.
- Do not treat a checklist item as relevant merely because it exists.
- Do not invent requirements that were not part of the applicable task contract or standing boundary.
- Do not equate uncertainty with failure.
- Do not equate access with authority.
- Do not turn review into implementation unless recovery is authorized.
- Do not preserve detailed incident history here when a smaller general invariant or conditional specialist skill is sufficient.
