import Foundation
import Observation

enum TaskSection: String, CaseIterable, Identifiable {
    case overdue = "Overdue"
    case today = "Today"
    case upcoming = "Upcoming"
    case noDate = "No Due Date"

    var id: String { self.rawValue }
}

@Observable
class TaskListViewModel {
    var showCompleted: Bool = true
    var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }

    private let saveURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("tasks.json")
    }()

    init() {
        loadTasks()
    }

    func filteredTasks(on date: Date?, searchText: String = "") -> [Task] {
        let base = tasks.filter { showCompleted || !$0.isCompleted }

        let dateFiltered: [Task]
        if let date = date {
            dateFiltered = base.filter { task in
                guard let due = task.dueDate else { return false }
                return Calendar.current.isDate(due, inSameDayAs: date)
            }
        } else {
            dateFiltered = base
        }

        return searchText.isEmpty
            ? dateFiltered
            : dateFiltered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    func groupedTasks(on date: Date? = nil, searchText: String = "") -> [TaskSection: [Task]] {
        let filtered = filteredTasks(on: date, searchText: searchText)
        let now = Date()
        let calendar = Calendar.current

        var grouped: [TaskSection: [Task]] = [
            .overdue: [],
            .today: [],
            .upcoming: [],
            .noDate: []
        ]

        for task in filtered {
            if let due = task.dueDate {
                if calendar.isDateInToday(due) {
                    grouped[.today]?.append(task)
                } else if due < now {
                    grouped[.overdue]?.append(task)
                } else {
                    grouped[.upcoming]?.append(task)
                }
            } else {
                grouped[.noDate]?.append(task)
            }
        }

        return grouped
    }

    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }

    func addTask(title: String, dueDate: Date? = nil, notes: String? = nil) {
        let newTask = Task(title: title, dueDate: dueDate)
        tasks.append(newTask)
        NotificationService.scheduleNotification(for: newTask)
    }

    func updateTask(_ task: Task, newTitle: String, newDueDate: Date?) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
            tasks[index].dueDate = newDueDate

            NotificationService.removeNotification(for: task.id)
            NotificationService.scheduleNotification(for: tasks[index])
        }
    }

    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func deleteTask(at offsets: IndexSet) {
        let idsToDelete = offsets.map { tasks[$0].id }
        tasks.remove(atOffsets: offsets)
        for id in idsToDelete {
            NotificationService.removeNotification(for: id)
        }
    }

    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: saveURL, options: [.atomicWrite])
        } catch {
            print("Error saving tasks: \(error)")
        }
    }

    private func loadTasks() {
        do {
            let data = try Data(contentsOf: saveURL)
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("No saved tasks found or error decoding: \(error)")
            tasks = []
        }
    }
}
