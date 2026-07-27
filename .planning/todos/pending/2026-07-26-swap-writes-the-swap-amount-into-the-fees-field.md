# Swap zapisuje kwotę swapa do pola `fees` — drawer pokazuje ją jako „Network Fee"

**Znalezione:** 2026-07-26, podczas audytu danych do szkicu 062 (Ledger).
**Typ:** błąd, nie luka. Widoczny dla użytkownika już dziś.
**Niezależny od:** layoutu strony Swap. Można naprawić osobno, w dowolnej kolejności.

## Co jest nie tak

`lib/squid_router/swap_screen.dart:243` buduje rekord transakcji swapa tak:

```dart
fees: fromAmount,
```

Do pola `Transaction.fees` trafia **wymieniana kwota**, nie opłata.

Konsumenci tego pola traktują je dosłownie:

- `lib/dashboard/home/widgets/transaction_displays.dart:474`
  → `add('Network Fee', '${formatTxAmount(tx.fees)} ${tx.coinSymbol}');`
- `lib/dashboard/home/widgets/transaction_utils.dart:403,405,410` — kwota, dokładna kwota
  i linia fiat dla transakcji, w których „opłata JEST kwotą"

Skutek: **drawer szczegółów swapa pokazuje dziś wymienioną kwotę pod etykietą „Network Fee".**
Do tego `coinSymbol` niesie symbol sieci portfela, a `fromAmount` jest w tokenie źródłowym —
więc liczba jest opisana także złą jednostką.

## Dlaczego to nie jest kosmetyka

Wartość jest o rzędy wielkości za duża i użytkownik nie ma jak jej zweryfikować.
W szkicu 062 to jedyny powód, dla którego `Fees paid` w panelu Summary nosi metrykę
`BUILD`, a nie `HAVE` — danych nie da się policzyć, dopóki źródło zapisu kłamie.

## Naprawa

Prawdziwy koszt jest dostępny w odpowiedzi trasy:

- `SquidRouteResponse.gasCosts[].amountUSD` (`squid_token_service.dart:105-118`)
- `SquidRouteResponse.feeCosts[].amountUSD` (`:127-148`)

Do rozstrzygnięcia przy planowaniu:

1. `fees` to `String` bez jednostki — zapisać sumę w tokenie natywnym łańcucha
   (spójne z `coinSymbol`) czy w USD? Konsumenci zakładają dziś to pierwsze.
2. Ekran stoi na `mockSquidRoute` (`:59`), więc do czasu podpięcia prawdziwej trasy
   „prawdziwy gas" też będzie z atrapy. Naprawa zapisu ma sens mimo to — dziś pole
   trzyma wartość **zdecydowanie błędną**, nie tylko atrapę.

## Uwaga dla naprawiającego

Zapis leci **dwa razy** i oba muszą się zgadzać:
`swap_screen.dart:277` (`transactionsCubit.addTransaction`) oraz `:280`
(`TransactionStorageService().addTransaction`) — ten sam obiekt, ale historia w Hive
przeżyje restart, więc rekordy zapisane przed poprawką zostaną błędne. Warto zdecydować,
czy stare wpisy migrować, czy zostawić.

**Powiązane:** `.planning/sketches/062-ledger-variants/README.md` (rachunek backendu, pozycja 2)
