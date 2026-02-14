import AppIntents

// MARK: - Shortcuts / Siri 자동 노출

struct FocusYouShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusIntent(),
            phrases: [
                "Start focusing in \(.applicationName)",
                "\(.applicationName)에서 집중 시작",
                "\(.applicationName) 집중",
            ],
            shortTitle: "집중 시작",
            systemImageName: "timer"
        )

        AppShortcut(
            intent: StopFocusIntent(),
            phrases: [
                "Stop focusing in \(.applicationName)",
                "\(.applicationName) 집중 중지",
            ],
            shortTitle: "집중 중지",
            systemImageName: "stop.fill"
        )

        AppShortcut(
            intent: TogglePauseIntent(),
            phrases: [
                "Pause \(.applicationName)",
                "\(.applicationName) 일시정지",
            ],
            shortTitle: "일시정지",
            systemImageName: "pause.fill"
        )

        AppShortcut(
            intent: GetFocusStatusIntent(),
            phrases: [
                "How's my focus in \(.applicationName)",
                "\(.applicationName) 상태",
            ],
            shortTitle: "상태 확인",
            systemImageName: "info.circle"
        )

        AppShortcut(
            intent: GetStreakIntent(),
            phrases: [
                "My focus streak in \(.applicationName)",
                "\(.applicationName) 스트릭",
            ],
            shortTitle: "스트릭",
            systemImageName: "flame.fill"
        )
    }
}
