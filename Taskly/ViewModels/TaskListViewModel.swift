import Foundation
import Observation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"

    var id: String { self.rawValue }
}

enum TaskSortOption: String, CaseIterable, Identifiable {
    case dueDate = "Due Date"
    case title = "Title"
    case status = "Status"

    var id: String { self.rawValue }
}

@Observable
class TaskListViewModel {
    var currentSort: TaskSortOption = .dueDate

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

    func filteredTasks(for filter: TaskFilter) -> [Task] {
        let filtered: [Task] = {
            switch filter {
            case .all:
                return tasks
            case .today:
                return tasks.filter {
                    guard let due = $0.dueDate else { return false }
                    return Calendar.current.isDateInToday(due)
                }
            }
        }()

        return sortTasks(filtered)
    }

    private func sortTasks(_ tasks: [Task]) -> [Task] {
        switch currentSort {
        case .dueDate:
            return tasks.sorted {
                ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
            }
        case .title:
            return tasks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .status:
            return tasks.sorted { !$0.isCompleted && $1.isCompleted }
        }
    }

    func addTask(title: String, dueDate: Date? = nil) {
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
