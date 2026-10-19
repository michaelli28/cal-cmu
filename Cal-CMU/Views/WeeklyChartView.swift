import SwiftUI

struct WeeklyChartView: View {
    let data: [(day: String, calories: Int)]
    let goal: Int

    @State private var animateChart = false
    @State private var selectedBar: Int?

    private var maxValue: Int {
        max(data.map(\.calories).max() ?? 1, goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Calories")
                    .font(FlatFont.heading(16))
                    .foregroundStyle(FlatColors.textPrimary)
                Spacer()
                if let selected = selectedBar, selected < data.count {
                    Text("\(data[selected].day): \(data[selected].calories) cal")
                        .font(FlatFont.label(13))
                        .fontWeight(.bold)
                        .foregroundStyle(FlatColors.primary)
                        .transition(.opacity)
                }
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 6) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(FlatColors.divider)
                                .frame(height: 120)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(for: item.calories))
                                .frame(height: animateChart ? barHeight(item.calories) : 0)
                                .animation(
                                    .easeOut(duration: 0.5).delay(Double(index) * 0.08),
                                    value: animateChart
                                )
                        }
                        .frame(height: 120)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedBar = selectedBar == index ? nil : index
                            }
                        }

                        Text(item.day)
                            .font(FlatFont.caption(11))
                            .fontWeight(index == currentDayIndex ? .bold : .medium)
                            .foregroundStyle(index == currentDayIndex ? FlatColors.primary : FlatColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            HStack {
                Rectangle()
                    .fill(FlatColors.divider)
                    .frame(height: 1)
                    .frame(maxWidth: 40)

                Text("Goal: \(goal) cal")
                    .font(FlatFont.caption())
                    .foregroundStyle(FlatColors.textTertiary)

                Spacer()
            }
        }
        .flatCard(cornerRadius: 12, padding: 20)
        .onAppear { animateChart = true }
    }

    private func barHeight(_ calories: Int) -> CGFloat {
        guard maxValue > 0, calories > 0 else { return 4 }
        return max(CGFloat(calories) / CGFloat(maxValue) * 120, 4)
    }

    private func barColor(for calories: Int) -> Color {
        if calories == 0 { return FlatColors.divider }
        if calories > goal { return FlatColors.coral }
        return FlatColors.primary
    }

    private var currentDayIndex: Int {
        let weekday = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        return weekday
    }
}

#Preview {
    WeeklyChartView(
        data: [("M", 1650), ("T", 1820), ("W", 2100), ("T", 1950), ("F", 1780), ("S", 0), ("S", 0)],
        goal: 2000
    )
    .padding()
    .background(FlatColors.background)
}
