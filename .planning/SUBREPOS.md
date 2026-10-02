# GeniusWallet Submodule Map

Maps nested submodules inside `GeniusWallet/`. Planning artifacts live in `GeniusWallet/.planning/`.

---

## Nested Submodules

| Submodule Path | Remote | Notes |
|---|---|---|
| `banxa/` | GeniusVentures/banxa | Banxa fiat on-ramp integration (auto-generated client) |
| `squidrouter/` | GeniusVentures/squidrouter | SquidRouter token swap integration (auto-generated client) |

## Planning Directory Ownership

All nested submodules use `GeniusWallet/.planning/` for workstream tracking. If a nested submodule needs independent workstreams, initialize its own `.planning/` with `/gsd:new-project`.

**Note:** `banxa/` and `squidrouter/` are auto-generated API clients. Per `AGENTS.md` guidelines, do not modify them directly.

---

*Generated: 2026-07-06*
