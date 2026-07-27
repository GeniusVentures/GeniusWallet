---
sketch: 040
name: swap-page-header
question: "Tytuł strony ma siedzieć top-left jak na innych zakładkach — ale kolumna swapa jest wycentrowana na 560px. Jak pogodzić te dwie osie, żeby strona czytała się jak skończona?"
winner: null
tags: [swap, page-header, title, layout, gw-page-header, chrome, resolves-025, resolves-026]
---

# Sketch 040: Swap page header

## Design Question

`GWPageHeader` rozciąga się na całą ramkę strony (`GeniusBreakpoints.xxl` = 1600), a kolumna
swapa jest wycentrowana na 560px. Na 1700px daje to **trzy niezależne osie** — tytuł przy lewej
rynnie, ikona `tune` przy prawej krawędzi, karta na środku — i żadna ich nie wiąże. Tytuł czyta
się jak sierota, nie jak nagłówek strony.

## Znalezisko z kodu (przed sketchowaniem)

Wygrany wariant **105 A1** trzymał `.pagehead` **wewnątrz** kolumny 560px (`.focus-col`,
`max-width:560px; margin:0 auto`) — tytuł był wycentrowany nad kartą i tworzył z nią jeden blok.
Shipowany kod przeniósł nagłówek do lewej rynny strony
(`lib/squid_router/swap_screen.dart:534-574`, komentarz: _"The header no longer shares this edge —
it deliberately spans the full page frame above"_). To jest **regresja decyzji z 105**, i to ona
produkuje obraz, na który Jakub patrzy.

Jakub chce jednak tytuł top-left (spójność z Transactions/Markets/News), więc powrót do 105 A1
nie jest odpowiedzią. Odpowiedzią jest coś, co utrzyma tytuł na lewej rynnie i **jednocześnie**
przestanie zostawiać go w próżni.

## How to View

```
open .planning/sketches/040-swap-page-header/index.html
```

Narzędzia w prawym dolnym rogu: Dark/Light · szerokość okna 1700/1280/900 · **Osie** (pokazuje
linie wyrównania) · **Navbar** (chowa pasek nawigacji — screen Jakuba go nie miał).

## Variants

- **0 · Dziś** — stan z kodu, jako uczciwy punkt odniesienia. Trzy osie.
- **A · Pasek nagłówka** — tytuł zostaje na X ramki strony, ale wiersz dostaje pełnoekranową
  linię 1px pod spodem. Tytuł oznacza region, zamiast unosić się nad nim. Ikona `tune` dostaje
  etykietę „Slippage 0.5%" — realna informacja zamiast samotnego ikonka na końcu 1600px.
  Karta zostaje wycentrowana pod paskiem. **Rekomendacja.**
- **B · Jedna oś** — tytuł, podtytuł, ikona i cała kolumna 560px dzielą jedną lewą krawędź.
  Najmocniejsza spójność, zero pływających elementów. Cena: na 1700px prawa połowa ekranu pusta.
- **C · Companion** — nagłówek pełną szerokością, a szerokość dostaje uzasadnienie: prawa kolumna
  z kursem pary i historią swapów. ⚠ **Oba panele wymagają danych, których ekran dziś nie ma** —
  to nie re-skin, to nowa funkcja. Szkic 105 odrzucił ten wariant z tego samego powodu (A2).
- **D · Pasek + jedna oś (hybryda A+B)** — pasek i etykietowany `tune` z A, ale kolumna 560px
  siedzi na lewej krawędzi ramki zamiast na środku. Tytuł, lewa krawędź karty i lewa krawędź CTA
  na jednej linii, a pasek trzyma cały wiersz.
- **↔ A | B obok siebie** — nie wariant, tylko widok: A i B jeden pod drugim, oba pełną
  szerokością, bez przełączania zakładek.

## What to Look For

1. **Przełącz 0 → A.** Czy sama linia 1px wystarcza, żeby tytuł przestał wyglądać na porzucony?
2. **Włącz „Osie" na B.** Tytuł, lewa krawędź karty i lewa krawędź CTA są na jednej linii —
   czy ta lewa kolumna czyta się jako decyzja, czy jako niedokończone centrowanie?
3. **Przełącz okno na 1280 i 900.** A i B mają zachować się sensownie; C znika do jednej kolumny
   poniżej 1180px.
4. **Ikona `tune`.** W 0 leci na koniec 1600px — 1500px od tytułu, do którego należy. W A jest
   etykietowana i siedzi na tej samej linii. Czy etykieta „Slippage 0.5%" niesie wartość?
5. **Light mode.** Linia w A na `--border-subtle` w jasnym motywie — czy jeszcze widoczna?

## Zasięg poza Swapem

A i B to zmiana w `lib/components/scaffold/gw_page_header.dart` — jednym ruchem dotyka
Transactions, Markets, News i Swap. To jest też odpowiedź na dwa otwarte szkice:

- **025 transactions-header** — _"a lone 'Transactions' word floating top-left over a 1600px page
  reads as unfinished"_
- **026 page-structure** — rekomendowany tam **S2** (full-width header band) to dokładnie
  wariant A.
