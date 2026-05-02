import SwiftUI

private let hostBuildStamp = "b2026.05.02-ios-002"

@main
struct OpenF1iOSHostApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("OpenF1 Dashboard")
                            .font(.system(size: 21, weight: .bold))

                        Text("Add the OpenF1 widget from the iOS Home Screen widget gallery.")
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Build \(hostBuildStamp)")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Data source: OpenF1 public API (https://api.openf1.org).")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Open-source license: GPL-3.0-or-later.")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("This host app exists to install the widget, host App Intent interactions, and provide a lightweight launch surface.")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
                .navigationTitle("OpenF1")
            }
        }
    }
}
