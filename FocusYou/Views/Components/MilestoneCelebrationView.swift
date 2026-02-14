import SwiftUI

// MARK: - 마일스톤 축하 뷰 (v1.5)
// 마일스톤 달성 시 오버레이로 표시

struct MilestoneCelebrationView: View {
    let milestone: Milestone
    let onDismiss: () -> Void
    @Environment(ThemeManager.self) private var themeManager
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: Constants.Design.spacingXL) {
            Text(milestone.emoji)
                .font(.system(size: 64))
                .scaleEffect(scale)

            VStack(spacing: Constants.Design.spacingSM) {
                Text("마일스톤 달성!")
                    .font(.title3.bold())
                    .foregroundStyle(themeManager.primary)

                Text(milestone.title)
                    .font(.headline)

                Text(milestone.desc)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                withAnimation(.quickEase) {
                    onDismiss()
                }
            } label: {
                Label("확인", systemImage: "checkmark")
            }
            .primaryActionStyle(color: themeManager.primary)
        }
        .padding(Constants.Design.spacingXXL)
        .frostedCard()
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("마일스톤 달성: \(milestone.title). \(milestone.desc)")
    }
}

#Preview {
    MilestoneCelebrationView(
        milestone: .streak7,
        onDismiss: {}
    )
    .environment(ThemeManager.shared)
    .frame(width: 340)
    .padding()
}
