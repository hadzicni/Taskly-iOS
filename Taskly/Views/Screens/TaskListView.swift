import SwiftUI

struct TaskListView: View {
    @Bindable var viewModel: TaskListViewModel
    @AppStorage("userName") private var userName: String = ""
    @Namespace private var weekSelectorAnimation

    @State private var editingTask: Task? = nil
    @State private var selectedDate: Date? = nil
    @State private var weekOffset: Int = 0
    @State private var showDatePicker = false
    @State private var tempSelectedDate = Date()
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    // 📅 Kalenderbereich
                    VStack(spacing: 16) {
                        // 👋 Begrüßung
                        VStack(alignment: .leading, spacing: 6) {
                            Text("👋 Hello,")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text(userName.isEmpty ? "you" : userName)
                                .font(.largeTitle.bold())
                        }
                        .padding(.horizontal)

                        // Kalender Auswahl
                        VStack(spacing: 12) {
                            Button {
                                tempSelectedDate = selectedDate ?? Date()
                                showDatePicker = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                    Text(currentWeekLabel())
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.primary)

                            HStack(spacing: 12) {
                                Button { withAnimation { weekOffset -= 1 } } label: {
                                    Image(systemName: "chevron.left")
                                }

                                HorizontalDateStrip(
                                    dates: currentWeekDates(),
                                    selectedDate: selectedDate,
                                    taskCounts: taskCountsForCurrentWeek(),
                                    onSelect: { date in selectedDate = date }
                                )

                                Button { withAnimation { weekOffset += 1 } } label: {
                                    Image(systemName: "chevron.right")
                                }

                                Button("Today") {
                                    selectedDate = Date()
                                    weekOffset = 0
                                }
                                .buttonStyle(.bordered)
                                .disabled(selectedDate != nil && Calendar.current.isDateInToday(selectedDate!))
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }

                    // 📝 Aufgabenliste
                    let tasks = viewModel.filteredTasks(on: selectedDate)

                    if tasks.isEmpty {
                        ContentUnavailableView("No Tasks", systemImage: "checkmark.circle")
                            .padding(.top, 20)
                    } else {
                        ForEach(TaskSection.allCases) { section in
                            let sectionTasks = viewModel.groupedTasks(on: selectedDate)[section, default: []]
                            if !sectionTasks.isEmpty {
                                VStack(spacing: 8) {
                                    Text(section.rawValue)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal)

                                    ForEach(sectionTasks) { task in
                                        TaskRowView(task: task, toggle: {
                                            viewModel.toggleCompletion(for: task)
                                        })
                                        .onTapGesture {
                                            editingTask = task
                                        }
                                        .padding(.leading, 16) // Abstand links von den Tasks
                                    }
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 12)

                // ➕ New Task Button
                Button {
                    showCreateSheet = true
                } label: {
                    Label("New Task", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                        .font(.headline)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .foregroundColor(.white) // Weißer Text und Icon
                        .shadow(radius: 5) // Schatten für Tiefe
                }
                .buttonStyle(.plain)
            }

            .navigationTitle("Tasks")
            .popover(isPresented: $showDatePicker) {
                DatePickerPopover
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateTaskView { title, dueDate in
                    viewModel.addTask(title: title, dueDate: dueDate)
                }
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task) { newTitle, newDueDate in
                    viewModel.updateTask(task, newTitle: newTitle, newDueDate: newDueDate)
                    editingTask = nil
                }
            }
            .onAppear {
                NotificationService.requestAuthorization()
            }
        }
    }

    // ⏱ Popover für Datumsauswahl
    private var DatePickerPopover: some View {
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

    // 📆 Hilfsfunktionen
    private func currentWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let offsetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today)!
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: offsetDate))!
        return (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
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
        return (targetYear - currentYear) * 52 + (targetWeek - currentWeek)
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

    private func taskCount(on date: Date) -> Int {
        viewModel.tasks.filter {
            guard let due = $0.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }.count
    }

    private func weekDates(for referenceDate: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate))!
        return (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
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
