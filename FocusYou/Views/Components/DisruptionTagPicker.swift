import SwiftUI

// MARK: - 방해요소 태그 선택 뷰 (v1.5)
// 회고 Level 3에서 사용. 복수 선택 가능.

struct DisruptionTagPicker: View {
    @Binding var selectedTags: Set<String>
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        FlowLayout(spacing: Constants.Design.spacingSM) {
            ForEach(Constants.Retrospect.disruptionTags, id: \.self) { tag in
                tagButton(tag)
            }
        }
    }

    private func tagButton(_ tag: String) -> some View {
        let isSelected = selectedTags.contains(tag)

        return Button {
            withAnimation(.focusSpring) {
                if isSelected {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                }
            }
        } label: {
            Text("#\(tag)")
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, Constants.Design.spacingSM)
                .padding(.vertical, Constants.Design.spacingXS)
                .background(
                    isSelected
                        ? AnyShapeStyle(themeManager.primary)
                        : AnyShapeStyle(.quaternary),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("방해요소: \(tag)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 태그 플로우 레이아웃

/// 가로 넘침 시 자동 줄바꿈하는 레이아웃
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return (positions, CGSize(width: totalWidth, height: currentY + lineHeight))
    }
}

#Preview {
    @Previewable @State var tags: Set<String> = ["SNS"]
    DisruptionTagPicker(selectedTags: $tags)
        .environment(ThemeManager.shared)
        .frame(width: 300)
        .padding()
}
