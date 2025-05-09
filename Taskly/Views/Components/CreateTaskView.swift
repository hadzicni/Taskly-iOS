import SwiftUI

struct CreateTaskView: View {
    var onCreate: (String, Date?) -> Void

    @State private var title: String = ""
    @State private var dueDate: Date? = Date()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("Enter title...", text: $title)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date & Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    DatePicker(
                        "",
                        selection: Binding(get: {
                            dueDate ?? Date()
                        }, set: { newValue in
                            dueDate = newValue
                        }),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }

                Spacer()

                Button {
                    onCreate(title.trimmingCharacters(in: .whitespacesAndNewlines), dueDate)
                    dismiss()
                } label: {
                    Label("Create Task", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
