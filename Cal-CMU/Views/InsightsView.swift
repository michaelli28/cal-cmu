import SwiftUI

struct InsightsView: View {
    @Environment(MealStore.self) private var store
    @State private var animateScore = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    WeeklyChartView(
                        data: store.weeklyCalories,
                        goal: store.activeCalorieGoal
                    )

                    averageStatsCard
                    macroSplitCard
                    topNutrientsCard

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(FlatColors.background)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Average Stats

    private var averageStatsCard: some View {
        HStack(spacing: 0) {
            statBubble(
                value: "\(store.averageWeeklyCalories)",
                label: "Avg Cal/Day",
                icon: "flame.fill",
                color: FlatColors.tangerine
            )
            statBubble(
                value: "\(store.todaysMeals.count)",
                label: "Meals Today",
                icon: "fork.knife",
                color: FlatColors.primary
            )
            statBubble(
                value: "\(store.streakDays)",
                label: "Day Streak",
                icon: "flame.fill",
                color: FlatColors.coral
            )
        }
        .padding(.vertical, 16)
        .background(FlatColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statBubble(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            FlatIconCircle(icon: icon, color: color, size: 44)

            Text(value)
                .font(FlatFont.title(20))
                .foregroundStyle(FlatColors.textPrimary)

            Text(label)
                .font(FlatFont.caption(11))
                .foregroundStyle(FlatColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Macro Split

    private var macroSplitCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macro Split")
                .font(FlatFont.heading(17))
                .foregroundStyle(FlatColors.textPrimary)

            HStack(spacing: 16) {
                ZStack {
                    let p = store.macroPercentages

                    Circle()
                        .stroke(FlatColors.divider, lineWidth: 16)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: animateScore ? p.protein / 100 : 0)
                        .stroke(FlatColors.ocean, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .trim(from: 0, to: animateScore ? p.carbs / 100 : 0)
                        .stroke(FlatColors.tangerine, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90 + 360 * p.protein / 100))

                    Circle()
                        .trim(from: 0, to: animateScore ? p.fat / 100 : 0)
                        .stroke(FlatColors.rose, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90 + 360 * (p.protein + p.carbs) / 100))

                    VStack(spacing: 0) {
                        Text("\(store.totalCaloriesToday)")
                            .font(FlatFont.heading(16))
                            .foregroundStyle(FlatColors.textPrimary)
                        Text("cal")
                            .font(FlatFont.caption(10))
                            .foregroundStyle(FlatColors.textSecondary)
                    }
                }
                .animation(.easeOut(duration: 0.6), value: animateScore)

                VStack(alignment: .leading, spacing: 12) {
                    macroLegend("Protein", pct: store.macroPercentages.protein, grams: store.totalProteinToday, color: FlatColors.ocean)
                    macroLegend("Carbs", pct: store.macroPercentages.carbs, grams: store.totalCarbsToday, color: FlatColors.tangerine)
                    macroLegend("Fat", pct: store.macroPercentages.fat, grams: store.totalFatToday, color: FlatColors.rose)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .flatCard(cornerRadius: 14, padding: 20)
        .onAppear { animateScore = true }
    }

    private func macroLegend(_ name: String, pct: Double, grams: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textPrimary)
                Text("\(Int(grams))g (\(Int(pct))%)")
                    .font(FlatFont.caption(11))
                    .foregroundStyle(FlatColors.textSecondary)
            }
        }
    }

    // MARK: - Top Nutrients

    private var topNutrientsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's Breakdown")
                .font(FlatFont.heading(17))
                .foregroundStyle(FlatColors.textPrimary)

            nutrientDetailRow("Calories", value: "\(store.totalCaloriesToday)", unit: "cal", icon: "flame.fill", color: FlatColors.tangerine)
            nutrientDetailRow("Protein", value: "\(Int(store.totalProteinToday))", unit: "g", icon: "circle.hexagongrid.fill", color: FlatColors.ocean)
            nutrientDetailRow("Carbs", value: "\(Int(store.totalCarbsToday))", unit: "g", icon: "bolt.fill", color: FlatColors.sunflower)
            nutrientDetailRow("Fat", value: "\(Int(store.totalFatToday))", unit: "g", icon: "drop.triangle.fill", color: FlatColors.rose)
            nutrientDetailRow("Vitamin C", value: "\(Int(store.totalVitaminCToday))", unit: "mg", icon: "pills.fill", color: FlatColors.sunflower)
            nutrientDetailRow("Iron", value: String(format: "%.1f", store.totalIronToday), unit: "mg", icon: "cross.vial.fill", color: FlatColors.coral)
            nutrientDetailRow("Calcium", value: "\(Int(store.totalCalciumToday))", unit: "mg", icon: "bone.fill", color: FlatColors.textSecondary)
        }
        .flatCard(cornerRadius: 14, padding: 20)
    }

    private func nutrientDetailRow(_ name: String, value: String, unit: String, icon: String, color: Color) -> some View {
        HStack {
            FlatIconCircle(icon: icon, color: color, size: 30)

            Text(name)
                .font(FlatFont.body(14))
                .foregroundStyle(FlatColors.textPrimary)

            Spacer()

            Text("\(value) \(unit)")
                .font(FlatFont.heading(14))
                .foregroundStyle(FlatColors.textSecondary)
        }
    }
}

#Preview {
    InsightsView()
        .environment(MealStore())
}
