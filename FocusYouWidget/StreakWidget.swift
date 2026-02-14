import WidgetKit
import SwiftUI

// MARK: - 스트릭 위젯

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("집중 스트릭")
        .description("연속 집중 기록을 표시합니다.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Timeline Entry

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let longestStreak: Int
    let todayFocusMinutes: Int
    let todaySessionCount: Int
    let primaryHex: String
}

// MARK: - Timeline Provider

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        makeEntry(from: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(makeEntry(from: SharedDataProvider.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = makeEntry(from: SharedDataProvider.read())

        // 15분 간격 리프레시
        let nextUpdate = Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func makeEntry(from data: SharedFocusData?) -> StreakEntry {
        let data = data ?? SharedDataProvider.placeholder
        return StreakEntry(
            date: .now,
            currentStreak: data.currentStreak,
            longestStreak: data.longestStreak,
            todayFocusMinutes: data.todayFocusMinutes,
            todaySessionCount: data.todaySessionCount,
            primaryHex: data.themePrimaryHex
        )
    }
}

// MARK: - Widget View

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(spacing: 8) {
            // 불꽃 아이콘 + 현재 스트릭
            HStack(spacing: 4) {
                Image(systemName: entry.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.title2)
                    .foregroundStyle(
                        entry.currentStreak > 0
                            ? Color(hex: entry.primaryHex)
                            : .secondary
                    )

                Text("\(entry.currentStreak)")
                    .font(.title.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color(hex: entry.primaryHex))
            }

            Text("일 연속")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Divider()
                .padding(.horizontal, 8)

            // 오늘 통계
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(entry.todayFocusMinutes)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                    Text("분")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 2) {
                    Text("\(entry.todaySessionCount)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                    Text("세션")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Color+Hex (위젯 전용)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(
        date: .now, currentStreak: 7, longestStreak: 14,
        todayFocusMinutes: 120, todaySessionCount: 4,
        primaryHex: "#E63946"
    )
    StreakEntry(
        date: .now, currentStreak: 0, longestStreak: 5,
        todayFocusMinutes: 0, todaySessionCount: 0,
        primaryHex: "#E63946"
    )
}
