import SwiftUI

struct TaskListView: View {
    @Bindable var viewModel: TaskListViewModel
    @State private var newTaskTitle: String = ""
    @State private var newDueDate: Date = Date()
    @State private var editingTask: Task? = nil
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSortOption = .dueDate
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                Picker("Sort by", selection: $selectedSort) {
                    ForEach(TaskSortOption.allCases) { sort in
                        Text(sort.rawValue).tag(sort)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                .onChange(of: selectedSort) {
                    viewModel.currentSort = selectedSort
                }
                
                if viewModel.filteredTasks(for: selectedFilter).isEmpty {
                    ContentUnavailableView("No Tasks", systemImage: "checkmark.circle")
                } else {
                    List {
                        ForEach(viewModel.filteredTasks(for: selectedFilter)) { task in
                            Button {
                                editingTask = task
                            } label: {
                                TaskRowView(task: task, toggle: {
                                    viewModel.toggleCompletion(for: task)
                                })
                            }
                        }
                        .onDelete(perform: viewModel.deleteTask)
                    }
                }
            
                HStack {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker("", selection: $newDueDate, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)
                    
                    Button("Add") {
                        guard !newTaskTitle.isEmpty else { return }
                        viewModel.addTask(title: newTaskTitle, dueDate: newDueDate)
                        newTaskTitle = ""
                        newDueDate = Date()
                    }
                }
                .padding()
            }
            .navigationTitle("Tasks")
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task) { newTitle, newDueDate in
                    viewModel.updateTask(task, newTitle: newTitle, newDueDate: newDueDate)
                    editingTask = nil
                }
            }
        }
        .onAppear {
            NotificationService.requestAuthorization()
        }
    }
}
