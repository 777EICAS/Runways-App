# Settings Page – Plan

## Overview

Add a settings entry point (cog icon) on the home/sidebar and a dedicated Settings screen to manage notifications, location services, and profile information.

---

## 1. Entry point: cog on home

- **Where:** Top-right of the “home” area — i.e. the **sidebar** (the column that contains `AppHeaderView`, the list mode picker, and the airfield list).
- **Options:**
  - **A. In the header row:** Put the cog in the same row as the “Runways App” title in `AppHeaderView`, aligned trailing. Keeps the icon always visible and clearly part of the chrome.
  - **B. In a toolbar:** Add a `.toolbar` to the sidebar’s `NavigationStack`/container with a trailing `ToolbarItem` containing the cog. Slightly more system-standard but your sidebar currently hides the nav bar (`.toolbar(.hidden, for: .navigationBar)`), so this might need a small layout tweak (e.g. a visible toolbar only for the sidebar, or a custom header row that includes the cog).
- **Recommendation:** **A** — extend `AppHeaderView` to accept an optional trailing view (e.g. `@ViewBuilder trailing: () -> some View`) and place a `Button` with `Image(systemName: "gearshape")` that presents the settings sheet. Keeps the cog in the same visual block as the app title and doesn’t fight the hidden nav bar.

---

## 2. Presenting Settings

- **Mechanism:** Use a **sheet** (`.sheet(isPresented:content:)` or `.sheet(item:content:)`) so that:
  - Settings feels like a modal “page” the user opens from home and dismisses to return.
  - On iPad (with `NavigationSplitView`), the sheet can be presented from the sidebar and doesn’t require pushing onto the detail column.
- **State:** Hold a `@State private var showSettings = false` (or similar) in the view that owns the sidebar — i.e. **`ContentView`** — and pass a binding or an action into `AppHeaderView` so the cog button can set `showSettings = true`.
- **Dismissal:** Settings view uses `@Environment(\.dismiss)` and a “Done” or “Close” button to dismiss.

---

## 3. Settings page structure

Single scrollable screen (e.g. `Form` or `List` with sections) with three main areas:

### 3.1 Notifications

- **Purpose:** Let the user enable/disable and optionally configure notification-related behavior.
- **Possible controls:**
  - Master toggle: “Allow notifications” (reflects system permission; if off, open Settings.app or prompt to enable).
  - If the app has “near airfield” prompts (from `AirfieldLocationService`): toggle “Notify me when I’m near an airfield” (or similar). This would gate whether `AirfieldLocationService` schedules those prompts; actual permission request can still be done when they turn it on.
- **Data:** Persist the user’s choices in `UserDefaults` (or a small `Observable` settings object backed by `UserDefaults`) so the app and `AirfieldLocationService` read from it on launch and when toggles change.

### 3.2 Location services

- **Purpose:** Explain and control use of location (e.g. for “near airfield” detection).
- **Possible controls:**
  - Toggle: “Use location for nearby airfields” (or similar). When on, call `AirfieldLocationService.start()` (or your existing “opt-in” flow); when off, stop monitoring and clear any related state.
  - Display **current authorization status** (e.g. “Location: Always / When in use / Denied”) — read-only, with a button “Open Settings” that deep-links to the app’s page in Settings.app if status is denied or restricted.
- **Data:** Same as notifications — persist the “user wants location on/off” in `UserDefaults`; `AirfieldLocationService` can check this before starting. Optionally show a short explanation (e.g. “Used to remind you to add notes when you’re near an airfield”).

### 3.3 Profile information

- **Purpose:** Let the user add and edit profile info (e.g. name, email, or pilot/org details). Exact fields TBD; keep the model small so it’s easy to extend later (e.g. name, optional email, optional tail number or similar).
- **Possible controls:**
  - Text fields or small form for: display name, email (optional), and one or two optional aviation-specific fields.
  - “Profile” could live in a separate section or a subscreen (e.g. tap “Profile” row → push or sheet to `ProfileEditorView`).
- **Data:** Persist in `UserDefaults` or a simple JSON file in app support; if you later add a backend, this becomes the local cache. No need for Sign in with Apple or account system in this first version unless you decide otherwise.

---

## 4. Technical notes

- **Single source of truth:** Introduce a small **Settings store** (e.g. `AppSettings` or `UserSettings`: `@Observable` class or struct with `UserDefaults` backing) for:
  - Notifications enabled (and any sub-options).
  - Location-for-airfields enabled.
  - Profile fields.
  Pass this (or bindings) into the Settings view and into `AirfieldLocationService` / notification logic so they react to changes.
- **Where the Settings view lives:** Add something like `Runways App/Views/SettingsView.swift` (and optionally `ProfileEditorView.swift` if profile is a separate screen). Register any new types in the Xcode project.
- **Navigation:** If you use a `Form`, you can use `Section` for “Notifications”, “Location”, and “Profile”. For “Profile”, either inline fields in that section or a `NavigationLink` to a dedicated profile editor screen.
- **Styling:** Reuse `AppTheme` (e.g. `SkySunsetBackground`, `AppTheme.skyBlue`, section headers) so Settings matches the rest of the app.

---

## 5. Implementation order (when you build it)

1. **Settings model & persistence**  
   Create `AppSettings` (or similar) and persist notifications/location toggles and profile fields (e.g. in `UserDefaults`).

2. **Cog + sheet from home**  
   Add the cog to the header (or toolbar), present a **placeholder** Settings sheet from `ContentView`.

3. **Settings UI**  
   Build `SettingsView` with three sections (Notifications, Location, Profile); wire toggles and profile fields to `AppSettings`.

4. **Hooking up behavior**  
   - Notifications: ensure `AirfieldLocationService` (and any notification scheduling) respects the “notifications allowed” and “near airfield” toggles.  
   - Location: start/stop `AirfieldLocationService` and show authorization status + “Open Settings” when needed.

5. **Profile (optional)**  
   If profile is more than a couple of fields, add `ProfileEditorView` and navigate to it from the Profile section.

---

## 6. Out of scope for this plan

- Sign in with Apple or other account system (include only if you decide to add it).
- Backend sync of profile or settings (plan assumes local-only for now).
- Actual copy and icons for each row (can be refined in UI).

---

*Document created for planning only. No code changes have been made yet.*
