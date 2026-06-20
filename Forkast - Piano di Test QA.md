# Forkast — Piano di Test (QA)

**App Menu Settimanale & Lista della Spesa — versione web**

_Versione 0.4  ·  20 giugno 2026  ·  Complementare a Requisiti v0.5, Mappa flussi v1.1, ADR v1.1_

## 1. Scopo e ambiente di test

Questo piano elenca i casi di test per validare la versione web di Forkast rispetto ai requisiti funzionali (FR-1…FR-22), alle regole di calcolo e alle decisioni architetturali. Ogni caso indica cosa verificare, i passi e il risultato atteso; usare la colonna esito per annotare pass/fail e i difetti trovati.

Priorità di questa fase, in ordine: (1) correttezza dei calcoli — riscalo e aggregazione; (2) lista a due strati — override, ripristino, avviso di rigenerazione; (3) sincronizzazione tra i due telefoni per l'uso simultaneo. L'uso offline al supermercato è stato deprioritizzato per scelta consapevole: dove si fa la spesa il segnale è affidabile, quindi i relativi casi restano come verifiche opzionali, non bloccanti. In ambra i casi ad alta priorità.

Legenda priorità: **Alta** = eseguire per primo · **Bassa** = verifica opzionale · — = standard.

## 2. Gestione dei piatti

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-01 | — | Crea un piatto con nome, una portata, più attributi e 3+ ingredienti scelti dal catalogo. | Il piatto compare nel catalogo; ingredienti e quantità (base 4) sono salvati. (FR-1, 3, 14) |
| TC-02 | — | Modifica un piatto già usato in una settimana: cambia un ingrediente e una quantità. | Le modifiche persistono; se la lista di quella settimana era generata, compare l'avviso "Aggiorna". (FR-1, 21) |
| TC-03 | — | Elimina un piatto non assegnato ad alcun piano. | Eliminazione consentita; il piatto sparisce dal catalogo. (FR-1) |
| TC-04 | — | Crea "Hamburger" base 4: 4 panini, 600 g carne, 4 pomodori freschi, sale q.b. | Quantità memorizzate in base 4; il sale è marcato "quanto basta", senza quantità. (FR-2, 6) |

## 3. Catalogo degli ingredienti

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-05 | — | Crea un ingrediente con la sua unità e usalo in due piatti diversi. | È la stessa voce di catalogo in entrambi i piatti. (FR-4) |
| TC-06 | — | Marca un ingrediente come "quanto basta". | Compare senza campo quantità; non verrà riscalato. (FR-6) |
| TC-07 | — | Prova a cambiare l'unità di un ingrediente già usato in un piatto. | L'azione è bloccata o non disponibile. (FR-16) |
| TC-08 | — | Prova a eliminare un ingrediente usato in uno o più piatti. | Eliminazione protetta; la schermata mostra dove è usato. (FR-17) |
| TC-09 | — | Unisci due voci doppione: una volta con stessa unità, una volta con unità diverse. | Unione riuscita a parità di unità; impedita se le unità differiscono. (FR-18) |

## 4. Pianificazione settimanale

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-10 | — | Assegna più piatti alla stessa cena. | Tutti i piatti compaiono per quel giorno. (FR-7) |
| TC-11 | — | Imposta il default commensali a N nelle impostazioni, poi pianifica una cena. | Il valore N viene proposto automaticamente. (FR-8) |
| TC-12 | — | Sovrascrivi i commensali di una singola serata. | Vale per tutti i piatti di quella sera; il default globale resta invariato. (FR-8) |
| TC-13 | — | Assegna lo stesso piatto a due giorni con commensali diversi (es. 6 e 2). | Le due assegnazioni coesistono con numeri distinti. (FR-9) |
| TC-14 | — | "Copia settimana precedente" su una settimana vuota. | Copia piatti e commensali, non la lista (che si rigenera dal piano). (FR-19) |
| TC-15a | — | "Copia settimana precedente" su una settimana NON vuota — scegli **Sostituisci**. | L'app chiede la scelta tra "Sostituisci" e "Aggiungi". Scegliendo "Sostituisci": il piano esistente viene cancellato e rimpiazzato con piatti e commensali della settimana precedente. (FR-19) |
| TC-15b | — | "Copia settimana precedente" su una settimana NON vuota — scegli **Aggiungi**. | L'app chiede la scelta tra "Sostituisci" e "Aggiungi". Scegliendo "Aggiungi": i piatti della settimana precedente vengono accodati ai piatti già presenti, giorno per giorno; i commensali preesistenti non cambiano. (FR-19) |
| TC-16 | — | Cambia l'inizio settimana (lunedì/domenica) nelle impostazioni. | La griglia del piano si riallinea correttamente. (FR-20) |

