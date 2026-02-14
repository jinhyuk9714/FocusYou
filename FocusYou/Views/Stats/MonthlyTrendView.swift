import SwiftUI
import Charts

// MARK: - 월간 트렌드 뷰 (v1.5)
// 일별 집중 시간을 라인 차트로 표시. 그라디언트 영역 채움.

struct MonthlyTrendView: View {
    let data: [DailyFocusEntry]
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacingMD) {
            Text("집중 트렌드")
                .font(.headline)

            if data.isEmpty {
                emptyState
            } else {
                trendChart
            }
        }
        .frostedCard()
    }

    // MARK: - 라인 차트

    private var trendChart: some View {
        Chart(data) { entry in
            LineMark(
                x: .value("날짜", entry.date, unit: .day),
                y: .value("시간", entry.focusHours)
            )
            .foregroundStyle(themeManager.primary)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("날짜", entry.date, unit: .day),
                y: .value("시간", entry.focusHours)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [themeManager.primary.opacity(0.3), themeManager.primary.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartYAxisLabel("시간")
        .frame(height: 160)
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            Text("데이터가 없습니다")
                .font(.callout)
                .foregroundStyle(.tertiary)
                .padding(.vertical, Constants.Design.spacingXL)
            Spacer()
        }
    }
}

#Preview {
    MonthlyTrendView(data: [
        DailyFocusEntry(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, focusSeconds: 3600),
        DailyFocusEntry(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, focusSeconds: 5400),
        DailyFocusEntry(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, focusSeconds: 1800),
        DailyFocusEntry(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, focusSeconds: 7200),
        DailyFocusEntry(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, focusSeconds: 4500),
        DailyFocusEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, focusSeconds: 6000),
        DailyFocusEntry(date: Date(), focusSeconds: 2700),
    ])
    .environment(ThemeManager.shared)
    .frame(width: 400)
    .padding()
}
