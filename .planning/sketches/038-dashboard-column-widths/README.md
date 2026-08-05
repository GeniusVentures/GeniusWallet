---
sketch: 038
name: dashboard-column-widths
question: "Ile szerokości ma dostać kolumna Transactions, i czym za to płacą panele po lewej?"
winner: "A1"
shipped: 2026-07-25
tags: [dashboard, layout, widths, columns, transactions, chart, three-column]
---

# Sketch 038: Dashboard — szerokości kolumn

## Design Question

Jakub: *"zmniejszyłbym trochę szerokość Assets oraz Chartu, dawaj więcej szerokości dla Transactions."*

Dashboard ma dziś nierówny rytm i za wąską kolumnę transakcji. Pytanie brzmi: **o ile
przesunąć podział między lewym blokiem a kolumną Transactions, i czy da się to zrobić bez
ruszania proporcji wewnątrz rzędów.**

## Skąd wzięły się liczby

Wszystkie z `lib/dashboard/home/view/dashboard_screen.dart`, `_threeColumnLayout()`:

- linia 157 — `Row(spacing: space3)`, lewy blok `Expanded(flex: 3)`, Transactions `Expanded()` (flex 1)
- linia 189 — Transactions ma `BoxConstraints(maxWidth: 600)`
- linie 165/174 — podział pionowy `flex: 45` / `flex: 55`, minHeight 300 / 380
- `_OverviewContributionsRow` — Assets `flex: 2`, Compute `flex: 3`
- `_ChartMarketsRow` — Chart `flex: 3`, Markets `flex: 2`
- padding i wszystkie odstępy = `space3` = **6px** (nie 8 — to udokumentowany wyjątek od siatki 4-pt)

Wyliczone dla okna **1920px**: 1920 − 12 (padding) − 6 (spacing) = 1902 do podziału.

| Panel | DZIŚ | A1 | Zmiana |
|---|---|---|---|
| Transactions | 476 px | **634 px** | **+158** |
| Assets | 568 px | 505 px | −63 |
| Compute | 852 px | 757 px | −95 |
| Chart | 852 px | 757 px | −95 |
| Markets | 568 px | 505 px | −63 |

## How to View

```
open .planning/sketches/038-dashboard-column-widths/index.html
```

Skala **1:1 przy 1920px** — nic nie jest pomniejszone, przewiń w bok. Zakładki DZIŚ ↔ A1
przełączają wyłącznie szerokości na tym samym drzewie DOM, więc panele przepływają na żywo.

## Variants

- **DZIŚ** — stan z `main`: `flex 3:1`, cap 600. Punkt odniesienia, nie propozycja.
- **A1** — `flex: 3` → `flex: 2` (linia 161) i `maxWidth: 600` → `760` (linia 189).
  Proporcje wewnątrz obu rzędów **bez żadnej zmiany**. Dwie liczby, nic więcej.

## What to Look For

1. **Kolumna Transactions przy 634px** — dopiero przy tej szerokości mieszczą się kolumny
   Status i Fee ze sketcha **029** (obrysowane na niebiesko; w widoku DZIŚ znikają, bo nie ma
   dla nich miejsca). To jedyna zmiana układu, która realnie odblokowuje tamten sketch.
2. **Chart przy 757px** — czerwony znacznik pokazuje, ile potrzebuje rząd zoom/pan razem z ceną.
   To jest cena wariantu A1 i trzeba na nią spojrzeć, a nie przyjąć na słowo.
3. **Assets przy 505px** — czy trzy wiersze tokenów + saldo dalej oddychają.

## Znane napięcie (nie ukrywać)

Chart traci 95px, a jego rząd zoom/pan **już dziś się nie mieści** —
`.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md` to zaakceptowany
override z Fazy 5, a obejście `260721-gx1` Jakub odrzucił słowami *"nieprzepełniona zepsuta
karta to nie naprawiona karta"*. W tym samym todo wisi nierozstrzygnięte pytanie, **czy rząd
zoom/pan jest w ogóle potrzebny**. Jeśli odpadnie, zwężenie wykresu robi się darmowe.

## Wynik

**A1 wdrożone 2026-07-25** — dwie liczby w `dashboard_screen.dart`: `flex: 3` → `flex: 2`
(linia 161) i `maxWidth: 600` → `760` (linia 189). `flutter analyze lib` = 59, bez zmian.

## Pozycja wallet/processing jest USTALONA

`OverviewDashboardView` (wallet + processing) **zostaje top-left przy każdej szerokości** —
to jego miejsce, potwierdzone przez Jakuba 2026-07-25 po tym, jak ta sesja przestawiła go w
prawo, źle odczytawszy potwierdzenie obecnego stanu jako prośbę o zmianę. Zamiana została
cofnięta. **Nie przestawiać górnego rzędu**, w żadnym wariancie, w żadnej fazie.

## A2 — ZBUDOWANE, OBEJRZANE NA ŻYWO, ODRZUCONE (2026-07-25)

**Nie proponować tego ponownie.** A2 zamieniało kolejność w dolnym rzędzie na `Markets | Chart`,
przez co oba szwy siadały na 40% i cztery panele czytały się jako dwie kolumny zamiast zygzaka
40/60-then-60/40. Koszt: zero pikseli, samo przestawienie dzieci.

Wdrożone i obejrzane przez Jakuba w działającej aplikacji tego samego dnia. Werdykt: **"nie jest
lepszy"** — wyrównane szwy nie były warte przesunięcia wykresu z lewej krawędzi. Cofnięte.

Wniosek do zapamiętania: **zygzak 40/60 / 60/40 to świadomy, obejrzany kompromis, nie
przeoczenie.** Wykres zostaje po lewej w dolnym rzędzie, tak samo jak wallet/processing zostaje
top-left w górnym. Oba rzędy mają teraz ustaloną kolejność i żadnego z nich się nie przestawia.

Wariant A2 zostaje w `index.html` (zakładka + przełącznik `szew`) jako zapis tego, co zostało
sprawdzone i odrzucone — nie jako propozycja.
