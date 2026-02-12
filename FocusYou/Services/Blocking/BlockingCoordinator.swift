import Foundation
import os

// MARK: - 차단 통합 코디네이터
// 웹사이트 차단 + 앱 차단을 통합 관리하는 중앙 오케스트레이터

actor BlockingCoordinator {
    static let shared = BlockingCoordinator()

    // MARK: - 상태

    enum State: Sendable {
        case idle
        case blocking
        case error(FocusYouError)
    }

    private(set) var state: State = .idle

    // MARK: - Dependencies

    private let websiteBlocker: any WebsiteBlocker
    private let logger = Logger(
        subsystem: Constants.App.subsystem,
        category: "BlockingCoordinator"
    )

    init(websiteBlocker: any WebsiteBlocker = HostsFileBlocker()) {
        self.websiteBlocker = websiteBlocker
    }

    // MARK: - Public

    /// 차단 활성화 (타이머 시작 시 호출)
    func activateBlocking(
        domains: [String],
        appBundleIds: [String]
    ) async throws {
        logger.info("차단 활성화 시작: 사이트 \(domains.count)개, 앱 \(appBundleIds.count)개")

        // 웹사이트 차단
        if !domains.isEmpty {
            do {
                try await websiteBlocker.activate(domains: domains)
            } catch {
                logger.error("웹사이트 차단 실패: \(error.localizedDescription)")
                state = .error(error as? FocusYouError ?? .hostsFileWriteFailed)
                throw error
            }
        }

        // 앱 차단 (MainActor에서 실행)
        if !appBundleIds.isEmpty {
            await MainActor.run {
                AppBlocker.shared.activate(bundleIds: appBundleIds)
            }
        }

        // 안전장치 활성화
        installSafetyNet()

        state = .blocking
        logger.info("차단 활성화 완료")
    }

    /// 차단 해제 (타이머 종료/취소 시 호출)
    func deactivateBlocking() async throws {
        logger.info("차단 해제 시작")

        // 웹사이트 차단 해제
        do {
            try await websiteBlocker.deactivate()
        } catch {
            logger.error("웹사이트 차단 해제 실패: \(error.localizedDescription)")
            // 실패해도 앱 차단은 해제 시도
        }

        // 앱 차단 해제
        await MainActor.run {
            AppBlocker.shared.deactivate()
        }

        // 안전장치 해제
        removeSafetyNet()

        state = .idle
        logger.info("차단 해제 완료")
    }

    /// 긴급 정리 (앱 시작 시 stale 마커 감지용)
    /// 활성 표시 파일이 있을 때만 실행
    /// 헬퍼를 통해 비밀번호 없이 복구 시도, 실패 시 admin fallback
    func emergencyCleanup() async {
        guard FileManager.default.fileExists(atPath: Constants.Blocking.activeIndicatorPath) else {
            return
        }

        logger.warning("긴급 정리 수행 (활성 표시 파일 감지)")

        // hosts 파일에 차단 마커가 있는 경우에만 복구
        guard await HostsFileManager.shared.hasActiveBlocking() else {
            logger.info("긴급 정리: 차단 마커 없음, 표시 파일만 제거")
            removeSafetyNet()
            state = .idle
            return
        }

        // 헬퍼를 통해 비밀번호 없이 복구 시도
        do {
            let cleanContent = try await HostsFileManager.shared.buildCleanContent()
            try await PrivilegedHelper.shared.writeHostsViaHelper(content: cleanContent)
            logger.info("긴급 정리: 헬퍼를 통해 복원 완료")
        } catch {
            logger.warning("헬퍼 복구 실패, admin fallback 시도: \(error.localizedDescription)")
            // Fallback: 기존 방식 (비밀번호 필요)
            do {
                try await websiteBlocker.deactivate()
                logger.info("긴급 정리: hosts 파일 복원 완료 (admin)")
            } catch {
                logger.error("긴급 정리 실패: \(error.localizedDescription)")
            }
        }

        removeSafetyNet()
        state = .idle
    }

    // MARK: - 안전장치 (LaunchAgent)

    /// 앱 크래시 시 자동 정리를 위한 LaunchAgent 설치
    private func installSafetyNet() {
        logger.debug("안전장치 설치")

        // 활성 상태 표시 파일 생성
        FileManager.default.createFile(
            atPath: Constants.Blocking.activeIndicatorPath,
            contents: Date().description.data(using: .utf8)
        )

        // LaunchAgent plist 생성
        // 부팅 시 활성 표시 파일이 있으면 헬퍼로 hosts 복구 시도
        let helperPath = Constants.Blocking.helperPath
        let backupPath = Constants.Blocking.hostsBackupPath
        let activeIndicatorPath = Constants.Blocking.activeIndicatorPath
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(Constants.App.launchAgentLabel)</string>
            <key>ProgramArguments</key>
            <array>
                <string>/bin/bash</string>
                <string>-c</string>
                <string>if [ -f \(activeIndicatorPath) ] &amp;&amp; [ -f \(backupPath) ]; then sudo -n \(helperPath) \(backupPath) 2>/dev/null; fi; rm -f \(activeIndicatorPath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
        </dict>
        </plist>
        """

        let launchAgentDir = (Constants.App.launchAgentPath as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(
            atPath: launchAgentDir,
            withIntermediateDirectories: true
        )

        try? plistContent.write(
            toFile: Constants.App.launchAgentPath,
            atomically: true,
            encoding: .utf8
        )
    }

    /// 안전장치 제거
    private func removeSafetyNet() {
        logger.debug("안전장치 제거")
        try? FileManager.default.removeItem(atPath: Constants.Blocking.activeIndicatorPath)
        try? FileManager.default.removeItem(atPath: Constants.App.launchAgentPath)
    }
}
