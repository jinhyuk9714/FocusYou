import XCTest
@testable import Focus_You

final class AmbientSoundManagerTests: XCTestCase {

    func testPlayAndStop() async {
        let manager = AmbientSoundManager.shared

        await manager.play(track: .whiteNoise, volume: 0.5)
        let playing = await manager.isPlaying
        XCTAssertTrue(playing, "play 후 isPlaying이 true여야 합니다")

        await manager.stop()
        let stopped = await manager.isPlaying
        XCTAssertFalse(stopped, "stop 후 isPlaying이 false여야 합니다")
    }

    func testPauseAndResume() async {
        let manager = AmbientSoundManager.shared

        await manager.play(track: .brownNoise, volume: 0.3)
        let playing = await manager.isPlaying
        XCTAssertTrue(playing)

        await manager.pause()
        let paused = await manager.isPlaying
        XCTAssertFalse(paused, "pause 후 isPlaying이 false여야 합니다")

        await manager.resume()
        let resumed = await manager.isPlaying
        XCTAssertTrue(resumed, "resume 후 isPlaying이 true여야 합니다")

        await manager.stop()
    }

    func testSetVolume() async {
        let manager = AmbientSoundManager.shared

        await manager.play(track: .pinkNoise, volume: 0.5)
        await manager.setVolume(0.8)

        // 재생이 유지되는지 확인
        let playing = await manager.isPlaying
        XCTAssertTrue(playing, "볼륨 변경 후에도 재생이 유지되어야 합니다")

        await manager.stop()
    }

    func testStopWithoutPlayDoesNotCrash() async {
        let manager = AmbientSoundManager.shared

        // play 없이 stop 호출 — 크래시 없이 통과해야 함
        await manager.stop()
        let playing = await manager.isPlaying
        XCTAssertFalse(playing)
    }

    func testAllTrackTypes() async {
        let manager = AmbientSoundManager.shared

        for track in AmbientSoundTrack.allCases {
            await manager.play(track: track, volume: 0.3)
            let playing = await manager.isPlaying
            XCTAssertTrue(playing, "\(track.rawValue) 재생 실패")
            await manager.stop()
        }
    }
}
