import SwiftUI

struct MainView: View {
    @ObservedObject var vm: TrackerViewModel

    private var monthProgress: Double {
        Double(vm.monthRange.dayOfMonth) / Double(vm.monthRange.daysInMonth)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Earned This Month")
                        .font(.headline)
                    Text(vm.monthRange.monthName.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Day \(vm.monthRange.dayOfMonth) of \(vm.monthRange.daysInMonth)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Earnings
            if let error = vm.error {
                Text(error)
                    .font(.body)
                    .foregroundStyle(.red)
            } else if vm.token.isEmpty {
                Text("Enter token in settings")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            } else {
                Text(formatMoney(vm.earned, currency: vm.currency))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .opacity(vm.loading && vm.totalSecs == 0 ? 0.5 : 1)
            }

            // Stats
            if !vm.token.isEmpty && vm.error == nil {
                GroupBox {
                    HStack {
                        StatItem(label: "Hours", value: formatHours(vm.totalSecs))
                        Divider()
                        StatItem(label: "Rate/hr", value: vm.hourlyRate > 0
                            ? "$\(NumberFormatter.localizedString(from: NSNumber(value: vm.hourlyRate), number: .decimal))"
                            : "—")
                        Divider()
                        StatItem(label: "Progress", value: "\(Int(monthProgress * 100))%")
                    }
                }

                // Progress bar
                ProgressView(value: monthProgress)
                    .progressViewStyle(.linear)
            }

            Spacer()

            // Footer
            HStack {
                if let updated = vm.lastUpdated {
                    Text("Updated \(updated, format: .dateTime.hour().minute())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    vm.load()
                } label: {
                    Label("Refresh", systemImage: vm.loading ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                }
                .disabled(vm.loading || vm.token.isEmpty)

                Button {
                    vm.showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .padding()
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}
