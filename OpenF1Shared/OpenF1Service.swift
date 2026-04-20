import Foundation
import WidgetKit

public enum AppGroupConfig {
    // Replace with your real App Group in Xcode capabilities.
    public static let identifier = "group.com.afsilva.openf1widget"
}

public enum OpenF1Config {
    public static let apiBase = URL(string: "https://api.openf1.org/v1")!

    public static let refreshWeekSeconds: TimeInterval = 24 * 60 * 60
    public static let refreshWeekendSeconds: TimeInterval = 60 * 60
    public static let resultCacheSeconds: TimeInterval = 30 * 24 * 60 * 60

    public static let maxCacheBytes: Int = 2 * 1024 * 1024
    public static let maxResponseBytes: Int = 1024 * 1024
    public static let maxEndpointEntries: Int = 200

    public static let allowedEndpoints: Set<String> = ["meetings", "sessions", "session_result", "drivers"]
}

public struct OpenF1Service {
    public init() {}

    private struct CacheEnvelope: Codable {
        struct EndpointEntry: Codable {
            let ts: TimeInterval
            let data: Data
        }

        struct Meta: Codable {
            var lastRefreshTs: TimeInterval
            var refreshInterval: TimeInterval
            var lastRefreshSource: String
        }

        struct StandingsCache: Codable {
            var sessionPoints: [String: [String: Double]]
            var driverInfo: [String: DriverInfo]
        }

        struct DriverInfo: Codable {
            var name: String
            var team: String
        }

        var endpoints: [String: EndpointEntry]
        var meta: Meta
        var standings: StandingsCache
        var lastGoodModel: WidgetViewModel?

        static var empty: CacheEnvelope {
            .init(
                endpoints: [:],
                meta: .init(lastRefreshTs: 0, refreshInterval: OpenF1Config.refreshWeekSeconds, lastRefreshSource: "CACHE"),
                standings: .init(sessionPoints: [:], driverInfo: [:]),
                lastGoodModel: nil
            )
        }
    }

    private enum Keys {
        static let cacheFile = "openf1-widget-cache.json"
        static let forceRefresh = "openf1.force-refresh"
    }

    // MARK: - Public API

