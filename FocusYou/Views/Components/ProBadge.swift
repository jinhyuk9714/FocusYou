import SwiftUI

// MARK: - Pro 배지 (v2.0)
// 잠긴 기능 옆에 표시하는 작은 캡슐 배지

struct ProBadge: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Text("PRO")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(themeManager.primary.gradient, in: Capsule())
    }
}

// MARK: - Pro 잠금 오버레이 (v2.0)
// 무료 사용자에게 Pro 기능 위에 블러 + 배지 표시

struct ProLockedOverlay: View {
    @Environment(ThemeManager.self) private var themeManager
    let message: String

    var body: some View {
        VStack(spacing: Constants.Design.spacingSM) {
            ProBadge()
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Design.cornerMD))
    }
}

#Preview {
    VStack(spacing: 20) {
        ProBadge()

        ProLockedOverlay(message: "Pro로 업그레이드하면\n사용할 수 있습니다.")
            .frame(width: 200, height: 100)
    }
    .padding()
    .environment(ThemeManager.shared)
}
