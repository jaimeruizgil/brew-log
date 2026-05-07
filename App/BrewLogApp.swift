import SwiftUI
import SwiftData

@main
struct BrewLogApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([Coffee.self, Extraction.self, CoffeeLocation.self])

            // ──────────────────────────────────────────────────────────────────
            // CloudKit sync: swap the local config for the CloudKit config below.
            // Requirements before enabling:
            //   1. Add "iCloud" capability in Xcode → Signing & Capabilities
            //   2. Check "CloudKit" and select/create a container (iCloud.<bundle-id>)
            //   3. Add "Background Modes → Remote notifications" capability
            //
            // let config = ModelConfiguration(
            //     "BrewLog",
            //     schema: schema,
            //     cloudKitDatabase: .automatic   // uses first container in entitlements
            // )
            // ──────────────────────────────────────────────────────────────────
            let config = ModelConfiguration("BrewLog", schema: schema)
            container  = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .task {
                    await SampleData.insertIfNeeded(into: container.mainContext)
                }
        }
    }
}
