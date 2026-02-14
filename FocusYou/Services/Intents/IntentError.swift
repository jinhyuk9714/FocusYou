import Foundation
import AppIntents

// MARK: - AppIntent 에러 정의

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case appNotRunning
    case sessionAlreadyActive
    case noActiveSession
    case profileNotFound(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .appNotRunning:
            return "Focus You 앱이 실행 중이어야 합니다."
        case .sessionAlreadyActive:
            return "이미 집중 세션이 진행 중입니다."
        case .noActiveSession:
            return "진행 중인 집중 세션이 없습니다."
        case .profileNotFound(let name):
            return "'\(name)' 프로필을 찾을 수 없습니다."
        }
    }
}
