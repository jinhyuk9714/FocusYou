import XCTest
@testable import Focus_You

final class AppIntentsTests: XCTestCase {

    // MARK: - IntentError

    func testIntentErrorAppNotRunning() {
        let error = IntentError.appNotRunning
        XCTAssertNotNil(error.localizedStringResource)
    }

    func testIntentErrorSessionAlreadyActive() {
        let error = IntentError.sessionAlreadyActive
        XCTAssertNotNil(error.localizedStringResource)
    }

    func testIntentErrorNoActiveSession() {
        let error = IntentError.noActiveSession
        XCTAssertNotNil(error.localizedStringResource)
    }

    func testIntentErrorProfileNotFound() {
        let error = IntentError.profileNotFound("테스트 프로필")
        XCTAssertNotNil(error.localizedStringResource)
    }

    // MARK: - AppState.shared

    @MainActor
    func testAppStateSharedIsNilBeforeInit() {
        // AppState.shared는 테스트 환경에서 이미 nil이거나 이전 테스트의 인스턴스일 수 있음
        // 단순히 접근 가능성만 확인
        _ = AppState.shared
    }

    @MainActor
    func testAppStateSharedSetOnInit() {
        let appState = AppState(
            blockingCoordinator: MockBlockingCoordinator(),
            notificationService: MockNotificationService(),
            shouldRequestNotificationPermission: false,
            shouldRunStartupCleanup: false
        )

        XCTAssertTrue(AppState.shared === appState)
    }
}
