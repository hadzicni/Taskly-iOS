import SwiftUI

struct TaskRowView: View {
    let task: Task
    let toggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: toggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .gray.opacity(0.3))
                    .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .gray.opacity(0.5))
                    .lineLimit(2)
                    .truncationMode(.tail)

                if let due = task.dueDate {
                    Label(deadlineText(for: due), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.001)) // Touch-Fläche vergrößern
        )
        .contentShape(Rectangle())
    }

    private func deadlineText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateStyle = .short
        shortDateFormatter.timeStyle = .short

        if calendar.isDateInToday(date) {
            return "Today at \(timeFormatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow at \(timeFormatter.string(from: date))"
        } else if date < now {
            if calendar.isDateInYesterday(date) {
                return "Overdue – yesterday at \(timeFormatter.string(from: date))"
            } else {
                return "Overdue – \(shortDateFormatter.string(from: date))"
            }
        } else {
            return "\(weekdayFormatter.string(from: date)) at \(timeFormatter.string(from: date))"
        }
    }
}
