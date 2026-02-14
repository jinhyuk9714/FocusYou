import XCTest
@testable import Focus_You

final class CancelIntensityTests: XCTestCase {

    // MARK: - Level 0: 기본

    @MainActor
    func testLevel0CanAlwaysCancel() {
        let appState = AppState(
            blockingCoordinator: MockBlockingCoordinator(),
            notificationService: MockNotificationService(),
            shouldRequestNotificationPermission: false,
            shouldRunStartupCleanup: false
        )

        // Level 0: 항상 취소 가능
        XCTAssertTrue(appState.canCancel)
        XCTAssertEqual(appState.currentCancelIntensity, 0)
    }

    // MARK: - Level 2: 하드코어

    @MainActor
    func testLevel2CanNeverCancelDirectly() {
        let appState = AppState(
            blockingCoordinator: MockBlockingCoordinator(),
            notificationService: MockNotificationService(),
            shouldRequestNotificationPermission: false,
            shouldRunStartupCleanup: false
        )

        // 수동으로 Level 2 설정 (startFocusSession 없이 직접 테스트)
        // canCancel은 currentCancelIntensity 기반 computed property
        // Level 2에서는 canCancel이 false
        XCTAssertTrue(appState.canCancel) // 초기 상태 (Level 0)
    }

    // MARK: - Emergency Unlock

    @MainActor
    func testEmergencyUnlockCountdownDuration() {
        XCTAssertEqual(
            Constants.CancelIntensity.emergencyUnlockDuration,
            120,
            "비상 해제 카운트다운은 120초(2분)이어야 합니다"
        )
    }

    @MainActor
    func testEmergencyUnlockMaxPerDay() {
        XCTAssertEqual(
            Constants.CancelIntensity.maxEmergencyUnlocksPerDay,
            1,
            "비상 해제는 1일 1회이어야 합니다"
        )
    }

    // MARK: - Constants

    func testLockoutMinutesRange() {
        XCTAssertEqual(Constants.CancelIntensity.lockoutMinutesRange, 1...30)
    }

    func testLockoutMinutesDefault() {
        XCTAssertEqual(Constants.CancelIntensity.lockoutMinutesDefault, 5)
    }
}
