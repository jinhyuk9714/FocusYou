import SwiftUI
import SwiftData

// MARK: - 배지 갤러리 뷰 (v1.5)

struct BadgeGalleryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Query(sort: \Badge.achievedAt, order: .reverse)
    private var badges: [Badge]

    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: Constants.Design.spacingSM),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Design.spacingMD) {
            HStack {
                Text("배지")
                    .font(.headline)
                Spacer()
                Text("\(badges.count)/\(Milestone.all.count)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if badges.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: Constants.Design.spacingSM) {
                    ForEach(Milestone.all, id: \.id) { milestone in
                        badgeCell(milestone)
                    }
                }
            }
        }
        .frostedCard()
    }

    private func badgeCell(_ milestone: Milestone) -> some View {
        let isAchieved = badges.contains { $0.milestoneID == milestone.id }
        let achievedBadge = badges.first { $0.milestoneID == milestone.id }

        return VStack(spacing: 4) {
            Text(milestone.emoji)
                .font(.system(size: 28))
                .opacity(isAchieved ? 1 : 0.2)
                .grayscale(isAchieved ? 0 : 1)

            Text(milestone.title)
                .font(.caption2)
                .foregroundStyle(isAchieved ? .primary : .tertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Design.spacingSM)
        .help(isAchieved
            ? "\(milestone.desc) — \(achievedBadge?.achievedAt.formatted(date: .abbreviated, time: .omitted) ?? "")"
            : milestone.desc
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(milestone.title), \(isAchieved ? "획득" : "미획득")")
        .accessibilityHint(milestone.desc)
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: Constants.Design.spacingSM) {
                Image(systemName: "trophy")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                Text("아직 획득한 배지가 없어요")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, Constants.Design.spacingLG)
            Spacer()
        }
    }
}

#Preview {
    BadgeGalleryView()
        .environment(ThemeManager.shared)
        .modelContainer(for: Badge.self, inMemory: true)
        .frame(width: 400)
        .padding()
}
