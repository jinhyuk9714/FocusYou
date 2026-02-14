import AppIntents

// MARK: - 일시정지 토글 인텐트

struct TogglePauseIntent: AppIntent {
    static let title: LocalizedStringResource = "일시정지 토글"
    static let description: IntentDescription = "집중 세션을 일시정지하거나 재개합니다."

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let appState = AppState.shared else {
            throw IntentError.appNotRunning
        }

        switch appState.focusState {
        case .focusing:
            appState.pauseSession()
            return .result(dialog: "집중을 일시정지했습니다.")
        case .paused:
            appState.resumeSession()
            return .result(dialog: "집중을 재개했습니다.")
        default:
            return .result(dialog: "진행 중인 세션이 없습니다.")
        }
    }
}
