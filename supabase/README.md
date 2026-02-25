# Supabase setup for Runways App

1. Create a project at [supabase.com](https://supabase.com) (or use the CLI).
2. In the Dashboard go to **SQL Editor** and run the contents of `migrations/001_profiles_forum.sql`. If you already ran an older version of the migration, add the author display name column: `ALTER TABLE public.forum_posts ADD COLUMN IF NOT EXISTS author_display_name text DEFAULT '';`
3. In **Project Settings > API** copy your **Project URL** and **anon public** key.
4. In the app, set these so `SupabaseConfig` can read them:
   - **Option A**: Add to your scheme’s Run arguments: `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the environment (e.g. in Xcode: Edit Scheme → Run → Arguments → Environment Variables).
   - **Option B**: Add to Info.plist: `SUPABASE_URL` and `SUPABASE_ANON_KEY` (string values). Do not commit real keys; use xcconfig or build settings for production.
   - See `Runways App/Services/SupabaseConfig.swift` for how the app reads URL and key.
