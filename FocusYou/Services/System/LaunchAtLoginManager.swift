import ServiceManagement
import os

// MARK: - 로그인 시 자동 시작 관리

enum LaunchAtLoginManager {
    private static let logger = Logger(
        subsystem: Constants.App.subsystem,
        category: "LaunchAtLogin"
    )

    /// 로그인 시 자동 시작을 활성화/비활성화합니다.
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
                logger.info("로그인 시 자동 시작 등록 완료")
            } else {
                try SMAppService.mainApp.unregister()
                logger.info("로그인 시 자동 시작 해제 완료")
            }
        } catch {
            logger.error(
                "로그인 시 자동 시작 설정 실패: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    /// 현재 로그인 시 자동 시작 상태
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
