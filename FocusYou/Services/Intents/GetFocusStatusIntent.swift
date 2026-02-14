import AppIntents

// MARK: - 현재 집중 상태 조회 인텐트

struct GetFocusStatusIntent: AppIntent {
    static let title: LocalizedStringResource = "집중 상태 확인"
    static let description: IntentDescription = "현재 집중 세션 상태를 확인합니다."

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let appState = AppState.shared else {
            throw IntentError.appNotRunning
        }

        switch appState.focusState {
        case .idle:
            return .result(dialog: "현재 집중 세션이 없습니다.")
        case .focusing:
            let remaining = appState.timer.remainingTime.formattedAsTimer
            let mode = appState.timerMode.rawValue
            return .result(dialog: "\(mode) 모드로 집중 중입니다. 남은 시간: \(remaining)")
        case .paused:
            let remaining = appState.timer.remainingTime.formattedAsTimer
            return .result(dialog: "일시정지 중입니다. 남은 시간: \(remaining)")
        case .completed:
            return .result(dialog: "집중 세션이 완료되었습니다.")
        }
    }
}
