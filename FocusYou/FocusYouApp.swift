import SwiftUI
import SwiftData
import AppKit

@main
struct FocusYouApp: App {
    @State private var appState = AppState()
    @State private var settingsViewModel = SettingsViewModel()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    /// 모든 Scene에서 공유하는 단일 ModelContainer
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: BlockProfile.self,
                BlockedSite.self,
                BlockedApp.self,
                FocusSession.self
            )
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }

    var body: some Scene {
        // MARK: - 메뉴바 (메인)
        // NOTE: .modelContainer()를 View 레벨에 직접 적용
        // MenuBarExtra의 Scene 레벨 수정자가 content view에 modelContext를 전파하지 않는 SwiftUI 버그 대응
        MenuBarExtra {
            MenuBarView()
                .modelContainer(modelContainer)
                .environment(appState)
                .environment(settingsViewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: appState.menuBarIcon)

                if appState.focusState == .focusing,
                   settingsViewModel.showMenuBarTime {
                    Text(appState.timer.remainingTime.formattedAsTimer)
                        .monospacedDigit()
                }
            }
        }
        .menuBarExtraStyle(.window)

        // MARK: - 차단 목록 관리 윈도우
        Window("차단 목록 관리", id: "block-list") {
            BlockListView()
                .modelContainer(modelContainer)
                .environment(appState)
        }
        .defaultSize(width: 520, height: 450)

        // MARK: - 설정 윈도우
        Window("설정", id: "settings") {
            SettingsView()
                .environment(settingsViewModel)
        }
        .defaultSize(width: 400, height: 250)
    }
}

// MARK: - AppDelegate (앱 시작/종료 관리)

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 앱 시작 시 메뉴바 팝오버 자동 열기
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApp.activate(ignoringOtherApps: true)
            // MenuBarExtra가 생성한 NSStatusBarButton을 재귀 탐색으로 찾아서 클릭
            for window in NSApp.windows {
                if let button = Self.findStatusBarButton(in: window.contentView) {
                    button.performClick(nil)
                    return
                }
            }
        }
    }

    /// 뷰 계층을 재귀 탐색하여 NSStatusBarButton 찾기
    private static func findStatusBarButton(in view: NSView?) -> NSStatusBarButton? {
        guard let view else { return nil }
        if let button = view as? NSStatusBarButton { return button }
        for subview in view.subviews {
            if let button = findStatusBarButton(in: subview) { return button }
        }
        return nil
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 앱 종료 시 차단이 활성화되어 있으면 정리
        Task {
            try? await BlockingCoordinator.shared.deactivateBlocking()
        }
    }
}
