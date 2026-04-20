import Foundation

// MARK: - API models

public struct Meeting: Codable, Hashable {
    public let meeting_key: Int
    public let meeting_name: String?
    public let country_code: String?
    public let location: String?
    public let date_start: String
    public let date_end: String
    public let gmt_offset: String?
}

public struct Session: Codable, Hashable {
    public let session_key: Int
    public let meeting_key: Int
    public let session_name: String?
    public let session_type: String?
    public let date_start: String
    public let date_end: String?
    public let is_cancelled: Bool?
}

public struct SessionResult: Codable, Hashable {
    public let driver_number: Int?
    public let points: Double?
    public let full_name: String?
    public let broadcast_name: String?
    public let team_name: String?
}

public struct DriverDirectoryEntry: Codable, Hashable {
    public let driver_number: Int?
    public let full_name: String?
    public let broadcast_name: String?
    public let last_name: String?
    public let team_name: String?
    public let team_colour: String?
}

// MARK: - App models

public struct StandingDriver: Codable, Hashable {
    public let rank: Int
    public let driverNumber: String
    public let name: String
    public let team: String
    public let points: Double
}

public struct StandingTeam: Codable, Hashable {
    public let rank: Int
    public let team: String
    public let points: Double
}

public struct CalendarRow: Codable, Hashable {
    public let text: String
    public let dim: Bool
}

public struct WidgetViewModel: Codable, Hashable {
    public let panelTitle: String
    public let subtitle: String
    public let calendarRows: [CalendarRow]
    public let driverRows: [String]
    public let teamRows: [String]
    public let refreshSource: String
    public let lastUpdated: Date?
}

public struct DashboardPayload: Codable, Hashable {
    public let model: WidgetViewModel
    public let refreshInterval: TimeInterval
}
