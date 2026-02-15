import SwiftUI

// MARK: - 페이월 뷰 (v2.0)
// 무료 한도 초과 시 자연스럽게 Pro 업그레이드를 안내하는 시트

struct PaywallView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    /// 페이월 트리거 이유
    let reason: PaywallReason

    var body: some View {
        VStack(spacing: Constants.Design.spacingXL) {
            // 헤더
            headerSection

            // 기능 설명
            featureSection

            // 가격
            pricingSection

            // 버튼
            actionSection

            Spacer()
        }
        .padding(Constants.Design.spacingXL)
        .frame(minWidth: 360, maxWidth: 360, minHeight: 420)
    }

    // MARK: - 헤더

    private var headerSection: some View {
        VStack(spacing: Constants.Design.spacingSM) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(themeManager.primary.gradient)

            Text("Pro로 업그레이드")
                .font(.title2.bold())

            Text(reason.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 기능

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacingMD) {
            featureRow(icon: "infinity", text: "무제한 차단 / 타이머 / 프로필")
            featureRow(icon: "paintpalette.fill", text: "70+ 프리미엄 테마")
            featureRow(icon: "speaker.wave.2.fill", text: "앰비언트 사운드")
            featureRow(icon: "chart.bar.fill", text: "고급 통계 + 히트맵")
            featureRow(icon: "calendar", text: "스케줄 · 캘린더 · Shortcuts")
            featureRow(icon: "square.and.arrow.up", text: "데이터 내보내기 (CSV/JSON)")
        }
        .padding(Constants.Design.cardPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.Design.cornerLG))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Constants.Design.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: Constants.Design.iconSM))
                .foregroundStyle(themeManager.primary)
                .frame(width: 20, alignment: .center)

            Text(text)
                .font(.callout)
        }
    }

    // MARK: - 가격

    private var pricingSection: some View {
        VStack(spacing: Constants.Design.spacingXS) {
            HStack(spacing: Constants.Design.spacingSM) {
                pricingBadge(
                    price: Constants.Subscription.annualDiscountPrice,
                    period: "/년",
                    highlight: true
                )
                pricingBadge(
                    price: Constants.Subscription.monthlyPrice,
                    period: "/월",
                    highlight: false
                )
            }

            Text("출시 기념 50% 할인 (정가 \(Constants.Subscription.annualPrice)/년)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func pricingBadge(price: String, period: String, highlight: Bool) -> some View {
        VStack(spacing: 2) {
            Text(price)
                .font(.title3.bold())
            Text(period)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Design.spacingMD)
        .background(
            highlight
                ? AnyShapeStyle(themeManager.primary.opacity(0.1))
                : AnyShapeStyle(Color.secondary.opacity(0.06)),
            in: RoundedRectangle(cornerRadius: Constants.Design.cornerMD)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Design.cornerMD)
                .stroke(
                    highlight ? themeManager.primary.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }

    // MARK: - 액션

    private var actionSection: some View {
        VStack(spacing: Constants.Design.spacingSM) {
            Button {
                // App Store 출시 시 StoreKit 2 구매 연결
            } label: {
                Label("App Store 출시 시 이용 가능", systemImage: "clock.fill")
            }
            .primaryActionStyle(color: themeManager.primary)
            .disabled(true)
            .opacity(0.6)

            Button("닫기") {
                dismiss()
            }
            .secondaryActionStyle(color: themeManager.primary)
        }
    }
}

// MARK: - 페이월 트리거 이유

enum PaywallReason {
    case websiteLimit
    case appLimit
    case profileLimit
    case timerLimit
    case themeLimit
    case statsLimit
    case retrospectLimit
    case proFeature(LicenseManager.ProFeature)

    var message: String {
        switch self {
        case .websiteLimit:
            return "무료 버전은 최대 \(Constants.Subscription.freeWebsiteLimit)개의 사이트를 차단할 수 있습니다."
        case .appLimit:
            return "무료 버전은 최대 \(Constants.Subscription.freeAppLimit)개의 앱을 차단할 수 있습니다."
        case .profileLimit:
            return "무료 버전은 \(Constants.Subscription.freeProfileLimit)개의 프로필을 사용할 수 있습니다."
        case .timerLimit:
            return "무료 버전은 최대 \(Constants.Subscription.freeTimerMaxMinutes / 60)시간 타이머를 사용할 수 있습니다."
        case .themeLimit:
            return "\(Constants.Subscription.freeThemeLimit)개 이상의 테마는 Pro에서 사용할 수 있습니다."
        case .statsLimit:
            return "월간/연간 통계는 Pro에서 확인할 수 있습니다."
        case .retrospectLimit:
            return "상세 회고 기능은 Pro에서 사용할 수 있습니다."
        case .proFeature(let feature):
            return proFeatureMessage(feature)
        }
    }

    private func proFeatureMessage(_ feature: LicenseManager.ProFeature) -> String {
        switch feature {
        case .overflow: return "Overflow 모드는 Pro 기능입니다."
        case .ambientSound: return "앰비언트 사운드는 Pro 기능입니다."
        case .schedule: return "자동 스케줄은 Pro 기능입니다."
        case .keywordBlocking: return "키워드 차단은 Pro 기능입니다."
        case .allowlistMode: return "화이트리스트 모드는 Pro 기능입니다."
        case .hardcoreMode: return "하드코어 모드는 Pro 기능입니다."
        case .focusModeIntegration: return "Focus Mode 연동은 Pro 기능입니다."
        case .shortcuts: return "Shortcuts 자동화는 Pro 기능입니다."
        case .calendarSync: return "캘린더 동기화는 Pro 기능입니다."
        case .appDimming: return "앱 디밍은 Pro 기능입니다."
        case .dataExport: return "데이터 내보내기는 Pro 기능입니다."
        case .unlimitedBlocks: return "무제한 차단은 Pro 기능입니다."
        case .unlimitedTimer: return "무제한 타이머는 Pro 기능입니다."
        case .unlimitedProfiles: return "무제한 프로필은 Pro 기능입니다."
        case .premiumThemes: return "프리미엄 테마는 Pro 기능입니다."
        case .advancedStats: return "고급 통계는 Pro 기능입니다."
        case .advancedRetrospect: return "상세 회고는 Pro 기능입니다."
        }
    }
}

#Preview {
    PaywallView(reason: .websiteLimit)
        .environment(ThemeManager.shared)
}
