import SwiftUI

struct HomeView: View {
    @Environment(MealStore.self) private var store
    let onScanTap: () -> Void
    let onQuickAdd: (MealType) -> Void
    let onMealTap: (Meal) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    if !store.nudges.isEmpty {
                        nudgeCardsSection
                    }
                    StreakBadgeView(streakDays: store.streakDays)
                    calorieCard
                    macroCard
                    WaterTrackerView()
                    quickAddSection
                    todaysMealsSection
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(FlatColors.background)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), \(store.userName)")
                    .font(FlatFont.title(26))
                    .foregroundStyle(FlatColors.textPrimary)

                Text(dateString)
                    .font(FlatFont.label(14))
                    .foregroundStyle(FlatColors.textSecondary)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 12)
                .fill(FlatColors.primary)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(store.userName.prefix(1)).uppercased())
                        .font(FlatFont.heading(18))
                        .foregroundStyle(.white)
                )
        }
        .padding(.top, 16)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Calorie Card

    private var calorieCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Calories")
                        .font(FlatFont.heading(17))
                        .foregroundStyle(FlatColors.textPrimary)
                    if store.useWeekendPlan {
                        Text(store.activePlanLabel)
                            .font(FlatFont.caption(11))
                            .foregroundStyle(FlatColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(FlatColors.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                Spacer()
                Text("\(store.totalCaloriesToday) / \(store.activeCalorieGoal)")
                    .font(FlatFont.mono(13))
                    .fontWeight(.bold)
                    .foregroundStyle(FlatColors.primary)
            }

            CalorieRingView(
                consumed: store.totalCaloriesToday,
                goal: store.activeCalorieGoal
            )
        }
        .flatCard(cornerRadius: 16, padding: 20)
    }

    // MARK: - Macro Card

    private var macroCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Macronutrients")
                    .font(FlatFont.heading(17))
                    .foregroundStyle(FlatColors.textPrimary)
                Spacer()
            }

            MacroBarView(
                label: "Protein", current: store.totalProteinToday,
                goal: store.activeProteinGoal, unit: "g", color: FlatColors.ocean
            )
            MacroBarView(
                label: "Carbs", current: store.totalCarbsToday,
                goal: store.activeCarbsGoal, unit: "g", color: FlatColors.tangerine
            )
            MacroBarView(
                label: "Fat", current: store.totalFatToday,
                goal: store.activeFatGoal, unit: "g", color: FlatColors.rose
            )
        }
        .flatCard(cornerRadius: 16, padding: 20)
    }

    // MARK: - Quick Add

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(FlatFont.heading(17))
                .foregroundStyle(FlatColors.textPrimary)

            HStack(spacing: 10) {
                ForEach(MealType.allCases) { type in
                    Button {
                        onQuickAdd(type)
                    } label: {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(type.flatColor.opacity(0.12))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: type.icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(type.flatColor)
                                )

                            Text(type.rawValue)
                                .font(FlatFont.caption(11))
                                .foregroundStyle(FlatColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FlatScaleButtonStyle())
                }
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    // MARK: - Nudge Cards

    private var nudgeCardsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(store.nudges) { nudge in
                nudgeCard(nudge)
            }
        }
    }

    private func nudgeCard(_ nudge: MealStore.Nudge) -> some View {
        HStack(spacing: 12) {
            FlatIconCircle(icon: nudge.icon, color: nudge.swiftUIColor, size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(nudge.title)
                    .font(FlatFont.label(14))
                    .fontWeight(.semibold)
                    .foregroundStyle(FlatColors.textPrimary)
                Text(nudge.message)
                    .font(FlatFont.caption(12))
                    .foregroundStyle(FlatColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .flatCard(cornerRadius: 12, padding: 14)
    }

    // MARK: - Today's Meals

    private var todaysMealsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today's Meals")
                    .font(FlatFont.title(20))
                    .foregroundStyle(FlatColors.textPrimary)
                Spacer()
                Text("\(store.todaysMeals.count) logged")
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textSecondary)
            }

            if store.todaysMeals.isEmpty {
                emptyMealsView
            } else {
                ForEach(store.todaysMeals) { meal in
                    MealCardView(meal: meal)
                        .onTapGesture { onMealTap(meal) }
                        .transition(.opacity)
                }
            }
        }
    }

    private var emptyMealsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.macro")
                .font(.system(size: 36))
                .foregroundStyle(FlatColors.textTertiary)

            Text("No meals logged yet")
                .font(FlatFont.body(15))
                .foregroundStyle(FlatColors.textSecondary)

            Button {
                onScanTap()
            } label: {
                Text("Scan a receipt to start")
                    .font(FlatFont.label(14))
                    .foregroundStyle(FlatColors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(FlatColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Flat Scale Button Style

struct FlatScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    HomeView(onScanTap: {}, onQuickAdd: { _ in }, onMealTap: { _ in })
        .environment(MealStore())
}
