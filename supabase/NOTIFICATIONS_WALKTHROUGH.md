# New-post notifications — step-by-step walkthrough

This guide takes you through enabling and testing the feature where **you get a notification when someone posts on the community board for an airfield you’ve favourited**. If you’ve never set this up before, follow the steps in order.

---

## Part A: Make sure the basics are done

You need a Supabase project and the app talking to it. If you’ve already done the main setup, skip to **Part B**.

### A1. Supabase project and tables

1. Go to [supabase.com](https://supabase.com) and sign in.
2. Create a new project (name, password, region) if you don’t have one yet.
3. In the left sidebar, click **SQL Editor**.
4. Click **New query**.
5. Open this file in your project: **`supabase/migrations/001_profiles_forum.sql`**.
6. Select all (Cmd+A), copy, then paste into the Supabase SQL Editor.
7. Click **Run** (or Cmd+Enter).
8. You should see a success message. That creates the tables the app needs.

### A2. Project URL and key in the app

1. In Supabase: left sidebar → **Project Settings** (gear) → **API**.
2. Copy:
   - **Project URL** (e.g. `https://xxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`).
3. In Xcode: **Product → Scheme → Edit Scheme…** (or Cmd+<).
4. Select **Run** on the left, then the **Arguments** tab.
5. Under **Environment Variables**, add:
   - **Name:** `SUPABASE_URL` → **Value:** your Project URL
   - **Name:** `SUPABASE_ANON_KEY` → **Value:** your anon public key
6. Click **Close**.

After this, the app can connect to Supabase. Next we enable Realtime for new-post notifications.

---

## Part B: Enable Realtime for forum posts

Realtime is what lets the app “listen” for new rows in the `forum_posts` table. You only do this once per project.

### Option 1 — Using the SQL Editor (recommended)

1. In Supabase, open **SQL Editor** in the left sidebar.
2. Click **New query**.
3. Open this file in your project: **`supabase/migrations/002_realtime_forum_posts.sql`**.
4. It contains a single line. Select all, copy, and paste into the SQL Editor.
5. Click **Run** (or Cmd+Enter).
6. You should see **Success** (or “No rows returned”). That’s correct.

If you see an error like “table already in publication”, that’s fine — it means Realtime was already enabled for `forum_posts`. You can move on.

### Option 2 — Using the Dashboard

1. In Supabase, left sidebar → **Database**.
2. Click **Replication** (or look for “Publications” / “Realtime” in the Database section).
3. Find the publication **supabase_realtime**.
4. Add the table **forum_posts** to that publication (use the UI to add it).
5. Save.

Once Realtime is enabled for `forum_posts`, the app can subscribe to new posts.

---

## Part C: Turn on notifications in the app

1. Build and run the Runways app from Xcode (Cmd+R).
2. Tap the **Settings** (gear) icon.
3. In **Account**, sign in or create an account if you aren’t already.
4. In the **Notifications** section:
   - Turn **Allow notifications** **ON** (the app may ask for permission — tap **Allow**).
   - Turn **Notify when someone posts on a favourited airfield** **ON**.

Leave the app open (or in the background) so it can receive Realtime events. Notifications only fire when the app has been run recently enough to have an active Realtime connection.

---

## Part D: Test the notification

You need **two ways to post** (e.g. two accounts or two devices) so that one device can be “listening” and the other can post.

### D1. On the device that should receive the notification

1. Make sure you’re **signed in**.
2. **Favourite an airfield:**  
   Switch the list to **Favourites**, tap **Edit**, tick at least one airfield (e.g. London Heathrow), then **Done**.
3. In **Settings**, confirm:
   - **Allow notifications** is ON.
   - **Notify when someone posts on a favourited airfield** is ON.
4. Leave the app **open** or **in the background** (don’t force-quit).

### D2. Create the new post (second account or second device)

- **If you have two accounts:**  
  Sign out on the first device, sign in with a different account, open that same airfield (e.g. London Heathrow), go to the **Community board**, and post a short message (e.g. “Test post”).
- **If you have two devices:**  
  On the second device, sign in with a **different** account, open the same airfield you favourited on the first device, go to **Community board**, and post (e.g. “Test post”).

### D3. Check the first device

Within a few seconds you should see a **notification**:  
**“New community post”** / **“Someone posted on [Airfield name]”**.

- Tapping it should open the app and take you to that airfield (and you can open the Community board to see the new post).

---

## If you don’t get a notification

- **App not open recently:**  
  The Realtime connection only runs when the app has been opened (or in background) recently. Open the app again, leave it in the foreground or background, then trigger a new post from the other account/device.

- **Same account on both sides:**  
  The app does **not** notify you when **you** are the author. Use a **different** account (or device with a different account) to post.

- **Airfield not favourited:**  
  The listening device must have that airfield in **Favourites** (and the “Notify when someone posts on a favourited airfield” toggle must be ON).

- **Realtime not enabled:**  
  Re-run **Part B** and confirm `forum_posts` is in the `supabase_realtime` publication (SQL or Dashboard).

- **Permissions:**  
  In iOS **Settings → Runways App → Notifications**, make sure notifications are allowed.

---

## Summary

| Part | What you did |
|------|----------------|
| A | Ensured Supabase project exists, ran `001_profiles_forum.sql`, and set `SUPABASE_URL` and `SUPABASE_ANON_KEY` in Xcode. |
| B | Ran `002_realtime_forum_posts.sql` (or added `forum_posts` to Realtime in the Dashboard). |
| C | In the app: signed in, enabled “Allow notifications” and “Notify when someone posts on a favourited airfield”. |
| D | Favourited an airfield on one device/account, posted from another account/device, and checked for the notification. |

After this, any time someone (other than you) posts on a favourited airfield and your app has been open recently, you’ll get that notification.
