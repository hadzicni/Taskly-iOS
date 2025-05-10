import SwiftUI

@main
struct TasklyApp: App {
    @State private var viewModel = TaskListViewModel()
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showOnboarding {
                    OnboardingView {
                        withAnimation {
                            hasSeenOnboarding = true
                            showOnboarding = false
                        }
                    }
                    .transition(.move(edge: .trailing)) // Übergang, wenn Onboarding abgeschlossen wird
                } else {
                    MainTabView(viewModel: viewModel)
                        .transition(.move(edge: .trailing)) // Übergang zur TaskView
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showOnboarding) // Animation beim Wechseln
        }
    }
}
