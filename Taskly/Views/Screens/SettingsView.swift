import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TaskListViewModel
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var permissionStatusMessage: String? = nil
    @State private var showStatusMessage = false
    @State private var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showDeleteConfirmation = false
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Display Settings").foregroundStyle(.primary)) {
                    Toggle("Show Completed Tasks", isOn: $viewModel.showCompleted)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .padding(.vertical, 4)
                }

                Section(header: Text("Notifications").foregroundStyle(.primary)) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .padding(.vertical, 4)

                    Button("Request Permission Again") {
                        NotificationService.requestAuthorization { granted in
                            DispatchQueue.main.async {
                                permissionStatusMessage = granted ? "Permission Granted ✅" : "Permission Denied ❌"
                                showStatusMessage = true

                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    showStatusMessage = false
                                }
                            }
                        }
                    }

                    if showStatusMessage, let message = permissionStatusMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }

                    if !notificationsEnabled {
                        Text("Notifications are disabled. Enable them to receive task reminders.")
                            .foregroundStyle(.red)
                            .font(.caption)
                            .padding(.top, 8)
                    }
                }

                Section(header: Text("Task Management").foregroundStyle(.primary)) {
                    Button("Delete All Tasks", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .confirmationDialog("Are you sure you want to delete all tasks?", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            viewModel.tasks.removeAll()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }

                Section(header: Text("App Reset").foregroundStyle(.primary)) {
                    Button("Reset App to Initial State", role: .destructive) {
                        showResetConfirmation = true
                    }
                    .confirmationDialog("This will reset the app, delete all tasks, and restart the onboarding process. Are you sure?", isPresented: $showResetConfirmation) {
                        Button("Reset App", role: .destructive) {
                            resetApp()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }

                Section(header: Text("App Information").foregroundStyle(.primary)) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Nikola Hadzic ❤️")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("GitHub Repository")
                        Spacer()
                        Link("Visit on GitHub", destination: URL(string: "https://github.com/hadzicni/Taskly-iOS")!)
                            .foregroundColor(.blue)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Settings")
            .padding(.top, 10)
        }
    }

    private func resetApp() {
        // Reset the tasks
        viewModel.tasks.removeAll()

        // Reset any other data you might want to reset
        hasSeenOnboarding = false // Set onboarding to false so it shows again

        // Optionally, you could also remove notifications or reset other user preferences here

        // Navigate back to the Onboarding screen
        // This could be done by changing a navigation view or presentation state in your app
    }
}
