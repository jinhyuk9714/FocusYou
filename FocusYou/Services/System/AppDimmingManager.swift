import AppKit
import os

// MARK: - 비활성 앱 디밍 관리 (v1.4)
// 차단 대상 앱의 윈도우 위에 반투명 오버레이를 띄워 시각적 사용 자제 유도

@MainActor
@Observable
final class AppDimmingManager {
    static let shared = AppDimmingManager()

    /// 앱 PID → 오버레이 패널 매핑
    private var overlayPanels: [pid_t: [NSPanel]] = [:]
    private var trackingTimer: Timer?
    private var trackedBundleIds: [String] = []
    private var dimmingOpacity: Double = 0.3

    var isActive: Bool { trackingTimer != nil }

    private let logger = Logger(
        subsystem: Constants.App.subsystem,
        category: "AppDimming"
    )

    private init() {}

    // MARK: - Public

    func activate(bundleIds: [String], opacity: Double) {
        guard !bundleIds.isEmpty else { return }
        trackedBundleIds = bundleIds
        dimmingOpacity = opacity

        // 즉시 한번 업데이트 후 주기적 추적 시작
        updateOverlays()

        trackingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateOverlays()
            }
        }

        logger.info("앱 디밍 활성화: \(bundleIds.count)개 앱, 불투명도 \(opacity)")
    }

    func deactivate() {
        trackingTimer?.invalidate()
        trackingTimer = nil
        trackedBundleIds = []
        removeAllOverlays()
        logger.info("앱 디밍 비활성화")
    }

    // MARK: - Window Tracking

    private func updateOverlays() {
        // 1. 차단 대상 앱의 실행 중인 PID 수집
        let runningApps = NSWorkspace.shared.runningApplications.filter { app in
            guard let bundleId = app.bundleIdentifier else { return false }
            return trackedBundleIds.contains(bundleId)
        }

        let activePIDs = Set(runningApps.map(\.processIdentifier))

        // 2. 종료된 앱의 오버레이 제거
        for pid in overlayPanels.keys where !activePIDs.contains(pid) {
            removeOverlays(for: pid)
        }

        // 3. 각 앱의 윈도우 프레임에 오버레이 배치
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else { return }

        // PID별 윈도우 프레임 수집
        var pidFrames: [pid_t: [CGRect]] = [:]
        for windowInfo in windowList {
            guard let ownerPID = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
                  activePIDs.contains(ownerPID),
                  let boundsDict = windowInfo[kCGWindowBounds as String] as? [String: Any],
                  let frame = CGRect(dictionaryRepresentation: boundsDict as CFDictionary) else {
                continue
            }

            // 최소 크기 필터 (너무 작은 윈도우 무시)
            guard frame.width > 50 && frame.height > 50 else { continue }

            pidFrames[ownerPID, default: []].append(frame)
        }

        // 4. 오버레이 생성/업데이트
        for (pid, frames) in pidFrames {
            let existingPanels = overlayPanels[pid] ?? []

            // 기존 패널 재활용 또는 새로 생성
            var updatedPanels: [NSPanel] = []

            for (index, frame) in frames.enumerated() {
                let screenFrame = convertToScreenCoordinates(frame)

                if index < existingPanels.count {
                    // 기존 패널 위치/크기 업데이트
                    existingPanels[index].setFrame(screenFrame, display: true)
                    updatedPanels.append(existingPanels[index])
                } else {
                    // 새 패널 생성
                    let panel = createOverlayPanel(frame: screenFrame)
                    panel.orderFront(nil)
                    updatedPanels.append(panel)
                }
            }

            // 남는 기존 패널 제거
            for index in frames.count..<existingPanels.count {
                existingPanels[index].close()
            }

            overlayPanels[pid] = updatedPanels
        }

        // 프레임이 없는 PID의 오버레이 제거
        for pid in activePIDs where pidFrames[pid] == nil {
            removeOverlays(for: pid)
        }
    }

    // MARK: - Overlay Panel

    private func createOverlayPanel(frame: NSRect) -> NSPanel {
        let panel = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = NSColor.black.withAlphaComponent(dimmingOpacity)
        panel.ignoresMouseEvents = true
        panel.hasShadow = false
        panel.isOpaque = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        return panel
    }

    /// CGWindowList 좌표(top-left 원점) → NSScreen 좌표(bottom-left 원점) 변환
    private func convertToScreenCoordinates(_ cgRect: CGRect) -> NSRect {
        guard let mainScreen = NSScreen.screens.first else {
            return NSRect(x: cgRect.origin.x, y: cgRect.origin.y,
                          width: cgRect.width, height: cgRect.height)
        }
        let screenHeight = mainScreen.frame.height
        return NSRect(
            x: cgRect.origin.x,
            y: screenHeight - cgRect.origin.y - cgRect.height,
            width: cgRect.width,
            height: cgRect.height
        )
    }

    private func removeOverlays(for pid: pid_t) {
        overlayPanels[pid]?.forEach { $0.close() }
        overlayPanels.removeValue(forKey: pid)
    }

    private func removeAllOverlays() {
        for (_, panels) in overlayPanels {
            panels.forEach { $0.close() }
        }
        overlayPanels.removeAll()
    }
}
