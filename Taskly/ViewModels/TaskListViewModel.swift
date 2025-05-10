import Foundation
import Observation

enum TaskSection: String, CaseIterable, Identifiable {
    case overdue = "Overdue"
    case today = "Today"
    case upcoming = "Upcoming"
    case noDate = "No Due Date"

    var id: String { rawValue }
}

@Observable
class TaskListViewModel {
    var showCompleted: Bool = true
    var tasks: [Task] = [] {
        didSet { saveTasks() }
    }

    private let saveURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("tasks.json")

    // MARK: - Init

    init() {
        loadTasks()
    }

    // MARK: - Task Filtering

    func filteredTasks(on date: Date?, searchText: String = "") -> [Task] {
        tasks
            .filter { showCompleted || !$0.isCompleted }
            .filter {
                guard let date else { return true }
                guard let due = $0.dueDate else { return false }
                return Calendar.current.isDate(due, inSameDayAs: date)
            }
            .filter {
                searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
            }
    }

    func groupedTasks(on date: Date? = nil, searchText: String = "") -> [TaskSection: [Task]] {
        let now = Date()
        let calendar = Calendar.current

        var grouped: [TaskSection: [Task]] = [
            .overdue: [], .today: [], .upcoming: [], .noDate: [],
        ]

        for task in filteredTasks(on: date, searchText: searchText) {
            if let due = task.dueDate {
                if calendar.isDateInToday(due) {
                    grouped[.today, default: []].append(task)
                } else if due < now {
                    grouped[.overdue, default: []].append(task)
                } else {
                    grouped[.upcoming, default: []].append(task)
                }
            } else {
                grouped[.noDate, default: []].append(task)
            }
        }

        return grouped
    }

    // MARK: - Task Management

    func addTask(title: String, dueDate: Date? = nil, notes _: String? = nil) {
        let newTask = Task(title: title, dueDate: dueDate)
        tasks.append(newTask)
        NotificationService.scheduleNotification(for: newTask)
    }

    func updateTask(_ task: Task, newTitle: String, newDueDate: Date?) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].title = newTitle
        tasks[index].dueDate = newDueDate

        NotificationService.removeNotification(for: task.id)
        NotificationService.scheduleNotification(for: tasks[index])
    }

    func toggleCompletion(for task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }

    func deleteTask(at offsets: IndexSet) {
        let idsToDelete = offsets.map { tasks[$0].id }
        tasks.remove(atOffsets: offsets)
        idsToDelete.forEach { NotificationService.removeNotification(for: $0) }
    }

    // MARK: - Persistence

    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("❌ Save error: \(error.localizedDescription)")
        }
    }

    private func loadTasks() {
        do {
            let data = try Data(contentsOf: saveURL)
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("ℹ️ No saved tasks or error decoding: \(error.localizedDescription)")
            tasks = []
        }
    }
}
