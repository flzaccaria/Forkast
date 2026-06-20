# Forkast — Setup Guide

How to go from zero to running the app on your phone.

## Prerequisites

- Flutter SDK (stable channel, 3.x)
- A physical device or emulator (iOS Simulator / Android Emulator)
- For iOS: Xcode + CocoaPods; for Android: Android Studio + SDK

---

## 1. Supabase (backend)

1. Create a new project at [supabase.com](https://supabase.com).
   **Choose the EU region** (required by ADR-008).

2. **Run the migrations** in order. Go to **SQL Editor** and paste each file:

   ```
   supabase/migrations/00001_initial_schema.sql
   supabase/migrations/00002_pairing.sql
   supabase/migrations/00003_ingredient_category.sql
   ```

   Alternatively, if you have the Supabase CLI linked to the project:
   ```bash
   supabase db push
   ```

3. **Enable anonymous sign-in**:
   Dashboard → Authentication → Providers → Anonymous Sign-Ins → **Enable**.

4. **Note down** two values from Settings → API:
   - **Project URL**: `https://<project-ref>.supabase.co`
   - **anon / publishable key**: `eyJ...`

5. **Optional but recommended**: reduce WAL size for a small project.
   SQL Editor:
   ```sql
   ALTER SYSTEM SET max_wal_size = '512MB';
   SELECT pg_reload_conf();
   ```

---

## 2. PowerSync (sync layer)

1. Create an account at [powersync.com](https://powersync.com) and create a
   new instance.

2. **Connect to Supabase Postgres**:
   - Go to your Supabase project → Settings → Database → Connection string
     (URI format).
   - Paste it in the PowerSync instance connection settings.

3. **Upload sync rules**: copy the content of `powersync/sync-rules.yaml`
   into the PowerSync instance's Sync Rules editor and deploy.

4. **Configure authentication** (JWT):
   - In PowerSync → instance → Client Auth, select **Supabase** as the auth
     provider.
   - Use JWKS mode and point it to:
     ```
     https://<project-ref>.supabase.co/auth/v1/jwks
     ```
   - See `docs/auth_jwt_migration.md` for full details on asymmetric JWT setup.

5. **Note down** the PowerSync URL:
   `https://<instance-id>.powersync.journeyapps.com`

---

## 3. Run the app

### Install dependencies

```bash
cd Forkast
flutter pub get
```

### Run on a connected device or emulator

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=POWERSYNC_URL=https://<instance-id>.powersync.journeyapps.com
```

### Tip: use a launch configuration

To avoid typing `--dart-define` every time:

**VS Code** (`.vscode/launch.json`):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Forkast",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://<project-ref>.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=eyJ...",
        "--dart-define=POWERSYNC_URL=https://<instance-id>.powersync.journeyapps.com"
      ]
    }
  ]
}
```

**Android Studio**: Run → Edit Configurations → Additional run args → paste
the three `--dart-define` flags.

---

## 4. Pair a second device

Once the app is running on the first phone:

1. Open **Settings → Pair device** on the first phone. A 6-digit code and a QR code appear.
2. On the second phone, run the app with the same `--dart-define` values.
3. The second phone can either **scan the QR** with the system camera (opens the PWA with the code pre-filled) or **type the 6-digit code** manually in the pairing screen.
4. The second device joins the first's household. Data syncs automatically.

> The QR encodes the PWA URL with `?code=<6 digits>` (e.g. `https://your-app.pages.dev?code=123456`). This requires `APP_URL` to be set via `--dart-define`. Without it, the QR contains only the raw code.

---

## 5. Build a release (when ready)

### Android (APK / App Bundle)

```bash
flutter build appbundle \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=POWERSYNC_URL=...
```

The `.aab` is at `build/app/outputs/bundle/release/`.

### iOS

```bash
flutter build ipa \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=POWERSYNC_URL=...
```

Requires an Apple Developer account and provisioning profile.

---

## Checklist

- [ ] Supabase project created (EU region)
- [ ] Migrations applied (00001, 00002, 00003)
- [ ] Anonymous sign-in enabled
- [ ] PowerSync instance created and connected to Supabase
- [ ] Sync rules deployed
- [ ] JWT auth configured (JWKS mode)
- [ ] App runs on first device
- [ ] Second device paired successfully
- [ ] Sync working (changes on one device appear on the other)
