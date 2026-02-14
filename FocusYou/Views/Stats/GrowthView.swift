import SwiftUI

// MARK: - 성장 타임라인 뷰 (v1.5)
// 전체 5단계 성장 진행 시각화

struct GrowthView: View {
    let totalHours: Double
    @Environment(ThemeManager.self) private var themeManager

    private var currentStage: GrowthStage {
        GrowthManager.currentStage(totalHours: totalHours)
    }

    private var currentProgress: Double {
        GrowthManager.progress(totalHours: totalHours)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacingMD) {
            Text("성장")
                .font(.headline)

            // 메인 뱃지
            HStack(spacing: Constants.Design.spacingMD) {
                GrowthBadgeView(stage: currentStage, progress: currentProgress)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(totalHours))시간 누적")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(themeManager.primary)

                    if let remaining = GrowthManager.hoursToNextStage(totalHours: totalHours) {
                        Text("다음 단계까지 \(Int(remaining))시간")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("최고 단계 달성!")
                            .font(.caption)
                            .foregroundStyle(themeManager.accent)
                    }
                }
            }

            // 단계 타임라인
            HStack(spacing: 0) {
                ForEach(GrowthStage.allCases, id: \.rawValue) { stage in
                    stageIndicator(stage)
                    if stage != .garden {
                        Spacer()
                    }
                }
            }
        }
        .frostedCard()
    }

    private func stageIndicator(_ stage: GrowthStage) -> some View {
        let isReached = currentStage >= stage
        let isCurrent = currentStage == stage

        return VStack(spacing: 4) {
            Text(stage.emoji)
                .font(.system(size: isCurrent ? 20 : 14))
                .opacity(isReached ? 1 : 0.3)
                .scaleEffect(isCurrent ? 1.1 : 1.0)
                .animation(.focusSpring, value: isCurrent)

            Text(stage.name)
                .font(.caption2)
                .foregroundStyle(isReached ? .primary : .tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stage.name) 단계, \(isCurrent ? "현재" : isReached ? "달성" : "미달성")")
    }
}

#Preview {
    VStack(spacing: 16) {
        GrowthView(totalHours: 5)
        GrowthView(totalHours: 75)
        GrowthView(totalHours: 600)
    }
    .environment(ThemeManager.shared)
    .padding()
    .frame(width: 400)
}
