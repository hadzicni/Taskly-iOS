import SwiftUI

struct MainTabView: View {
    var viewModel: TaskListViewModel

    var body: some View {
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
