# Brew Log — Xcode Setup

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 16+ |
| iOS Deployment Target | 17.0+ |
| Swift | 5.10+ |

---

## 1. Create the Xcode project

1. Open Xcode → **File → New → Project…**
2. Choose **iOS → App**
3. Set:
   - **Product Name:** `BrewLog`
   - **Bundle Identifier:** `com.yourname.BrewLog` (you'll need this for CloudKit)
   - **Interface:** SwiftUI
   - **Storage:** SwiftData *(Xcode adds the container boilerplate — you'll replace it with the code here)*
4. Click **Next** and choose a location.

---

## 2. Add the source files

Copy the entire `BrewLog/` folder (everything except this README) into your Xcode project:

```
App/
Models/
Extensions/
Views/
  Components/
  Cafes/
  Extracciones/
Helpers/
```

In Xcode, right-click the project root in the Navigator → **Add Files to "BrewLog"…** → select the folders and make sure **Copy items if needed** is checked and **Create groups** is selected.

**Delete** the default `ContentView.swift` and `BrewLogApp.swift` that Xcode generated (our versions replace them).

---

## 3. Add MapKit

1. Select the project in the Navigator → target **BrewLog** → **General** tab
2. Under **Frameworks, Libraries, and Embedded Content** → **+** → search for **MapKit** → **Add**

Alternatively, in `Info.plist` you don't need any special key — `Map` and `CLGeocoder` work without a usage key unless you request location access.

---

## 4. Enable CloudKit sync (optional)

The app defaults to **local SwiftData** storage. To enable iCloud sync:

### 4a. Add capabilities

1. Target → **Signing & Capabilities → + Capability**
2. Add **iCloud** — check **CloudKit**, create/select a container (usually `iCloud.com.yourname.BrewLog`)
3. Add **Background Modes** — check **Remote notifications**

### 4b. Swap the container config

Open `App/BrewLogApp.swift` and replace:

```swift
let config = ModelConfiguration("BrewLog", schema: schema)
```

with:

```swift
let config = ModelConfiguration(
    "BrewLog",
    schema: schema,
    cloudKitDatabase: .automatic   // uses iCloud.<bundle-id> container
)
```

SwiftData + CloudKit requires **all model relationships to have inverses** (already done) and **no unique-attribute constraints** (already respected).

---

## 5. Accent colours & card style

User preferences are stored in `UserDefaults` via `@AppStorage` in `ContentView.swift`:

| Key | Default | Options |
|-----|---------|---------|
| `accentHex` | `#A87750` (Crema cálida) | `#A87750` `#6B8B6E` `#B5573A` `#1F1F1F` |
| `cardStyle` | `Tarjeta` | `Lista` `Tarjeta` `Compacto` |
| `fontScale` | `1.0` | 0.9 – 1.15 |
| `boldFont` | `false` | — |

Add a Settings or Preferences screen using `AccentOption.allCases` and `CardStyle.allCases` to expose these to the user.

---

## 6. Sample data

`SampleData.insertIfNeeded` runs once on first launch (it checks for existing `Coffee` records). It inserts:
- **10 coffees** across 7 Spanish specialty roasters
- **31 extractions** spread over the past months

To reset and re-seed during development:

```swift
// Temporary — in BrewLogApp.init(), after creating the container:
try? container.mainContext.delete(model: Coffee.self)
try? container.mainContext.delete(model: Extraction.self)
try? container.mainContext.delete(model: CoffeeLocation.self)
await SampleData.insertIfNeeded(into: container.mainContext)
```

---

## File map

```
App/
  BrewLogApp.swift          – @main entry, ModelContainer setup
Models/
  Coffee.swift              – @Model Coffee + RoastLevel enum
  Extraction.swift          – @Model Extraction
  CoffeeLocation.swift      – @Model CoffeeLocation
Extensions/
  Color+Hex.swift           – Color(hex:) initializer
  Date+Brewing.swift        – Spanish date formatting helpers
Views/
  ContentView.swift         – TabView shell + accent/card prefs + AddMenu
  Components/
    ScoreDotsView.swift     – ●●●●○ dot score (0–5, half-step)
    RoastBadgeView.swift    – Diamond-fill roast badge
    BagThumbView.swift      – Tinted bag placeholder with monogram
    OpenDotView.swift       – Pulsing "en uso" indicator
    ParamPillView.swift     – "2.4 mol" extraction param
  Cafes/
    CafesView.swift         – List with search, filter, 3 card styles
    CoffeeDetailView.swift  – Detail: score, notes, specs, map, extractions
    FilterSheetView.swift   – Bottom sheet: roast / origin / min score
    AddEditCoffeeView.swift – Add/edit form
  Extracciones/
    ExtraccionesView.swift  – Chronological feed grouped by day
    AddExtractionView.swift – Big-stepper extraction form
Helpers/
  SampleData.swift          – First-launch seed data
```
