import SwiftUI

struct TaskRowView: View {
    let task: Task
    let toggle: () -> Void

    var body: some View {
        HStack {
            Button(action: toggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }

            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .primary)

            Spacer()

            if let due = task.dueDate {
                Text(due.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