    public func buildDashboard(force: Bool = false, now: Date = Date()) async -> DashboardPayload {
        do {
            var cache = loadCache()
            let year = Calendar.current.component(.year, from: now)

            let meetingsQ = "meetings?year=\(year)"
            let sessionsQ = "sessions?year=\(year)"

            // Re-evaluate policy from cached schedule if possible
            if
                let cachedMeetings: [Meeting] = endpointDecode(query: meetingsQ, maxAge: 7 * 24 * 60 * 60, cache: cache),
                let cachedSessions: [Session] = endpointDecode(query: sessionsQ, maxAge: 7 * 24 * 60 * 60, cache: cache)
            {
                cache.meta.refreshInterval = isRaceWeekend(meetings: cachedMeetings, sessions: cachedSessions, now: now)
                    ? OpenF1Config.refreshWeekendSeconds
                    : OpenF1Config.refreshWeekSeconds
                saveCache(cache)
            }

            let forced = force || consumeForceRefreshFlag()
            let isDue = forced || ((now.timeIntervalSince1970 - cache.meta.lastRefreshTs) >= cache.meta.refreshInterval)

            var meetings: [Meeting] = []
            var sessions: [Session] = []
            var apiUsed = false

            if isDue {
                do {
                    let meetingsResp = try await fetchJSONCached(
                        query: meetingsQ,
                        type: [Meeting].self,
                        maxAge: 24 * 60 * 60,
                        forceApi: true,
                        cache: &cache
                    )
                    let sessionsResp = try await fetchJSONCached(
                        query: sessionsQ,
                        type: [Session].self,
                        maxAge: 24 * 60 * 60,
                        forceApi: true,
                        cache: &cache
                    )
                    meetings = meetingsResp.value
                    sessions = sessionsResp.value
                    apiUsed = meetingsResp.source == "API" || sessionsResp.source == "API"
                } catch {
                    // Degrade gracefully: fallback to cached schedule data if API fails.
                    meetings = endpointDecode(query: meetingsQ, maxAge: 7 * 24 * 60 * 60, cache: cache) ?? []
                    sessions = endpointDecode(query: sessionsQ, maxAge: 7 * 24 * 60 * 60, cache: cache) ?? []
                }
            } else {
                meetings = endpointDecode(query: meetingsQ, maxAge: 7 * 24 * 60 * 60, cache: cache) ?? []
                sessions = endpointDecode(query: sessionsQ, maxAge: 7 * 24 * 60 * 60, cache: cache) ?? []
            }

            let cal = buildCalendarView(meetings: meetings, sessions: sessions, now: now)

            var standingsDrivers: [StandingDriver] = []
            var standingsTeams: [StandingTeam] = []
            do {
                let standings = try await buildStandings(sessions: sessions, now: now, cache: &cache)
                apiUsed = apiUsed || standings.source == "API"
                standingsDrivers = standings.drivers
                standingsTeams = standings.teams
            } catch {
                // Keep calendar visible even if standings endpoints fail.
                standingsDrivers = []
                standingsTeams = []
            }

            // Fallback: if current season has no completed race-like sessions yet, try previous season standings.
            if standingsDrivers.isEmpty && standingsTeams.isEmpty {
                let previousYear = max(2018, year - 1)
                let prevSessionsQ = "sessions?year=\(previousYear)"
                do {
                    let prevSessionsResp = try await fetchJSONCached(
                        query: prevSessionsQ,
                        type: [Session].self,
                        maxAge: 7 * 24 * 60 * 60,
                        forceApi: false,
                        cache: &cache
                    )
                    let prevStandings = try await buildStandings(sessions: prevSessionsResp.value, now: now, cache: &cache)
                    if !prevStandings.drivers.isEmpty || !prevStandings.teams.isEmpty {
                        standingsDrivers = prevStandings.drivers
                        standingsTeams = prevStandings.teams
                        apiUsed = apiUsed || prevStandings.source == "API" || prevSessionsResp.source == "API"
                    }
                } catch {
                    // Keep empty standings text if fallback also fails.
                }
            }

            let driverRows = formatDriverRows(standingsDrivers)
            let teamRows = formatTeamRows(standingsTeams)

            let interval = (!meetings.isEmpty && !sessions.isEmpty && isRaceWeekend(meetings: meetings, sessions: sessions, now: now))
                ? OpenF1Config.refreshWeekendSeconds
                : OpenF1Config.refreshWeekSeconds
            cache.meta.refreshInterval = interval
            cache.meta.lastRefreshTs = now.timeIntervalSince1970
            cache.meta.lastRefreshSource = apiUsed ? "API" : "CACHE"
            saveCache(cache)

            let model = WidgetViewModel(
                panelTitle: cal.title,
                subtitle: cal.subtitle,
                calendarRows: cal.rows,
                driverRows: driverRows,
                teamRows: teamRows,
                refreshSource: cache.meta.lastRefreshSource,
                lastUpdated: cache.meta.lastRefreshTs > 0 ? Date(timeIntervalSince1970: cache.meta.lastRefreshTs) : nil
            )

            cache.lastGoodModel = model
            saveCache(cache)

            let nextRefreshInterval = max(cache.meta.refreshInterval, 15 * 60)
            return DashboardPayload(model: model, refreshInterval: nextRefreshInterval)
        } catch {
            let cache = loadCache()
            if let lastGood = cache.lastGoodModel {
                return DashboardPayload(model: lastGood, refreshInterval: max(cache.meta.refreshInterval, 15 * 60))
            }

            let fallback = WidgetViewModel(
                panelTitle: "F1 !",
                subtitle: "Data unavailable",
                calendarRows: [.init(text: "Calendar unavailable (network/API error).", dim: false)],
                driverRows: ["Standings unavailable"],
                teamRows: ["Standings unavailable"],
                refreshSource: "CACHE",
                lastUpdated: nil
            )
            return DashboardPayload(model: fallback, refreshInterval: OpenF1Config.refreshWeekendSeconds)
        }
    }

