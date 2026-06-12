---
name: write-commit-message
description: Author a commit message from the staged diff, and tighten an existing draft, so it explains why the change was made for someone reading `git log` with no other context. Use before `git commit`.
---

# Write commit message

Write (or tighten) the message for the staged changes, then let the commit proceed. The diff already shows *what* changed — the message exists to explain *why*. History and past tense are inherent to the form; they are not violations here.

## Shape

- **Subject**: one concise line, imperative mood, no trailing period. Summarize the change, not the files touched.
- **Body** (only when the why isn't obvious from the subject): the motivation and any consequence a future reader needs. Wrap at ~72 columns.

## Rules

1. **Explain why, not what.** The diff shows what. If the body just restates the diff, drop it.
2. **No rejected alternatives** unless the reader genuinely needs the dead end to understand the change.
3. **Standalone-reader test, `git log` as the audience.** Strike anything that only makes sense to someone who saw this session ("as discussed", "per the review") or the branch's working history ("fix the thing from earlier").

(The harness appends the standard co-author trailer — don't add it yourself.)

## Example

```
# before (draft)
update auth

Refactored the token check. We tried doing it in middleware first but that
didn't work, so per Johan's suggestion it now lives in resolve_user. As
discussed this also fixes the retry bug.

# after
Dedupe expired-token check in resolve_user

Tokens were validated twice on the retry path, so an expired token could slip
through on the second attempt. Validate once, at resolution.
```
