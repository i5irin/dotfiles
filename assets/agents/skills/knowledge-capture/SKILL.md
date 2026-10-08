---
name: knowledge-capture
description: Capture, reconcile, query, and surface transient knowledge and attention candidates across conversations and workspaces. Use when the user explicitly signals that something should be remembered, reused, revisited, or published later; when a conversation produces reusable knowledge, a process improvement, important decision rationale, a publishing seed, or an important unresolved item; or when an assistant identifies something likely to remain useful across future work. Also use when querying, reconciling, reminding, expiring, or backfilling the shared AI Capture Buffer. Do not use for routine facts, ordinary task status, generic tips, or content that is already durably routed or resolved.
---

# Knowledge capture

Use the AI Capture Buffer to prevent useful knowledge, process improvements, publishing ideas, and unresolved attention items from disappearing inside individual conversations.

The buffer is a temporary machine-managed staging layer.

It is not:

- a canonical knowledge base;
- a conversation archive;
- a replacement for a Domain Workspace;
- a replacement for the Information Inbox;
- a permanent task manager.

Its purpose is to retain potentially valuable items long enough for them to be reused, routed, acted on, dismissed, or allowed to expire.

## 1. Core model

The lifecycle is:

```text
Conversation / Workspace
        |
        | detect candidate
        v
AI Capture Buffer
        |
        | reconcile / deduplicate / remind
        v
     pending
        |
        +--> routed
        +--> incorporated
        +--> acted
        +--> dismissed
        |
        +--> expired
```

The derived item state is intentionally small:

- `pending`
- `closed`
- `expired`

When an item is closed, preserve a separate reason:

- `routed`
- `incorporated`
- `acted`
- `dismissed`

Do not use `dismissed` for an item that was successfully handed to another durable destination.

## 2. When to trigger this skill

Trigger when either the user explicitly signals value or the assistant identifies material future value.

### Explicit user signals

Typical signals include statements equivalent to:

- this seems useful;
- this is a good insight;
- I want to remember this;
- I may want to use this later;
- I may want to post or publish this;
- this could become an article, video, post, or other output;
- keep this in mind;
- we should revisit this;
- this may affect how we work later.

Do not depend on exact wording.

Interpret the user's intent.

### Assistant-detected candidates

Trigger when the assistant identifies something with meaningful future value, including:

- knowledge likely to be reused in similar work;
- a pattern that generalizes beyond the current project;
- a process improvement;
- a repeated failure mode and a useful prevention rule;
- a design or decision rationale likely to matter later;
- an observation that may alter future workflows;
- an insight that applies across domains;
- a useful explanation or mental model;
- a potentially valuable publishing idea;
- a timely or distinctive publishing angle that could attract attention even when it does not yet contain deep durable knowledge;
- an important unresolved decision or question whose loss could affect future work.

The threshold is not "interesting."

The threshold is:

> Would losing this when the conversation ends create a meaningful chance of repeating work, losing an insight, missing an output opportunity, or overlooking an important unresolved matter?

If not, do not capture it.

## 3. What not to capture

Normally do not capture:

- routine factual answers;
- ordinary status updates;
- commit, PR, issue, or file activity with no reusable learning;
- generic advice that is easy to search again;
- temporary wording choices;
- minor implementation details that belong only to the current task;
- every alternative mentioned during brainstorming;
- every assistant suggestion;
- content already present in its proper canonical source;
- content already stored in an actual Issue, Inbox item, task, or other durable owner unless new independent knowledge remains;
- content the user explicitly rejects;
- raw transcripts merely because they contain useful material.

Avoid turning the buffer into a second Inbox.

## 4. Candidate kinds

Use one primary kind.

Allowed values are:

- `knowledge`
- `process`
- `decision`
- `attention`
- `publishing`

### knowledge

Reusable understanding, explanation, lesson, method, or mental model.

### process

A finding likely to improve a workflow, development process, operating process, review method, or recurring practice.

### decision

A significant decision, decision rationale, or unresolved decision whose future context matters.

### attention

Something that materially requires the user's future awareness, judgment, confirmation, or follow-up.

Use this conservatively.

### publishing

