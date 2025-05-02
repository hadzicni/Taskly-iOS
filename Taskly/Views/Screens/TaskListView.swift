import SwiftUI

struct TaskListView: View {
    @Bindable var viewModel: TaskListViewModel
    @Namespace private var weekSelectorAnimation
    @State private var newTaskTitle: String = ""
    @State private var newDueDate: Date = Date()
    @State private var editingTask: Task? = nil
    @State private var selectedSort: TaskSortOption = .title
    @State private var selectedDate: Date? = nil
    @State private var weekOffset: Int = 0
    @State private var showDatePicker = false
    @State private var tempSelectedDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                HStack {
                    Picker("Sort by", selection: $selectedSort) {
                        ForEach(TaskSortOption.allCases) { sort in
                            Text(sort.rawValue).tag(sort)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()
                }
                .padding(.horizontal)

                HStack {
                    Button {
                        tempSelectedDate = selectedDate ?? Date()
                        showDatePicker = true
                    } label: {
                        Label(currentWeekLabel(), systemImage: "calendar")
                            .labelStyle(.titleAndIcon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal)

                .popover(isPresented: $showDatePicker) {
                    VStack(spacing: 16) {
                        DatePicker("Select Week", selection: $tempSelectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()

                        Text(weekInfo(for: tempSelectedDate))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(weekDates(for: tempSelectedDate), id: \.self) { date in
                                HStack {
                                    Text(shortDateLabel(for: date))
                                    Spacer()
                                    Text("\(taskCount(on: date)) task\(taskCount(on: date) == 1 ? "" : "s")")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal)

                        Button("Go to Week") {
                            withAnimation {
                                selectedDate = tempSelectedDate
                                weekOffset = calculateWeekOffset(from: tempSelectedDate)
                            }
                            showDatePicker = false
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancel", role: .cancel) {
                            showDatePicker = false
                        }
                    }
                    .frame(width: 320)
                    .padding()
                }

                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation { weekOffset -= 1 }
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    HorizontalDateStrip(
                        dates: currentWeekDates(),
                        selectedDate: selectedDate,
                        taskCounts: taskCountsForCurrentWeek(),
                        onSelect: { date in selectedDate = date }
                    )

                    Button(action: {
                        withAnimation { weekOffset += 1 }
                    }) {
                        Image(systemName: "chevron.right")
                    }

                    Button("Today") {
                        selectedDate = Date()
                        weekOffset = 0
                    }
                    .buttonStyle(.bordered)

                    if selectedDate != nil {
                        Button {
                            selectedDate = nil
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear selected date")
                    }
                }
                .padding(.horizontal)

                let tasks = viewModel.filteredTasks(on: selectedDate)

                if tasks.isEmpty {
                    ContentUnavailableView("No Tasks", systemImage: "checkmark.circle")
                } else {
                    List {
                        ForEach(TaskSection.allCases) { section in
                            let sectionTasks = viewModel.groupedTasks(on: selectedDate)[section, default: []]

                            if !sectionTasks.isEmpty {
                                Section(header: Text(section.rawValue)) {
                                    ForEach(sectionTasks) { task in
                                        Button {
                                            editingTask = task
                                        } label: {
                                            TaskRowView(task: task, toggle: {
                                                viewModel.toggleCompletion(for: task)
                                            })
                                        }
                                    }
                                    .onDelete(perform: viewModel.deleteTask)
                                    .onMove(perform: selectedSort == .manual ? moveTask : nil)
                                }
                            }
                        }
                    }
                }

                Divider()

                HStack(spacing: 8) {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)

                    DatePicker("", selection: $newDueDate, displayedComponents: .date)
                        .labelsHidden()
                        .frame(maxWidth: 120)

                    Button(action: {
                        guard !newTaskTitle.isEmpty else { return }
                        viewModel.addTask(title: newTaskTitle, dueDate: newDueDate)
                        newTaskTitle = ""
                        newDueDate = Date()
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Tasks")
            .toolbar {
                if selectedSort == .manual {
                    EditButton()
                }
            }
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

    private func currentWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let offsetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today)!
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: offsetDate))!

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func currentWeekLabel() -> String {
        let dates = currentWeekDates()
        guard let start = dates.first, let end = dates.last else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")

        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: start)

        return "Week \(weekNumber): \(formatter.string(from: start)) – \(formatter.string(from: end))"
    }

    private func calculateWeekOffset(from date: Date) -> Int {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let targetWeek = calendar.component(.weekOfYear, from: date)
        let currentYear = calendar.component(.yearForWeekOfYear, from: Date())
        let targetYear = calendar.component(.yearForWeekOfYear, from: date)

        let weekDelta = (targetYear - currentYear) * 52 + (targetWeek - currentWeek)
        return weekDelta
    }

    private func weekInfo(for date: Date) -> String {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.yearForWeekOfYear, from: date)
        return "Week \(week) of \(year)"
    }

    private func shortDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("E d")
        return formatter.string(from: date)
    }

    private func moveTask(from source: IndexSet, to destination: Int) {
        guard viewModel.currentSort == .manual else { return }
        viewModel.moveTask(from: source, to: destination)
    }

    private func taskCount(on date: Date) -> Int {
        viewModel.tasks.filter {
            guard let due = $0.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }.count
    }

    private func weekDates(for referenceDate: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func taskCountsForCurrentWeek() -> [Date: Int] {
        var counts: [Date: Int] = [:]
        for date in currentWeekDates() {
            counts[date] = viewModel.tasks.filter {
                guard let due = $0.dueDate else { return false }
                return Calendar.current.isDate(due, inSameDayAs: date)
            }.count
        }
        return counts
    }
}