---
sketch: 171
name: mobile-home-and-nav
question: "Jak ekran główny i nawigacja mają czytać się na iOS, gdy pasek ma 8 pozycji i trzy etykiety się nie mieszczą?"
winner: null
tags: [mobile, ios, navigation, bottom-nav, header, home, dashboard, sheet, contrast]
---

# Sketch 171: Mobile home + navigation

## Design Question

Ekran główny i cała nawigacja na telefonie: pasek dolny, header i menu. Pierwszy sketch tej rundy
po przejściu na **mobile-only** (Jakub, 2026-08-06 - iOS jest jego powierzchnią, Brian prowadzi Androida).

## How to View

```
open http://localhost:8899/171-mobile-home-and-nav/
```

Serwer: `python3 -m http.server 8899 --directory .planning/sketches`

Otwieraj w **przeglądarce Jakuba**, nie w wąskim viewporcie rozszerzenia - telefony renderują się 1:1
w 390 px, obok siebie z kolumną notatek.

## Variants

- **Dziś (baseline)** - stan faktyczny z iPhone'a Sidney, z pięcioma problemami opisanymi `file:line`.
- **A: Curated Five ★** - pasek do 5 pozycji, cztery wypadające do arkusza "More". Header niesie portfel. FAB usunięty.
- **B: Center Action** - 4 pozycje + środkowy dok otwierający arkusz czynności (Send/Receive/Swap/Buy).
- **C: Wallet Header** - AppBar zdjęty całkowicie, tożsamość portfela w przewijanej treści, +56 px pionu.
- **D: Segmented Home** - pasek trzyma tylko czynności; Assets/Compute/Markets/News to segmenty wewnątrz Home.

## What to Look For

1. **Szerokość kafelka paska.** Dziś 48,7 px na pozycję i trzy wielokropki. A/B/C dają 78 px, D daje 97,5 px.
2. **Gdzie ląduje to, co wypada.** Arkusz (A, C), arkusz dwupoziomowy (B), segmenty w treści (D).
   Wszystkie 8 destynacji zostaje osiągalnych - twardy warunek z Phase 4 i z todo 2026-07-18.
3. **Co robi header.** Dziś napis "Genius Wallet" plus desktopowy control track w poziomym scrollu.
   Warianty zastępują go tożsamością portfela; C usuwa AppBar w ogóle.
4. **Zerowe saldo.** Dziś `textPrimary38` = 3.54:1, poniżej AA. Wszystkie warianty podnoszą do `textPrimary80` = 12.4:1.
5. **Zakładka "Inwentarz i kontrast"** - tabela Existing/Adapted/New z dowodem w pliku, policzone ratio
   i porównanie liczbowe (nowe komponenty, dotknięte trasy, tapnięcia do celu).

## Findings grounded in code

| # | Problem | Miejsce |
|---|---|---|
| 1 | Jedna lista 8 destynacji dla desktopu i mobile | `responsive_overlay.dart:38-75` |
| 2 | Aktywna zakładka: ciche `return 0`, `/buy` i `/token-info` podświetlają Dashboard | `responsive_overlay.dart:82-92` |
| 3 | Desktopowy control track w `AppBar.actions` za poziomym scrollem | `responsive_overlay.dart:470-500` |
| 4 | Zerowe saldo malowane `textPrimary38`, 3.54:1, poniżej AA 4.5:1 | `coin_card_row.dart:126,134` |
| 5 | FAB `bottom: 80` nachodzi na listę aktywów | `global_swap_fab_host.dart:124-128` |

## Recommendation

**A + kurczenie control tracku z C.** A realizuje rozwiązanie zapisane w todo, nie wymyślając nowego
języka nawigacji - jedna pozycja `New`, jedna dotknięta trasa, więc da się zweryfikować na telefonie
w jednym cyklu. Runner-up **C** (projektowo najlepszy, ale zdjęcie AppBara dotyka ośmiu tras naraz -
własna faza). Odrzucony **B** (dok to nowy widget i łamie regułę jednego wypełnionego gradientu na powierzchnię).

## Open

- Skład piątki zgadnięty, nie oparty na danych o użyciu.
- Light mode nieliczony (reguła "dark first").
- Makiety pokazują portfel zerowy - z realnymi kwotami trzeba sprawdzić łamanie prawej kolumny.
- Weryfikacja na realnym ekranie telefonu wciąż przed nami: podgląd szedł z kamery Maca, nie z feedu ekranu.
