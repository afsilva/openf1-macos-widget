import WidgetKit
import SwiftUI
import AppIntents

private let buildStamp = "b2026.04.20-ios-009"

struct OpenF1iOSWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "OpenF1 Widget Configuration"
    static var description = IntentDescription("Configuration intent for OpenF1 Dashboard iOS widget.")
}

struct OpenF1iOSEntry: TimelineEntry {
    let date: Date
    let model: WidgetViewModel
}

struct OpenF1iOSProvider: AppIntentTimelineProvider {
    typealias Entry = OpenF1iOSEntry
    typealias Intent = OpenF1iOSWidgetConfigurationIntent

    func placeholder(in context: Context) -> OpenF1iOSEntry {
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

    func snapshot(for configuration: OpenF1iOSWidgetConfigurationIntent, in context: Context) async -> OpenF1iOSEntry {
        let payload = await OpenF1Service().buildDashboard(force: false)
        return .init(date: Date(), model: payload.model)
    }

    func timeline(for configuration: OpenF1iOSWidgetConfigurationIntent, in context: Context) async -> Timeline<OpenF1iOSEntry> {
        let payload = await OpenF1Service().buildDashboard(force: false)
        let entry = OpenF1iOSEntry(date: Date(), model: payload.model)
        let next = Date().addingTimeInterval(payload.refreshInterval)
        return Timeline(entries: [entry], policy: .after(next))
    }
}

struct OpenF1iOSWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: OpenF1iOSProvider.Entry

    private var isMedium: Bool { family == .systemMedium }

    private var rowsForLarge: [CalendarRow] {
        let all = entry.model.calendarRows

        let headerRows = all.filter {
            let t = $0.text
            return !(t.contains("➡") || t.contains("•"))
        }

        let detectedSessionRows = all.filter {
            let t = $0.text
            return (t.contains("➡") || t.contains("•")) && t.contains(":") && t.contains("/")
        }

        let uniqueSessionRows = dedupeRenderedRows(detectedSessionRows)
        let limitedSessionRows = Array(uniqueSessionRows.prefix(8))

        if limitedSessionRows.isEmpty {
            return Array(all.prefix(10))
        }

        // Keep section header/context rows, but do not prepend rows that are already sessions.
        return Array(headerRows.prefix(2)) + limitedSessionRows
    }

    private var nextSessionSummary: String {
        let candidate = entry.model.calendarRows.first {
            let t = $0.text
            return (t.contains("➡") || t.contains("•")) && t.contains(":")
        }?.text ?? "No upcoming session"
        return compactSession(candidate)
    }

    private var topDriverSummary: String {
        guard let row = entry.model.driverRows.first else { return "No driver standings yet" }
        return compactStanding(row)
    }

    private var topTeamSummary: String {
        guard let row = entry.model.teamRows.first else { return "No team standings yet" }
        return compactStanding(row)
    }

    var body: some View {
        Group {
            if isMedium {
                mediumLayout
            } else {
                largeLayout
            }
        }
        .padding(isMedium ? 8 : 8)
        .containerBackground(.background, for: .widget)
        .widgetURL(nil)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.12), lineWidth: 0.6)
        )
    }

    private var largeLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(entry.model.panelTitle)
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
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary.opacity(0.95))
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Text("Build \(buildStamp)")
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Divider()

            ForEach(rowsForLarge, id: \.self) { row in
                Text(row.text)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(row.dim ? .secondary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Divider()

            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Drivers")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    ForEach(entry.model.driverRows.prefix(10), id: \.self) { line in
                        Text(line)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                    }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Teams")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    ForEach(entry.model.teamRows.prefix(11), id: \.self) { line in
                        Text(line)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                    }
                }
            }
        }
    }

    private var mediumLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(entry.model.panelTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                Button(intent: RefreshNowIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }

            Text(entry.model.subtitle)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary.opacity(0.95))
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            if let ts = entry.model.lastUpdated {
                Text("Updated \(ts, style: .time)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Divider()

            Text("Next: \(nextSessionSummary)")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("Top Driver: \(topDriverSummary)")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("Top Team: \(topTeamSummary)")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
    }

    private func dedupeRenderedRows(_ rows: [CalendarRow]) -> [CalendarRow] {
        var out: [CalendarRow] = []
        var seen: Set<String> = []
        for row in rows {
            let key = row.text
                .replacingOccurrences(of: "➡", with: "")
                .replacingOccurrences(of: "•", with: "")
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            if seen.contains(key) { continue }
            seen.insert(key)
            out.append(row)
        }
        return out
    }

    private func compactSession(_ row: String) -> String {
        let cleaned = row
            .replacingOccurrences(of: "➡", with: "")
            .replacingOccurrences(of: "•", with: "")
            .trimmingCharacters(in: .whitespaces)

        let parts = cleaned.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return cleaned }

        let label = parts[0].trimmingCharacters(in: .whitespaces)
        let firstTime = parts[1]
            .split(separator: "/")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .first ?? ""

        if firstTime.isEmpty { return label }
        return "\(label) \(firstTime)"
    }

    private func compactStanding(_ row: String) -> String {
        let trimmed = row.trimmingCharacters(in: .whitespaces)
        if let dotRange = trimmed.range(of: ".") {
            let afterRank = trimmed[dotRange.upperBound...].trimmingCharacters(in: .whitespaces)
            return String(afterRank)
        }
        return trimmed
    }
}

struct OpenF1iOSWidget: Widget {
    let kind: String = "com.afsilva.openf1.widget.ios.v3"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: OpenF1iOSWidgetConfigurationIntent.self, provider: OpenF1iOSProvider()) { entry in
            OpenF1iOSWidgetView(entry: entry)
        }
        .configurationDisplayName("OpenF1 Dashboard (iOS)")
        .description("Shows next F1 session and championship standings from OpenF1.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct OpenF1iOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        OpenF1iOSWidget()
    }
}
