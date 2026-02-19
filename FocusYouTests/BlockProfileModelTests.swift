import XCTest
import SwiftData
@testable import Focus_You

final class BlockProfileModelTests: XCTestCase {

    // MARK: - 초기값 검증

    func testBlockProfileDefaultValues() {
        let profile = BlockProfile(name: "Test")
        XCTAssertEqual(profile.name, "Test")
        XCTAssertEqual(profile.icon, "shield.fill")
        XCTAssertEqual(profile.color, "#E63946")
        XCTAssertEqual(profile.timerMode, "free")
        XCTAssertEqual(profile.focusDuration, 25 * 60)
        XCTAssertEqual(profile.breakDuration, 5 * 60)
        XCTAssertEqual(profile.longBreakDuration, 15 * 60)
        XCTAssertEqual(profile.pomodoroCount, 4)
        XCTAssertFalse(profile.isDefault)
        XCTAssertEqual(profile.blocklistMode, "blocklist")
        XCTAssertEqual(profile.cancelIntensity, 0)
        XCTAssertEqual(profile.cancelLockoutMinutes, 5)
    }

    func testBlockProfileTimerModes() {
        let profile = BlockProfile(name: "Test")

        profile.timerMode = "free"
        XCTAssertEqual(profile.timerMode, "free")

        profile.timerMode = "pomodoro"
        XCTAssertEqual(profile.timerMode, "pomodoro")

        profile.timerMode = "flowmodoro"
        XCTAssertEqual(profile.timerMode, "flowmodoro")
    }

    func testBlockProfileCancelIntensityLevels() {
        let profile = BlockProfile(name: "Test")

        profile.cancelIntensity = 0
        XCTAssertEqual(profile.cancelIntensity, 0)

        profile.cancelIntensity = 1
        XCTAssertEqual(profile.cancelIntensity, 1)

        profile.cancelIntensity = 2
        XCTAssertEqual(profile.cancelIntensity, 2)
    }

    func testSetAsDefaultUpdatesFlag() {
        let profile1 = BlockProfile(name: "Profile 1")
        let profile2 = BlockProfile(name: "Profile 2")
        profile1.isDefault = true

        profile2.setAsDefault(allProfiles: [profile1, profile2])

        XCTAssertFalse(profile1.isDefault)
        XCTAssertTrue(profile2.isDefault)
    }

    func testBlockProfileBlocklistModes() {
        let profile = BlockProfile(name: "Test")

        XCTAssertEqual(profile.blocklistMode, "blocklist")

        profile.blocklistMode = "allowlist"
        XCTAssertEqual(profile.blocklistMode, "allowlist")
    }
}
