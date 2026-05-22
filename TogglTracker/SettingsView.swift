import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: TrackerViewModel
    @State private var draftToken = ""
    @State private var draftRate = ""
    @State private var showToken = false

    private var canApply: Bool {
        !draftToken.trimmingCharacters(in: .whitespaces).isEmpty
        && (Double(draftRate) ?? 0) > 0
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    if showToken {
                        TextField("Paste your Toggl API token", text: $draftToken)
                    } else {
                        SecureField("Paste your Toggl API token", text: $draftToken)
                    }

                    Button {
                        showToken.toggle()
                    } label: {
                        Image(systemName: showToken ? "eye.slash" : "eye")
                    }
                }
            } header: {
                Text("Toggl API Token")
            } footer: {
                Text("Get your token from toggl.com → Profile Settings → API Token")
            }

            Section {
                TextField("Hourly rate", text: $draftRate)
            } header: {
                Text("Hourly Rate (USD)")
            }

            HStack {
                Spacer()

                if !vm.token.isEmpty {
                    Button("Cancel") {
                        vm.showSettings = false
                    }
                }

                Button("Apply") {
                    vm.token = draftToken
                    vm.rate = draftRate
                    vm.currency = "USD"
                    vm.showSettings = false
                    vm.load()
                }
                .disabled(!canApply)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 8)
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            draftToken = vm.token
            draftRate = vm.rate
        }
    }
}
