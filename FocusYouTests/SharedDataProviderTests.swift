import XCTest
@testable import Focus_You

final class SharedDataProviderTests: XCTestCase {

    // MARK: - Placeholder

    func testPlaceholderHasDefaultValues() {
        let placeholder = SharedDataProvider.placeholder
        XCTAssertFalse(placeholder.isFocusing)
        XCTAssertEqual(placeholder.timerMode, "free")
        XCTAssertEqual(placeholder.remainingSeconds, 0)
        XCTAssertEqual(placeholder.totalSeconds, 0)
        XCTAssertEqual(placeholder.currentStreak, 0)
        XCTAssertEqual(placeholder.longestStreak, 0)
    }

    func testPlaceholderThemeColors() {
        let placeholder = SharedDataProvider.placeholder
        XCTAssertFalse(placeholder.themePrimaryHex.isEmpty)
        XCTAssertFalse(placeholder.themeAccentHex.isEmpty)
        XCTAssertTrue(placeholder.themePrimaryHex.hasPrefix("#"))
        XCTAssertTrue(placeholder.themeAccentHex.hasPrefix("#"))
    }

    // MARK: - SharedFocusData Codable

    func testSharedFocusDataEncodeDecode() throws {
        let original = SharedFocusData(
            isFocusing: true,
            timerMode: "pomodoro",
            remainingSeconds: 1234,
            totalSeconds: 1500,
            currentStreak: 5,
            longestStreak: 10,
            todayFocusMinutes: 120,
            todaySessionCount: 4,
            themePrimaryHex: "#E63946",
            themeAccentHex: "#2A9D8F",
            updatedAt: Date(timeIntervalSince1970: 1000000)
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SharedFocusData.self, from: data)

        XCTAssertEqual(decoded.isFocusing, original.isFocusing)
        XCTAssertEqual(decoded.timerMode, original.timerMode)
        XCTAssertEqual(decoded.remainingSeconds, original.remainingSeconds)
        XCTAssertEqual(decoded.totalSeconds, original.totalSeconds)
        XCTAssertEqual(decoded.currentStreak, original.currentStreak)
        XCTAssertEqual(decoded.longestStreak, original.longestStreak)
        XCTAssertEqual(decoded.todayFocusMinutes, original.todayFocusMinutes)
        XCTAssertEqual(decoded.themePrimaryHex, original.themePrimaryHex)
        XCTAssertEqual(decoded.themeAccentHex, original.themeAccentHex)
    }

    // MARK: - Constants

    func testAppGroupsIdentifier() {
        XCTAssertFalse(Constants.AppGroups.identifier.isEmpty)
        XCTAssertTrue(Constants.AppGroups.identifier.hasPrefix("group."))
    }

    func testWidgetConstants() {
        XCTAssertFalse(Constants.Widget.focusStatusKind.isEmpty)
        XCTAssertFalse(Constants.Widget.streakKind.isEmpty)
        XCTAssertGreaterThan(Constants.Widget.refreshInterval, 0)
    }
}
