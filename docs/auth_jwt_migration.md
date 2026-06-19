# JWT Migration: from shared secret (legacy) to asymmetric keys (JWKS)

> Open point from `CLAUDE.md`: both Supabase and PowerSync flag the old
> **shared JWT secret (HS256)** mechanism as deprecated. This is a
> **configuration** migration (Supabase dashboard + PowerSync instance):
> it **requires no changes to the app code**. To be done before release.

## Why

- The legacy mechanism signs JWTs with a **shared symmetric secret (HS256)**:
  whoever holds the secret can both sign and verify tokens.
- The new mechanism uses **asymmetric keys (ES256)**: Supabase signs with the
  private key; anyone verifies with the **public key** exposed via the
  **JWKS** endpoint (`https://<project-ref>.supabase.co/auth/v1/jwks`). No
  secret to share with PowerSync.
- Since **October 1, 2025** new Supabase projects use asymmetric JWTs by
  default; existing projects migrate whenever they want. The two systems can
  **coexist** during the transition (the JWKS also includes the old secret as a
  symmetric JWK, so old tokens remain verifiable).

## Why the app code does not change

- `SupabaseConnector.fetchCredentials()` passes the `session.accessToken` to
  PowerSync as-is. Token verification happens **on the PowerSync side** via
  JWKS: it is independent of the signing algorithm.
- `Supabase.initialize(... publishableKey: ...)` already uses the new key API
  (publishable key), not the old `anonKey`.
- **Anonymous** sign-in keeps working: only *how* the token is signed and
  verified changes, not *how* it is issued.

## Steps (dashboard only)

1. **Supabase → Project Settings → JWT**: check which key type is in use.
2. **Create/enable the asymmetric signing key** (ES256) and import the legacy
   secret, so tokens already issued remain valid during the transition.
3. **PowerSync → instance → Client Auth**: configure Supabase authentication in
   **asymmetric/JWKS** mode (PowerSync fetches the public keys from the
   project's JWKS endpoint). Remove the shared JWT secret once it is no longer
   needed.
4. **Rotation**: complete the **"Rotate to asymmetric JWTs"** step on Supabase.
   ⚠️ Skipping this step leaves the migration incomplete and causes
   **authentication failures**.
5. **Verification**: launch the app on a clean device (new anonymous session),
   check in *Settings → Sync* that the status reaches "Connected" and that no
   download/upload errors appear.

## Notes

- Keep an eye on the JWKS endpoint: if the keys rotate, PowerSync re-downloads
  them automatically. No manual action on the client.
- References: Supabase "JWT Signing Keys" and PowerSync "Supabase Auth".
