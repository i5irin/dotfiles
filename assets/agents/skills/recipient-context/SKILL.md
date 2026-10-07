---
name: recipient-context
description: Prepare or review recipient-facing task context such as prompts, handoffs, subagent requests, reviewer requests, or third-party messages. Use when knowledge from the current conversation, canonical sources, private workspaces, or other projects must be projected to a different person or agent. Also use when reviewing whether an existing recipient-facing artifact contains unnecessary context or omits context required to perform the task correctly. Do not use for ordinary direct answers to the current user unless the answer itself is a handoff or task artifact for another recipient.
---

# Recipient context

Prepare the context that a specific recipient needs for a specific task.

> Use broad knowledge for reasoning. Expose only the context that is necessary for the recipient to perform the current task correctly.

Knowledge available to the sender is not automatically recipient context.

The goal is not to make every prompt or handoff short. A phase handoff may legitimately need substantial context, while a narrow implementation task may need very little. Optimize for **minimum sufficient context**, not minimum length.

## 1. Establish the recipient boundary

Before drafting, identify:

- who the recipient is;
- what task the recipient is being asked to perform;
- what outcome or stopping point is expected;
- what decisions the recipient is allowed or expected to make;
- what sources the recipient can actually access.

Do not assume that the recipient shares the sender's:

- conversation history;
- personal knowledge;
- corrections or prior mistakes;
- project-management model;
- permissions;
- attachments;
- private workspace;
- future plans;
- responsibilities.

If the recipient needs information derived from any of those sources, carry over the relevant meaning explicitly and in a self-contained form.

## 2. Build a task projection

Select context according to whether removing it would materially impair the recipient's ability to:

- understand the task;
- make a required decision;
- implement the requested change;
- verify the result;
- preserve a required invariant;
- operate within the applicable safety or authority boundary.

Typical recipient context may include:

- the current task and expected outcome;
- current state directly relevant to the task;
- relevant domain invariants;
- accepted decisions that constrain the task;
- acceptance or verification criteria;
- references to canonical sources the recipient can access;
- required authority or stopping boundaries;
- unresolved questions the recipient is expected to resolve.

Context may be known and useful to the sender without belonging in the recipient artifact.

## 3. Keep internal context internal when it does not change the task

Do not expose context merely because it is correct, interesting, or available.

Normally keep context internal when it does not materially change the recipient's current work, such as:

- unrelated future roadmap;
- work planned for a later phase;
- cross-project priorities;
- personal planning or portfolio context;
- internal information-management terminology;
- historical correction chains;
- failure lessons whose trigger is not relevant;
- abandoned or superseded alternatives;
- source-discovery history;
- internal reasoning about why the sender selected the task;
- background from another project that does not constrain this task.

These are examples of the principle, not a permanent denylist.

If one of these items actually constrains the current task, include the necessary meaning rather than excluding it because of its category.

## 4. Preserve current meaning

Prefer the current explicit task state and applicable canonical sources over stale conversational context.

When older context conflicts with a newer accepted decision:

- carry forward the current decision;
- omit obsolete alternatives unless the recipient needs the history to understand or resolve the task;
- do not preserve correction history merely to prove that a correction happened.

A recipient should not need to reconstruct current state from superseded decisions.

## 5. Make the artifact self-contained

A recipient-facing task artifact should normally make it possible to answer:

- What am I being asked to do?
- What is currently true?
- What constraints or invariants matter?
- What may I change?
- What should I leave unchanged?
- How will completion be judged?
- Where should I look for authoritative details?
- Where should I stop or escalate?

Self-contained does not mean copying every source into the artifact.

Prefer a concise statement plus an accessible canonical reference when the source itself should remain authoritative.

## 6. Separate disclosure from authority

Providing information does not grant authority.

Do not infer that a recipient may:

- modify another workspace;
- publish information;
- commit or push changes;
- broaden scope;
- access secrets;
- make unrelated product decisions;

merely because context about those matters is available.

Follow the applicable global, repository, project, privacy, persistence, approval, and authority rules independently of this skill.

## 7. Handle sensitive or source-dependent context

When context may contain private, machine-specific, secret-bearing, client-specific, or otherwise destination-sensitive information, apply the applicable disclosure and approval rules before transmission or persistence.

Prefer conveying the portable technical meaning when the original source identity is unnecessary.

Do not treat this skill as a substitute for security, privacy, credential, or approval gates.

## 8. Review mode

When reviewing an existing prompt, handoff, or recipient-facing artifact, check only the boundaries relevant to that artifact.

Ask:

### Necessity

Would removing this context materially reduce the recipient's ability to perform or verify the current task correctly?

### Relevance

Does the context constrain the current task, or does it belong to another phase, project, or decision?

### Currency

Does the artifact represent the latest accepted state rather than a superseded decision or stale conversation state?

### Accessibility

Can the recipient understand and access the references, terminology, and sources it is expected to use?

### Self-containment

Can the recipient act without relying on an unstated conversation, attachment, correction, or permission?

### Boundary integrity

Does the artifact disclose context or imply authority beyond the recipient's task?

Do not report a boundary violation merely because the artifact contains substantial context. The question is whether that context is necessary and appropriately scoped.

## 9. Output behavior

When drafting:

- produce the recipient-ready artifact from the recipient's perspective;
- include necessary context directly or by usable reference;
- avoid narrating internal selection decisions unless the user needs to approve a disclosure;
- keep sender-only reasoning outside the recipient-ready text.

When reviewing:

- follow any result format or classification required by the caller;
- identify concrete unnecessary exposure or missing context;
- explain how it affects the recipient's task;
- recommend the smallest correction that restores the intended boundary.

Do not invent additional requirements merely to make the artifact more comprehensive.

## Boundaries

- Minimum sufficient context is task-dependent; do not optimize for brevity alone.
- Do not convert internal knowledge into recipient-facing context without a task reason.
- Do not remove necessary domain invariants, current state, acceptance criteria, or authority boundaries merely to shorten a prompt.
- Do not require every handoff to use the same structure.
- Do not create a permanent denylist from individual incidents.
- Do not assume that a past failure lesson applies when its triggering condition is absent.
- Do not duplicate canonical source content when an accessible reference is sufficient.
- Do not treat recipient context selection as permission to disclose secrets or otherwise restricted information.
