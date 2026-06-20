# Mappa dei flussi e delle schermate — App Menu Settimanale & Lista della Spesa

*v1.0 • 17 giugno 2026 • Complementare ai Requisiti Funzionali v0.3*

## 1. Scopo

Questo documento è l'indice navigabile delle schermate progettate per l'app e delle loro connessioni. Accompagna i Requisiti Funzionali v0.3: i requisiti dicono cosa l'app deve fare, questa mappa dice dove e come ci si muove tra le schermate.

## 2. Aree e navigazione principale

L'app si articola in tre sezioni, raggiungibili da una barra a tre voci in basso: **Piatti**, **Piano**, **Lista**. Una quarta area, **Impostazioni**, contiene la configurazione e la gestione dei cataloghi (ingredienti e tag) ed è raggiungibile dall'icona impostazioni. In questa versione si gestiscono solo le cene.

## 3. Inventario delle schermate

| Area | Schermata | Scopo | Requisiti |
| --- | --- | --- | --- |
| Piatti | Catalogo piatti | Elenco, ricerca per nome, filtri a tag | FR-1, FR-15 |
| Piatti | Editor piatto | Nome, portata e attributi, ingredienti in base 4, q.b. | FR-1, 2, 3, 6, 14 |
| Piatti | Selettore ingrediente | Ricerca nel catalogo condiviso | FR-3, 4, 5 |
| Piatti | Nuovo ingrediente | Crea voce: nome, unità, q.b. | FR-4, 5, 6 |
| Piano | Piano settimanale | Settimana di cene; copia settimana precedente | FR-7, 9, 19, 20 |
| Piano | Cena del giorno | Commensali per serata (default sovrascrivibile) e piatti | FR-8, 9 |
| Piano | Selezione piatto | Catalogo in selezione multipla (riusa Catalogo piatti) | FR-7 |
| Lista | Lista della spesa | Voci aggregate, riscalo, q.b., spunte, avviso rigenerazione | FR-10, 11, 12, 21 |
| Lista | Aggiungi / Modifica voce | Aggiunta manuale e override con ripristino | FR-13, 21 |
| Impostazioni | Impostazioni | Default commensali, inizio settimana, rigenerazione auto, promemoria, tema, lingua, sync | FR-8, 20, 21 |
| Impostazioni | Gestione ingredienti | Lista, modifica (unità bloccata), unione, eliminazione protetta | FR-4, 5, 16, 17, 18 |
| Impostazioni | Gestione tag | Portata e attributi, utilizzo, riordino | FR-14 |

## 4. Mappa di navigazione

### Piatti

- Catalogo piatti → Editor piatto (tocca un piatto o "+ nuovo").
- Editor piatto → Selettore ingrediente ("+ aggiungi ingrediente") → Nuovo ingrediente ("crea nuovo").
- Ritorni: il Selettore conferma e torna all'Editor; l'Editor salva e torna al Catalogo.

### Piano

- Piano settimanale → Cena del giorno (tocca un giorno).
- Cena del giorno → Selezione piatto ("+ aggiungi piatto"), che riusa il Catalogo piatti in modalità a scelta multipla.
- Scorciatoia: "Copia la settimana precedente" dal Piano — in evidenza quando la settimana è vuota, sempre disponibile dal menu.

### Lista

- Lista della spesa → Aggiungi / Modifica voce ("+ aggiungi voce" o tocca una riga).
- Quando il piano cambia, un avviso "Aggiorna" rigenera le righe derivate; le voci manuali e le spunte restano.

### Impostazioni

- Impostazioni → Gestione ingredienti e Gestione tag (sezione Cataloghi).
- Raggiungibile dall'icona impostazioni; non fa parte della barra a tre sezioni.

## 5. Connessioni trasversali

- Il **Catalogo piatti** è riusato dalla Selezione piatto del Piano: stessa lista, in modalità a scelta multipla.
- Il **Selettore ingrediente** è riusato ovunque si compongano i piatti.
- Il **Piano** alimenta la **Lista**: la lista si genera dal piano tramite riscalo e aggregazione.
- Le **Impostazioni** forniscono i valori predefiniti usati altrove (commensali, inizio settimana, rigenerazione automatica).

## 6. Registro delle decisioni di design

- Nell'Editor le quantità sono sempre in base 4; i commensali reali si impostano nel Piano (separazione dei due momenti).
- Tag in due gruppi con colori distinti: portata (singola, facoltativa) e attributi (multipla); vocabolario curato.
- L'unità appartiene all'ingrediente ed è bloccata dopo l'uso: si modifica la quantità, non l'unità.
- Ingrediente "quanto basta": nessuna quantità, non riscalato.
- Lista a due strati: righe generate (ricalcolabili) e strato manuale (persistente); override reversibile; rigenerazione su richiesta per impostazione predefinita.
- Eliminazioni protette quando una voce è in uso; unione doppioni solo a parità di unità.
- "Copia settimana precedente" copia piatti e commensali, non la lista.

## 7. Punti aperti residui

- Rimozione di un tag in uso: proteggere oppure "scollega dai piatti".
- Obbligatorietà della portata: proposta attuale, facoltativa.
- Ordinamento della lista per reparto: richiederebbe una categoria sugli ingredienti, oggi assente.
- "Copia settimana" su una settimana non vuota: sostituire, unire o bloccare.
- Crescita del vocabolario dei tag: curato oppure con aggiunte libere.
