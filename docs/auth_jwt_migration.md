# Migrazione JWT: da secret condiviso (legacy) a chiavi asimmetriche (JWKS)

> Punto aperto di `CLAUDE.md`: sia Supabase sia PowerSync segnalano come
> deprecato il vecchio meccanismo a **secret JWT condiviso (HS256)**. Questa è
> una migrazione di **configurazione** (dashboard Supabase + istanza PowerSync):
> **non richiede modifiche al codice dell'app**. Da fare prima del rilascio.

## Perché

- Il meccanismo legacy firma i JWT con un **secret simmetrico condiviso (HS256)**:
  chi possiede il secret può sia firmare sia verificare i token.
- Il nuovo meccanismo usa **chiavi asimmetriche (ES256)**: Supabase firma con la
  chiave privata; chiunque verifica con la **chiave pubblica** esposta via
  endpoint **JWKS** (`https://<project-ref>.supabase.co/auth/v1/jwks`). Niente
  secret da condividere con PowerSync.
- Dal **1° ottobre 2025** i nuovi progetti Supabase usano JWT asimmetrici di
  default; i progetti esistenti migrano quando vogliono. I due sistemi possono
  **coesistere** durante la transizione (il JWKS include anche il vecchio secret
  come JWK simmetrico, così i token vecchi restano verificabili).

## Perché il codice dell'app non cambia

- `SupabaseConnector.fetchCredentials()` passa a PowerSync il
  `session.accessToken` così com'è. La verifica del token avviene **lato
  PowerSync** tramite JWKS: è indipendente dall'algoritmo di firma.
- `Supabase.initialize(... publishableKey: ...)` usa già la nuova API delle
  chiavi (publishable key), non la vecchia `anonKey`.
- Il sign-in **anonimo** continua a funzionare: cambia solo *come* il token è
  firmato e verificato, non *come* viene emesso.

## Passi (solo dashboard)

1. **Supabase → Project Settings → JWT**: verifica quale tipo di chiave è in uso.
2. **Crea/abilita la chiave di firma asimmetrica** (ES256) e importa il secret
   legacy, così i token già emessi restano validi durante la transizione.
3. **PowerSync → istanza → Client Auth**: configura l'autenticazione Supabase in
   modalità **asimmetrica/JWKS** (PowerSync recupera le chiavi pubbliche
   dall'endpoint JWKS del progetto). Rimuovi il secret JWT condiviso quando non
   serve più.
4. **Rotazione**: completa lo step **"Rotate to asymmetric JWTs"** su Supabase.
   ⚠️ Saltare questo passo lascia la migrazione incompleta e provoca **fallimenti
   di autenticazione**.
5. **Verifica**: avvia l'app su un dispositivo pulito (nuova sessione anonima),
   controlla in *Impostazioni → Sincronizzazione* che lo stato vada a "Connesso"
   e che non compaiano errori di download/upload.

## Note

- Tieni d'occhio l'endpoint JWKS: se le chiavi ruotano, PowerSync le ri-scarica
  automaticamente. Nessuna azione manuale sul client.
- Riferimenti: Supabase "JWT Signing Keys" e PowerSync "Supabase Auth".
