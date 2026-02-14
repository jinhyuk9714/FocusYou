import XCTest
@testable import Focus_You

final class FocusModeObserverTests: XCTestCase {

    @MainActor
    func testSingletonInstance() {
        let observer = FocusModeObserver.shared
        XCTAssertNotNil(observer)
        XCTAssertTrue(observer === FocusModeObserver.shared)
    }

    @MainActor
    func testInitialStateIsInactive() {
        let observer = FocusModeObserver.shared
        XCTAssertFalse(observer.isSystemFocusModeActive)
    }

    // MARK: - Settings Constants

    func testFocusModeSettingsKey() {
        XCTAssertEqual(Constants.Settings.enableFocusModeKey, "enableFocusMode")
        XCTAssertFalse(Constants.Settings.enableFocusModeDefault)
    }
}
