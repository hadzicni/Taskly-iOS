import SwiftUI

struct HorizontalDateStrip: View {
    let dates: [Date]
    let selectedDate: Date?
    let taskCounts: [Date: Int]
    let onSelect: (Date) -> Void

    @Namespace private var animation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(dates, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date())
                    let isToday = Calendar.current.isDateInToday(date)
                    let taskCount = taskCounts[date] ?? 0

                    VStack(spacing: 8) {
                        ZStack {
                            if isSelected {
                                Capsule()
                                    .fill(Color.accentColor)
                                    .matchedGeometryEffect(id: "selection", in: animation)
                                    .frame(width: 56, height: 48)
                            }

                            Text(shortDateLabel(for: date))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: 56)
                                .foregroundColor(
                                    isSelected ? .white :
                                        (isToday ? .accentColor : .primary)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.accentColor.opacity(isToday && !isSelected ? 0.6 : 0), lineWidth: 1.5)
                                        .frame(width: 56, height: 48)
                                )
                        }

                        if taskCount > 0 {
                            Text("\(taskCount)")
                                .font(.caption2)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.white.opacity(0.3) : Color.accentColor.opacity(0.15))
                                )
                                .foregroundColor(isSelected ? .white : .accentColor)
                        } else {
                            Spacer().frame(height: 18)
                        }
                    }
                    .frame(width: 64)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            onSelect(date)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(height: 88)
    }

    private func shortDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("E d")
        let label = formatter.string(from: date)
        return label.replacingOccurrences(of: " ", with: "\n")
    }
}
