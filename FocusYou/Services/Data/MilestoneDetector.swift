import Foundation
import SwiftData
import os

// MARK: - 마일스톤 감지 서비스 (v1.5)

struct Milestone: Identifiable, Equatable {
    let id: String
    let title: String
    let emoji: String
    let desc: String

    // MARK: - 스트릭 마일스톤

    static let streak7 = Milestone(
        id: "streak_7", title: "일주일 전사", emoji: "🔥",
        desc: "7일 연속 집중 달성"
    )
    static let streak30 = Milestone(
        id: "streak_30", title: "한 달의 힘", emoji: "💪",
        desc: "30일 연속 집중 달성"
    )
    static let streak100 = Milestone(
        id: "streak_100", title: "백일의 기적", emoji: "⭐",
        desc: "100일 연속 집중 달성"
    )
    static let streak365 = Milestone(
        id: "streak_365", title: "일 년의 대장정", emoji: "👑",
        desc: "365일 연속 집중 달성"
    )

    // MARK: - 누적 시간 마일스톤

    static let hours50 = Milestone(
        id: "hours_50", title: "50시간 달성", emoji: "⏱️",
        desc: "총 50시간 집중 달성"
    )
    static let hours100 = Milestone(
        id: "hours_100", title: "100시간 달성", emoji: "🎯",
        desc: "총 100시간 집중 달성"
    )
    static let hours500 = Milestone(
        id: "hours_500", title: "500시간 마스터", emoji: "🏆",
        desc: "총 500시간 집중 달성"
    )

    // MARK: - 세션 수 마일스톤

    static let sessions100 = Milestone(
        id: "sessions_100", title: "100회 집중", emoji: "💯",
        desc: "100회 집중 세션 완료"
    )
    static let sessions500 = Milestone(
        id: "sessions_500", title: "500회 집중", emoji: "🚀",
        desc: "500회 집중 세션 완료"
    )
    static let sessions1000 = Milestone(
        id: "sessions_1000", title: "1000회 전설", emoji: "🌟",
        desc: "1000회 집중 세션 완료"
    )

    static let all: [Milestone] = [
        streak7, streak30, streak100, streak365,
        hours50, hours100, hours500,
        sessions100, sessions500, sessions1000,
    ]
}

@MainActor
enum MilestoneDetector {
    private static let logger = Logger(
        subsystem: Constants.App.subsystem,
        category: "MilestoneDetector"
    )

    private static let achievedKey = "achievedMilestoneIDs"

    /// 달성된 마일스톤 ID 세트
    static var achievedIDs: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: achievedKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: achievedKey)
        }
    }

    /// 새로 달성한 마일스톤 반환 (중복 제외)
    static func checkMilestones(
        streakDays: Int,
        totalHours: Double,
        totalSessions: Int
    ) -> [Milestone] {
        var newMilestones: [Milestone] = []
        let achieved = achievedIDs

        // 스트릭 체크
        let streakMilestones: [(Int, Milestone)] = [
            (7, .streak7), (30, .streak30), (100, .streak100), (365, .streak365),
        ]
        for (threshold, milestone) in streakMilestones {
            if streakDays >= threshold && !achieved.contains(milestone.id) {
                newMilestones.append(milestone)
            }
        }

        // 누적 시간 체크
        let hoursMilestones: [(Double, Milestone)] = [
            (50, .hours50), (100, .hours100), (500, .hours500),
        ]
        for (threshold, milestone) in hoursMilestones {
            if totalHours >= threshold && !achieved.contains(milestone.id) {
                newMilestones.append(milestone)
            }
        }

        // 세션 수 체크
        let sessionMilestones: [(Int, Milestone)] = [
            (100, .sessions100), (500, .sessions500), (1000, .sessions1000),
        ]
        for (threshold, milestone) in sessionMilestones {
            if totalSessions >= threshold && !achieved.contains(milestone.id) {
                newMilestones.append(milestone)
            }
        }

        // 새로 달성된 마일스톤 기록
        if !newMilestones.isEmpty {
            var updated = achieved
            for m in newMilestones {
                updated.insert(m.id)
            }
            achievedIDs = updated
            logger.info("새 마일스톤 달성: \(newMilestones.map(\.id))")
        }

        return newMilestones
    }

    /// 배지 저장 (SwiftData)
    static func saveBadges(_ milestones: [Milestone], modelContext: ModelContext) {
        for milestone in milestones {
            let badge = Badge(
                milestoneID: milestone.id,
                title: milestone.title,
                emoji: milestone.emoji,
                desc: milestone.desc
            )
            modelContext.insert(badge)
        }
    }
}
