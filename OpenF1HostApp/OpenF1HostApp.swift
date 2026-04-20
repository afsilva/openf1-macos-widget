import SwiftUI

@main
struct OpenF1HostApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: 12) {
                Text("OpenF1 Dashboard")
                    .font(.title2).bold()
                Text("Use the macOS widget gallery to add OpenF1 Dashboard widget.")
                Text("This host app primarily exists to install the widget and host App Intent interactions.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(minWidth: 520, minHeight: 220)
        }
    }
}
