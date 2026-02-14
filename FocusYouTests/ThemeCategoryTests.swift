import XCTest
@testable import Focus_You

final class ThemeCategoryTests: XCTestCase {

    @MainActor
    func testThemeCatalogHasAtLeast70Themes() {
        let manager = ThemeManager()
        XCTAssertGreaterThanOrEqual(manager.availableThemes.count, 70)
    }

    @MainActor
    func testAllThemesHaveCategory() {
        let manager = ThemeManager()
        for theme in manager.availableThemes {
            XCTAssertNotNil(
                theme.category,
                "테마 '\(theme.name)' (id: \(theme.id))에 category가 없습니다"
            )
        }
    }

    @MainActor
    func testAllCategoriesAreValid() {
        let validCategories = Set(Constants.ThemeCategory.all)
        let manager = ThemeManager()
        for theme in manager.availableThemes {
            guard let category = theme.category else { continue }
            XCTAssertTrue(
                validCategories.contains(category),
                "테마 '\(theme.name)'의 category '\(category)'가 유효하지 않습니다"
            )
        }
    }

    @MainActor
    func testThemesByCategoryGroupsCorrectly() {
        let manager = ThemeManager()
        let grouped = manager.themesByCategory

        XCTAssertFalse(grouped.isEmpty, "카테고리 그룹이 비어있습니다")

        let totalGroupedCount = grouped.reduce(0) { $0 + $1.themes.count }
        XCTAssertEqual(
            totalGroupedCount,
            manager.availableThemes.count,
            "그룹된 테마 수가 전체 테마 수와 일치해야 합니다"
        )
    }

    @MainActor
    func testEachCategoryHasAtLeastOneTheme() {
        let manager = ThemeManager()
        let grouped = manager.themesByCategory
        let groupedCategories = Set(grouped.map(\.category))

        for category in Constants.ThemeCategory.all {
            XCTAssertTrue(
                groupedCategories.contains(category),
                "카테고리 '\(category)'에 테마가 없습니다"
            )
        }
    }

    @MainActor
    func testAllThemesHaveValidHexColors() {
        let manager = ThemeManager()
        let hexPattern = /^#[0-9A-Fa-f]{6}$/

        for theme in manager.availableThemes {
            XCTAssertNotNil(
                theme.primaryHex.wholeMatch(of: hexPattern),
                "테마 '\(theme.name)' primaryHex '\(theme.primaryHex)' 유효하지 않음"
            )
            XCTAssertNotNil(
                theme.secondaryHex.wholeMatch(of: hexPattern),
                "테마 '\(theme.name)' secondaryHex '\(theme.secondaryHex)' 유효하지 않음"
            )
            XCTAssertNotNil(
                theme.accentHex.wholeMatch(of: hexPattern),
                "테마 '\(theme.name)' accentHex '\(theme.accentHex)' 유효하지 않음"
            )
        }
    }

    @MainActor
    func testAllThemeIDsAreUnique() {
        let manager = ThemeManager()
        let ids = manager.availableThemes.map(\.id)
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "중복 테마 ID가 있습니다")
    }
}
