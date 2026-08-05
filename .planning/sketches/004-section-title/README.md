---
sketch: 004
name: section-title
question: "Should all dashboard panel section-titles share one title→content geometry?"
winner: "Unified section-title variant (consumed by shipped quick-task bxr)"
tags: [section-title, header, dashboard, consistency]
---

# Sketch 004: Section Title

## Purpose

Explore a single shared section-title treatment so every dashboard panel header
(Assets / Markets / Transactions / Bitcoin-Chart) lines up (`index.html`).

## Winner (consumed by shipped quick-task)

The unified variant: `GWSectionTitle` Row wrapped in `ConstrainedBox(minHeight:44)` so all panels
share one title→top and title→first-row geometry (the redundant call-site `ConstrainedBox(minHeight:45)`
was removed). Shipped by quick-task **`bxr`**.

Winner locked in code. See the STATE quick-task row **`bxr`** for the exact edits.
