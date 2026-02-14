import Foundation

// MARK: - Widget / Extension 데이터 공유

/// 메인 앱 ↔ Widget Extension 간 공유 데이터 모델
struct SharedFocusData: Codable, Sendable {
    let isFocusing: Bool
    let timerMode: String
    let remainingSeconds: Int
    let totalSeconds: Int
    let currentStreak: Int
    let longestStreak: Int
    let todayFocusMinutes: Int
    let todaySessionCount: Int
    let themePrimaryHex: String
    let themeAccentHex: String
    let updatedAt: Date
}

/// App Groups UserDefaults를 통한 데이터 공유
enum SharedDataProvider {
    private static let dataKey = "sharedFocusData"

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: Constants.AppGroups.identifier)
    }

    /// 공유 데이터 쓰기 (메인 앱에서 호출)
    static func write(_ data: SharedFocusData) {
        guard let defaults = sharedDefaults else { return }
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: dataKey)
    }

    /// 공유 데이터 읽기 (위젯에서 호출)
    static func read() -> SharedFocusData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: dataKey) else { return nil }
        return try? JSONDecoder().decode(SharedFocusData.self, from: data)
    }

    /// 기본 데이터 (위젯 초기 로드 시 사용)
    static var placeholder: SharedFocusData {
        SharedFocusData(
            isFocusing: false,
            timerMode: "free",
            remainingSeconds: 0,
            totalSeconds: 0,
            currentStreak: 0,
            longestStreak: 0,
            todayFocusMinutes: 0,
            todaySessionCount: 0,
            themePrimaryHex: "#E63946",
            themeAccentHex: "#2A9D8F",
            updatedAt: .now
        )
    }
}