Something worth considering for SNS, a blog post, video, stream, short-form content, essay, presentation, or another public output.

Publishing candidates may be captured because of timeliness, novelty, personal experience, entertainment value, or likely audience interest even when they are not strong durable knowledge.

Do not force multi-label taxonomy.

Semantic querying can recover overlapping meanings later.

## 5. Attention candidates

Attention candidates require a higher threshold than ordinary assistant suggestions.

Capture an unresolved item as attention when all of the following are broadly true:

1. the matter could materially affect later decisions, process, project progress, or a canonical source;
2. the user has not actually resolved it;
3. losing it when the conversation moves on would be undesirable;
4. there is no confirmed durable destination that already owns it.

Examples:

- an unresolved architectural choice that blocks later work;
- a process problem that needs the user's judgment;
- a possible canonical-source conflict;
- an important question the user did not answer before the conversation moved elsewhere.

Do not create an attention candidate merely because:

- the user did not reply to a minor suggestion;
- the conversation moved to another topic;
- an optional alternative was mentioned;
- the assistant would personally prefer an answer.

Silence is not rejection and is not resolution.

## 6. Minimal capture content

Capture only the minimum context needed to understand and recover the candidate later.

Prefer:

- a short title;
- a concise summary;
- why it may matter;
- domain or project when useful;
- a minimal source reference;
- enough context to distinguish it from similar items.

Do not copy an entire conversation.

Do not preserve private context merely because it was available.

Do not persist:

- passwords;
- API keys;
- access tokens;
- private keys;
- credentials;
- unnecessary machine-local paths;
- unnecessary personal data;
- unrelated private conversation history;
- raw logs containing sensitive information.

When private source material contains a reusable conclusion, preserve the portable conclusion rather than the private source details.

## 7. Storage binding and model

This skill does not define or hard-code a storage provider or physical root.

Use the capture sink and logical storage root supplied by the caller, execution environment, applicable global instructions, or another explicitly authorized configuration.

When multiple configurations exist, prefer the most specific applicable configuration.

Do not infer a storage destination merely from tool availability.

If no authorized writable capture sink or logical root is available:

- do not invent one;
- do not claim persistence succeeded;
- continue the main task where possible;
- report the persistence gap when it materially matters.

Within the configured logical storage root, use an append-only model.

Do not implement the queue by repeatedly reading and overwriting one shared mutable state file such as `open-items.json`.

Use one immutable file or record per event.

Recommended logical layout:

```text
<capture-root>/
├ events/
│  └ YYYY/
│     └ MM/
│        └ DD/
│           ├ <event-id>.json
│           └ ...
├ tombstones/
│  └ YYYY/
│     └ MM/
│        ├ <item-id>.json
│        └ ...
├ runs/
│  └ YYYY/
│     └ MM/
│        └ DD/
│           ├ <run-id>.json
│           └ ...
└ snapshots/
   └ <timestamp>.json
```

`events/` is authoritative for active operational history.

`tombstones/` contains minimal records for recently closed or expired items after detailed event cleanup.

`runs/` may record report execution and surfaced candidate IDs for idempotency and reminder accounting.

`snapshots/` is optional.

A snapshot is only a derived acceleration structure and must be rebuildable from events and tombstones. Never treat it as a second canonical source.

A storage implementation may map this logical structure differently when required by the provider, but it must preserve the same ownership and append-only semantics.

## 8. Event model

Every mutation is a new event.

Never edit a previous event merely to change state.

Use a UUID, ULID, or comparably unique identifier for `event_id`.

### Capture event

Example:

```json
{
  "schema_version": 1,
  "event_id": "01K...",
  "event_type": "capture",
  "occurred_at": "2026-10-08T14:30:00+09:00",
  "captured_at": "2026-10-08T14:31:00+09:00",
  "kind": "process",
  "title": "Fresh-context validation benefits from context separation",
  "summary": "A verifier that inherits the implementation context may also inherit its assumptions. Separating the verification context can improve independent error detection.",
  "why": "This pattern may generalize to other AI-assisted development workflows.",
  "importance": "normal",
  "user_attention": false,
  "domain": "software-engineering",
  "project": "dolefull",
  "dedupe_hint": "software-engineering|process|fresh-context-validation",
  "source": {
    "system": "chat",
    "workspace": "Software Engineering",
    "conversation": "AI development process design",
    "reference": null
  }
}
```

