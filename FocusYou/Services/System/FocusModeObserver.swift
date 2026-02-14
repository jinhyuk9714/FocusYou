import Foundation
import SwiftData
import os

// MARK: - macOS Focus Mode 연동 (v1.4)
// 시스템 집중 모드(방해금지) 활성화/비활성화를 감지하여 자동 세션 시작/종료

@MainActor
@Observable
final class FocusModeObserver {
    static let shared = FocusModeObserver()

    private(set) var isSystemFocusModeActive = false
    private var notificationObserver: NSObjectProtocol?
    private weak var appState: AppState?
    private var modelContext: ModelContext?

    private let logger = Logger(
        subsystem: Constants.App.subsystem,
        category: "FocusModeObserver"
    )

    private init() {}

    // MARK: - Public

    func startObserving(appState: AppState, modelContext: ModelContext) {
        self.appState = appState
        self.modelContext = modelContext

        // DistributedNotificationCenter를 통한 DND 상태 변경 감시
        // macOS 12+ 에서 "com.apple.doNotDisturbChanged" 알림 발송
        notificationObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.doNotDisturbChanged"),
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.handleDNDStateChanged()
            }
        }

        logger.info("Focus Mode 감시 시작")
    }

    func stopObserving() {
        if let observer = notificationObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
            notificationObserver = nil
        }
        appState = nil
        modelContext = nil
        logger.info("Focus Mode 감시 중지")
    }

    // MARK: - Private

    private func handleDNDStateChanged() async {
        // userInfo에서 상태 추출 시도
        let isActive = detectCurrentFocusModeState()

        guard isActive != isSystemFocusModeActive else { return }
        isSystemFocusModeActive = isActive

        logger.info("Focus Mode 상태 변경: \(isActive ? "활성" : "비활성")")

        guard let appState, let modelContext else { return }

        if isActive && appState.focusState == .idle {
            // Focus Mode 활성화 → 기본 프로필로 세션 시작
            let profiles = (try? modelContext.fetch(FetchDescriptor<BlockProfile>())) ?? []
            if let defaultProfile = profiles.first(where: \.isDefault) ?? profiles.first {
                await appState.startSessionFromProfile(defaultProfile, modelContext: modelContext)
                logger.info("Focus Mode 연동: 기본 프로필로 세션 자동 시작")
            }
        } else if !isActive && (appState.focusState == .focusing || appState.focusState == .paused) {
            // Focus Mode 비활성화 → 세션 중지
            if appState.canCancel {
                await appState.stopSession(modelContext: modelContext)
                logger.info("Focus Mode 연동: 세션 자동 중지")
            }
        }
    }

    /// 현재 시스템 Focus Mode 상태 감지
    /// NSDoNotDisturbEnabled 키를 통해 DND 상태 확인
    private func detectCurrentFocusModeState() -> Bool {
        // macOS DND 상태는 CFPreferences로 확인 가능
        let dndDefaults = UserDefaults(suiteName: "com.apple.controlcenter")
        return dndDefaults?.bool(forKey: "NSDoNotDisturbEnabled") ?? false
    }
}
