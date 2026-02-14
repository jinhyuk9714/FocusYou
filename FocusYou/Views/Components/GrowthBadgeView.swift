import SwiftUI

// MARK: - 성장 뱃지 뷰 (v1.5)
// 이모지 + 원형 진행률 링 + 레벨 텍스트

struct GrowthBadgeView: View {
    let stage: GrowthStage
    let progress: Double
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        HStack(spacing: Constants.Design.spacingSM) {
            // 원형 진행률 링 + 이모지
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.1), lineWidth: 3)
                    .frame(width: 36, height: 36)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        themeManager.primary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))

                Text(stage.emoji)
                    .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Lv.\(stage.rawValue + 1)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stage.name) 단계, 레벨 \(stage.rawValue + 1), 진행률 \(Int(progress * 100))%")
    }
}

#Preview {
    VStack(spacing: 16) {
        GrowthBadgeView(stage: .seed, progress: 0.3)
        GrowthBadgeView(stage: .tree, progress: 0.7)
        GrowthBadgeView(stage: .garden, progress: 1.0)
    }
    .environment(ThemeManager.shared)
    .padding()
}
