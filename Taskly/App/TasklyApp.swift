import SwiftUI

@main
struct TasklyApp: App {
    @State private var viewModel = TaskListViewModel()
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView(viewModel: viewModel)
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
    }
}
