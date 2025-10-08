# Supabase Setup for Vaccine Tracker MVP

## Option 1: Supabase Cloud (Recommended for MVP)

1. **Create Account**:
   - Go to [https://supabase.com](https://supabase.com)
   - Sign up for free account

2. **Create Project**:
   - Click "New Project"
   - Name: `vaccine-tracker-mvp`
   - Database Password: (choose strong password)
   - Region: Choose closest to your location
   - Click "Create new project" (wait 1-2 minutes)

3. **Get Credentials**:
   - Go to Settings → API
   - Copy:
     - `Project URL` (e.g., https://xxxxx.supabase.co)
     - `anon public` key
   - Save these for later (needed in web/.env.local and mobile config)

4. **Run Migration**:
   ```bash
   # Install Supabase CLI first if not installed
   brew install supabase/tap/supabase  # macOS
   # OR
   npm install -g supabase             # npm

   # Link to your project
   supabase link --project-ref YOUR_PROJECT_REF

   # Push migration to cloud
   supabase db push
   ```

5. **Verify Setup**:
   - Go to Table Editor in Supabase dashboard
   - Should see `qr_codes` and `scan_events` tables

---

## Option 2: Local Supabase (For Development)

1. **Install Docker**:
   - Download from [https://www.docker.com](https://www.docker.com)
   - Ensure Docker Desktop is running

2. **Install Supabase CLI**:
   ```bash
   brew install supabase/tap/supabase  # macOS
   # OR
   npm install -g supabase             # npm
   ```

3. **Initialize Supabase**:
   ```bash
   cd /Users/aviraj/vaccine-tracker
   supabase init  # Creates supabase/ directory (already exists)
   ```

4. **Start Supabase**:
   ```bash
   supabase start
   ```

   **Expected Output**:
   ```
   Started supabase local development setup.

   API URL: http://localhost:54321
   DB URL: postgresql://postgres:postgres@localhost:54322/postgres
   Studio URL: http://localhost:54323
   anon key: eyJhbG...
   service_role key: eyJhbG...
   ```

5. **Copy Credentials**:
   - Save the `API URL` and `anon key` for web/.env.local
   - Save the `DB URL` for migrations

6. **Apply Migration**:
   ```bash
   supabase db reset  # Applies all migrations in supabase/migrations/
   ```

---

## Migration Files

This directory contains:

- **migrations/001_initial_schema.sql** - Creates qr_codes and scan_events tables
- **seed.sql** - Test data for development (optional)

## Environment Variables

After setting up Supabase, create these files:

**web/.env.local**:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co  # Or http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbG...
```

**mobile/lib/config/env.dart**:
```dart
const String supabaseUrl = 'https://xxxxx.supabase.co';  // Or http://10.0.2.2:54321 for Android emulator
const String supabaseAnonKey = 'eyJhbG...';
```

---

## Verification

After setup, verify with:

```bash
# Check tables exist
psql $DB_URL -c "\dt"

# Expected output:
#  public | qr_codes      | table | postgres
#  public | scan_events   | table | postgres
```

Or via Supabase Studio: http://localhost:54323 (local) or dashboard.supabase.com (cloud)
