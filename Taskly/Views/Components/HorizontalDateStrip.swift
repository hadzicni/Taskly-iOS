import SwiftUI

struct HorizontalDateStrip: View {
    let dates: [Date]
    let selectedDate: Date?
    let taskCounts: [Date: Int]
    let onSelect: (Date) -> Void

    @State private var initialScrollDone = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dates, id: \.self) { date in
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date())
                        let isToday = Calendar.current.isDateInToday(date)
                        let taskCount = taskCounts[date, default: 0]

                        VStack(spacing: 6) {
                            Button(action: {
                                onSelect(date)
                            }) {
                                VStack(spacing: 2) {
                                    Text(formattedWeekday(for: date))
                                        .font(.caption2)
                                        .foregroundColor(isSelected ? .white : .secondary)

                                    Text(formattedDay(for: date))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSelected ? .white : .primary)
                                }
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.accentColor : (isToday ? Color.accentColor.opacity(0.1) : Color.clear))
                                )
                            }
                            .buttonStyle(.plain)

                            if taskCount > 0 {
                                Text("\(taskCount)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .id(date) // wichtig für ScrollViewReader
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onAppear {
                    if !initialScrollDone {
                        scrollToToday(proxy: proxy)
                        initialScrollDone = true
                    }
                }
            }
        }
        .frame(height: 84)
    }

    private func formattedWeekday(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("E")
        return formatter.string(from: date)
    }

    private func formattedDay(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter.string(from: date)
    }

    private func scrollToToday(proxy: ScrollViewProxy) {
        let today = Date()
        if let target = dates.first(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            DispatchQueue.main.async {
                withAnimation {
                    proxy.scrollTo(target, anchor: .center)
                }
            }
        }
    }
}
