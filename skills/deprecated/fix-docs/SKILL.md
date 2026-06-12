---
name: fix-docs
description: Fix documentation across the current branch's pending changes before a commit or PR. Auto-invoke before `git commit` or `gh pr create`. Walks docstrings, inline comments, commit messages on the branch, and changed Markdown, and edits violations in place.
---

## What to do

1. Find pending changes on the branch: changed files (staged + unstaged + diff vs the base branch) and commit messages added since the branch diverged.
2. Walk each artifact and apply the rules below.
   - Code files → docstring rules (the 6 checks). Python files also get the Google-style structural pass. Inline comments → the 4 checks.
   - Changed Markdown → see the Markdown section (full 6 checks for reference docs, check #6 only for standalone prose).
   - Each branch commit message → the commit-message checks.
3. Edit files, commit messages, and PR descriptions in place.
4. Report in 2–4 lines: which files, commits, and PR descriptions were edited. No per-violation play-by-play unless asked.

## Docstring rules — the 6 checks

A docstring describes the contract for a reader with zero history.

1. **Forward-looking only**: does any sentence reference history, prior versions, "we used to", "previously"? → strike it.
2. **No rejected alternatives**: does it justify the design by contrasting with an approach that was dropped? → strike it.
3. **No negative documentation**: does any sentence enumerate what the code does NOT do? → strike unless the negation counters a reasonable default expectation a stranger would actually hold (rare).
4. **No implementation leakage**: does it mention internals ("uses X internally", "implemented via Y")? → strike. Implementation notes go inline next to the code.
5. **No specific callers**: does it name a function/class/module that calls this code, or describe behavior in terms of "the X flow"? → strike. Same applies to type names and parameter names — don't shape them around a specific caller.
6. **Standalone-reader test**: for each remaining sentence, ask "would a reader with no history of this code benefit from this?" → if no, strike. This also catches references to the authoring session ("as you asked", "per our discussion", "the conversation above") — shorthand that only makes sense to someone who saw the chat thread.

### Structural pass — Python only, Google style

- Summary line in imperative mood, on its own line.
- Non-trivial docstrings use `Args:`, `Returns:`, `Raises:` sections; omit sections that would be empty (`-> None` → no `Returns:`).
- Continuation lines indented.
- Type info lives in annotations; sections describe intent, not types.
- Trivial one-liners skip the sections.

For non-Python languages, apply the 6 content checks to the language's native doc-comment syntax (JSDoc, Go doc comments, etc.). Don't impose the Google-style structure.

## Inline comment rules — the 4 checks

Inline comments are allowed to explain WHAT (unlike docstrings). But before keeping one:

1. **Is the WHY non-obvious?** Hidden constraint, subtle invariant, workaround for a specific bug, behavior that would surprise a reader. If the comment just narrates the next few lines, delete it.
2. **Does it narrate a callee?** "Look up X so foo() doesn't bar Y" describes mechanics that belong on `foo`'s docstring, not at every call site. If the gotcha is real, fix the callee's docstring instead.
3. **Negative framing?** "...so X doesn't happen" — rephrase as a positive invariant the code maintains, or move the warning to where the risky behavior lives.
4. **References specific callers / change history / rejected alternatives?** Same rules as docstrings — strike.

## Markdown prose

Markdown serves different purposes — pick the right ruleset:

- **Reference docs that complement code** (READMEs describing an API, module docs, anything that functions as extended docstrings) → apply the full docstring 6 checks.
- **Standalone prose** (design docs, RFCs, proposals, retrospectives) → apply only docstring check #6 (standalone-reader test). Contrasting approaches, history, and negative framing are legitimate in this form.

## Commit messages

Commit messages document a change relative to its parent, so history references and past-tense framing are inherent to the form. Apply docstring checks #2 (no rejected alternatives) and #6 (standalone-reader test, with `git log` as the audience). Skip the rest. The diff shows *what*; the message should explain *why*.