    public func requestManualRefresh() {
        let defaults = sharedDefaults()
        defaults.set(true, forKey: Keys.forceRefresh)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Calendar logic

    private func buildCalendarView(
        meetings: [Meeting],
        sessions: [Session],
        now: Date
    ) -> (title: String, subtitle: String, rows: [CalendarRow]) {
        guard !meetings.isEmpty, !sessions.isEmpty else {
            return (
                "F1 -",
                "No schedule data",
                [.init(text: "No schedule data", dim: false)]
            )
        }

        var byMeeting: [Int: [Session]] = [:]
        for s in sessions {
            byMeeting[s.meeting_key, default: []].append(s)
        }
        for key in byMeeting.keys {
            byMeeting[key]?.sort { parseDate($0.date_start) < parseDate($1.date_start) }
        }

        let sortedMeetings = meetings.sorted { parseDate($0.date_start) < parseDate($1.date_start) }

        var selectedMeeting: Meeting?
        var selectedSessions: [Session] = []
        var nextSession: Session?

        for meeting in sortedMeetings {
            let mStart = parseDate(meeting.date_start)
            let mEnd = parseDate(meeting.date_end)
            let active = (byMeeting[meeting.meeting_key] ?? []).filter { !($0.is_cancelled ?? false) }

            if active.isEmpty { continue } // Skip fully canceled weekends

            if now < mStart {
                selectedMeeting = meeting
                selectedSessions = active
                nextSession = active.first
                break
            }

            if now >= mStart && now <= mEnd {
                selectedMeeting = meeting
                selectedSessions = active
                nextSession = active.first(where: { now < parseDate($0.date_start) })
                break
            }
        }

        // Fallback: if no active meeting window matched, use first upcoming non-cancelled meeting.
        if selectedMeeting == nil {
            for meeting in sortedMeetings {
                let mStart = parseDate(meeting.date_start)
                let active = (byMeeting[meeting.meeting_key] ?? []).filter { !($0.is_cancelled ?? false) }
                if active.isEmpty { continue }
                if now < mStart {
                    selectedMeeting = meeting
                    selectedSessions = active
                    nextSession = active.first
                    break
                }
            }
        }

        // Final fallback: use latest non-cancelled meeting (show completed sessions instead of empty panel).
        if selectedMeeting == nil {
            for meeting in sortedMeetings.reversed() {
                let active = (byMeeting[meeting.meeting_key] ?? []).filter { !($0.is_cancelled ?? false) }
                if active.isEmpty { continue }
                selectedMeeting = meeting
                selectedSessions = active
                nextSession = active.first(where: { now < parseDate($0.date_start) })
                break
            }
        }

        guard let meeting = selectedMeeting else {
            return (
                "F1 ✓",
                "No upcoming weekend",
                [.init(text: "No upcoming weekend this season", dim: false)]
            )
        }

        let flag = countryFlag(code: meeting.country_code)
        let code = meeting.country_code ?? "N/A"
        let location = sanitize(meeting.location ?? "Unknown")
        let name = sanitize(meeting.meeting_name ?? "Race Weekend")

        var rows: [CalendarRow] = []
        rows.append(.init(text: "Sessions (Local / UTC / System):", dim: true))

        let tz = meeting.gmt_offset ?? "+00:00"
        for s in selectedSessions.prefix(8) {
            let marker = (nextSession?.session_key == s.session_key) ? "➡" : "•"
            let short = abbreviateSessionName(s.session_name)
            let local = formatWithOffset(parseDate(s.date_start), offset: tz)
            let utc = formatUTC(parseDate(s.date_start))
            let sys = formatLocal(parseDate(s.date_start))
            rows.append(.init(text: "\(marker) \(short): \(local) / \(utc) / \(sys)", dim: false))
        }

        let title: String
        if let next = nextSession {
            title = "\(flag) \(abbreviateSessionName(next.session_name))"
        } else {
            title = "\(flag) done"
        }

        return (title, "\(name) · \(location)", rows)
    }

    // MARK: - Standings logic

    private func buildStandings(sessions: [Session], now: Date, cache: inout CacheEnvelope) async throws -> (drivers: [StandingDriver], teams: [StandingTeam], source: String) {
        let raceLike = sessions.filter { s in
            let n = (s.session_name ?? "").lowercased()
            let t = (s.session_type ?? "").lowercased()
            return n == "race" || n == "sprint" || t == "race" || t == "sprint"
        }
        .sorted { parseDate($0.date_start) < parseDate($1.date_start) }

        let completed = raceLike.filter { s in
            !((s.is_cancelled) ?? false) && now >= parseDate(s.date_end ?? s.date_start)
        }

        guard !completed.isEmpty else { return ([], [], "CACHE") }

        let latest = completed.last!
        let latestDirectory = (try? await loadDriverDirectory(sessionKey: latest.session_key, cache: &cache)) ?? [:]

        var apiUsed = false

        for s in completed {
            let sk = String(s.session_key)
            if cache.standings.sessionPoints[sk] != nil { continue }

            let endDate = parseDate(s.date_end ?? s.date_start)
            let isPast = Date().timeIntervalSince(endDate) > 2 * 60 * 60
            let maxAge = isPast ? OpenF1Config.resultCacheSeconds : OpenF1Config.refreshWeekendSeconds

            do {
                let resultResp = try await fetchJSONCached(
                    query: "session_result?session_key=\(s.session_key)",
                    type: [SessionResult].self,
                    maxAge: maxAge,
                    forceApi: false,
                    cache: &cache
                )
                apiUsed = apiUsed || resultResp.source == "API"

                var perSession: [String: Double] = [:]
                for r in resultResp.value {
                    guard let dn = r.driver_number else { continue }
                    let points = r.points ?? 0
                    let key = String(dn)
                    perSession[key, default: 0] += points

                    let dInfo = latestDirectory[key]
                    let name = sanitize(r.full_name ?? r.broadcast_name ?? dInfo?.name ?? "#\(dn)")
                    let team = sanitize(r.team_name ?? dInfo?.team ?? "Unknown Team")

                    if cache.standings.driverInfo[key] == nil {
                        cache.standings.driverInfo[key] = .init(name: name, team: team)
                    } else {
                        if cache.standings.driverInfo[key]?.name.hasPrefix("#") == true { cache.standings.driverInfo[key]?.name = name }
                        if cache.standings.driverInfo[key]?.team == "Unknown Team" { cache.standings.driverInfo[key]?.team = team }
                    }
                }

                if !perSession.isEmpty {
                    cache.standings.sessionPoints[sk] = perSession
                }
            } catch {
                // Keep processing other sessions; one failed endpoint should not erase standings.
                continue
            }
        }

        for (dkey, info) in latestDirectory {
            if cache.standings.driverInfo[dkey] == nil {
                cache.standings.driverInfo[dkey] = .init(name: info.name, team: info.team)
            }
        }

        var pointsByDriver: [String: Double] = [:]
        for s in completed {
            let sk = String(s.session_key)
            let per = cache.standings.sessionPoints[sk] ?? [:]
            for (d, p) in per {
                pointsByDriver[d, default: 0] += p
            }
        }

        // Include all known drivers (directory/cache), even with 0 points, for fuller season standings.
        for key in cache.standings.driverInfo.keys {
            pointsByDriver[key, default: 0] += 0
        }
        for key in latestDirectory.keys {
            pointsByDriver[key, default: 0] += 0
        }

        var teamPoints: [String: Double] = [:]
        let driversSorted = pointsByDriver
            .map { key, points -> StandingDriver in
                let info = cache.standings.driverInfo[key] ?? .init(name: "#\(key)", team: "Unknown Team")
                let team = sanitize(info.team)
                teamPoints[team, default: 0] += points
                return StandingDriver(rank: 0, driverNumber: key, name: sanitize(info.name), team: team, points: points)
            }
            .sorted {
                if $0.points == $1.points { return $0.name < $1.name }
                return $0.points > $1.points
            }
            .enumerated()
            .map { idx, d in
                StandingDriver(rank: idx + 1, driverNumber: d.driverNumber, name: d.name, team: d.team, points: d.points)
            }

        let teamsSorted = teamPoints
            .map { StandingTeam(rank: 0, team: sanitize($0.key), points: $0.value) }
            .sorted {
                if $0.points == $1.points { return $0.team < $1.team }
                return $0.points > $1.points
            }
            .enumerated()
            .map { idx, t in StandingTeam(rank: idx + 1, team: t.team, points: t.points) }

        saveCache(cache)
        return (driversSorted, teamsSorted, apiUsed ? "API" : "CACHE")
    }

    private func loadDriverDirectory(sessionKey: Int, cache: inout CacheEnvelope) async throws -> [String: (name: String, team: String)] {
        let resp = try await fetchJSONCached(
            query: "drivers?session_key=\(sessionKey)",
            type: [DriverDirectoryEntry].self,
            maxAge: OpenF1Config.resultCacheSeconds,
            forceApi: false,
            cache: &cache
        )

        var map: [String: (name: String, team: String)] = [:]
        for d in resp.value {
            guard let dn = d.driver_number else { continue }
            let key = String(dn)
            let name = sanitize(d.full_name ?? d.broadcast_name ?? d.last_name ?? "#\(dn)")
            let team = sanitize(d.team_name ?? d.team_colour ?? "Unknown Team")
            map[key] = (name: name, team: team)
        }
        return map
    }

    // MARK: - Fetch/cache

    private func fetchJSONCached<T: Decodable>(
        query: String,
        type: T.Type,
        maxAge: TimeInterval,
        forceApi: Bool,
        cache: inout CacheEnvelope
    ) async throws -> (value: T, source: String) {
        if !forceApi, let cached: T = endpointDecode(query: query, maxAge: maxAge, cache: cache) {
            return (cached, "CACHE")
        }

        guard isValidPathAndQuery(query) else {
            throw URLError(.badURL)
        }

        let data = try await fetchData(query: query)
        endpointSet(query: query, data: data, cache: &cache)
        saveCache(cache)

        let decoded = try JSONDecoder().decode(T.self, from: data)
        return (decoded, "API")
    }

    private func fetchData(query: String) async throws -> Data {
        let parts = query.split(separator: "?", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { throw URLError(.badURL) }

        let endpoint = parts[0]
        let queryString = parts[1]

        guard OpenF1Config.allowedEndpoints.contains(endpoint) else { throw URLError(.unsupportedURL) }

        var comps = URLComponents(url: OpenF1Config.apiBase.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)
        comps?.percentEncodedQuery = queryString

        guard let url = comps?.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: req)

        if data.count > OpenF1Config.maxResponseBytes {
            throw NSError(domain: "OpenF1", code: 413, userInfo: [NSLocalizedDescriptionKey: "API response too large"])
        }

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if http.statusCode == 429 {
            throw NSError(domain: "OpenF1", code: 429, userInfo: [NSLocalizedDescriptionKey: "OpenF1 API rate limited"])
        }

        guard (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "OpenF1", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
        }

        return data
    }

    // MARK: - Cache storage

    private func cacheURL() -> URL? {
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupConfig.identifier) {
            return container.appendingPathComponent(Keys.cacheFile)
        }

        // Fallback for environments where App Groups are unavailable (e.g., some Personal Team setups).
        if let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return caches.appendingPathComponent(Keys.cacheFile)
        }

