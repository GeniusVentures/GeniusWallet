---
sketch: 036
name: web-tab-strip
question: "Jak przełączać i dodawać karty w zakładce Web na desktopie?"
winner: "A"
tags: [web, browser, tabs, tab-strip, tab-manager, new-tab]
---

# Sketch 036: Web tab — karty (przełączanie + dodawanie)

## Design Question
Dziś karty (`_controllers`, `_tabUrls`, `_tabImages`) są schowane za przyciskiem-licznikiem `1`,
który otwiera **pełnoekranowy** `_buildTabManager` (`web_view_mobile.dart:374`) — pionowy `ListView`
odwróconych miniatur (`Matrix4.rotationX(pi)` — miniatury renderują się do góry nogami), z `+`
w lewym dolnym i `×` w prawym. Na desktopie marnuje szerokość i chowa karty za jednym kликiem.
**Jak przełączać i dodawać karty, mając szerokie okno?**

## How to View
open .planning/sketches/036-web-tab-strip/index.html

## Variants
- **A · Stały pasek kart** — poziomy pasek kart zawsze widoczny między navbarem a paskiem adresu
  (styl Chrome/Arc). Favicon + tytuł + ×, aktywna karta = surface-elevated + 2px brand underline
  (ten sam mark co aktywna zakładka navbara — spójność z sketch 022). `+` na końcu dodaje kartę.
  Karty zero-kliku, ale zjada 46px pionu.
- **B · Dopracowana nakładka** — model przycisk-licznik → nakładka, ale przeprojektowany: siatka
  kart (miniatura NIE odwrócona, favicon + tytuł + ×) + kafel „Nowa karta" (dashed brand + duży `+`).
  Nagłówek z licznikiem i „Gotowe". Bliski dzisiejszej architekturze, naprawia buga z miniaturami.
- **C · Boczny rail kart** — pionowy rail 232px po lewej (styl Arc): karty jedna pod drugą, aktywna =
  3px brand bar po lewej, × na hover, „Nowa karta" na dole. Webview po prawej. Skaluje się do wielu
  kart i długich tytułów bez ściskania, kosztem szerokości webview.

## What to Look For
- **Widoczność** — czy chcesz karty zawsze na widoku (A/C), czy na żądanie (B)?
- **Dodawanie** — `+` w pasku (A), kafel „Nowa karta" (B), „Nowa karta" w railu (C). Każdy dodaje
  kartę DuckDuckGo (`_addNewTab("https://www.duckduckgo.com")`, `:500`).
- **Aktywny stan** — wszędzie użyty brand mark z navbara, nie osobny język.
- **Zamykanie** — × zamyka; ostatnia karta się nie zamyka (`if(_controllers.length==1) return;`, `:236`).
- **Pion vs szerokość** — A i C kradną miejsce webview; B nie, ale chowa karty. Otwórz 4+ karty,
  klikaj między nimi, dodawaj/zamykaj — poczuj który model męczy.
- **Light mode** (toolbar → Theme).

## Grounding
- Model kart: `_addNewTab` / `_switchTab` / `_closeTab`, faktyczne listy `_tabUrls`/`_tabImages`.
- Favicon: `_getFaviconUrl` → `google.com/s2/favicons?domain=host` — tu emoji-proxy dla mocka.
- Tytuł: `_controllers[i].getTitle()` z fallbackiem na URL (`:462`).
- Bug do naprawy: miniatury w managerze są odwrócone (`Matrix4.rotationX(pi)`, `:396`) — B pokazuje
  je poprawnie.
- Reguła ostatniej karty i domyślny URL nowej karty — z kodu.
