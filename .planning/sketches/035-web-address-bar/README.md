---
sketch: 035
name: web-address-bar
question: "Jak pasek adresu ma czytać się jako chrome przeglądarki wewnątrz zredesignowanej aplikacji?"
winner: "B"
tags: [web, browser, address-bar, chrome, omnibar, url]
---

# Sketch 035: Web tab — pasek adresu / chrome przeglądarki

## Design Question
Dzisiejszy pasek adresu (`_buildSearchBar`, `web_view_mobile.dart:289`) to pełnoszerokościowy
`deepBlueCardColor` doklejony pod navbarem: strzałka wstecz, nieostylowane pole `Enter URL…`
(fill = `deepBlueTertiary`, brak favicon/kłódki/kontroli), obramowany przycisk `1` liczący karty.
Czyta się jak starsza aplikacja niż chrome nad nim. **Jak ten pasek ma być zintegrowany z
zredesignowanym chrome na desktopie?**

## How to View
open .planning/sketches/035-web-address-bar/index.html

## Variants
- **A · Przeskórowany pasek** — dedykowany pasek pod navbarem, ale przeskórowany: sunken pill
  (radius-pill), leading favicon + zielona kłódka, host wyróżniony / ścieżka wyszarzona, brand
  focus ring 3px na fokusie, prawdziwe ghost-buttony back/forward/refresh (back = brand aktywny,
  forward = disabled — jak stany z kodu), po prawej licznik kart jako brand chip z `+`. **Ścieżka
  najmniejszego oporu** — zachowuje strukturę, wymienia tylko styl.
- **B · Scalony toolbar** — jeden rząd 56px, kontrolki wtopione w LEWĄ krawędź pola (omnibox jak
  Safari/Arc): back/forward | favicon+kłódka+host | refresh — wszystko w jednym elemencie,
  po prawej licznik kart + menu ⋯. Znika wrażenie „drugiego paska pod paskiem".
- **C · Minimal / Arc** — wąski pływający command-bar (surface-menu + shadow), zwinięty pokazuje
  tylko favicon + host; na fokus rozszerza się do pełnego edytowalnego pola; kontrolki
  back/forward/refresh pojawiają się dopiero na hover paska. Maksimum miejsca dla webview.

## What to Look For
- **Integracja z navbarem** — czy pasek czyta się jako część chrome, czy jak osobny widget?
  (A = wyraźnie osobny sub-pasek; B = jeden toolbar; C = prawie niewidoczny).
- **Fokus / edycja** — kliknij pole adresu: brand ring + edytowalny input, Enter zwija do hosta.
- **Stany kontrolek** — Forward jest wyłączony (`canGoForward` false na starcie), Back podświetlony
  jak w realnym `_goBack`. Refresh kręci się na klik.
- **Licznik kart** — przycisk `1` (z kodu) przeprojektowany na brand chip z `+`; pełny model kart
  to sketch 036.
- **Light mode** (toolbar → Theme) — kłódka/host/ring muszą trzymać kontrast w obu motywach.

## Grounding
- Kontrolki: `_goBack`/`_goForward`/`_loadUrl`, `_controllers[i].canGoBack()` — stany real.
- Licznik: `"${_controllers.length}"` w obramowanym boxie (`:360`).
- Wyszukiwarka fallback: nie-URL → `google.com/search?q=` (`_loadUrl:222`) — stąd „search or URL".
- Tokeny: wspólny `default.css` (surface-sunken pole, brand-primary ring, status-success kłódka).
