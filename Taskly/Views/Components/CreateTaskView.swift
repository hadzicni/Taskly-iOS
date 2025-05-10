import SwiftUI

struct CreateTaskView: View {
    var onCreate: (String, Date?) -> Void

    @State private var title: String = ""
    @State private var dueDate: Date? = Date()
    @Environment(\.dismiss) private var dismiss

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
                                .strokeBorder(Color.accentColor.opacity(0.15), lineWidth: 1)
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
                    onCreate(title.trimmingCharacters(in: .whitespacesAndNewlines), dueDate)
                    dismiss()
                } label: {
                    Label("Create Task", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