        return nil
    }

    private func loadCache() -> CacheEnvelope {
        guard let url = cacheURL() else { return .empty }
        guard let data = try? Data(contentsOf: url) else { return .empty }

        if data.count > OpenF1Config.maxCacheBytes { return .empty }
        return (try? JSONDecoder().decode(CacheEnvelope.self, from: data)) ?? .empty
    }

    private func saveCache(_ cache: CacheEnvelope) {
        guard let url = cacheURL() else { return }

        var mutable = cache
        if mutable.endpoints.count > OpenF1Config.maxEndpointEntries {
            let sorted = mutable.endpoints.sorted { $0.value.ts > $1.value.ts }
            let limited: [(String, CacheEnvelope.EndpointEntry)] = sorted
                .prefix(OpenF1Config.maxEndpointEntries)
                .map { ($0.key, $0.value) }
            mutable.endpoints = Dictionary(uniqueKeysWithValues: limited)
        }

        guard let data = try? JSONEncoder().encode(mutable) else { return }
        guard data.count <= OpenF1Config.maxCacheBytes else { return }

        try? data.write(to: url, options: .atomic)
    }

    private func endpointDecode<T: Decodable>(query: String, maxAge: TimeInterval, cache: CacheEnvelope) -> T? {
        guard let entry = cache.endpoints[query] else { return nil }
        if Date().timeIntervalSince1970 - entry.ts > maxAge { return nil }
        return try? JSONDecoder().decode(T.self, from: entry.data)
    }

    private func endpointSet(query: String, data: Data, cache: inout CacheEnvelope) {
        cache.endpoints[query] = .init(ts: Date().timeIntervalSince1970, data: data)
    }

    // MARK: - Policy / helpers

    private func isRaceWeekend(meetings: [Meeting], sessions: [Session], now: Date) -> Bool {
        var byMeeting: [Int: [Session]] = [:]
        for s in sessions {
            byMeeting[s.meeting_key, default: []].append(s)
        }

        let sorted = meetings.sorted { parseDate($0.date_start) < parseDate($1.date_start) }
        for m in sorted {
            let active = (byMeeting[m.meeting_key] ?? []).filter { !($0.is_cancelled ?? false) }.sorted { parseDate($0.date_start) < parseDate($1.date_start) }
            if active.isEmpty { continue }

            let start = parseDate(m.date_start)
            let end = parseDate(m.date_end)

            if now >= start && now <= end { return true }
            if now < start, let first = active.first {
                let delta = parseDate(first.date_start).timeIntervalSince(now)
                return delta <= 72 * 60 * 60
            }
        }

        return false
    }

    private func isValidPathAndQuery(_ pathAndQuery: String) -> Bool {
        let parts = pathAndQuery.split(separator: "?", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return false }

        let endpoint = parts[0]
        let query = parts[1]

        guard OpenF1Config.allowedEndpoints.contains(endpoint) else { return false }

        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_=&.,:%+\\-]*$", options: [])
        let range = NSRange(location: 0, length: query.utf16.count)
        return regex.firstMatch(in: query, options: [], range: range) != nil
    }

    private func sharedDefaults() -> UserDefaults {
        UserDefaults(suiteName: AppGroupConfig.identifier) ?? .standard
    }

    private func consumeForceRefreshFlag() -> Bool {
        let defaults = sharedDefaults()
        let force = defaults.bool(forKey: Keys.forceRefresh)
        if force {
            defaults.set(false, forKey: Keys.forceRefresh)
        }
        return force
    }

    private func parseDate(_ iso: String) -> Date {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: iso) { return d }

        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        return f2.date(from: iso) ?? Date.distantPast
    }

    private func sanitize(_ s: String, maxLen: Int = 160) -> String {
        let controls = CharacterSet.controlCharacters
        let cleaned = s.unicodeScalars.map { controls.contains($0) ? " " : String($0) }.joined()
        let normalized = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.count <= maxLen { return normalized }
        return String(normalized.prefix(maxLen - 1)) + "…"
    }

    private func abbreviateSessionName(_ name: String?) -> String {
        let n = (name ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if n == "practice 1" || n == "free practice 1" { return "FP1" }
        if n == "practice 2" || n == "free practice 2" { return "FP2" }
        if n == "practice 3" || n == "free practice 3" { return "FP3" }
        if n == "practice" { return "FP" }
        if n == "qualifying" { return "Q" }
        if n == "sprint qualifying" || n == "sprint shootout" { return "SQ" }
        if n == "sprint" { return "SPR" }
        if n == "race" { return "R" }

        let parts = n.split(separator: " ").map(String.init)
        return parts.prefix(3).compactMap { $0.first?.uppercased() }.joined()
    }

    private func countryFlag(code: String?) -> String {
        guard let code else { return "🏁" }
        let upper = code.uppercased()
        let map: [String: String] = [
            "AUS": "AU", "CHN": "CN", "JPN": "JP", "BHR": "BH", "SAU": "SA", "KSA": "SA",
            "USA": "US", "ITA": "IT", "GBR": "GB", "BEL": "BE", "HUN": "HU", "NLD": "NL",
            "AZE": "AZ", "SGP": "SG", "MEX": "MX", "BRA": "BR", "QAT": "QA", "ARE": "AE",
            "UAE": "AE", "CAN": "CA", "ESP": "ES", "MCO": "MC", "AUT": "AT", "FRA": "FR"
        ]

        let alpha2: String
        if upper.count == 2 { alpha2 = upper }
        else if upper.count == 3, let c = map[upper] { alpha2 = c }
        else { return "🏁" }

        let scalars = alpha2.unicodeScalars.compactMap { UnicodeScalar(127397 + Int($0.value)) }
        return String(String.UnicodeScalarView(scalars))
    }

    private func formatUTC(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f.string(from: date)
    }

    private func formatLocal(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm"
        f.timeZone = .current
        return f.string(from: date)
    }

    private func formatWithOffset(_ date: Date, offset: String) -> String {
        let secs = parseOffsetSeconds(offset)
        let tz = TimeZone(secondsFromGMT: secs) ?? .current
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm"
        f.timeZone = tz
        return f.string(from: date)
    }

    private func parseOffsetSeconds(_ offset: String) -> Int {
        // Examples: +02:00, -05:30
        guard offset.count >= 6 else { return 0 }
        let sign = offset.hasPrefix("-") ? -1 : 1
        let parts = offset.dropFirst().split(separator: ":").map(String.init)
        guard parts.count == 2, let hh = Int(parts[0]), let mm = Int(parts[1]) else { return 0 }
        return sign * ((hh * 3600) + (mm * 60))
    }

    private func formattedRefresh(ts: TimeInterval) -> String {
        guard ts > 0 else { return "never" }
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm z"
        return f.string(from: Date(timeIntervalSince1970: ts))
    }

    private func formatDriverRows(_ drivers: [StandingDriver]) -> [String] {
        if drivers.isEmpty { return ["No completed race results yet"] }
        return drivers.prefix(10).map { d in
            let pts = Int(d.points.rounded())
            return "\(d.rank). \(sanitize(d.name, maxLen: 40)) \(pts)p"
        }
    }

    private func formatTeamRows(_ teams: [StandingTeam]) -> [String] {
        if teams.isEmpty { return ["No completed race results yet"] }
        return teams.prefix(11).map { t in
            let pts = Int(t.points.rounded())
            return "\(t.rank). \(sanitize(t.team, maxLen: 40)) \(pts)p"
        }
    }

    private func fit(_ s: String, width: Int) -> String {
        if s.count == width { return s }
        if s.count < width { return s + String(repeating: " ", count: width - s.count) }
        if width <= 1 { return String(s.prefix(width)) }
        return String(s.prefix(width - 1)) + "…"
    }
}
