import Foundation

struct DataStoreRecoveryImportSelectionSummary: Equatable {
    let sourceDirectoryName: String
    let sourceStoreFileName: String
    let selectedCandidateCount: Int
    let totalCandidateCount: Int
    let profileCount: Int
    let siteCount: Int
    let appCount: Int
    let scheduleCount: Int
    let importedFocusSessionCount: Int
    let importedBadgeCount: Int
    let skippedFocusSessionCount: Int
    let skippedBadgeCount: Int

    var totalImportItemCount: Int {
        profileCount + siteCount + appCount + scheduleCount
            + importedFocusSessionCount + importedBadgeCount
    }

    var canImport: Bool {
        selectedCandidateCount > 0
    }

    var sourceSummary: String {
        "\(sourceDirectoryName)/\(sourceStoreFileName)"
    }

    var selectionSummaryText: String {
        guard selectedCandidateCount > 0 else {
            return String(localized: "선택된 항목이 없습니다.")
        }

        if selectedCandidateCount == totalCandidateCount {
            return String(localized: "프로필 \(totalCandidateCount)개 모두 선택")
        }

        return String(localized: "프로필 \(totalCandidateCount)개 중 \(selectedCandidateCount)개 선택")
    }

    var importSummaryText: String {
        var parts = [
            String(localized: "프로필 \(profileCount)개"),
            String(localized: "사이트 \(siteCount)개"),
            String(localized: "앱 \(appCount)개"),
            String(localized: "스케줄 \(scheduleCount)개"),
        ]

        if importedFocusSessionCount > 0 {
            parts.append(String(localized: "세션 \(importedFocusSessionCount)개"))
        }

        if importedBadgeCount > 0 {
            parts.append(String(localized: "배지 \(importedBadgeCount)개"))
        }

        return String(
            localized: "선택 항목: 총 \(totalImportItemCount)개 (\(parts.joined(separator: ", ")))"
        )
    }

    var skippedSummaryText: String {
        if importedFocusSessionCount > 0, importedBadgeCount > 0 {
            return String(localized: "세션 기록과 배지도 새 항목으로 가져옵니다. 중복 항목은 저장 시 건너뜁니다.")
        }

        if importedFocusSessionCount > 0 {
            return String(
                localized: "세션 기록도 새 항목으로 가져옵니다. 중복 세션은 저장 시 건너뛰고, 배지 \(skippedBadgeCount)개는 가져오지 않습니다."
            )
        }

        if importedBadgeCount > 0 {
            return String(
                localized: "배지도 새 항목으로 가져옵니다. 기존 배지와 중복 배지는 저장 시 건너뛰고, 세션 \(skippedFocusSessionCount)개는 가져오지 않습니다."
            )
        }

        return String(
            localized: "세션 \(skippedFocusSessionCount)개와 배지 \(skippedBadgeCount)개는 가져오지 않습니다."
        )
    }

    var confirmationMessageText: String {
        let base = String(
            localized: "기존 데이터는 변경하지 않고 선택 항목을 새 항목으로 추가합니다."
        )

        if importedFocusSessionCount > 0 || importedBadgeCount > 0 {
            return base + " " + String(
                localized: "세션 기록 또는 배지는 중복으로 판단되면 자동으로 건너뜁니다."
            )
        }

        return base + " " + String(localized: "세션 기록과 배지는 가져오지 않습니다.")
    }
}

extension DataStoreRecoveryImportPreview {
    func selectionSummary(
        selectedCandidateIDs: Set<String>
    ) -> DataStoreRecoveryImportSelectionSummary {
        selectionSummary(
            selection: DataStoreRecoveryImportSelection(
                selectedCandidateIDs: selectedCandidateIDs
            )
        )
    }

    func selectionSummary(
        selection: DataStoreRecoveryImportSelection
    ) -> DataStoreRecoveryImportSelectionSummary {
        let selectedCandidates = profileCandidates
            .filter { selection.selectedCandidateIDs.contains($0.id) }

        return DataStoreRecoveryImportSelectionSummary(
            sourceDirectoryName: sourceDirectoryURL.lastPathComponent,
            sourceStoreFileName: sourceStoreFileName,
            selectedCandidateCount: selectedCandidates.count,
            totalCandidateCount: profileCandidates.count,
            profileCount: selectedCandidates.count,
            siteCount: selectedCandidates.reduce(0) { $0 + $1.siteCount },
            appCount: selectedCandidates.reduce(0) { $0 + $1.appCount },
            scheduleCount: selectedCandidates.reduce(0) { $0 + $1.scheduleCount },
            importedFocusSessionCount: selection.includeFocusSessions ? skippedFocusSessionCount : 0,
            importedBadgeCount: selection.includeBadges ? skippedBadgeCount : 0,
            skippedFocusSessionCount: selection.includeFocusSessions ? 0 : skippedFocusSessionCount,
            skippedBadgeCount: selection.includeBadges ? 0 : skippedBadgeCount
        )
    }
}
