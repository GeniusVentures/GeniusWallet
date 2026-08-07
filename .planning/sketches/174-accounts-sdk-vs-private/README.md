---
sketch: 174
name: accounts-sdk-vs-private
question: "Jak arkusz kont ma rozróżniać konta SDK od portfeli prywatnych - i jakie ograniczenia narzuca kod?"
winner: null
tags: [mobile, ios, accounts, sdk, wallets, sheet, follows-173]
---

# Sketch 174: Konta SDK vs portfele prywatne

## Design Question

Jakub, 2026-08-06: *"musi byc tez rozroznienie miedzy SDK accounts oraz Your Accounts - zobacz w
kodzie jak mozemy to przedstawic najlepiej czy sa jakie obowstrzenia"*.

## Co mówi kod

| | Konta SDK | Portfele prywatne |
|---|---|---|
| Źródło | `api.getAvailableAccounts()` (natywny węzeł) | `_baseWallets`, lokalny magazyn |
| Typ | `WalletType.sgnus` | mnemonic / privateKey / keystore / tracking |
| Tworzone w | `app_bloc.dart:605-628` `_mergeSgnusWallet()` | `LoadWallets` |
| Jednostka | `currencySymbol: 'minions'` | waluta sieci |
| Saldo czyta | natywny SDK, `readSuperGeniusTokenAssets` (`wallet_details_cubit.dart:198-206`) | RPC sieci |
| Transakcje | `SgnusTransactionsScreen` (`dashboard_screen.dart:407-411`) | `TransactionsStream` |
| Nazwa | generowana `Super Genius Wallet N` (`app_bloc.dart:616-618`) | użytkownika |
| Rename / Delete | zablokowane (`account_drawer.dart:307,320`) | dostępne |
| Znikają | gdy `!connection.isConnected` (`app_bloc.dart:606-609`) | nigdy |

## Dwa ustalenia, które zmieniają design

**1. To są dwie niezależne osie, nie dwa rodzaje tej samej rzeczy.**
Wybór w szufladzie kont woła tylko `walletCubit.selectWallet()` (`account_drawer.dart:69`) - mówi
"co oglądam". To, które konto SDK jest **aktywne w węźle**, ustawia inna kontrolka:
`sdk_account_manager.dart:185` wysyła `SelectSDKAccount` → `api.selectGeniusAccountAsync`.
`SelectSDKAccount` nie jest wysyłane znikąd indziej w `lib/`. Podświetlenie listy i aktywne konto
węzła to dwa różne stany, a UI nigdy tego nie mówi.

**2. Konta SDK znikają bez komunikatu.** Pierwsze linie `_mergeSgnusWallet()`: brak połączenia →
zwracane są same `_baseWallets`. Lista po prostu się kurczy.

## Co zmieniono względem 173

- Dwie sekcje z nagłówkami i jednozdaniowym wyjaśnieniem każdej.
- Salda w prawdziwych jednostkach (minions vs waluta sieci), nie wspólna kolumna dolarowa.
- Odznaka `AKTYWNE W NODZIE` + akcja `Ustaw w nodzie`, rozdzielające obie osie.
- Jawny stan rozłączonego węzła zamiast cichego zniknięcia.
- Adres wypłat widoczny w sekcji SDK - to on łączy oba światy.
- `TYLKO PODGLĄD` przy portfelu typu `tracking`.

## Open

- Czy wybór konta SDK do podglądu powinien **jednocześnie** ustawiać je jako aktywne w węźle.
  Kod trzyma to osobno; zlanie w jedno byłoby prostsze, ale zmienia zachowanie węzła.
- Co pokazać, gdy węzeł jest połączony, ale nie ma żadnych kont SDK.