## 5. Lista della spesa: generazione, riscalo, aggregazione

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-17 | — | Genera la lista a partire da un piano con più cene. | Compaiono le righe derivate dal piano. (FR-10) |
| TC-18 | Alta | Oracolo: Hamburger per 6 (lunedì) + Insalata mista per 2 (mercoledì), entrambi con "pomodori freschi". | Riga unica "pomodori freschi: 7" (6 da hamburger + 1 da insalata); carne 600 g × 1,5 = 900 g; sale q.b. senza quantità. (FR-11, 12) |
| TC-19 | Alta | Arrotondamento di un prodotto a pezzo intero: 1 insalata × 1,5. | Arrotondato per eccesso a 2, in modo coerente (regola deterministica). (§5 ADR) |
| TC-20 | — | Ingrediente "quanto basta" presente in più piatti della settimana. | Compare una sola volta, senza quantità, indipendentemente dai commensali. (FR-6) |

## 5a. Arrotondamento per rounding_kind e granularità (C1/C3)

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-43 | Alta | Crea un ingrediente "uovo" con unità "uovo" e rounding_kind **whole**. Piatto con 1 uovo base 4, cena per 6 persone. Genera la lista. | La lista mostra **2 uova** (1 × 1,5 = 1,5 → ↑ 2), non "1,5 uova". |
| TC-44 | — | Crea un ingrediente "vasetto" con rounding_kind **whole**. Piatto con 3 vasetti base 4, cena per 2 persone. | La lista mostra **2 vasetti** (3 × 0,5 = 1,5 → ↑ 2). Il downscaling arrotonda comunque per eccesso. |
| TC-45 | — | Crea ingredienti con rounding_kind **whole** per unità prima fuori dall'allowlist: barattolo, lattina, confezione, mazzo. Piatto con 1 di ciascuno base 4, cena per 6. | Tutti mostrano **2** (1 × 1,5 → ↑ 2). |
| TC-46 | Alta | Crea un ingrediente "carne macinata" con unità "g" e rounding_kind **weight**. Piatto con 600 g base 4, cena per 7 persone. | La lista mostra **1.050 g** (600 × 1,75 = 1050 → esatto, multiplo di 10). Non "1050,5 g" o "1050,0 g". |
| TC-47 | — | Carne 600 g base 4, cena per 3 persone (× 0,75 = 450 g). | La lista mostra **450 g** (esatto, multiplo di 10). |
| TC-48 | — | Ingrediente "latte" con unità "ml" e rounding_kind **volume**. Piatto con 500 ml base 4, cena per 3 persone. | La lista mostra **380 ml** (500 × 0,75 = 375 → ↑ 380, al 10 superiore). |
| TC-49 | — | Ingrediente con unità "kg" e rounding_kind **weight**. Piatto con 1 kg base 4, cena per 5 persone. | La lista mostra **1,3 kg** (1 × 1,25 = 1,25 → ↑ 1,3, a 0,1 superiore). Non "1,5 kg". |
| TC-50 | — | Ingrediente con unità "l" e rounding_kind **volume**. Piatto con 0,5 l base 4, cena per 5 persone. | La lista mostra **0,7 l** (0,5 × 1,25 = 0,625 → ↑ 0,7). |

## 5b. Formattazione locale delle quantità (C2)

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-42 | — | Verifica la formattazione locale delle quantità nella lista e nell'editor piatto. Crea un piatto con 600 g di carne e 1,5 pz di un ingrediente, genera la lista per 6 persone. | Le quantità usano la virgola come separatore decimale (es. "1,5" non "1.5") e non mostrano zeri finali (es. "900" non "900,0"). La formattazione è coerente tra lista generata, voci manuali e editor piatto. |
| TC-51 | — | Genera la lista con un ingrediente che produce una quantità decimale (es. 1,3 kg). | Il separatore decimale è la virgola ("1,3 kg"); nessun punto ("1.3 kg") né trailing zero ("1,30 kg"). |
| TC-52 | — | Genera la lista con una quantità ≥ 1000 (es. 1050 g). | Mostrata come "1.050 g" (punto per le migliaia, virgola per i decimali, locale it_IT). |

