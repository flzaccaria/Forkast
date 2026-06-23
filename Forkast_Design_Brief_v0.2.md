# Forkast — Design Brief

*v0.2 · Bozza per implementazione · Complementare a: Requisiti Funzionali v0.3, Mappa dei flussi v1.0, ADR v1.0*

> **Scopo del documento.** Definire un sistema visivo coerente per Forkast e tradurlo in token e regole applicabili direttamente in codice (Flutter). Non è un mockup pixel-perfect: è la *base condivisa* che evita decisioni estetiche prese schermata per schermata. Dove una scelta è ancora aperta, è marcata come `[DA DECIDERE]`.

> **Modifiche rispetto alla v0.1.** Sezione 5 (Marchio/logo) riscritta sulla costruzione definitiva approvata. Direzione della curva e altezza della F risolte. Asset SVG di produzione consegnati a parte (`forkast-wordmark.svg`, `forkast-mark.svg`, `forkast-app-icon.svg`).

---

## 0. Principio guida

Forkast è un **tool casalingo self-service**, non un gestionale né una piattaforma nutrizionale. L'estetica deve risultare calda, ordinata e leggibile con una mano sola al supermercato (è il caso d'uso reale dichiarato nell'ADR). Regola trasversale: **il colore primario si guadagna lo spazio** — usato con parsimonia, non per riempire superfici.

---

## 1. Palette colori (token)

Un solo sistema di colore, applicato come token. Niente colori decisi ad-hoc nelle singole schermate.

| Token | Hex | Uso |
| --- | --- | --- |
| `primary` | `#D85A30` | Corallo/terracotta. Logo, bottone d'azione principale, stato attivo. **Solo accenti.** |
| `primary-pressed` | `#B8431F` | Stato premuto/hover del primario. |
| `ink` | `#2C2C2A` | Testo principale (nomi piatti, voci, titoli). |
| `ink-muted` | `#5F5E5A` | Testo secondario: metadati, unità di misura, "q.b.", sottotitoli. |
| `surface-page` | `#FAF8F3` | Sfondo pagina (avorio caldo, **non** bianco puro). |
| `surface-card` | `#FFFFFF` | Card e righe: bianco puro, così "galleggiano" sullo sfondo avorio. |
| `border` | `#E7E3DA` | Bordi 0.5px, separatori. |
| `success` | `#2E7D52` | **Riservato:** spunte di acquisto completate. |
| `warning` | `#C9871F` | **Riservato:** avviso "Aggiorna lista" (rigenerazione, FR-21). |

**Dark mode:** invertire `surface-page → #1A1917`, `surface-card → #232220`, `ink → #F2EFE9`, `ink-muted → #A3A099`. Il `primary` corallo resta invariato (leggibile su entrambi i fondi).

---

## 2. Tipografia

- **Un solo font, due pesi:** regular (400) e medium (500). Nessun grassetto a metà frase.
- **Gerarchia:**
  - Titolo schermata — ~22px / 500
  - Nome piatto · voce lista — ~16px / 500, colore `ink`
  - Quantità · unità · metadati — ~13px / 400, colore `ink-muted`
- **Separare per peso e colore, non per dimensione.** Nome piatto in `ink` medium, quantità in `ink-muted`: l'occhio distingue subito i due piani informativi.
- **Sentence case** ovunque (no Title Case, no maiuscolo).

---

## 3. Spaziatura e densità

- Righe lista/piatto: altezza ~56px, padding interno generoso. Leggibili camminando, con una mano.
- Ritmo verticale a step di 8px (8 / 16 / 24).
- Le card respirano: padding ~16px verticale, ~20px orizzontale.
- Evitare la densità "foglio di calcolo": più aria = meno percezione di gestionale.

---

## 4. Iconografia

- **Una sola famiglia di icone, stile outline, tratto sottile.**
- **Reparti della lista** `[collegato a punto aperto: ordinamento per reparto]`: una micro-icona per reparto (ortofrutta, latticini, dispensa…) rende la lista scansionabile tra le corsie. Richiede l'attributo categoria su `ingredient` (oggi assente — vedi ADR §7).
- **"Quanto basta":** non la scritta "q.b." nuda, ma una pillola tenue (sfondo `border`, testo `ink-muted`). Comunica "nessuna quantità" senza far rileggere.

---

## 5. Marchio / logo — DEFINITIVO

