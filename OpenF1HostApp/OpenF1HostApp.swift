import SwiftUI

@main
struct OpenF1HostApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: 12) {
                Text("OpenF1 Dashboard")
                    .font(.title2).bold()

                Text("Use the macOS widget gallery to add OpenF1 Dashboard widget.")

                Text("Data source: OpenF1 public API (https://api.openf1.org).")
                    .foregroundStyle(.secondary)

                Text("Open-source license: GPL-3.0-or-later.")
                    .foregroundStyle(.secondary)

                Text("This host app primarily exists to install the widget and host App Intent interactions.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(minWidth: 520, minHeight: 240)
        }
    }
}
