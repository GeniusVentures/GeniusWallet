---
sketch: 003
name: markets-panel
question: "How should the dashboard Markets panel header read, and what replaces the dead 'Top {n}·24h' filler?"
winner: "A and D (consumed by shipped quick-tasks)"
tags: [markets, panel, header, view-all, sparkline]
---

# Sketch 003: Markets Panel

## Purpose

Explore the dashboard Markets panel — its header row and the trailing slot
(`index.html`, `header-trailing.html`, `view-all.html`).

## Winner (consumed by shipped quick-tasks)

- **A** — real "Markets" header row (titleLg + sub) plus shared `CryptoSparkLineChart` rows made
  Assets-twins (34px icon, name-over-price, filled % chip, status colors). Shipped by quick-task **`1nk`**.
- **D** — the editorial "View all" link (`GWViewAllLink`) replacing the dead "Top {n}·24h" filler,
  wired `→ /markets`. Shipped by quick-task **`ch1`**.

Winner locked in code. See the STATE quick-task rows **`1nk`** and **`ch1`** for the exact edits.
