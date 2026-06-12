---
name: improve-comments
description: Improve docstrings and inline comments so each serves the next reader — docstrings that state the contract, inline comments that earn their place — and conform Python docstrings to the repo's convention. Use when writing or revising code, or as a pre-commit sweep of changed code files.
---

# Improve comments

A docstring is a contract, not a logbook: it states what the code guarantees a caller, not the story of how it came to be. That story — the alternative you rejected, the change you just made, how today's callers happen to use it — is alive in the author's head and noise to everyone after. An inline comment earns its place only when it tells a later reader something the code itself can't.

Apply this to code you touch as you write it. Before a commit, sweep every changed code file — staged, unstaged, and the diff against the base branch. Edit in place; report in 2–4 lines which files changed, no per-violation play-by-play unless asked.

## Docstrings

Hold every docstring to one test: *would a reader with no history of this code benefit from this sentence?* A handful of things reliably fail it:

- **History** — "we used to", "previously", prior versions. The contract is what the code does now.
- **Rejected alternatives** — justifying the design against an approach that was dropped.
- **Negative documentation** — enumerating what the code doesn't do. Keep it only when the negation counters a default expectation a stranger would actually hold; that's rare.
- **Implementation leakage** — "uses X internally", "implemented via Y". Describe the contract; implementation notes go inline, next to the code.
- **Caller-specific framing** — naming a function that calls this, or describing behavior as "the X flow". The same leak shows up in type and parameter names shaped around one caller.
- **Session references** — "as you asked", "per our discussion", "the conversation above".

Striking removes noise, not signal. When an offending sentence also carried real contract information, rewrite it forward-looking — never leave a docstring describing less than it did.

### Python structure

Detect the convention before editing, strongest signal first: an explicit declaration in config — e.g. `convention = "google"` under `[tool.ruff.lint.pydocstyle]` in `pyproject.toml` — then the style the surrounding package already uses (Google, NumPy, reST). Default to Google only when nothing is declared or established. The test above applies in every convention. In Google style:

- Imperative summary line, on its own line.
- `Args:`/`Returns:`/`Raises:` for non-trivial docstrings; omit any section that would be empty (`-> None` gets no `Returns:`).
- Types live in annotations; sections describe intent.
- Trivial one-liners skip the sections.

For other languages, apply the test to the native doc-comment syntax (JSDoc, Go doc comments, rustdoc) — don't impose a foreign structure.

## Inline comments

An inline comment may explain *what* the code does, but it has to earn the line:

- **Narration goes.** If the comment restates the next few lines, delete it — the code already says that.
- **The why has to be non-obvious** to survive: a hidden constraint, a subtle invariant, a workaround for a specific bug, behavior that would surprise the reader.
- **A gotcha about a callee belongs on the callee.** "Look up X so foo() doesn't bar Y" describes foo's contract — fix foo's docstring instead of warning at every call site.
- **State the invariant, not the fear.** Reframe "...so X doesn't happen" as the positive property the code maintains.

History, rejected alternatives, and caller-specific framing are out here too, same as docstrings.

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
