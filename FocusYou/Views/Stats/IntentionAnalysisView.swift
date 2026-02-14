import SwiftUI

// MARK: - 의도별 분석 뷰 (v1.5)
// 세션 의도(intention)별 총 시간 상위 5개를 수평 바 차트로 표시.

struct IntentionAnalysisView: View {
    let entries: [IntentionEntry]
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacingMD) {
            Text("의도별 분석")
                .font(.headline)

            if entries.isEmpty {
                emptyState
            } else {
                barChart
            }
        }
        .frostedCard()
    }

    // MARK: - 바 차트

    private var barChart: some View {
        let maxSeconds = entries.map(\.totalSeconds).max() ?? 1

        return VStack(spacing: Constants.Design.spacingSM) {
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(entry.intention)
                            .font(.caption.weight(.medium))
                            .lineLimit(1)

                        Spacer()

                        Text(TimeInterval(entry.totalSeconds).formattedAsReadable)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)

                        Text("(\(entry.sessionCount)회)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    GeometryReader { geometry in
                        let ratio = CGFloat(entry.totalSeconds) / CGFloat(maxSeconds)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [themeManager.primary.opacity(0.7), themeManager.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * ratio)
                    }
                    .frame(height: 8)
                }
            }
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: Constants.Design.spacingXS) {
                Text("의도를 입력한 세션이 없습니다")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
                Text("설정 → 의도 입력을 활성화해 보세요")
                    .font(.caption)
                    .foregroundStyle(.quaternary)
            }
            .padding(.vertical, Constants.Design.spacingLG)
            Spacer()
        }
    }
}

#Preview {
    IntentionAnalysisView(entries: [
        IntentionEntry(intention: "코딩 작업", totalSeconds: 5400, sessionCount: 3),
        IntentionEntry(intention: "문서 작성", totalSeconds: 3600, sessionCount: 2),
        IntentionEntry(intention: "리뷰", totalSeconds: 1800, sessionCount: 1),
    ])
    .environment(ThemeManager.shared)
    .frame(width: 400)
    .padding()
}
