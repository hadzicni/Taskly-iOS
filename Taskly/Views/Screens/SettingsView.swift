import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TaskListViewModel
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultDueTime") private var defaultDueTime = true
    @State private var appVersion = "1.0.0" // kannst du dynamisch aus Info.plist holen

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Display")) {
                    Toggle("Show Completed Tasks", isOn: $viewModel.showCompleted)
                    Toggle("Default to Today's Date", isOn: $defaultDueTime)
                }

                Section(header: Text("Notifications")) {
                    Toggle("Enable Reminders", isOn: $notificationsEnabled)
                    Button("Request Permission Again") {
                        NotificationService.requestAuthorization()
                    }
                }

                Section(header: Text("Task Management")) {
                    Button(role: .destructive) {
                        viewModel.tasks.removeAll()
                    } label: {
                        Label("Delete All Tasks", systemImage: "trash")
                    }
                }

                Section(header: Text("App Info")) {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Made by", systemImage: "heart.fill")
                            .foregroundColor(.pink)
                        Spacer()
                        Text("Nikola Hadzic")
                            .foregroundStyle(.secondary)
                    }

                    Link("GitHub Repository", destination: URL(string: "https://github.com/hadzicni/Taskly-iOS")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
