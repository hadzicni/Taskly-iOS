import SwiftUI

struct EditTaskView: View {
    let task: Task
    var onSave: (String, Date?) -> Void

    @State private var title: String
    @State private var dueDate: Date?
    @Environment(\.dismiss) private var dismiss

    init(task: Task, onSave: @escaping (String, Date?) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task.title)
        _dueDate = State(initialValue: task.dueDate)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Task Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("Enter title...", text: $title)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor.opacity(0.15), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 12) {
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
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()

                Button {
                    onSave(title.trimmingCharacters(in: .whitespacesAndNewlines), dueDate)
                    dismiss()
                } label: {
                    Label("Save Changes", systemImage: "checkmark")
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
