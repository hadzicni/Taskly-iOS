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
            Form {
                Section(header: Text("Title")) {
                    TextField("Task Title", text: $title)
                }

                Section(header: Text("Due Date")) {
                    DatePicker("Due", selection: Binding(get: {
                        dueDate ?? Date()
                    }, set: { newValue in
                        dueDate = newValue
                    }), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }

                Section {
                    Button("Save") {
                        onSave(title, dueDate)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
