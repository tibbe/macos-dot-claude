---
name: improve-comments
description: Review a change's docstrings and inline comments for a reader with zero history of the code. Runs the review in a sub-agent. Use when the user wants to improve or review the docstrings and comments on a branch, a PR, or a change, or asks to clean up comments since a fixed point.
---

Review of the diff between `HEAD` and a fixed point the user supplies — do its comments hold up for a reader with **zero history** of the code (no memory of how it got here, no access to the conversation you're in now)?

- **Docstrings** — state the contract: what the code guarantees a caller.
- **Inline comments** — earn their line, or go.

The review runs as a **sub-agent** so what you already know about the change can't stand in for reading it, then this skill applies its findings.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base).

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here — not inside the sub-agent.

### 2. Spawn the sub-agent

Send one `Agent` tool call. Use the `general-purpose` subagent.

**Review sub-agent prompt** — include:

- The diff command from step 1.
- The **Docstrings and Inline comments rules below, with their Examples**, pasted in full — the sub-agent has no other access to them.
- The brief: "Apply the rules to every comment in the diff, and report each one that fails: its file and line, the current text, and the exact rewrite — or that it should be deleted."

### 3. Apply

Apply the reported edits verbatim — the judgment is already made; you're transcribing it, not re-deciding.

## Docstrings

Hold every docstring to one test: would a **zero-history** reader benefit from this sentence? Don't include:

- **History** — the contract is the current behavior.
- **Rejected alternatives** — defending the design against an approach you dropped.
- **Negative documentation** — listing what the code doesn't do. Keep it only when the negation counters a default a stranger would actually assume; that's rare.
- **Implementation leakage** — describe the contract; implementation notes go inline, next to the code.
- **Caller-specific framing** — naming a function that calls this, or calling behavior "the X flow". The same leak shows up in type and parameter names shaped around one caller.
- **Session references** — "as you asked", "per our discussion". The subtler form has no tell-phrase: a fact reads as worth stating only because it just came up. Would you write it having opened the file cold? If not, cut it.

When a struck sentence also carried a real guarantee, rewrite it forward-looking — don't drop the guarantee along with the noise.

### Python structure

Detect the convention before editing, strongest signal first: an explicit declaration in config — e.g. `convention = "google"` under `[tool.ruff.lint.pydocstyle]` in `pyproject.toml` — then the style the surrounding package already uses (Google, NumPy, reST). Default to Google only when nothing is declared or established. The zero-history test applies in every convention. In Google style:

- Imperative summary line, on its own line.
- `Args:`/`Returns:`/`Raises:` for non-trivial docstrings; omit any section that would be empty (`-> None` gets no `Returns:`).
- Types live in annotations; sections describe intent.
- Trivial one-liners skip the sections.

For other languages, apply the test to the native doc-comment syntax (JSDoc, Go doc comments, rustdoc) — don't impose a foreign structure.

## Inline comments

An inline comment earns its line only when the code would **surprise** the zero-history reader — leave them wondering *why* it's written this way, or unable to tell *what* it does. Deletion is the default fix; keep or rewrite a comment only when you can name that surprise without narrating what changed.

- **Narration goes.** If the comment restates the next few lines, delete it — nothing there surprises the reader.
- **The why must be non-obvious**: a hidden constraint, a subtle invariant, a workaround for a specific bug.
- **A gotcha about a callee belongs on the callee.** "Look up X so foo() doesn't bar Y" describes foo's contract — fix foo's docstring instead of warning at every call site.
- **State the invariant, not the fear.** Rewrite "...so X doesn't happen" as the positive property the code keeps.

Every docstring failure mode applies here too — except implementation leakage, which is fine inline, where implementation notes belong.

## Examples

**Docstring — history + implementation + caller leak (rewrite, keep the contract):**

```python
# before
def resolve_user(token: str) -> User:
    """Resolve a token to a user via the CacheManager (we moved this off the
    direct DB path for the login flow). Raises AuthError if the token is
    expired or unknown.
    """

# after
def resolve_user(token: str) -> User:
    """Return the user a session token belongs to.

    Raises AuthError if the token is expired or unknown.
    """
```

**Inline comment — pure narration (delete):**

```python
# before
counter += 1  # increment the counter by one

# after
counter += 1
```

**Inline comment — negative framing (name the real why):**

```python
# before
# so we don't double-charge if the webhook retries
if event.id not in processed:

# after
# Stripe redelivers webhooks; dedupe by event id to stay idempotent.
if event.id not in processed:
```
