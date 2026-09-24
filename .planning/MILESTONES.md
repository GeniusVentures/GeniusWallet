# Milestones

## v2.0 Squid Router integration — shipped 2026-09-24

Phases 26, 29, 30, 31 · PRs #233, #234, #235, #244.

- Swaps execute live Squid routes and record what actually happened; first real swap on Base mainnet 2026-09-17
- Route details name every fee separately from chain gas before the user confirms
- dApp approvals decode ERC-20 and Squid calldata; undecodable calls carry a visible warning
- Send for native coins and ERC-20 tokens on any signable EVM chain, walked on Sepolia

Known gaps: DAP-02 shows the input side only; swap history explorer links key off the symbol.
Archive: `milestones/v2.0-ROADMAP.md`, `milestones/v2.0-REQUIREMENTS.md`, audit `v2.0-MILESTONE-AUDIT.md`.
