import Foundation
import SwiftData

// MARK: - 배지 모델 (v1.5)
// 마일스톤 달성 시 획득하는 배지

@Model
final class Badge {
    /// 마일스톤 타입 식별자 (예: "streak_7", "hours_50")
    var milestoneID: String

    /// 배지 제목
    var title: String

    /// 배지 이모지/심볼
    var emoji: String

    /// 배지 설명
    var desc: String

    /// 획득 일시
    var achievedAt: Date

    init(
        milestoneID: String,
        title: String,
        emoji: String,
        desc: String
    ) {
        self.milestoneID = milestoneID
        self.title = title
        self.emoji = emoji
        self.desc = desc
        self.achievedAt = .now
    }
}
