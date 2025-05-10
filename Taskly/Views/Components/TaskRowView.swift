import SwiftUI

struct TaskRowView: View {
    let task: Task
    let toggle: () -> Void

    @State private var isCompleted: Bool

    init(task: Task, toggle: @escaping () -> Void) {
        self.task = task
        self.toggle = toggle
        _isCompleted = State(initialValue: task.isCompleted)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    toggle()
                    isCompleted.toggle()
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? .green : .gray.opacity(0.5))
                    .scaleEffect(isCompleted ? 1.2 : 1)
                    .rotationEffect(.degrees(isCompleted ? 360 : 0))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .gray.opacity(0.5))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .opacity(isCompleted ? 0.6 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isCompleted)

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
