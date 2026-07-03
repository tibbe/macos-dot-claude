---
name: improve-markdown
description: Improve Markdown prose: extended docs held to the docstring bar, standalone prose where history and trade-offs are legitimate. Use when writing or revising Markdown, or as a pre-commit sweep of changed .md files.
---

# Improve markdown

Markdown serves two purposes, and each gets a different bar. Decide which one you're editing before you start.

## Reference docs

READMEs, module docs, API docs — anything that functions as an extended docstring. Hold it to the docstring bar: a forward-looking contract for a reader with **zero history** of the code. Same failure modes as a code docstring — history, rejected alternatives, implementation leakage, caller-specific framing (`/improve-comments` has the full list). When a struck line also carried something the reader needs, rewrite it forward rather than delete.

## Standalone prose

Design docs, RFCs, proposals, retrospectives. Apply one test: would a **zero-history** reader benefit from this sentence? History, contrasting approaches, and negative framing are the point of these forms — keep them. Cut only what serves no reader: session references ("as we discussed"), restated boilerplate, filler.
