import SwiftUI

struct CreateTaskView: View {
    var onCreate: (String, Date?) -> Void

    @State private var title: String = ""
    @State private var dueDate: Date? = Date()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Task Title", text: $title)
                }

                Section(header: Text("Due Date & Time")) {
                    DatePicker("Due", selection: Binding(get: {
                        dueDate ?? Date()
                    }, set: { newValue in
                        dueDate = newValue
                    }), displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }

                Section {
                    Button("Create") {
                        onCreate(title, dueDate)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
