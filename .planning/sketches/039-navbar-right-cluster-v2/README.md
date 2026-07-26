---
sketch: 039
name: navbar-right-cluster-v2
question: "Jak prawy klaster navbara ma czytać się w dzisiejszym płaskim języku - i przeżyć 4 stany Connect oraz znikający przycisk SDK?"
winner: "B"
shipped: 2026-07-26
supersedes: 005
tags: [navbar, chrome, cluster, dropdowns, connect, cta, reown, sdk, states]
---

# Sketch 039: Navbar right cluster v2

## Dlaczego ten sketch istnieje, skoro jest 005

**Sketch 005 odpowiedział na to pytanie i ma zwycięzcę: `B · Normalized quiet chips`, wybrany
2026-07-21, z adnotacją "GSD implementation pending". Nigdy nie został wdrożony.** Dlatego pasek
nadal wygląda tak, jak wyglądał przed decyzją.

Nowa runda, a nie ślepe wdrożenie B, z jednego konkretnego powodu: B opisano jako *"quiet menu fill
+ hairline border"*, czyli zaprojektowano przeciwko światu z gradientowym sheenem. **Ten świat
zniknął 2026-07-25**, gdy `GWDecorations._surfaceSheenDark` spłaszczono do `#0C0E14` pod wygląd
zakładki Swap, a tory kontrolek dostały `surfaceSunken` jako zapisany standard
(`.planning/codebase/CONVENTIONS.md` → Control track). Klaster navbara to ten sam rodzaj bytu -
pasek kontrolek - więc powinien mówić dzisiejszym językiem.

## Diagnoza — POPRAWIONA 2026-07-26

⚠️ **Pierwsza wersja tej sekcji była BŁĘDNA i została tu poprawiona, a nie zachowana.** Twierdziła,
że selektory to gołe 58-pikselowe `TextButton`y bez odstępów. Powstała z przepisania README sketcha
005 sprzed pięciu dni; sprawdzono wtedy tylko `theme.dart` (które faktycznie ma feralne
`vertical: space10`), nie sprawdzając, że kontrolki i tak nadpisują to własnym stylem.

Stan faktyczny:

| Element | Stan w kodzie |
|---|---|
| Wszystkie trzy selektory | używają `navContextChipStyle` z `lib/theme/nav_chip_style.dart` — `network_dropdown_selector.dart:141`, `account_dropdown_selector.dart:428`, `sdk_account_manager.dart:47` |
| `nav_chip_style.dart` | wszedł w `0bcf3df8`, przestrojony w `e620b8b5` — **pinuje chipy na 40 px** |
| `responsive_overlay.dart:391` | już miało `spacing: space4` |
| `ReownConnectButton` | 5 gałęzi, wszystkie **wypełnione 18% i bez obrysu** |
| Buy GNUS | `GWButton`, `height: 40` |

**Konsekwencja dla tego sketcha:** wariant **A był w praktyce już wdrożony**. Realna różnica, którą
kupuje B, to **tor, cichsze chipy i obrys** — nie naprawa wysokości. Zakładka `DZIŚ` w `index.html`
została przerysowana z prawdziwego kodu (40 px, gap 8, wypełnione stany).

Pułapka, która zostaje aktualna: `theme.dart:266-269` naprawdę daje `vertical: space10` każdemu
gołemu `TextButton`owi w aplikacji, więc **wysokości nigdy nie naprawia się tam** — tylko na
kontrolkach albo ich wspólnym kontenerze.

## Dwa wymiary, na których każdy wariant musi przeżyć

1. **Connect ma 4 gałęzie** (`reown_connect_button.dart:502-540`): idle obrysowany marką ·
   połączony na `statusError` 18% · rozłączanie na `statusWarning` 18% · timeout na `statusWarning` 18%.
2. **Przycisk SDK znika całkowicie** przy `accounts.isEmpty` (`sdk_account_manager.dart:40-41`) -
   liczba elementów w rzędzie jest **zmienna**. To dzisiejszy bug, nie hipoteza.

