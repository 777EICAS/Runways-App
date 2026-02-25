# Supabase setup for Runways App — step by step

Follow these steps in order. You only need to do this once per project.

---

## Step 1: Create a new Supabase project

You’re on the **Create a new project** page. Do this:

1. **Organization**  
   Leave as is (e.g. “Adam Da Costa (FREE)”).

2. **Project name**  
   Type a name, e.g. `Runways App` or `runways-app`. It must be unique in your account.

3. **Database password**  
   - Click **Generate a password** and **copy the password** somewhere safe (e.g. a password manager).  
   - You need this only for direct database access; the Runways app will use the API key, not this password.

4. **Region**  
   Pick the region closest to you (e.g. **Europe** if that’s what you have). This is where your data is stored.

5. **Enable Data API**  
   Leave this **checked**. The app uses the Supabase client (Swift), which needs the Data API.

6. Click the green **Create new project** button.  
   Creation can take 1–2 minutes. Wait until the dashboard loads.

---

## Step 2: Run the database migration (create tables)

After the project is ready:

1. In the left sidebar, open **SQL Editor** (database icon).
2. Click **New query** (or the + button).
3. Open this file in your project:  
   **`supabase/migrations/001_profiles_forum.sql`**
4. **Select all** the SQL in that file (Cmd+A) and **copy** it.
5. **Paste** it into the Supabase SQL Editor.
6. Click **Run** (or press Cmd+Enter).
7. You should see a success message. This creates the `profiles`, `forum_posts`, and `forum_votes` tables and their security rules.

8. **Optional — enable Realtime for new-post notifications:**  
   To let the app notify users when someone posts on a favourited airfield, run the second migration: open **`supabase/migrations/002_realtime_forum_posts.sql`**, copy its contents into a new SQL Editor query, and run it. This adds `forum_posts` to the Realtime publication. Alternatively, in the Dashboard go to **Database → Replication** and add the `forum_posts` table to the `supabase_realtime` publication.

---

## Step 3: Get your Project URL and anon key

The app needs two values from Supabase:

1. In the left sidebar, click the **gear icon** (**Project Settings**).
2. In the left menu under **Project Settings**, click **API**.
3. On the API page you’ll see:
   - **Project URL** — e.g. `https://xxxxxxxxxxxx.supabase.co`  
     → Copy this.
   - **Project API keys** — find the key named **anon** **public** (not the `service_role` key).  
     → Copy that key (long string starting with `eyJ...`).

Keep these handy for the next step.

---

## Step 4: Add the URL and key to the Runways app in Xcode

You’ll add them as **environment variables** so the app can connect to your Supabase project.

1. In Xcode, open the **Runways App** project.
2. In the menu bar: **Product → Scheme → Edit Scheme…** (or press Cmd+<).
3. In the left column, select **Run**.
4. Open the **Arguments** tab.
5. Under **Environment Variables**, click the **+** button twice to add two variables:

   **First variable**
   - **Name:** `SUPABASE_URL`  
   - **Value:** paste your **Project URL** (e.g. `https://xxxxxxxxxxxx.supabase.co`)

   **Second variable**
   - **Name:** `SUPABASE_ANON_KEY`  
   - **Value:** paste your **anon public** key (the long `eyJ...` string)

6. Leave **“Expand Variables Based On”** as default.
7. Click **Close**.

From now on, when you run the app from Xcode, it will use this Supabase project.

---

## Step 5: Run the app and test

1. Build and run the Runways app (Cmd+R).
2. Open **Settings** (gear icon).
3. In the **Account** section you should see **Sign in** and **Create account**.
4. Tap **Create account**, enter an email and password (min 6 characters), then tap **Create account**.
5. After signing in you should see **Signed in as** and your email, plus **Sign out**.

If that works, Supabase is set up correctly. You can then:
- Sync favourites and settings (they’re stored in your profile).
- Post on the **Community board** for an airfield (posts are stored in Supabase and visible to other users).

---

## If something goes wrong

- **“Invalid API key” or connection errors**  
  Double-check **Step 3** and **Step 4**: the URL must end with `.supabase.co` (no trailing slash), and you must use the **anon public** key, not the `service_role` key.

- **SQL errors when running the migration**  
  Make sure you copied the **entire** contents of `001_profiles_forum.sql` and that you’re running it in the **SQL Editor** of the correct project.

- **Sign up / sign in fails**  
  In Supabase: **Authentication → Providers** and ensure **Email** is enabled.  
  If you have “Confirm email” enabled, check your email (and spam) for the confirmation link before signing in.

---

## Summary

| Step | What you did |
|------|----------------|
| 1 | Created a Supabase project (name, password, region). |
| 2 | Ran `001_profiles_forum.sql` in the SQL Editor. |
| 3 | Copied Project URL and anon public key from Project Settings → API. |
| 4 | Added `SUPABASE_URL` and `SUPABASE_ANON_KEY` as environment variables in the Xcode Run scheme. |
| 5 | Ran the app and created an account to verify. |

After this, you don’t need to repeat these steps unless you create a new Supabase project or a new app that uses the same backend.
