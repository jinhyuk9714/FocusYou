import SwiftUI
import SwiftData

// MARK: - 앱 차단 관리

struct AppBlockView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var blockedApps: [BlockedApp]
    @State private var viewModel = BlockListViewModel()
    @State private var installedApps: [BlockListViewModel.InstalledApp] = []
    @State private var isLoading = true

    private var blockedBundleIds: Set<String> {
        Set(blockedApps.map(\.bundleId))
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField("앱 검색...", text: $viewModel.appSearchText)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("설치된 앱 검색")

            if isLoading {
                ProgressView("앱 목록 불러오는 중...")
                    .frame(maxHeight: .infinity)
            } else if filteredApps.isEmpty {
                ContentUnavailableView(
                    viewModel.appSearchText.isEmpty ? "설치된 앱 없음" : "검색 결과 없음",
                    systemImage: "app.dashed",
                    description: Text(viewModel.appSearchText.isEmpty
                        ? "차단할 수 있는 앱이 없습니다"
                        : "'\(viewModel.appSearchText)' 검색 결과가 없습니다")
                )
            } else {
                appList
            }
        }
        .task {
            installedApps = viewModel.scanInstalledApps()
            isLoading = false
        }
    }

    // MARK: - 앱 목록

    private var filteredApps: [BlockListViewModel.InstalledApp] {
        if viewModel.appSearchText.isEmpty {
            return installedApps
        }
        return installedApps.filter {
            $0.name.localizedCaseInsensitiveContains(viewModel.appSearchText)
        }
    }

    private var appList: some View {
        List(filteredApps) { app in
            appRow(app)
        }
        .listStyle(.inset)
    }

    private func appRow(_ app: BlockListViewModel.InstalledApp) -> some View {
        let isBlocked = blockedBundleIds.contains(app.bundleId)

        return HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .opacity(isBlocked ? 1.0 : 0.6)

            Text(app.name)
                .font(.body)
                .foregroundStyle(isBlocked ? .primary : .secondary)

            Spacer()

            Toggle("", isOn: Binding(
                get: { isBlocked },
                set: { newValue in
                    viewModel.toggleApp(
                        app,
                        isBlocked: newValue,
                        modelContext: modelContext
                    )
                }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)
        }
        .padding(.vertical, 2)
        .accessibilityLabel("\(app.name), \(isBlocked ? "차단 중" : "차단 안 함")")
    }
}

#Preview {
    AppBlockView()
        .modelContainer(for: [
            BlockedSite.self, BlockedApp.self,
            BlockProfile.self, FocusSession.self,
        ], inMemory: true)
}
