---
name: improve-comments
description: Make docstrings and inline comments serve a reader with zero history of the code. Use when writing or revising code, and as a pre-commit sweep — strike history, rejected alternatives, implementation leakage, and caller-specific framing, and conform Python docstrings to the repo's convention.
---

# Improve comments

A docstring describes the contract for a reader with zero history. An inline comment earns its place only when it tells that reader something the code itself can't.

## What to do

- **While writing or revising code** → apply the checks below to the code you touch.
- **Before a commit** → sweep every changed code file: staged + unstaged + diff vs the base branch.
- Edit in place. Report in 2–4 lines: which files were touched. No per-violation play-by-play unless asked.

## Docstring rules — the 6 checks

1. **Forward-looking only**: does any sentence reference history, prior versions, "we used to", "previously"? → strike it.
2. **No rejected alternatives**: does it justify the design by contrasting with an approach that was dropped? → strike it.
3. **No negative documentation**: does any sentence enumerate what the code does NOT do? → strike unless the negation counters a reasonable default expectation a stranger would actually hold (rare).
4. **No implementation leakage**: does it mention internals ("uses X internally", "implemented via Y")? → strike. Implementation notes go inline next to the code.
5. **No specific callers**: does it name a function/class/module that calls this code, or describe behavior in terms of "the X flow"? → strike. Same applies to type and parameter names — don't shape them around a specific caller.
6. **Standalone-reader test**: for each remaining sentence, ask "would a reader with no history of this code benefit from this?" → if no, strike. This also catches references to the authoring session ("as you asked", "per our discussion", "the conversation above").

**Don't strike out the contract.** Striking removes noise, not signal. If an offending sentence also carried real contract information, rewrite it forward-looking instead of deleting — never leave a docstring describing less than it did.

### Structural pass — Python

Detect the docstring convention already used in the surrounding package (Google, NumPy, reST) and conform to it. Default to Google style only when the repo hasn't established one. The 6 content checks apply in every convention.

For Google style:

- Summary line in imperative mood, on its own line.
- Non-trivial docstrings use `Args:`, `Returns:`, `Raises:` sections; omit sections that would be empty (`-> None` → no `Returns:`).
- Continuation lines indented.
- Type info lives in annotations; sections describe intent, not types.
- Trivial one-liners skip the sections.

For non-Python languages, apply the 6 content checks to the native doc-comment syntax (JSDoc, Go doc comments, rustdoc); don't impose a foreign structure.

## Inline comment rules — the 4 checks

Inline comments are allowed to explain WHAT (unlike docstrings). But before keeping one:

1. **Is the WHY non-obvious?** Hidden constraint, subtle invariant, workaround for a specific bug, behavior that would surprise a reader. If the comment just narrates the next few lines, delete it.
2. **Does it narrate a callee?** "Look up X so foo() doesn't bar Y" describes mechanics that belong on `foo`'s docstring, not at every call site. If the gotcha is real, fix the callee's docstring instead.
3. **Negative framing?** "...so X doesn't happen" — rephrase as a positive invariant the code maintains, or move the warning to where the risky behavior lives.
4. **References specific callers / change history / rejected alternatives?** Same rules as docstrings — strike.

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

**Inline comment — negative framing (reframe as a positive invariant, name the real why):**

```python
# before
# so we don't double-charge if the webhook retries
if event.id not in processed:

# after
# Stripe redelivers webhooks; dedupe by event id to stay idempotent.
if event.id not in processed:
```
