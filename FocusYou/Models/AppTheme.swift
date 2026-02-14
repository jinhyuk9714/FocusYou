import Foundation

// MARK: - 앱 테마 모델

struct AppTheme: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
    let stopHex: String
    let backgroundHex: String
    /// 다크모드 배경 (optional, 하위호환)
    let backgroundDarkHex: String?
    /// 테마 카테고리 (v1.3: "미니멀", "따뜻한", "차가운", "자연", "네온", "파스텔")
    let category: String?

    init(
        id: String,
        name: String,
        primaryHex: String,
        secondaryHex: String,
        accentHex: String,
        stopHex: String,
        backgroundHex: String,
        backgroundDarkHex: String? = nil,
        category: String? = nil
    ) {
        self.id = id
        self.name = name
        self.primaryHex = primaryHex
        self.secondaryHex = secondaryHex
        self.accentHex = accentHex
        self.stopHex = stopHex
        self.backgroundHex = backgroundHex
        self.backgroundDarkHex = backgroundDarkHex
        self.category = category
    }
}