**Concetto.** Una "F" costruita come **forchetta vista di lato**: il manico è l'asta verticale, i **quattro rebbi** sono quattro barre orizzontali che escono verso destra. I quattro rebbi richiamano la base-4 persone dell'app. Il manico termina con una **curva morbida verso sinistra**, come una forchetta "piegata con la mente" (strizzata d'occhio alla scena del cucchiaio di Matrix).

**Costruzione definitiva (variante approvata):**
- **Quattro barre orizzontali** sottili e ravvicinate, con estremità arrotondate, in alto.
- **Manico** = asta verticale che parte in cima e prosegue **nuda** sotto le barre fino alla linea di base, poi **curva a sinistra** con punta arrotondata (`stroke-linecap: round`). Niente "cappuccio" arrotondato in cima: il bordo superiore è netto.
- **Allineamento verticale (nel wordmark):** il **secondo rebbio dal basso** è allineato all'altezza della "k". La F si alza di poco sopra le minuscole (presenza da iniziale), il tratto di manico nudo sotto le barre ne rende netta la silhouette di F.
- **Spessore dei tratti:** pari a quello delle lettere di "orkast" (la F appartiene alla stessa famiglia, nessuno stacco di peso).
- **Colore:** `primary` corallo. Versione icona app: marchio in **bianco** su tile `primary` arrotondata.

**Wordmark.** F-forchetta come iniziale + "orkast" in minuscolo, peso 500, colore `ink`. La F è **agganciata a "orkast"** con la stessa spaziatura naturale delle altre lettere (niente spazio extra). Il manico curvo a sinistra fa da piccola coda sotto la F.

**Posizionamento.** Wordmark **sempre in alto a sinistra** in ogni schermata (requisito esplicito del committente).

**Regola d'uso.** Il marchio **nudo** (senza "orkast") legge come F solo dove il contesto rende ovvio che è Forkast. Altrove usare il **wordmark completo** o l'**icona-tile**. Versione extra-compatta (favicon, righe strette): in alternativa esiste una variante con tutta la F all'altezza della "k" — non è quella scelta per il wordmark, ma è il fallback se serve massima compattezza.

**Asset consegnati (SVG, scalabili):**
- `forkast-wordmark.svg` — wordmark completo.
- `forkast-mark.svg` — marchio da solo.
- `forkast-app-icon.svg` — icona app, marchio bianco su tile corallo 512×512.

**Note di produzione:**
- In `forkast-wordmark.svg` il testo "orkast" è un `<text>` in font sans: **convertirlo in tracciati (outline)** con il font di brand scelto per un rendering identico ovunque.
- Per la submission store: iOS applica la propria maschera (fornire un quadrato full-bleed); Android adaptive icon richiede foreground/background separati (area sicura ~66%).
- I tratti del manico hanno `stroke-linecap: round`; la curva è un singolo tracciato, facilmente regolabile in ampiezza.

---

## 6. Note schermata per schermata

### Barra superiore (globale)
Wordmark Forkast in alto a sinistra; icona impostazioni in alto a destra. Barra di navigazione a tre voci in basso (Piatti / Piano / Lista), ognuna con icona + testo; voce attiva in `primary`.

### Catalogo piatti (FR-1, FR-15)
- Barra di ricerca **sempre visibile** in cima (con 50+ piatti la ricerca è il mezzo primario, non una lente nascosta).
- Filtri-tag come chip orizzontali scorrevoli sotto la ricerca.
- Riga piatto: nome in evidenza (`ink` 500), tag (portata + attributi) come chip colorate piccole sotto.
- Predisporre lo spazio a destra per future micro-icone difficoltà/tempo.

### Editor piatto (FR-1, 2, 3, 6, 14)
- Schermata più densa → la più a rischio. Raggruppare in sezioni separate da aria: *Nome e tag* → *Ingredienti (base 4)*.
- Promemoria **persistente** "le quantità sono per 4 persone" sotto il titolo della sezione ingredienti (nota tenue, non tooltip che sparisce: il concetto è controintuitivo e va ricordato sempre).

### Piano settimanale (FR-7, 9, 19, 20)
- Mostrare i **nomi reali dei piatti** in ciascuna giornata, non un conteggio ("Lun · Hamburger, Insalata" >> "2 piatti").
- Giorno corrente evidenziato.
- Bottone "Copia settimana precedente" prominente **solo quando la settimana è vuota**; altrimenti si ritira nel menu.

### Lista della spesa (FR-10, 11, 12, 21)
- **Schermata-vetrina.** Raggruppata per reparto con intestazioni sticky.
- Spunte con feedback soddisfacente: riga attenuata + barrata quando spuntata, così l'occhio salta a ciò che manca.
- Avviso "Aggiorna" (FR-21) come **banner tenue** in cima (colore `warning`), non pop-up invadente: informa, non interrompe.
- Segno distintivo sulle **voci manuali** vs righe generate (chiarisce cosa sopravvive alla rigenerazione — strato a due livelli, ADR-004).

---

## 7. Microcopy e tono

Il tono dei testi è parte dell'estetica. Forkast è caldo, non burocratico.
- Stati vuoti con una frase calda invece del vuoto. Es. lista vuota: *"Ancora niente in lista. Pianifica qualche cena e ci penso io."*
- Tagline di marchio: *"Pianifica le cene, salta i pensieri."*

---

## 8. Decisioni

| Tema | Stato |
| --- | --- |
| Colore primario corallo `#D85A30` | **Confermato** |
| Costruzione e altezza del logo | **Confermato** (variante 2: secondo rebbio a livello della «k») |
| Direzione curva del manico | **Confermato** (sinistra) |
| Icone per reparto | `[Dipendenza]` Richiede l'attributo categoria su `ingredient` (oggi assente — ADR §7) |

---

*Forkast — Design Brief v0.2*
