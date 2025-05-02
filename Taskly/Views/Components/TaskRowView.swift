import SwiftUI

struct TaskRowView: View {
    let task: Task
    let toggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: toggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                if let due = task.dueDate {
                    Text(deadlineText(for: due))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func deadlineText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE" // e.g., Monday

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateStyle = .short
        shortDateFormatter.timeStyle = .short

        if calendar.isDateInToday(date) {
            return "Today at \(timeFormatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow at \(timeFormatter.string(from: date))"
        } else if date < now && !calendar.isDateInToday(date) {
            if calendar.isDateInYesterday(date) {
                return "Overdue – yesterday at \(timeFormatter.string(from: date))"
            } else {
                return "Overdue – \(shortDateFormatter.string(from: date))"
            }
        } else {
            let weekday = weekdayFormatter.string(from: date)
            return "\(weekday) at \(timeFormatter.string(from: date))"
        }
    }
}