Sketch ma przełączniki na oba wymiary. Wariant, który rozjeżdża się w którymkolwiek stanie, odpada.

## How to View

```
open .planning/sketches/039-navbar-right-cluster-v2/index.html
```

Skala 1:1 - pasek 1600×62 px, kontrolki w realnych rozmiarach. Zakładka `DZIŚ` pokazuje punkt
wyjścia w tej samej skali.

## Variants

- **DZIŚ** - stan z `main`. Punkt odniesienia, nie propozycja.
- **A · ciche chipy** - 005-B przestrojone na płaski język: każda kontrolka 40 px,
  `surfaceElevated` + hairline, gap 8. Najmniejszy diff, zero nowych komponentów.
  Ścieżka najmniejszego oporu dla portu. Słabość: pięć osobnych kafelków to nadal pięć rzeczy.
- **B · jeden tor** - trzy selektory kontekstu w jednym torze `surfaceSunken` + hairline +
  `radiusPill` + 3 px, czyli **dokładnie standard toru kontrolek z CONVENTIONS.md**. Connect i Buy
  GNUS zostają na zewnątrz jako akcje. Znikający SDK to jeden chip mniej w torze - problem zmiennej
  liczby elementów znika strukturalnie.
- **C · kapsuła** - portfel jako bohater: awatar z odznaką sieci, adres i **kropka niosąca stan
  Reown**. Connect przestaje być osobnym przyciskiem, SDK spada do ikony, Buy GNUS jest jedynym CTA.
  Trzy elementy zamiast pięciu.

## What to Look For

1. Przełącz **DZIŚ ↔ A/B/C** i patrz na linię dolnych krawędzi - dziś jej nie ma.
2. Przejedź **wszystkie cztery stany Connect** w każdym wariancie. W C sprawdź, czy „Disconnect"
   jest nadal odkrywalne, gdy stan niesie kropka zamiast etykiety przycisku.
3. Przełącz **brak konta SDK**. A gubi kafelek i rząd się przesuwa; B gubi chip wewnątrz toru,
   który zachowuje kształt; C nie zmienia się prawie wcale.
4. Sprawdź **jasny motyw** - `surfaceSunken` w jasnym to `#CFD4DB`, więc tor jest tam ciemniejszy
   od karty tak samo jak w ciemnym. Uwaga: pełny przebieg light jest odłożony do dedykowanej sesji.

## Rekomendacja

**B**, z jednego powodu, który nie jest estetyczny: dziś zapisaliśmy standard toru kontrolek i
zastosowaliśmy go do segmentu timeframe oraz paska filtrów. Klaster navbara jest trzecim
wystąpieniem tego samego wzorca. Jeśli B wygra, standard ma trzy zgodne zastosowania zamiast dwóch
plus wyjątek - a znikający przycisk SDK przestaje rozjeżdżać rząd bez pisania jednej linijki logiki.

## Decyzja (2026-07-26)

Jakub wybrał **B**, z dwoma własnymi doprecyzowaniami:

1. **Buy GNUS zostaje 40px** - jedna wysokość w całym klastrze; nacisk bierze się z gradientu, nie
   z rozmiaru. Opcja wyższego CTA była dostępna i nie została wzięta.
2. **Wszystkie gałęzie stanu `ReownConnectButton` stają się obrysowane** - przezroczyste
   wypełnienie, 1px obrys w kolorze stanu, etykieta i ikona w kolorze stanu. Poproszone dla gałęzi
   połączony/"Disconnect", rozszerzone celowo na resztę tak, aby przycisk niósł jeden język
   wizualny.

Poprawka do własnej tabeli `## Diagnoza` powyżej: opisuje ona selektory jako gołe 58px
`TextButton`y, ale `nav_chip_style.dart` znormalizował je do 40px zanim ten sketch powstał - więc
to, co wdrożono, to tor i obrys, a nie poprawka wysokości. Odnotowane tutaj; tabela powyżej
pozostaje bez zmian.
