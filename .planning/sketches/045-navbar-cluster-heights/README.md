---
sketch: 045
name: navbar-cluster-heights
question: "Klaster jest niższy niż taby nawigacji obok - do jakiej wysokości go podnieść, i co przy okazji zrobić z Connect oraz Buy GNUS?"
winner: null
follows: 039
tags: [navbar, cluster, heights, dropdowns, connect, buy-gnus, cta, reown, sdk]
---

# Sketch 045: Navbar cluster — wysokości + Connect/Buy GNUS

## Design Question

Jakub po wdrożeniu 039-B: *"wysokość tych dropdownów jest chyba trochę za mała, wyrównaj bardziej do
hoverów na tabach dashboard/transaction, ewentualnie do CTA"* oraz *"nic się nie zmieniło jeśli
chodzi o Connect i Genius"*.

Dwa pytania w jednym, i tu są rozpisane jako jedna oś: **każdy wariant podnosi klaster do 44 px i
robi coś innego z dwoma akcjami po prawej.**

## Problem — zmierzony, nie odczuty

| Element | Wysokość | Źródło |
|---|---|---|
| Hover / aktywny tab nawigacji | **44 px** | `responsive_overlay.dart:317` |
| Tor kontrolek (3 px padding + 1 px ramka) | 40 px | `responsive_overlay.dart:113-119` |
| **Chip w torze** | **32 px** | `nav_chip_style.dart:53` |
| Connect, Buy GNUS | 40 px | `reown_connect_button.dart`, `GWButton(height: 40)` |

Trzy różne wysokości w jednym pasku, a najniższa (chip, 32) sąsiaduje z najwyższą (tab, 44).
Różnica 12 px — dlatego dropdowny czytają się jako „za małe". To nie jest kwestia gustu.

## How to View

```
open .planning/sketches/045-navbar-cluster-heights/index.html
```

Skala 1:1. Taby nawigacji narysowane w prawdziwych 44 px hovera, żeby porównanie było uczciwe.
Zakładka `DZIŚ` pokazuje stan z drzewa. Przełącznik `linie 44` rysuje prowadnice.

## Variants — wszystkie podnoszą klaster do 44

| # | Nazwa | Tor / chip | Connect | Buy GNUS |
|---|---|---|---|---|
| 1 | **wszystko 44** | 44 / 36 | pełny przycisk 44 + kropka stanu | 44, ikona + większy oddech |
| 2 | **grubsze chipy** | 44 / 38 (padding toru 2 px) | jw. | jw. |
| 3 | **bez toru** | brak toru, chipy 44 samodzielne | jw. | jw. |
| 4 | **Connect w torze** | 44 / 36, czwarty chip = stan | znika jako osobny przycisk | jedyny akcent |
| 5 | **Connect jako ikona** | 44 / 36 | kwadrat 44×44, ikona w kolorze stanu | jedyna etykieta w rzędzie |

## Doprecyzowanie 2026-07-26 — sieć tylko ikoną

Jakub: *"dla sieci pokazuj tylko ikonę, np. eth icon"*. Chip sieci traci etykietę `Ethereum` we
**wszystkich pięciu wariantach** — zostaje ikona łańcucha + strzałka, padding schodzi z 12 na 8 px.
Pełna nazwa sieci nadal jest w otwieranym menu (`NetworkDropdownSelector` renderuje ją w `ListTile`
z tytułem i symbolem — `network_dropdown_selector.dart:105-114`), więc nic nie ginie, a pasek
oddaje ~70 px.

Do sprawdzenia okiem: czy sama ikona wystarcza do rozpoznania sieci, gdy nie jest to Ethereum.
Alternatywa, gdyby nie wystarczała: ikona + symbol (`ETH`, `BSC`) zamiast pełnej nazwy — krótsza
niż dziś, czytelniejsza niż sama ikona.

## What to Look For

1. **Najpierw `DZIŚ`, potem cokolwiek innego.** Rozjazd 32 ↔ 44 jest widoczny dopiero w zestawieniu.
2. **Wariant 1 vs 2** — czy tor „zjada" chipy. Jeśli w 1 obwolutka jest za gruba, 2 jest odpowiedzią
   (padding 3 → 2 px, chip 36 → 38).
3. **Wariant 3** — jedyny, w którym pasek czyta się jako jeden ciąg równych kafli od logo do CTA.
   Koszt: wraca problem, który 039-B rozwiązał — znikający przycisk SDK znów przesuwa cały rząd.
4. **Wariant 4** — sprawdź, czy „Disconnect" jest nadal odkrywalne, gdy stan jest chipem w torze,
   a nie przyciskiem z etykietą.
5. **Cztery stany Connect w każdym wariancie.** Obrys, kropka i etykieta zmieniają kolor razem.
6. **Brak konta SDK** — w 1, 2, 4, 5 tor gubi jeden chip i zachowuje kształt; w 3 rząd się przesuwa.

## Uwaga implementacyjna (dotyczy każdego wariantu)

Wysokości **nie wolno naprawiać w `theme.dart`** — `textButtonTheme` (`:261-270`) rządzi każdym gołym
`TextButton` w aplikacji. Właściwe miejsce to `nav_chip_style.dart` (chip w torze) i kontener toru w
`responsive_overlay.dart:113`. Zmiana `_buildActionRowWidgets` dotyka **dwóch** powierzchni — desktopu
(`:393`) i AppBara mobilnego (`:428`) — więc mobilny pasek trzeba obejrzeć razem z desktopowym.
