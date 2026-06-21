# Household bootstrap via SECURITY DEFINER

## Problem

The original bootstrap flow inserted `household` + `membership` rows locally
in drift and relied on PowerSync to upload them to Supabase. This caused a
**403 on the `household` table** because RLS policies filter by membership —
and the device is not yet a member of any household at that point
(chicken-and-egg).

## Solution

Household creation now goes through a server-side `SECURITY DEFINER` function
(`bootstrap_household`, migration `00006`), the same pattern used for device
pairing (`create_pairing_code` / `redeem_pairing_code`, migration `00002`).

The function:

1. Reads `auth.uid()` from the anonymous JWT.
2. Checks if the device already has a membership → returns the existing
   `household_id` (idempotent).
3. Otherwise creates `household` + `membership` atomically under elevated
   privileges, bypassing RLS.

The rows then arrive on the device via PowerSync sync (read path, not write).

## Client flow (`lib/data/bootstrap.dart`)

```
ensureAnonAuth()          — anonymous sign-in (cached after first launch)
ensureHousehold(db, id)   — 1. check local DB (offline-fast path)
                            2. if not found → rpc('bootstrap_household')
                            3. return household_id
powerSyncDb.connect()     — starts sync; household/membership arrive via read
```

- **First launch**: requires network (auth + RPC). PowerSync syncs the rows
  down afterwards.
- **Subsequent launches**: membership exists locally → returned immediately,
  no network needed.
- **Network failure after auth**: `BootstrapException` is thrown; the error
  screen tells the user to check connectivity and restart. The RPC is
  idempotent, so retry is safe.
- **`not_authenticated`**: separate error message; the session may have expired
  or been revoked.

## Why not local-first for bootstrap?

The household is the authorization boundary (ADR-005). Creating it requires a
privileged write that RLS intentionally blocks for unauthenticated devices.
This is the same reason pairing uses `SECURITY DEFINER` functions. All
subsequent data operations (ingredients, dishes, plans, lists) are local-first
as before.
