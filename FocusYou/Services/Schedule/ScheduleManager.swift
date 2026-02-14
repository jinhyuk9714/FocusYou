import Foundation
import SwiftData
import os

// MARK: - 스케줄 매니저 (v1.3)
// 요일별 자동 집중 세션 시작/종료 관리

@MainActor
@Observable
final class ScheduleManager {
    static let shared = ScheduleManager()

    private(set) var isMonitoring = false
    private var checkTimer: Timer?

    private let logger = Logger(
        subsystem: Constants.App.subsystem,
        category: "ScheduleManager"
    )

    // MARK: - 모니터링

    /// 스케줄 체크 시작 (앱 시작 시 호출)
    func startMonitoring(modelContext: ModelContext, appState: AppState) {
        guard !isMonitoring else { return }

        isMonitoring = true
        logger.info("스케줄 모니터링 시작")

        checkTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.Schedule.checkIntervalSeconds,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkSchedules(modelContext: modelContext, appState: appState)
            }
        }

        // 즉시 1회 체크
        checkSchedules(modelContext: modelContext, appState: appState)
    }

    /// 모니터링 중지
    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
        isMonitoring = false
        logger.info("스케줄 모니터링 중지")
    }

    // MARK: - 스케줄 체크

    private func checkSchedules(modelContext: ModelContext, appState: AppState) {
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        let currentMinute = calendar.component(.hour, from: now) * 60
            + calendar.component(.minute, from: now)

        // 활성 스케줄 가져오기
        let descriptor = FetchDescriptor<BlockSchedule>(
            predicate: #Predicate<BlockSchedule> { $0.isEnabled }
        )
        guard let schedules = try? modelContext.fetch(descriptor) else { return }

        for schedule in schedules {
            let weekdays = schedule.weekdayArray

            guard weekdays.contains(currentWeekday) else { continue }

            let isInTimeRange = currentMinute >= schedule.startMinuteOfDay
                && currentMinute < schedule.endMinuteOfDay

            if isInTimeRange && appState.focusState == .idle {
                // 스케줄 시간 내 + idle → 세션 시작
                guard let profile = schedule.profile else { continue }

                logger.info("스케줄 '\(schedule.name, privacy: .public)' 매칭 — 자동 세션 시작")
                Task {
                    await appState.startSessionFromProfile(profile, modelContext: modelContext)
                }
                return
            }
        }
    }
}