Allowed importance values:

- `normal`
- `high`

Use `high` sparingly.

### Close event

A close event records a confirmed end to this queue's responsibility.

Example:

```json
{
  "schema_version": 1,
  "event_id": "01K...",
  "event_type": "close",
  "occurred_at": "2026-10-08T15:00:00+09:00",
  "target": {
    "event_id": "01K...",
    "dedupe_hint": "software-engineering|process|fresh-context-validation"
  },
  "closed_reason": "routed",
  "destination": {
    "type": "github_issue",
    "reference": "https://github.com/example/repository/issues/123"
  },
  "evidence": "The Issue was confirmed to exist."
}
```

Allowed `closed_reason` values:

- `routed`
- `incorporated`
- `acted`
- `dismissed`

### Surface event

When an item is surfaced to the user by a daily report or explicit reminder, append a surface event.

Example:

```json
{
  "schema_version": 1,
  "event_id": "01K...",
  "event_type": "surface",
  "occurred_at": "2026-10-11T22:00:00+09:00",
  "target": {
    "item_id": "01K..."
  },
  "surface_kind": "reminder",
  "report": "knowledge-daily"
}
```

Allowed `surface_kind` values include:

- `initial`
- `reminder`
- `query`

A user-requested query should not normally consume a reminder allowance.

### Expire event

When the reminder lifecycle ends, append an expire event.

```json
{
  "schema_version": 1,
  "event_id": "01K...",
  "event_type": "expire",
  "occurred_at": "2026-10-22T22:00:00+09:00",
  "target": {
    "item_id": "01K..."
  },
  "reason": "reminder-window-elapsed"
}
```

Expiration means:

> stop proactively reminding the user.

It does not mean:

> this information never existed.

Expired items remain queryable while their retained events or tombstones exist.

## 9. Derived item state

Reconciliation derives items from one or more events.

An item should normally contain or derive:

- stable item ID;
- state;
- close reason when closed;
- primary kind;
- title;
- summary;
- why;
- importance;
- user-attention flag;
- domain;
- project;
- first-seen time;
- last-material-evidence time;
- last-surfaced time;
- reminder count;
- dedupe hints;
- supporting event IDs;
- source references.

Do not require every field to be populated when the source does not support it.

## 10. Closing rules

Be conservative when closing an item.

### Close as routed

Use `closed_reason = routed` only when an actual destination has been confirmed.

Examples:

- a GitHub Issue actually exists;
- an Information Inbox item was actually created;
- a task was actually recorded;
- a handoff was actually stored in its intended workspace.

A suggestion such as "we should create an Issue" is not routing.

### Close as incorporated

Use `closed_reason = incorporated` when the useful meaning has actually been integrated into its proper owner.

Examples:

- a canonical document was updated;
- existing durable knowledge was updated;
- the relevant Domain Workspace now owns the conclusion.

### Close as acted

Use `closed_reason = acted` when the action represented by the item has actually been completed and no further capture responsibility remains.

Identifying a next action is not the same as completing it.

If the next action is durably stored elsewhere, use `routed`.

### Close as dismissed

Use `closed_reason = dismissed` only when there is meaningful evidence that the item is no longer wanted or useful.

Examples:

- the user explicitly rejects it;
- the user explicitly says not to pursue or retain it;
- later evidence clearly supersedes it and there is no remaining reusable value.

Do not treat silence as dismissal.

## 11. User reactions that do not close an item

The following do not, by themselves, close a candidate:

- no response;
- changing the subject;
- "I see";
- "interesting";
- "I'll think about it";
- "maybe later";
- an assistant-generated next action;
- a suggestion to create an Issue;
- a suggestion to add something to the Inbox.

Keep the item pending unless another confirmed condition closes it.

If the user gives a concrete future revisit time, preserve that intent and avoid surfacing the item prematurely when the storage implementation supports scheduling metadata.

## 12. Deduplication and reconciliation

Use two levels.

### Cheap hint

