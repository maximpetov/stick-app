import SwiftUI
import Combine

class TrackerViewModel: ObservableObject {
    @Published var totalSecs: Double = 0
    @Published var loading = false
    @Published var error: String? = nil
    @Published var lastUpdated: Date? = nil
    @Published var showSettings = false

    @AppStorage("toggl_token") var token = ""
    @AppStorage("toggl_rate") var rate = ""
    @AppStorage("toggl_currency") var currency = "USD"

    var hourlyRate: Double { Double(rate) ?? 0 }
    var earned: Double { (totalSecs / 3600) * hourlyRate }
    var monthRange: MonthRange { currentMonthRange() }

    func load() {
        guard !token.isEmpty else { return }
        let currentToken = token
        Task {
            await MainActor.run {
                self.loading = true
                self.error = nil
            }
            do {
                let entries = try await fetchEntries(token: currentToken)
                let secs = totalSeconds(from: entries)
                await MainActor.run {
                    self.totalSecs = secs
                    self.lastUpdated = Date()
                    self.loading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.loading = false
                }
            }
        }
    }
}

struct MenuBarContentView: View {
    @StateObject private var vm = TrackerViewModel()

    var body: some View {
        Group {
            if vm.showSettings || vm.token.isEmpty {
                SettingsView(vm: vm)
            } else {
                MainView(vm: vm)
            }
        }
        .frame(width: 400, height: 320)
        .onAppear { vm.load() }
    }
}
