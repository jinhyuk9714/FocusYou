import Foundation
import SwiftData

// MARK: - 차단 스케줄 모델 (v1.3)
// 요일별 자동 차단 시작/종료 스케줄

@Model
final class BlockSchedule {
    /// 스케줄 이름 (예: "오전 딥워크")
    var name: String

    /// 활성 요일 (1=일, 2=월, ..., 7=토) — 쉼표 구분 문자열 "2,3,4,5,6"
    var weekdays: String

    /// 시작 시각 (분 단위, 0~1439, 예: 540 = 09:00)
    var startMinuteOfDay: Int

    /// 종료 시각 (분 단위)
    var endMinuteOfDay: Int

    /// 활성 여부
    var isEnabled: Bool

    /// 소속 프로필
    var profile: BlockProfile?

    /// 생성 일시
    var createdAt: Date

    init(
        name: String,
        weekdays: String = "2,3,4,5,6",
        startMinuteOfDay: Int = 540,
        endMinuteOfDay: Int = 720
    ) {
        self.name = name
        self.weekdays = weekdays
        self.startMinuteOfDay = startMinuteOfDay
        self.endMinuteOfDay = endMinuteOfDay
        self.isEnabled = true
        self.createdAt = .now
    }

    // MARK: - Computed Helpers

    /// 요일 배열 변환 (1=일, 2=월, ..., 7=토)
    var weekdayArray: [Int] {
        weekdays.split(separator: ",").compactMap { Int($0) }
    }

    /// 시작 시각 포맷 (HH:mm)
    var startTimeFormatted: String {
        String(format: "%02d:%02d", startMinuteOfDay / 60, startMinuteOfDay % 60)
    }

    /// 종료 시각 포맷 (HH:mm)
    var endTimeFormatted: String {
        String(format: "%02d:%02d", endMinuteOfDay / 60, endMinuteOfDay % 60)
    }

    /// 요일 표시용 문자열 (예: "월화수목금")
    var weekdayDisplayText: String {
        let symbols = Constants.Schedule.weekdaySymbols
        return weekdayArray
            .sorted()
            .compactMap { index in
                guard index >= 1, index <= 7 else { return nil }
                return symbols[index - 1]
            }
            .joined()
    }
}