Capture events should provide a lightweight `dedupe_hint` when practical.

It may be based on:

```text
domain + kind + normalized subject
```

The hint is not an identity guarantee.

Do not drop an event solely because its hint matches another event.

### Semantic reconciliation

The reconciler should decide whether multiple events represent:

- the same candidate;
- additional evidence for an existing candidate;
- a related but distinct candidate.

When the same insight appears in another domain, preserve the new evidence.

Cross-domain recurrence may increase the value of the candidate rather than make it redundant.

Do not discard the evidence that supported a semantic merge.

## 13. New evidence

When materially new evidence arrives for a pending candidate:

- update its derived summary when necessary;
- update `last_material_evidence_at`;
- preserve the new event as evidence;
- allow it to surface as a candidate update rather than a repetitive reminder.

Material new evidence includes:

- reproduction in another project;
- a counterexample;
- stronger verification;
- a broader application;
- a changed conclusion;
- evidence that increases or decreases confidence.

Mere repetition is not material new evidence.

Material new evidence may extend the reminder window.

An expired item may become pending again when genuinely new evidence makes it relevant.

Do not automatically reopen an item that was intentionally routed, incorporated, acted on, or dismissed. Treat new information according to its current owner or as a new candidate when appropriate.

## 14. Reminder policy

The purpose of reminders is to prevent silent loss, not to demand a response.

For normal candidates, use approximately:

```text
initial surface
    ↓
about 3 days
    ↓
about 7 days
    ↓
about 14 days
    ↓
expire
```

The initial surface is not counted as a reminder.

Use at most three proactive reminders within the normal 14-day window.

High-importance or user-attention items may surface earlier, but should still avoid repeated daily nagging.

If the user does not react after the reminder window, expire the item.

Do not interpret expiration as dismissal.

When producing a report:

- show the total pending count if useful;
- surface only a small number of relevant reminder items;
- prioritize importance, age, current relevance, and likely value;
- do not dump the entire pending queue into every report.

## 15. Retention

The buffer is temporary.

Detailed records for closed or expired items may be cleaned up after they are no longer operationally useful.

Before removing detailed records, preserve a minimal tombstone when deduplication or later fuzzy recall still benefits from it.

A tombstone should contain only what is needed to recognize the prior item, such as:

- item ID;
- compact fingerprint or dedupe hint;
- short title;
- final state;
- close reason when applicable;
- closed or expired time.

Retain tombstones for approximately **90 days**.

After the tombstone retention period, the item may disappear completely unless it was routed into another proper owner.

Do not preserve detailed conversation context merely to improve deduplication.

## 16. Query behavior

The AI Capture Buffer must be directly queryable by the user, not only consumed by scheduled reports.

Support both structured and semantic filtering.

Examples include requests equivalent to:

- show me everything currently pending;
- show only development-related items;
- show items older than one week;
- show only things waiting for my judgment;
- show Agent Elevator-related items;
- show things that could become public output;
- show the five most important items;
- show things that are not directly about DTM but may be useful for DTM;
- did we leave something unresolved about AI-agent verification?;
- show things that expired recently.

Use structured metadata first when it directly answers the filter.

Use semantic analysis for fuzzy concepts such as:

- likely publishing material;
- relevant to a process;
- applicable to another domain;
- potentially important;
- related in meaning even when terminology differs.

Do not require a large predeclared tag taxonomy just to support fuzzy retrieval.

When detailed source evidence is needed, narrow candidates first, then retrieve only the relevant evidence.

## 17. Daily knowledge report integration

The evening knowledge report should use both:

1. new activity from the report window;
2. the existing AI Capture Buffer.

A useful report structure is:

### Today's Knowledge

New candidates discovered in the current report window.

### Candidate Updates

Existing candidates with materially new evidence, changed interpretation, counterexamples, or broader applicability.

### Recovery Queue

Older pending candidates that are due to be surfaced again.

Do not list the entire queue.

Prefer output such as:

```text
Pending: 18
Due for reminder today: 3
```

followed by the selected items.

### Awaiting Your Attention

Important unresolved items that materially require user awareness or judgment.

Keep the threshold high.

