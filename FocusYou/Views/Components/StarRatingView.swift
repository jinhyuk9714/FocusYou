import SwiftUI

// MARK: - 별점 선택 뷰 (v1.5)
// 1-5 별점 인터랙티브 컴포넌트. 회고 Level 3에서 사용.

struct StarRatingView: View {
    @Binding var rating: Int
    @Environment(ThemeManager.self) private var themeManager

    private let maxRating = 5

    var body: some View {
        HStack(spacing: Constants.Design.spacingSM) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(star <= rating ? themeManager.accent : .secondary.opacity(0.4))
                    .onTapGesture {
                        withAnimation(.focusSpring) {
                            rating = star
                        }
                    }
                    .accessibilityLabel("별점 \(star)점")
            }
        }
    }
}

#Preview {
    @Previewable @State var rating = 3
    StarRatingView(rating: $rating)
        .environment(ThemeManager.shared)
        .padding()
}
