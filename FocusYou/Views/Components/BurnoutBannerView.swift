import SwiftUI

// MARK: - 번아웃 방지 배너 (v1.5)
// 긍정적 톤의 비차단 배너. 해제 시 24시간 미표시.

struct BurnoutBannerView: View {
    @Environment(ThemeManager.self) private var themeManager
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: Constants.Design.spacingSM) {
            Image(systemName: "heart.fill")
                .font(.callout)
                .foregroundStyle(themeManager.warning)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Button {
                withAnimation(.quickEase) {
                    onDismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(Constants.Design.spacingSM)
        .background(
            RoundedRectangle(cornerRadius: Constants.Design.cornerMD)
                .fill(themeManager.warning.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Design.cornerMD)
                        .stroke(themeManager.warning.opacity(0.15), lineWidth: 0.5)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("번아웃 방지 알림: \(message)")
        .accessibilityHint("닫기 버튼으로 해제할 수 있습니다")
    }
}

#Preview {
    BurnoutBannerView(
        message: "잘하고 있어요! 오늘 한계까지 약 30분 남았어요.",
        onDismiss: {}
    )
    .environment(ThemeManager.shared)
    .padding()
    .frame(width: 340)
}
