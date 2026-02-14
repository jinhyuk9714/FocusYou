import XCTest
@testable import Focus_You

final class AppDimmingManagerTests: XCTestCase {

    @MainActor
    func testSingletonInstance() {
        let manager = AppDimmingManager.shared
        XCTAssertNotNil(manager)
        XCTAssertTrue(manager === AppDimmingManager.shared)
    }

    @MainActor
    func testInitiallyInactive() {
        let manager = AppDimmingManager.shared
        // 이전 테스트에서 활성화됐을 수 있으므로 비활성화
        manager.deactivate()
        XCTAssertFalse(manager.isActive)
    }

    @MainActor
    func testActivateWithEmptyBundleIds() {
        let manager = AppDimmingManager.shared
        manager.deactivate()
        manager.activate(bundleIds: [], opacity: 0.3)
        // 빈 bundleIds → 활성화하지 않음
        XCTAssertFalse(manager.isActive)
    }

    @MainActor
    func testActivateAndDeactivate() {
        let manager = AppDimmingManager.shared
        manager.activate(bundleIds: ["com.test.nonexistent"], opacity: 0.3)
        XCTAssertTrue(manager.isActive)

        manager.deactivate()
        XCTAssertFalse(manager.isActive)
    }

    // MARK: - Settings Constants

    func testDimmingSettingsKeys() {
        XCTAssertEqual(Constants.Settings.enableAppDimmingKey, "enableAppDimming")
        XCTAssertFalse(Constants.Settings.enableAppDimmingDefault)
        XCTAssertEqual(Constants.Settings.dimmingOpacityDefault, 0.3, accuracy: 0.01)
    }
}
