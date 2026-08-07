---
sketch: 173
name: variant-a-interactive
question: "Co się dzieje po tapnięciu w nazwę portfela - i czy wariant A trzyma się, gdy da się go faktycznie przeklikać?"
winner: null
tags: [mobile, ios, prototype, interactive, wallet-switcher, navigation, follows-171, follows-172]
---

# Sketch 173: Wariant A jako klikalny prototyp

## Design Question

Jakub wybrał **A · Curated Five** (2026-08-06) i od razu znalazł dziurę w statycznych makietach:
*"aczkolwiek jak bedzie sie rozwijal wallet jak tam klikne? zrob interaktywny wersje w pelni"*.

Statyczny obrazek nie odpowiada na pytanie, co robi nagłówek. Ten sketch odpowiada przez działanie.

## How to View

```
open http://localhost:8899/173-variant-a-interactive/
```

Wszystko w telefonie jest klikalne. Każde tapnięcie ląduje w **dzienniku** po prawej z nazwą trasy,
która odpaliłaby się w `router.dart` - albo z informacją, że takiej trasy nie ma.

## Główna odpowiedź: portfel to arkusz, nie dropdown

Tapnięcie w nazwę portfela otwiera arkusz z listą portfeli (Main Wallet / Trading / Cold Storage),
saldem i liczbą aktywów przy każdym, oraz akcjami: Dodaj portfel, Połącz przez WalletConnect,
Zarządzaj portfelami. Wybór **realnie przełącza stan** - zmienia się nagłówek i saldo.

**Dlaczego arkusz, a nie rozwijana lista.** Dropdown pod nagłówkiem musi zmieścić się w 390 px
i rośnie w dół nad treścią. Przy wierszu ~56 px (nazwa + adres + saldo) cztery portfele zasłaniają
pół ekranu i i tak wymagają przewijania, a górna krawędź listy jest poza zasięgiem kciuka.
Arkusz przychodzi od dołu, ma miejsce na adres, saldo i sieć, i używa `GWBottomSheet`,
który obsługuje już "More" - zero nowych wzorców.

## Co jeszcze działa

- **Chip sieci** → arkusz sieci; zmiana sieci przebudowuje listę aktywów (Ethereum 3 / Polygon 2 / BNB 1).
- **Adres** → kopiowanie z potwierdzeniem.
- **Wiersz aktywu** → ekran monety, z paskiem powrotu pokazującym, skąd przyszedłeś.
- **Swap z monety** → dziennik pokazuje `/swap extra:{symbol}`, czyli realny kontrakt z `router.dart:224`.
- **Pasek dolny** → pięć pozycji; More otwiera arkusz z News / Web / Feedback / Settings.
- **Rail akcji** → Send / Receive / Buy / Compute.

## Co dziennik ujawnia

Trzy tapnięcia kończą się `brak trasy`: **Receive**, **Send** i **Compute**. To nie jest usterka
prototypu - to stan aplikacji. Send i Receive żyją dziś jako przyciski wewnątrz ekranów
(`wallet_information.dart:176-185`, `coins_screen.dart:179,345`), a nie jako trasy, więc nawigacja
nie ma ich jak pokazać. Ten prototyp czyni ten brak widocznym.

## Open

- Czy przełącznik portfeli ma też przełączać sieć, czy to dwie niezależne osie (teraz niezależne).
- Czy Compute zasługuje na własną trasę.
- Zachowanie przy jednym portfelu - arkusz z jedną pozycją jest bez sensu, potrzebny stan zwinięty.
