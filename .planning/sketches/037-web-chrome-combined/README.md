---
sketch: 037
name: web-chrome-combined
question: "Jak wybrany pasek adresu i pasek kart składają się w jedno chrome zakładki Web?"
winner: "B"
tags: [web, browser, chrome, combined, address-bar, tab-strip, synthesis]
---

# Sketch 037: Web tab — złożone chrome (adres + karty)

## Design Question
Sketch 035 (pasek adresu) i 036 (karty) rozstrzygnięto osobno. Ten sketch składa je w jedną
pełną zakładkę Web, żeby zobaczyć całe chrome razem i porównać dwie kombinacje na żywo.

## How to View
open .planning/sketches/037-web-chrome-combined/index.html

## Variants
- **A · Twój wybór** — 035-A (dedykowany przeskórowany pasek) + 036-A (pasek kart).
- **B · Rekomendacja ★** — 035-B (scalony omnibox toolbar) + 036-A (pasek kart). **WYBRANY.**

Oba dzielą pasek kart 036-A; jedyna różnica to pasek adresu, więc porównanie jest czyste.

## Decision (chosen 2026-07-24)
**B · 035-B + 036-A.** Finalna struktura chrome zakładki Web:

1. **Navbar aplikacji** (bez zmian) — brand + zakładki + prawy klaster.
2. **Pasek kart (036-A)** — poziomy strip zawsze widoczny: favicon + tytuł + ×, aktywna karta =
   surface-elevated + 2px brand underline (ten sam mark co aktywna zakładka navbara). `+` na końcu
   dodaje kartę DuckDuckGo. Zastępuje pełnoekranowy `_buildTabManager` i licznik `1`.
3. **Omnibox toolbar (035-B)** — jeden rząd 54px: back/forward wtopione w LEWĄ krawędź pola |
   favicon + zielona kłódka + host | refresh po prawej krawędzi pola; menu ⋯ obok. Brand focus
   ring na fokusie, edytowalny input, Enter zwija do hosta. Zastępuje surowy `_buildSearchBar`.

Wysokość chrome ≈ 178px (navbar 62 + strip 46 + adres 54) — praktycznie tyle samo co wariant A
(≈174px), więc różnica jest czysto estetyczna: B czyta się jako jeden scalony toolbar zamiast
„kontrolki + osobne pole", co było sednem skargi na dzisiejszy pasek.

## Build Notes (dla fazy implementacji)
- Docelowy plik: `lib/web/web_view_mobile.dart` (macOS/iOS) — przepisać `_buildSearchBar` na
  omnibox toolbar i dodać poziomy pasek kart nad nim; `web_view_windows.dart` to samo dla Windows.
- Zachować realne mechaniki: `_goBack`/`_goForward`/`canGoBack`/`canGoForward` (stany kontrolek),
  `_loadUrl` (URL vs search fallback), `_addNewTab`/`_switchTab`/`_closeTab`, reguła ostatniej karty.
- Naprawić buga miniatur (`Matrix4.rotationX(pi)`, `:396`) — nieużywany w 036-A (strip nie ma
  miniatur), ale gdyby wrócił overflow-manager, miniatury muszą być proste.
- Favicon: `_getFaviconUrl` (`google.com/s2/favicons`) — realne, nie emoji.
- Wszystko na tokenach `default.css`; light mode musi trzymać kontrast (kłódka/host/ring).
