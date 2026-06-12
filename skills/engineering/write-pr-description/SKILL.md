---
name: write-pr-description
description: Author a pull-request description from the branch's commits and diff, and tighten an existing draft, so a reviewer with no context can understand and verify the change. Use before `gh pr create`.
---

# Write PR description

Write (or tighten) the PR body from the branch's commits and diff, then let `gh pr create` proceed. Write for a reviewer who hasn't seen the work — orient them fast.

## Shape

A sensible default; adapt to the change and drop sections that would be empty:

```markdown
## What
One-paragraph summary of the change, from the reader's perspective.

## Why
The problem or motivation. Link the issue if there is one.

## How to verify
The steps or tests a reviewer runs to convince themselves it works.

## Notes
Anything out of scope, follow-ups, or trade-offs worth flagging.
```

## Rules

- **Standalone-reader test.** Every line should help a reviewer with no history of the branch. Strike session references ("as we discussed").
- **Why earns its place.** A diff-restating body wastes the reviewer's time. Lead with motivation and the shape of the change, not a file-by-file list `git` already shows.
- **Trade-offs are allowed here.** Unlike a commit, a PR may legitimately discuss alternatives considered — include them when they help the reviewer judge the change, omit them when they are noise.

(The harness appends the standard Claude Code trailer — don't add it yourself.)
