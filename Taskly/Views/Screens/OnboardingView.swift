import SwiftUI

struct OnboardingView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var nameInput: String = ""
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to Taskly!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Let’s get started by entering your name.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                TextField("Your name", text: $nameInput)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("Continue") {
                    userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }
}