## 5c. Raggruppamento per reparto (FR-22)

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-53 | — | Genera la lista con ingredienti assegnati a reparti diversi (es. Ortofrutta, Macelleria, Dispensa). | La lista è raggruppata per reparto con intestazioni; l'ordine segue il percorso nel negozio (Ortofrutta → Macelleria → … → Altro). (FR-22) |
| TC-54 | — | Genera la lista con un ingrediente il cui reparto è **null** (non assegnato). | L'ingrediente compare in coda, sotto l'intestazione "Senza reparto", dopo tutti i reparti incluso "Altro". (FR-22) |
| TC-55 | — | Crea un ingrediente con reparto **Altro** e un altro senza reparto. Genera la lista. | "Altro" compare nella sua posizione nell'ordine dei reparti (in fondo alla lista fissa); "Senza reparto" compare dopo "Altro", come ultimo gruppo. I due gruppi sono distinti. (FR-22) |
| TC-56 | — | All'interno di un reparto, verifica l'ordine degli ingredienti. | Ordinati alfabeticamente per nome all'interno di ogni gruppo. (FR-22) |

## 6. Lista a due strati: override, ripristino, rigenerazione

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-21 | Alta | Aggiungi una voce manuale alla lista. | Persiste come riga separata, additiva. (FR-13) |
| TC-22 | Alta | Override di una riga generata: cambia la quantità o rimuovila. | La modifica persiste e compare il comando "ripristina". (FR-13, 21) |
| TC-23 | Alta | Premi "ripristina" su una riga overridden. | La riga torna al valore calcolato dal piano. (FR-21) |
| TC-24 | Alta | Spunta alcune voci; poi cambia il piano e premi "Aggiorna". | Le righe generate si ricalcolano; spunte e voci manuali sopravvivono. (FR-21) |
| TC-25 | Alta | Con rigenerazione automatica OFF (default): cambia il piano dopo aver generato la lista. | Compare l'avviso "Aggiorna"; la lista NON cambia finché non lo premi. (FR-21) |
| TC-26 | — | Abilita la rigenerazione automatica nelle impostazioni, poi cambia il piano. | La lista si aggiorna da sola. (FR-21) |

## 7. Tag e ricerca del catalogo

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-27 | — | Assegna a un piatto una portata (singola) e più attributi. | Portata unica, attributi multipli; gruppi con colori distinti. (FR-14) |
| TC-28 | — | Cerca un piatto per nome e filtra il catalogo per tag. | Ricerca e filtri funzionano; restano usabili con 50+ piatti. (FR-15) |
| TC-29 | — | Prova a rimuovere un tag attualmente in uso su dei piatti. | Verifica il comportamento deciso (protetto oppure "scollega dai piatti") — punto aperto da confermare. |

## 8. Sincronizzazione tra dispositivi

