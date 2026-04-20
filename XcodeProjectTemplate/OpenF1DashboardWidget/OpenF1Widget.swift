import WidgetKit
import SwiftUI
import AppIntents

private let buildStamp = "b2026.04.20-0010"

struct OpenF1WidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "OpenF1 Widget Configuration"
    static var description = IntentDescription("Configuration intent for OpenF1 Dashboard widget.")
}

struct OpenF1Entry: TimelineEntry {
    let date: Date
    let model: WidgetViewModel
}

struct OpenF1Provider: AppIntentTimelineProvider {
    typealias Entry = OpenF1Entry
    typealias Intent = OpenF1WidgetConfigurationIntent

    func placeholder(in context: Context) -> OpenF1Entry {
        .init(
            date: Date(),
            model: WidgetViewModel(
                panelTitle: "🏁 FP1",
                subtitle: "Sample Grand Prix",
                calendarRows: [
                    .init(text: "• FP1: 04-19 11:30 / 09:30 / 05:30", dim: false),
                    .init(text: "• Q:   04-20 14:00 / 12:00 / 08:00", dim: true)
                ],
                driverRows: [" 1. Driver Name    123p"],
                teamRows: [" 1. Team Name      245p"],
                refreshSource: "CACHE",
                lastUpdated: Date()
            )
        )
    }

    func snapshot(for configuration: OpenF1WidgetConfigurationIntent, in context: Context) async -> OpenF1Entry {
        let payload = await OpenF1Service().buildDashboard(force: false)
        return .init(date: Date(), model: payload.model)
    }

    func timeline(for configuration: OpenF1WidgetConfigurationIntent, in context: Context) async -> Timeline<OpenF1Entry> {
        let payload = await OpenF1Service().buildDashboard(force: false)
        let entry = OpenF1Entry(date: Date(), model: payload.model)
        let next = Date().addingTimeInterval(payload.refreshInterval)
        return Timeline(entries: [entry], policy: .after(next))
    }
}

struct OpenF1WidgetView: View {
    var entry: OpenF1Provider.Entry

    private let sessionFont = Font.system(size: 10, weight: .regular, design: .monospaced)
    private let standingsFont = Font.system(size: 11, weight: .regular, design: .monospaced)
    private let sectionHeaderFont = Font.system(size: 11, weight: .semibold, design: .monospaced)

    private func fit(_ s: String, width: Int) -> String {
        if s.count == width { return s }
        if s.count < width { return s + String(repeating: " ", count: width - s.count) }
        guard width > 1 else { return String(s.prefix(1)) }
        return String(s.prefix(width - 1)) + "…"
    }

    private func pairedDriverRows(_ rows: [String]) -> [String] {
        stride(from: 0, to: rows.count, by: 2).map { i in
            let left = fit(rows[i], width: 24)
            let right = (i + 1 < rows.count) ? fit(rows[i + 1], width: 24) : ""
            return right.isEmpty ? left : left + "  " + right
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(entry.model.panelTitle)  [\(buildStamp)]")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if let ts = entry.model.lastUpdated {
                    Text(ts, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Button(intent: RefreshNowIntent()) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }

            Text(entry.model.subtitle)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text("Build \(buildStamp)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Divider()

            let contextRows = Array(entry.model.calendarRows.prefix(2))
            let detectedSessionRows = entry.model.calendarRows.filter {
                let t = $0.text
                return t.contains(":") && (t.contains("➡") || t.contains("•") || t.contains("/"))
            }
            let sessionRows = Array(detectedSessionRows.prefix(4))
            let rowsToShow = sessionRows.isEmpty ? Array(entry.model.calendarRows.prefix(6)) : (contextRows + sessionRows)

            ForEach(rowsToShow, id: \.self) { row in
                Text(row.text)
                    .font(sessionFont)
                    .foregroundStyle(row.dim ? .secondary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Divider()

            let pairedDriverRows = pairedDriverRows(entry.model.driverRows)

            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Drivers (22)")
                        .font(sectionHeaderFont)
                    ForEach(pairedDriverRows, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                    }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Teams (11)")
                        .font(sectionHeaderFont)
                    ForEach(entry.model.teamRows, id: \.self) { line in
                        Text(line)
                            .font(standingsFont)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                    }
                }
            }
        }
        .padding(8)
        .containerBackground(.background, for: .widget)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.12), lineWidth: 0.6)
        )
    }
}

struct OpenF1Widget: Widget {
    // New kind to avoid stale family cache interference from previous builds.
    let kind: String = "com.afsilva.openf1.widget.largeonly.v3"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: OpenF1WidgetConfigurationIntent.self, provider: OpenF1Provider()) { entry in
            OpenF1WidgetView(entry: entry)
        }
        .configurationDisplayName("OpenF1 Dashboard (macOS)")
        .description("Shows next F1 session and championship standings from OpenF1.")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct OpenF1WidgetBundle: WidgetBundle {
    var body: some Widget {
        OpenF1Widget()
    }
}
