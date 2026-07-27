# Slippage w SwapSettingsDrawer nie ma żadnej walidacji zakresu

**Znalezione:** 2026-07-26, przy szkicu 041 (swap page buildout)
**Plik:** `lib/squid_router/swap_settings_drawer.dart:32-53`
**Waga:** realny defekt, nie kosmetyka — trust boundary na polu, które decyduje o pieniądzach

## Co jest

Drawer ma jedno pole tekstowe i przy Apply robi:

```dart
final parsed = double.tryParse(slippageController.text);
if (parsed != null) {
  onSlippageChanged(parsed);
  Navigator.of(context).pop();
}
```

`double.tryParse` nie zna pojęcia zakresu. Przechodzą:

- **`0`** — każdy swap padnie na slippage check, użytkownik nie dowie się dlaczego
- **`900`** — użytkownik akceptuje dowolną cenę; to jest dokładnie ten scenariusz, na którym
  boty MEV zarabiają
- **`-5`** — `tryParse` to łyka, zachowanie routera nieokreślone

Nie ma też presetów, więc typowy przypadek (0.5%) wymaga wpisywania z klawiatury.

## Co powinno być

Granice zaproponowane i przetestowane w szkicu 041 (`slipState()`, funkcja czysta bez DOM,
z uruchamialnym checkiem na 10 przypadków i 4 poziomach):

| wejście | wynik |
|---|---|
| puste | trzymaj aktywny preset |
| `0`, `-1`, `abc` | blokada, Apply wyłączony |
| `> 50` | blokada — `Slippage cannot exceed 50%` |
| `> 5` | przejdź z ostrzeżeniem — `High slippage — your trade can be frontrun` |
| `< 0.05` | przejdź z ostrzeżeniem — `Very low — the swap will likely fail` |
| `0,5` | przecinek akceptowany jako separator dziesiętny |

Stałe: `SLIP_MIN = 0.05`, `SLIP_WARN_HI = 5`, `SLIP_MAX = 50`.

Do tego rząd presetów 0.1 / 0.5 / 1.0 obok pola — pole zostaje, nie zastępujemy go presetami.

## Gdzie jest wzorzec

`.planning/sketches/041-swap-page-buildout/index.html` — funkcja `slipState()` plus `selfCheck()`
tuż pod nią. Ten sam zestaw przypadków przenieść do testu w Darcie razem z portem.

## Uwaga

To jest niezależne od wyboru layoutu (041 → Ledger). Można naprawić osobno, wcześniej, bez
czekania na cokolwiek innego.
