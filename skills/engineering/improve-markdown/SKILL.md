---
name: improve-markdown
description: Improve Markdown prose so it serves its actual purpose — extended documentation held to the docstring bar, or standalone prose where history and trade-offs are legitimate. Use when writing or revising Markdown, or as a pre-commit sweep of changed .md files.
---

# Improve markdown

Markdown serves different purposes. Pick the ruleset before editing, then edit in place and report in 2–4 lines which files were touched.

## Reference docs that complement code

READMEs describing an API, module docs, anything that functions as an extended docstring. Hold them to the docstring bar:

- Forward-looking only — no change history or "we used to".
- No rejected alternatives.
- No implementation leakage — describe the contract, not the internals.
- No caller-specific framing.
- Every sentence must help a reader with zero history of the code.

Rewrite rather than delete when a struck line carried real information — never leave the doc describing less than it did.

## Standalone prose

Design docs, RFCs, proposals, retrospectives. Apply only the standalone-reader test: *would a reader with no history of this work benefit from this sentence?*

History, contrasting approaches, and negative framing are legitimate here — they are the point of the form. Don't strip them; only cut what serves no reader (session references like "as we discussed", restated boilerplate, filler).
