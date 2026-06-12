# User preferences

## Documentation

Comments and docstrings describe the contract for a reader with zero history — no change history, no rejected alternatives, no implementation leakage, no caller-specific framing. The detailed rules live in skills, each applied at its own moment:

- `/improve-comments` — docstrings and inline comments. Use while writing or revising code; also swept before a commit.
- `/improve-markdown` — Markdown prose (reference docs vs standalone prose).
- `/write-commit-message` — authors the commit message before `git commit`.
- `/write-pr-description` — authors the PR body before `gh pr create`.

## API design

### Before naming or shaping any API — ask one question

> Could I describe what this function/parameter/type means without referencing a specific caller?

If you find yourself reaching for "this is for the X flow" or "callers like Y need...", stop. Mentioning specific callers in your reasoning is a signal that the abstraction is leaking — you're shaping the interface around a concrete use site instead of around the operation it performs. That tempts concessions: optional parameters that only make sense for one caller, return shapes contorted to match one consumer, names that age out the moment a second caller appears.

Re-derive the API from the operation alone. If the resulting shape doesn't fit the caller, the caller adapts — not the abstraction.

### Before adding a parameter whose type includes `None` (or another "empty" variant) — ask one question

> Does this function have a natural behavior for the empty/`None` case, independent of any specific caller's use?

- **Yes** → keep the `None` in the signature; document the behavior.
- **No** → drop the `None`. Push the branch back to the caller. Accepting `None` "because a caller happens to have nullable data" is a concession that bends the abstraction toward caller convenience.

Example: `normalize_condition(expression: ConditionBase | None)` returning `()` for `None` is wrong. "Encode a condition" has no natural meaning for `None`. The caller with `extra_filter_expression: ConditionBase | None` should branch before calling.
