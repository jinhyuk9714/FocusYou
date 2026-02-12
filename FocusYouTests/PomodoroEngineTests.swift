import XCTest
@testable import Focus_You

@MainActor
final class PomodoroEngineTests: XCTestCase {
    func testBuildPhasesCreatesExpectedOrderForFourCycles() {
        let configuration = PomodoroConfiguration(
            focusMinutes: 25,
            shortBreakMinutes: 5,
            longBreakMinutes: 15,
            cycles: 4
        )

        let phases = PomodoroEngine.buildPhases(configuration: configuration)

        XCTAssertEqual(phases.count, 8)
        XCTAssertEqual(phases.first?.type, .focus)
        XCTAssertEqual(phases[1].type, .shortBreak)
        XCTAssertEqual(phases[3].type, .shortBreak)
        XCTAssertEqual(phases[5].type, .shortBreak)
        XCTAssertEqual(phases.last?.type, .longBreak)
        XCTAssertEqual(phases.last?.cycleIndex, 4)
    }

    func testAdvancePhaseMovesUntilEndThenReturnsNil() {
        let engine = PomodoroEngine()
        let configuration = PomodoroConfiguration(
            focusMinutes: 20,
            shortBreakMinutes: 5,
            longBreakMinutes: 10,
            cycles: 2
        )

        let first = engine.start(configuration: configuration)
        XCTAssertEqual(first?.type, .focus)
        XCTAssertEqual(first?.cycleIndex, 1)

        let second = engine.advancePhase()
        XCTAssertEqual(second?.type, .shortBreak)
        XCTAssertEqual(second?.cycleIndex, 1)

        let third = engine.advancePhase()
        XCTAssertEqual(third?.type, .focus)
        XCTAssertEqual(third?.cycleIndex, 2)

        let fourth = engine.advancePhase()
        XCTAssertEqual(fourth?.type, .longBreak)
        XCTAssertEqual(fourth?.cycleIndex, 2)

        XCTAssertNil(engine.advancePhase())
    }
}