### Cross-domain Insights

Patterns supported by evidence from multiple domains or projects.

Do not generate this section when there is no meaningful cross-domain insight.

## 18. Morning project report integration

The project summary may use the same capture buffer.

When an Active or Maintain project has a relevant pending attention item, the report may show it alongside project state.

Example:

```text
Agent Elevator — Active

Progress:
- ...

Attention:
- Credential-management ownership remains unresolved.
```

Do not duplicate or create a second copy of the candidate for the morning report.

## 19. Historical recovery

Historical recovery is a separate mode from normal capture.

Use it only when explicitly requested.

Because conversations and projects may be scoped separately, do not assume one workspace can inspect every historical conversation.

Recover history per accessible scope.

For a requested time range:

1. inspect the accessible conversations or workspace history;
2. identify items that would have met the current capture threshold;
3. ignore items already clearly resolved or durably routed;
4. create capture events for useful unresolved candidates;
5. preserve their original occurrence time when known;
6. mark the capture time separately;
7. avoid turning the process into a complete conversation archive.

If only part of the requested history was accessible, report the coverage gap.

## 20. Publishing candidates

Publishing value is not limited to durable knowledge.

A publishing candidate may be worth capturing because it is:

- timely;
- unusual;
- entertaining;
- personally distinctive;
- based on a real experiment;
- likely to generate discussion;
- connected to a current trend;
- suitable for a lightweight post even when it does not justify a full article.

Do not pretend a weak idea is deep knowledge.

Capture the actual value proposition.

Examples:

```text
why: "Likely useful as a short SNS observation while the topic is timely."
```

or:

```text
why: "Not durable knowledge yet, but the experiment/result could make a strong short-form post."
```

## 21. Interaction behavior

Do not interrupt the main conversation merely to announce every successful capture.

Capture should normally be quiet.

If the user explicitly asks whether something was captured, answer directly.

If persistence fails:

- do not claim that capture succeeded;
- do not invent a stored record;
- continue the user's main task where possible;
- briefly disclose the failure when the user explicitly asked for persistence or when losing a high-value or attention candidate would materially matter.

## 22. Storage capability boundary

This skill defines storage semantics, not a particular provider and not permission to bypass tool constraints.

Use only the configured capture sink and logical storage root that are applicable to the current executor.

Only write when a writable, authorized storage mechanism is available.

Do not assume that read access implies write access.

Do not assume that the presence of a provider integration makes that provider the capture sink.

Do not emulate successful persistence by saying an item was stored when it exists only in the current conversation.

If the configured provider cannot support efficient append-only writes, preserve this event model and use another authorized writer or adapter rather than changing the information model merely to fit the provider.

## 23. Canonical-source boundary

The AI Capture Buffer is upstream of durable ownership.

A capture candidate may eventually be routed to:

- Information Inbox;
- GitHub Issue;
- Domain Workspace;
- project task system;
- `personal-os`;
- publishing workflow;
- another appropriate owner.

Do not automatically promote a candidate into any of these destinations.

Promotion requires the normal rules and authority of that destination.

Once a confirmed destination owns the item, close the capture candidate as `routed` or `incorporated` as appropriate.

## 24. Keep the system lightweight

Do not introduce, solely for this buffer:

- a large tag taxonomy;
- a vector database;
- an embedding service;
- a custom web UI;
- a complex scoring model;
- a new canonical knowledge store;
- a second project-management system;
- automatic Portfolio changes;
- automatic publication.

Start with small append-only records, semantic reconciliation, reminders, expiration, and user queries.

Add infrastructure only after repeated operational evidence demonstrates a concrete need.

## Boundaries

- Silence is not a decision.
- A proposed route is not a confirmed route.
- A next action is not a completed action.
- An actual confirmed destination may close this queue's responsibility.
- Expiration stops reminders; it does not rewrite history.
- A tombstone is for short-term deduplication and recall, not permanent knowledge.
- Capture minimum sufficient context, not conversation history.
- Keep secrets and unnecessary private context out of the buffer.
- Do not duplicate canonical knowledge.
- Do not let the buffer become another permanent Inbox.
- Prefer losing low-value candidates over capturing everything.
