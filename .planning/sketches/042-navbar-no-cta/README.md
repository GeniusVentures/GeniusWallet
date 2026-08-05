---
sketch: 042
name: navbar-no-cta
question: "Bez Buy GNUS po prawej stronie - czym pasek ma się stać, skoro nic już nie musi krzyczeć?"
winner: null
recommendation: "3A · instrument + obwódka (z zastrzeżeniem o kolorze stanu połączony)"
follows: 045
tags: [navbar, cluster, no-cta, identity, connect, balance, reown, sdk, blue-sky]
---

# Sketch 042: Navbar bez CTA

## Design Question

Jakub: *"zaprojektuj, gdzie Buy GNUS nie jest dostępny z tamtej strony. Zaprojektuj ten pasek tak,
jak chcesz, żeby wyglądał jak najlepiej. Sky is the limit."*

## Co naprawdę zmienia zdjęcie CTA

Buy GNUS był **jedynym elementem wymuszającym hierarchię** po prawej stronie - gradient przyciągał
wzrok, a reszta układała się względem niego. Bez niego nie ma już nic, co musi krzyczeć, więc pasek
może przestać być rzędem guzików i stać się **jednym instrumentem stanu**. To jest realna zmiana
zadania, nie tylko usunięcie elementu.

Wszystkie pięć wariantów trzyma się tych samych twardych faktów z kodu: cztery gałęzie stanu Connect
(`reown_connect_button.dart`), znikający przycisk SDK przy `accounts.isEmpty`
(`sdk_account_manager.dart:40-41`), wysokość 44 px zgodna z hoverem tabów
(`responsive_overlay.dart:317`), tokeny z `themes/default.css`.

## How to View

```
open .planning/sketches/042-navbar-no-cta/index.html
```

Skala 1:1. **Przejedź cztery stany Connect w każdym wariancie** - bez CTA to stan połączenia jest
jedyną rzeczą w pasku, która się zmienia, więc każdy wariant musi go unieść.

## Warianty

| # | Nazwa | Elementów | Idea |
|---|---|---|---|
| 1 | kapsuła | 2 | Sieć + portfel + stan w jednym pill; SDK osobną ikoną |
| 2 | stan w obwódce | 1 | Tor zostaje; stan niesie **kolor obwódki i poświata**, nie osobny byt |
| 3 | **instrument** ★ | 1 | Jeden tor z hairline'owymi przegrodami: sieć │ SDK │ portfel │ stan |
| 4 | saldo | 3 | Zwolnione miejsce zajmuje **saldo GNUS + wycena**; tożsamość obok |
| 5 | awatar | 2 | Jeden awatar 40 px w pierścieniu stanu; reszta w panelu |

| 3A | **instrument + obwódka** ★ | 1 | 3 plus obwódka i poświata z 2 — sygnał z daleka BEZ utraty celu |

## ★ Moja rekomendacja: **3A** (dopisane po 3, na prośbę Jakuba)

3A bierze 3 i dokłada obwódkę z 2. To jest **ściśle lepsze od obu**: obwódka nie zastępuje pola
stanu, tylko je dubluje, więc dostajesz sygnał widoczny z drugiego końca ekranu i nadal masz
etykietowany, klikalny cel. Jedyny zarzut wobec 2 (kolor to słaby afordans) znika, a jedyna słabość
3 (stan czytelny dopiero z bliska) też.

### ⚠ Warunek, bez którego 3A nie zadziała

Stan „połączony" jest dziś malowany kolorem `statusError` — **nie dlatego, że coś jest nie tak**,
tylko dlatego, że etykieta akcji brzmi „Disconnect". W 2 i 3A ten kolor rozlewa się na obwódkę
całego toru, więc **udane połączenie świeci na czerwono i czyta się jak awaria**. Przy 30-pikselowym
chipie to uchodziło; przy obwódce całego paska nie.

Jeśli wybierzesz 3A, obwódka musi nieść **stan połączenia** (zielony = połączony), a pole w torze
może zostać czerwone, bo tam czerwień opisuje **to, co zrobi kliknięcie**. To rozdzielenie „kolor
stanu" od „koloru akcji" jest warunkiem wdrożenia, nie detalem.

## Rekomendacja pierwotna: **3 · instrument**

Nie dlatego, że jest najładniejszy - dlatego, że jako jedyny **nie płaci za wygląd informacją ani
afordansem**:

- **Nic nie znika z widoku.** 1 i 5 chowają sieć do odznaki na awatarze, a 5 chowa też adres
  portfela. Wybór sieci decyduje o tym, na jakiej sieci wysyłasz transakcję - to zły kandydat na
  element schowany o jedno kliknięcie głębiej.
- **Stan dostaje etykietowany dom.** W 2 stan niesie sam kolor obwódki; wygląda świetnie, ale kolor
  to słaby afordans - nie widać, że „Disconnect" jest tam do kliknięcia. W 3 stan jest polem z
  kropką i etykietą, czyli nadal celem.
- **To najmniejszy skok od kodu, który już masz.** Tor `surfaceSunken` jest w drzewie od dziś
  (039-B). 3 dokłada do niego przegrody i czwarte pole - reszta zostaje. 1, 4 i 5 to nowe
  komponenty i nowa nawigacja w panelu.
- **Przeżywa znikający SDK.** Chip i jego przegroda znikają razem, tor zachowuje kształt.

**Gdyby jednak nie 3:** wtedy **4 · saldo**, bo jako jedyny robi ze zwolnionego miejsca użytek
zamiast je oddać. Zastrzeżenie: na zakładce Dashboard saldo jest już wielkie na środku ekranu, więc
w pasku dubluje informację, którą i tak widzisz - wartość ma dopiero na pozostałych zakładkach.
Dane są w zasięgu (`WalletDetailsCubit.coins`, ten sam kubełek co `wallet_overview`), więc to jedno
podłączenie, nie nowa warstwa.

**Czego bym nie brał:** **5 · awatar** - adres portfela znika z paska, a to informacja, którą wielu
ludzi chce mieć na oku bez klikania, zwłaszcza przed wysłaniem transakcji.

## What to Look For

1. Cztery stany Connect w każdym wariancie - w 2 patrz, czy sam kolor obwódki wystarcza.
2. `brak SDK` - w 1, 3, 4, 5 nic się nie rozjeżdża; w 3 znika też przegroda.
3. W 5: czy brak adresu na pasku Ci przeszkadza. To jedyny wariant, który coś naprawdę zabiera.
4. Jasny motyw - `surfaceSunken` w jasnym to `#CFD4DB`, tor pozostaje ciemniejszy od paska.
