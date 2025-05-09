import SwiftUI

@main
struct TasklyApp: App {
    @State private var viewModel = TaskListViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                TaskListView(viewModel: viewModel)
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle")
                    }

                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
        }
    }
}
