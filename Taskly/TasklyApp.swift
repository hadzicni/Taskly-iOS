import SwiftUI

@main
struct TasklyApp: App {
    @State private var viewModel = TaskListViewModel()

    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: viewModel)
        }
    }
}
