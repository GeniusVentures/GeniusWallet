# Sketch Manifest

## Design Direction

Dark-first fintech dashboard ported to a light theme, built on the existing GeniusWallet token set
(Inter, `#14C8FF` cyan brand, mint `#2BF5B4` secondary, 15px card radius, subtle sheen gradient +
hairline border + soft card elevation). Sketches reuse the real tokens verbatim so a winner ports
directly; any deviation from a shipped token is a deliberate finding, recorded in the sketch README.

Guiding principle for this round: **a wallet with no funds is not a broken wallet.** Zero-state
surfaces should read as ready, not as failed loads.

## Reference Points

The app's own Markets and Transactions panels (existing dashboard chrome), plus the design reference
on `ui-redesign-3.514`.

## Sketches

| # | Name | Design Question | Winner | Tags |
|---|------|----------------|--------|------|
| 001 | holdings-panel | How should the dashboard assets panel read before the wallet has any balance? | **A2 · Market-forward + Stacked header + Center gap** | dashboard, empty-state, assets, coins |
| 005 | navbar-right-cluster | How should the top-bar's right side (chain/wallet selectors, Connect, Buy GNUS) read as one cohesive cluster, on par with the branded left? | **B · Normalized quiet chips** (chosen 2026-07-21; GSD implementation pending) | navbar, chrome, dropdowns, connect, cta |
| 006 | bitcoin-chart-section | How should the dashboard Bitcoin Chart card read — coin identity, price hierarchy, chart treatment, controls — using the mockup's chart language? | **A family** (2026-07-21): base **A · Mockup hero** (pure re-skin) + hover crosshair/tooltip; refining toward **A→ / A↓** which add a timeframe selector and drop the USD delta (% pill only). Final A-vs-A→-vs-A↓ pick pending. | dashboard, chart, price, coin, mockup-faithful, hover, timeframe |
| 007 | transaction-filters | How should the Sent/Received/Escrow/Mint transaction filter read — esp. in the narrow dashboard panel where it's a tiny scaled-down SegmentedButton — across the slim view + wider transactions area? | _pending pick_ (recommending **C · Compact icon-only segmented**: fits the title row, kills the FittedBox overflow, expands active chip's label; full labels on wide) | transactions, filters, segmented, chips, dashboard, chrome |
| 008 | hover-language | What single hover treatment makes nav tabs, timeframe tabs, and VIEW ALL feel like one interactive system (without VIEW ALL implying a persistent selected state)? | **D · Lift chip** (chosen 2026-07-21; now the design-system hover standard for all interactive chrome; timeframe done, nav+VIEW ALL handed to session 2) | hover, interaction, chrome, navbar, timeframe, consistency |
| 009 | transactions-area ~~rejected~~ | How should the transactions area read as one system — row, filter and empty states together — in both the narrow dashboard panel and the wide transactions page? | _pending pick_ (4 variants: A Ledger / B Statement / C Timeline / D Expand-in-place; supersedes the 007 filter pick — decide together) | transactions, rows, filters, empty-state, loading, dashboard |
| 010 | transaction-row-anatomy | With every transaction type sharing one row skeleton, what should the headline be — token, action, or value? | **A · Token-first** (chosen 2026-07-22; 009 rejected — it discarded the coin-icon+direction-badge identity that already works) | transactions, rows, anatomy, hierarchy, formatting |
| 011 | transaction-badges-filters | What colour should each type/status badge be, and how do filters cover all 7 TransactionTypes? | **Scheme 1 · Restrained** (chosen 2026-07-22); filters rec = **F1 two-tier**; coverage gap found: swap/purchase/process unreachable by any filter | transactions, badges, color, filters, tokens |
| 012 | icons-and-send-colour | Which glyph for Mint and Processing job, and what colour gives Sent presence without stealing Pending-amber or Failed-red? | **Sent = Slate #64748B**; **Mint icon = Pickaxe**; **Job icon = Server** (chosen 2026-07-22) | transactions, icons, color, badges |
| 013 | mint-job-badge-colour | What colour should the Mint and Processing-job badges be, given green/red/amber/slate are already taken? | **Mint = brandTertiary #C28FFF**, **Job = brandPrimaryStrong #0AAEE6** (chosen 2026-07-22) | transactions, badges, color, contrast |
| 014 | transactions-final | Consolidated spec: all locked badge/icon/colour decisions + the one open question (filter structure F1/F2/F3) | _filters pending_ (rec **F1 two-tier**) | transactions, spec, filters, badges |
| 015 | boot-loading-sequence | What does the boot screen look like during the 8.2 s in which nothing can animate — and how does one gate replace the per-section dashboard loaders? | _pending pick_ (recommending **B · Boot Ledger** — the only scheme whose static state is informative; A Steady Mark / C Signal Edge / Today baseline for comparison) | boot, splash, loading, progress, gate, dashboard, mode-invariant |
