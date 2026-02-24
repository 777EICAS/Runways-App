# Push: “New post on favourited airfield” – Plan (no code changes)

## Goal

When a pilot posts on the community board for an airfield, **all users who have that airfield in their favourites** receive a push notification (e.g. “New post on [Airfield Name]”).

---

## Current state

- **Community board**: Posts are stored **only on the device** that created them (`PublicBoardStore` → `public_notes.json` in the app’s documents directory). There is no backend or cloud sync. Other users never see each other’s posts.
- **Favourites**: Stored **only on each device** (`FavouritesStore` → UserDefaults). No server knows “who has which airfields favourited.”
- **Notifications today**: The app only uses **local** notifications (e.g. “you’re near an airfield – add notes?”). There is no remote (APNs) push setup.

So today:

- There is no shared “new post” event.
- There is no list of “all users” or “users who favourited this airfield.”
- There is no server that could send a push to those users.

**Therefore: “notify all users when someone posts on a favourited airfield” cannot be implemented with the current, local-only design. It requires a backend and remote push.**

---

## What “push for new post on favourited airfield” implies

To send a push to “all users who favourited this airfield” when someone posts:

1. **Shared source of truth for posts**  
   New posts must be written to a **backend** (e.g. REST API + database, or Firebase/Supabase). The backend is the only place that knows “a new post for airfield X just happened.”

2. **Backend knows “who to notify”**  
   For a given airfield, the backend must know which **users** (or devices) have that airfield in their favourites. So:
   - Favourites (or at least “favourites for notification purposes”) must be **synced to the backend** per user.
   - When a new post is created for airfield X, the backend looks up: “all users who have X in their favourites” and gets their push targets (see below).

3. **Push delivery (APNs)**  
   The backend needs a way to send a **remote push** to those users:
   - Each app instance registers for remote notifications and sends its **device token** to your backend.
   - The backend stores **user (or device) → device token(s)** and optionally **user → favourite airfield IDs**.
   - When a new post is created for airfield X, the backend:
     - Queries: users who have X in their favourites.
     - For each such user, gets their device token(s).
     - Sends an APNs payload (e.g. “New post on [Airfield Name]”) to each token.

4. **User/device identity**  
   The backend must associate:
   - “This device token” with “this user’s favourites” (or “this device’s favourites”).  
   So you need either:
   - **Logged-in users**: account per user, favourites synced to that account, device tokens linked to that account, or  
   - **Anonymous devices**: e.g. device ID + favourites synced per device, device tokens linked to that device.

So at a high level you need:

- A **backend** that stores:
  - Posts (per airfield, with creation time, etc.).
  - Favourites per user (or per device).
  - Device tokens per user (or per device).
- **App changes** (for later):
  - Submit new posts to the backend (instead of or in addition to local only).
  - Sync favourites to the backend when they change (and on login / app launch if you have accounts).
  - Register for remote notifications and send the device token to the backend.
- **Backend logic**: On “new post for airfield X” → find users who favourited X → send APNs to their tokens.
- **APNs**: Apple Push Notification service (certificate/key, app ID with push capability). Backend uses APNs to send the actual push.

---

## Architecture options (high level)

### Option A – Full backend + APNs (real push to all users)

- **Backend**: Your own server (or BaaS like Firebase/Supabase) that:
  - Stores posts per airfield (when a user “posts”, app sends the post to the backend).
  - Stores per user (or per device): favourite airfield IDs, and device token(s).
- **Flow**:
  1. User posts on community board → app sends post to backend (and can still keep local copy if desired).
  2. Backend saves post, then: “airfield X has a new post” → query “users who have X in favourites” → send APNs “New post on [Airfield Name]” to each of those users’ device tokens.
- **App**: Register for remote notifications, send token to backend; sync favourites to backend; submit posts to backend.
- **Result**: True push; all users who favourited that airfield get notified when anyone posts.

### Option B – Backend for posts only + local “new post” detection (no real push)

- **Backend**: Only stores/serves **posts** per airfield (read/write). Does **not** store favourites or send pushes.
- **App**: Periodically (or on app open) fetches latest posts for **favourited** airfields. If it sees a post newer than the last time we checked, show a **local** notification (“New post on [Airfield Name]”).
- **Limitation**: Not real-time push; depends on fetch interval. “All users” aren’t pushed; each user only finds out when their app next checks. No backend knowledge of “who favourited what” needed.

### Option C – Hybrid (backend knows favourites, no APNs yet)

- Backend stores posts and favourites per user (or device). When a new post is created, backend could later be extended to send APNs; until then, you could still do Option B–style polling on the app for “new posts on my favourited airfields” and local notifications.

---

## Recommendation for “all users get a push”

For the exact behaviour you described (“all users receive a push notification” when someone posts on a favourited airfield), you need **Option A**:

1. **Backend** that:
   - Accepts and stores community board posts (per airfield).
   - Stores favourites per user/device and device tokens per user/device.
   - On new post for airfield X: resolve “users who have X in favourites” and send one APNs payload per target device (e.g. “New post on [Airfield Name]”).
2. **App** (in a later phase):
   - Enable push capability, register for remote notifications, send device token to backend.
   - Sync favourites to backend when they change (and on launch).
   - Submit new community board posts to the backend (and optionally keep local copy).

No code has been changed; this document is planning only. When you’re ready to implement, the next step is to choose backend (e.g. Firebase, Supabase, or custom) and then implement backend logic + app registration/sync/post submission in that order.
