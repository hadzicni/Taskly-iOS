import SwiftUI

struct HorizontalDateStrip: View {
    let dates: [Date]
    let selectedDate: Date?
    let taskCounts: [Date: Int]
    let onSelect: (Date) -> Void

    @Namespace private var animation
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dates, id: \.self) { date in
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date())
                        let isToday = Calendar.current.isDateInToday(date)
                        let taskCount = taskCounts[date, default: 0]

                        Button {
                            withAnimation(.spring()) {
                                onSelect(date)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    if isSelected {
                                        Capsule()
                                            .fill(Color.accentColor)
                                            .matchedGeometryEffect(id: "selection", in: animation)
                                            .frame(width: 56, height: 48)
                                    }

                                    Text(formattedLabel(for: date))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 56)
                                        .foregroundColor(isSelected ? .white : (isToday ? .accentColor : .primary))
                                        .overlay(
                                            Circle()
                                                .strokeBorder(Color.accentColor.opacity((isToday && !isSelected) ? 0.6 : 0), lineWidth: 1.5)
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
                        }
                        .buttonStyle(.plain)
                        .id(date) // for ScrollViewReader
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .onAppear {
                    scrollProxy = proxy
                    scrollToInitialDate(proxy: proxy)
                }
                .onChange(of: dates) { _ in
                    scrollToInitialDate(proxy: proxy)
                }
            }
        }
        .frame(height: 88)
    }

    private func formattedLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("E d")
        return formatter.string(from: date).replacingOccurrences(of: " ", with: "\n")
    }

    private func scrollToInitialDate(proxy: ScrollViewProxy) {
        let targetDate = selectedDate ?? Date()
        DispatchQueue.main.async {
            withAnimation {
                proxy.scrollTo(dates.first(where: { Calendar.current.isDate($0, inSameDayAs: targetDate) }), anchor: .center)
            }
        }
    }
}
