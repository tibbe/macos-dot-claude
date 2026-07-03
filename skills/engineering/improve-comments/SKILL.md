---
name: improve-comments
description: Improve docstrings and inline comments for a reader with zero history of the code: docstrings state the contract, inline comments earn their place. Use when writing or revising code, or as a pre-commit sweep of changed code files.
---

# Improve comments

Write every comment for a reader with **zero history**: no memory of how the code got here, no access to the conversation you're in now. A docstring states the contract — what the code guarantees a caller. An inline comment must earn its line.

Apply this as you write code, and as a sweep of changed files before committing.

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
