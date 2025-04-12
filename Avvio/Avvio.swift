
import SwiftUI

@main
struct AvvioApp: App {

    let hkData = HealthKitData()
    let hkManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkData)
                .environment(hkManager)
        }
    }
}
