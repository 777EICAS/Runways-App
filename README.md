# Runways App

iOS app for pilots: airfield database with private notes and a shared pilot board. Built with SwiftUI.

## Requirements

- **Mac** with **Xcode** installed
- **Apple ID** (free) to run on the simulator; Apple Developer account needed for a physical device

## Running the project

1. **Clone the repo** (or download and unzip if shared another way):
   ```bash
   git clone <repository-url>
   cd "Runways App"
   ```

2. **Open in Xcode**
   - Double-click `Runways App.xcodeproj` or open it from Xcode (File → Open).

3. **Select a run destination**
   - In the Xcode toolbar, choose **iPhone** or **iPad** simulator (e.g. iPhone 16).

4. **Build and run**
   - Press **⌘R** or click the Run button.

## If you can’t build or run

- **“No such module” or SDK errors:** Your Xcode version may be older than the project’s. In Xcode: select the **Runways App** target → **General** → **Minimum Deployments**, and set **iOS** to the version that matches your Xcode (e.g. iOS 18 if you have Xcode 16).
- **Signing errors on a physical device:** Select the **Runways App** target → **Signing & Capabilities** → set **Team** to your own Apple ID or development team.

## Project structure

- **Runways App/** – Main app target
  - **Models/** – Airfield, Runway, notes
  - **Data/** – LHR data, stores (private/public notes)
  - **Views/** – UI (list, detail, runway info, notes, pilot board)
  - **Theme/** – Colors and header styling
  - **Utilities/** – e.g. network monitor
