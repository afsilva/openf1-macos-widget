import AppIntents

struct RefreshNowIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh OpenF1 Now"
    static var description = IntentDescription("Force the OpenF1 widget to refresh from API/cache policy immediately.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        OpenF1Service().requestManualRefresh()
        return .result()
    }
}