_La sincronizzazione tra i due telefoni serve per l'uso simultaneo (uno aggiunge un piatto, l'altro lo vede) e resta rilevante. I casi puramente offline sono a bassa priorità: dove si fa la spesa il segnale è affidabile._

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-30a | Alta | Abbina il secondo dispositivo **digitando a mano** il codice a 6 cifre mostrato dal primo. | Il secondo dispositivo entra nell'household e vede gli stessi dati. (ADR-006) |
| TC-30b | Alta | Abbina il secondo dispositivo **inquadrando il QR** con la fotocamera di sistema. | La fotocamera riconosce la URL (`https://<APP_URL>?code=123456`), apre la PWA, il campo codice è precompilato e il tab "Inserisci codice" è attivo. L'utente preme "Unisciti" e il dispositivo entra nell'household. (ADR-006) |
| TC-30c | — | Apri direttamente la URL `https://<APP_URL>?code=123456` nel browser (senza fotocamera). | La PWA si apre, il tab "Inserisci codice" è attivo, il campo codice è precompilato con il valore del parametro `code`. (ADR-006) |
| TC-31 | Alta | Modifica un dato su un dispositivo e osserva l'altro dopo la sync. | La modifica si propaga; i due dispositivi convergono. (ADR-002) |
| TC-32 | Bassa | (bassa priorità) Metti un dispositivo offline, spunta voci e aggiungi una voce manuale, poi riconnetti. | Le modifiche offline persistono e si risincronizzano; nulla va perso. |
| TC-33 | Bassa | (bassa priorità) Conflitto: modifica la stessa riga su due dispositivi entrambi offline, poi riportali online. | Riconciliazione last-write-wins; nessun dato corrotto; aggiunte concorrenti (UUID) coesistono. (ADR-003) |
| TC-34 | — | Genera lo snapshot della lista su un dispositivo e controlla l'altro. | L'altro dispositivo vede lo stesso snapshot; nessuna divergenza di arrotondamento. (ADR-004) |

## 8a. Pairing: casi di errore e QR (ADR-006, B1)

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-57 | — | Inserisci un codice a 6 cifre **errato** (non generato da nessuno) nel tab "Inserisci codice". | Errore "Codice non valido o scaduto." L'utente resta nella schermata e può riprovare. |
| TC-58 | — | Genera un codice sul primo dispositivo, **aspetta oltre la scadenza** (countdown a 00:00), poi inseriscilo sull'altro. | Errore "Codice non valido o scaduto." Il primo dispositivo mostra il codice sparito (countdown esaurito). |
| TC-59 | — | Prova ad abbinare un dispositivo che **ha già dati propri** (piatti o ingredienti creati) a un altro household. | Errore "Questo dispositivo ha già dati propri: l'abbinamento li scarterebbe." L'operazione è bloccata. |
| TC-60 | — | Verifica il **QR code** generato nel tab "Mostra codice": il codice e il QR compaiono insieme, con il countdown. | Il QR è visibile sotto il codice numerico; entrambi scompaiono quando il countdown raggiunge 00:00. |
| TC-61 | — | Il countdown del codice riflette la scadenza del server (non un valore hardcoded). Genera un codice e verifica che il countdown parta da ~10:00. | Il countdown parte dal valore restituito dal server (≈ 10:00, non esattamente 600 secondi hardcoded). |

## 9. Specifici della versione web

_Casi introdotti dal passaggio a web app. La persistenza dei dati a un refresh (TC-38) va verificata a prescindere dal segnale; il caricamento offline (TC-35) resta opzionale, coerente con la scelta sul segnale._

| ID | Priorità | Cosa testare / passi | Esito atteso |
| --- | --- | --- | --- |
| TC-35 | Bassa | (bassa priorità) Apri l'app, attiva la modalità aereo e ricarica la pagina. | L'app si carica comunque (PWA/service worker) e la lista resta consultabile. |
| TC-36 | — | Aggiungi l'app alla schermata Home del telefono e aprila da lì. | Si apre a tutto schermo come un'app; funziona normalmente. |
| TC-37 | — | Apri l'app in due schede contemporaneamente e modifica in entrambe. | Comportamento coerente, nessuna perdita di dati. |
| TC-38 | Alta | Modifica dati in locale, poi fai un refresh della pagina. | I dati locali persistono al reload; non si azzerano. |
| TC-39 | — | Su iPhone (Safari): apri dalla schermata Home e controlla barra di stato e titolo. | Aspetto corretto (i meta apple-mobile-web-app sono presenti nel build). |

## 10. Punti aperti da chiudere con il QA

- ~~"Copia settimana precedente" su settimana non vuota: confermare se sostituisce, unisce o blocca (TC-15).~~ → Risolto: l'utente sceglie tra sostituisci e aggiungi (TC-15a/TC-15b).
- Rimozione di un tag in uso: protetta oppure "scollega dai piatti" (TC-29).
- Persistenza dei dati locali al refresh della pagina (TC-38): da verificare a prescindere dal segnale.
- Uso offline: deprioritizzato per scelta (segnale affidabile dove si fa la spesa); TC-32, TC-33 e TC-35 restano come verifiche opzionali.
