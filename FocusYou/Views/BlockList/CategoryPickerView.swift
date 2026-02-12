import SwiftUI

// MARK: - 카테고리 프리셋 선택

struct CategoryPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BlockListViewModel()
    @State private var appliedCategories: Set<String> = []
    @State private var failedCategory: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("카테고리 프리셋을 선택하여 한 번에 추가하세요")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let failed = failedCategory {
                Text("'\(failed)' 프리셋을 불러올 수 없습니다")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140))],
                spacing: 12
            ) {
                ForEach(Constants.Category.all, id: \.self) { category in
                    categoryCard(category)
                }
            }

            Spacer()
        }
    }

    private func categoryCard(_ category: String) -> some View {
        let isApplied = appliedCategories.contains(category)
        let icon = Constants.Category.icons[category] ?? "folder.fill"

        return Button {
            if isApplied {
                // 토글: 제거
                viewModel.removePreset(
                    category: category,
                    modelContext: modelContext
                )
                withAnimation(.spring(duration: 0.3)) {
                    appliedCategories.remove(category)
                }
            } else {
                // 토글: 추가
                if viewModel.loadPreset(category: category) != nil {
                    viewModel.applyPreset(
                        category: category,
                        modelContext: modelContext
                    )
                    withAnimation(.spring(duration: 0.3)) {
                        appliedCategories.insert(category)
                    }
                    failedCategory = nil
                } else {
                    failedCategory = category
                }
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)

                Text(category)
                    .font(.callout.bold())

                if isApplied {
                    Text("제거하기")
                        .font(.caption)
                        .foregroundStyle(ThemeManager.shared.stopButton)
                } else {
                    Text("추가하기")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isApplied
                    ? ThemeManager.shared.completed.opacity(0.1)
                    : Color.secondary.opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isApplied
                            ? ThemeManager.shared.completed
                            : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category) 카테고리 프리셋")
    }
}

#Preview {
    CategoryPickerView()
        .modelContainer(for: [
            BlockedSite.self, BlockedApp.self,
            BlockProfile.self, FocusSession.self,
        ], inMemory: true)
        .frame(width: 400)
        .padding()
}
