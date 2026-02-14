import SwiftUI
import SwiftData

// MARK: - 데이터 내보내기 뷰 (v1.5)

struct ExportView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    let sessions: [FocusSession]

    @State private var selectedFormat: ExportFormat = .csv
    @State private var startDate: Date = Calendar.current.date(
        byAdding: .month, value: -1, to: Date()
    ) ?? Date()
    @State private var endDate: Date = Date()
    @State private var isExporting = false
    @State private var exportSuccess: Bool?

    private var filteredSessions: [FocusSession] {
        let start = startDate.startOfDay
        let end = Calendar.current.date(byAdding: .day, value: 1, to: endDate.startOfDay) ?? endDate
        return sessions.filter { $0.startedAt >= start && $0.startedAt < end }
    }

    var body: some View {
        VStack(spacing: Constants.Design.spacingXL) {
            // 헤더
            HStack {
                Text("데이터 내보내기")
                    .font(.title3.bold())
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }

            // 포맷 선택
            VStack(alignment: .leading, spacing: Constants.Design.spacingSM) {
                Text("포맷")
                    .font(.callout.weight(.medium))

                HStack(spacing: Constants.Design.spacingSM) {
                    ForEach(ExportFormat.allCases) { format in
                        formatButton(format)
                    }
                }
            }

            // 날짜 범위
            VStack(alignment: .leading, spacing: Constants.Design.spacingSM) {
                Text("기간")
                    .font(.callout.weight(.medium))

                HStack(spacing: Constants.Design.spacingMD) {
                    DatePicker("시작", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                    Text("~")
                        .foregroundStyle(.secondary)
                    DatePicker("종료", selection: $endDate, displayedComponents: .date)
                        .labelsHidden()
                }
            }

            // 세션 수 미리보기
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(themeManager.primary)
                Text("\(filteredSessions.count)개 세션")
                    .font(.callout)
                Spacer()

                if let success = exportSuccess {
                    Label(
                        success ? "저장 완료" : "저장 실패",
                        systemImage: success ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .font(.caption.weight(.medium))
                    .foregroundStyle(success ? .green : .red)
                    .transition(.opacity)
                }
            }
            .padding(Constants.Design.spacingMD)
            .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: Constants.Design.cornerMD))

            // 내보내기 버튼
            Button {
                performExport()
            } label: {
                HStack {
                    if isExporting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Text("내보내기")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Design.spacingSM)
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.primary)
            .disabled(filteredSessions.isEmpty || isExporting)
        }
        .padding(Constants.Design.spacingXL)
        .frame(width: 360)
        .animation(.quickEase, value: exportSuccess)
    }

    // MARK: - 포맷 버튼

    private func formatButton(_ format: ExportFormat) -> some View {
        let isSelected = selectedFormat == format
        return Button {
            selectedFormat = format
        } label: {
            HStack(spacing: Constants.Design.spacingXS) {
                Image(systemName: format == .csv ? "tablecells" : "curlybraces")
                Text(format.rawValue)
                    .font(.callout.weight(.medium))
            }
            .padding(.horizontal, Constants.Design.spacingMD)
            .padding(.vertical, Constants.Design.spacingSM)
            .background(
                isSelected
                    ? themeManager.primary.opacity(0.12)
                    : Color.secondary.opacity(0.06),
                in: RoundedRectangle(cornerRadius: Constants.Design.cornerMD)
            )
            .foregroundStyle(isSelected ? themeManager.primary : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Design.cornerMD)
                    .stroke(isSelected ? themeManager.primary.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(format.rawValue) 포맷\(isSelected ? ", 선택됨" : "")")
    }

    // MARK: - 내보내기 실행

    private func performExport() {
        isExporting = true
        exportSuccess = nil

        Task {
            let content: String
            switch selectedFormat {
            case .csv:
                content = ExportService.exportToCSV(sessions: filteredSessions)
            case .json:
                content = ExportService.exportToJSON(sessions: filteredSessions)
            }

            let success = await ExportService.saveFile(
                content: content,
                format: selectedFormat,
                sessionCount: filteredSessions.count
            )

            exportSuccess = success
            isExporting = false

            if success {
                try? await Task.sleep(for: .seconds(1.5))
                dismiss()
            }
        }
    }
}

#Preview {
    ExportView(sessions: [])
        .environment(ThemeManager.shared)
}
