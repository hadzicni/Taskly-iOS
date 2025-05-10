import SwiftUI

struct OnboardingView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var nameInput: String = ""
    @State private var isNavigating: Bool = false // Zustand für die Navigation
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Hintergrund: Linear Gradient
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Dieser Befehl sorgt dafür, dass der Hintergrund den gesamten Bildschirm abdeckt

            VStack(spacing: 32) {
                // Titel
                Text("Welcome to Taskly!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.top, 50)

                // Beschreibung
                Text("Let’s get started by entering your name.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                // Eingabefeld für den Namen
                TextField("Your name", text: $nameInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Hilfstext
                Text("This name will be used to personalize your experience.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                // Continue Button - Gleich wie der in der TaskListView
                Button {
                    userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    withAnimation {
                        isNavigating = true // Navigation starten
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Warten auf die Animation
                        onComplete()
                    }
                } label: {
                    Label("Continue", systemImage: "checkmark")
                        .labelStyle(.titleAndIcon)
                        .font(.headline)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .foregroundColor(.white) // Weißer Text und Icon
                        .shadow(radius: 5) // Schatten für Tiefe
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding(.bottom, 30)
            .background(Material.thin) // Statt VisualEffectBlur verwenden wir Material.thin für den Hintergrund
            .cornerRadius(30)
            .padding(.horizontal, 20)

            // Animation, die den Übergang zeigt, wenn isNavigating true wird
            if isNavigating {
                // Hier könnte eine sanfte Transition (z.B. Fade) hinzugefügt werden
                Color.white.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    }
            }
        }
    }
}
