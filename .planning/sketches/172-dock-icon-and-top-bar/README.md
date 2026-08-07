---
sketch: 172
name: dock-icon-and-top-bar
question: "Jaka konkretna ikona ma stać w środkowym doku zamiast plusa - i czym ten dok właściwie jest?"
winner: null
tags: [mobile, ios, bottom-nav, dock, icon, top-bar, total-balance, follows-171]
---

# Sketch 172: Ikona doku + górny pasek

## Design Question

Prośba Jakuba, 2026-08-06: *"jak wygląda bottom navigation z określoną ikoną zamiast plusa"*, górny pasek
wzięty z wariantu **D** sketcha 171, Total Balance uwzględniony, Assets bez zmian.

Kluczowe przeformułowanie: cztery warianty nie różnią się **rysunkiem**, tylko tym, **czym dok jest**.
Ikona jest konsekwencją tej decyzji, nie jej przedmiotem.

## How to View

```
open http://localhost:8899/172-dock-icon-and-top-bar/
```

## Variants

- **A: Swap ★** - dok = jedno tapnięcie w `/swap`. Ikona `Icons.swap_vert_rounded`, ta sama co dzisiejszy FAB.
- **B: Move** - dok otwiera arkusz Send / Receive / Buy / Swap. Daje Send i Receive pierwsze miejsce w nawigacji.
- **C: Scan** - dok otwiera skaner QR. Najczytelniejsza ikona, ale skanera nie ma.
- **D: GNUS** - dok niesie znak marki i otwiera Compute. Jedyny, w którym dok to marka, nie czynność.
- **Obok siebie** - cztery doki w jednym rzędzie, test czytelności bez etykiety.
- **Total Balance + inwentarz** - trzy kosmetyczne wersje bloku salda, tabela kosztów, rekomendacja.

## What to Look For

1. **Czy ikona czyta się bez podpisu.** Dok jako jedyny element paska nie ma etykiety.
   Przewidywanie do sprawdzenia: C natychmiast, A bo znane z FAB-a, B mylone z A, D wymaga nauki.
2. **Zależność TB-3 ↔ dok B.** Jeśli dok to "Move", to para CTA Receive/Send pod saldem dubluje go
   na tym samym ekranie. TB-3 ma sens tylko z dokiem A, C albo D.
3. **Koszt.** Pozycji `New` poza wspólnym dokiem i paskiem: A = 0, B = 1, C = 2, D = 1.

## Findings grounded in code

| Fakt | Miejsce |
|---|---|
| Istniejący FAB używa `Icons.swap_vert_rounded` | `gw_swap_fab.dart:73` |
| Send i Receive nie mają domu w nawigacji - są przyciskami wewnątrz ekranów | `wallet_information.dart:176-185`, `coins_screen.dart:179,345` |
| `mobile_scanner: ^5.2.3` w zależnościach, zero użyć w `lib/` | `pubspec.yaml:35` |
| W repo jest tylko wyświetlanie QR, nie czytanie | `components/qr/crypto_address_qr.dart` |
| Zerowe saldo na `textPrimary38` = 3.54:1, poniżej AA | `coin_card_row.dart:126,134` |

## Recommendation

**A · Swap**, ale warunkowo. A nie wprowadza żadnego nowego pojęcia - ta sama ikona, ta sama trasa,
ten sam kontrakt co FAB, więc ryzyko nieporozumienia jest zerowe. **Jeśli jednak jest przeczucie, że
użytkownicy częściej wysyłają niż zamieniają, B jest lepszą inwestycją** - zamyka udokumentowaną lukę
zamiast przestawiać istniejący przycisk. Odrzucone: C (skanera nie ma, a `mobile_scanner` to jeden z
dwóch powodów, dla których symulator iOS tu nie działa) i D (marka zamiast czynności w elemencie bez etykiety).

## Open

- Skład czterech pozostałych pozycji przeniesiony z 171-B bez zmian; zależy od rozstrzygnięcia 171.
- Dok łamie regułę "jeden wypełniony gradient na powierzchnię" w każdym wariancie - decyzja raz, nie per ikona.
- Czy dok jest stały w całej powłoce, czy tylko na Home.
