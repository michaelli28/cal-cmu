import SwiftUI

struct LogView: View {
    @Environment(MealStore.self) private var store
    let onAddMeal: (MealType) -> Void
    let onMealTap: (Meal) -> Void

    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    dateHeader
                    dailySummary
                    ForEach(MealType.allCases) { type in
                        mealCategorySection(type)
                    }
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(FlatColors.background)
            .navigationTitle("Food Log")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack {
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FlatColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(FlatColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Spacer()

            Button {
                showDatePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text(dateLabel)
                        .font(FlatFont.heading(16))
                }
                .foregroundStyle(FlatColors.textPrimary)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FlatColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(FlatColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var dateLabel: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: selectedDate)
        }
    }

    // MARK: - Daily Summary

    private var dailySummary: some View {
        HStack(spacing: 0) {
            summaryItem(value: "\(store.totalCaloriesToday)", label: "Calories", color: FlatColors.primary)
            flatDivider
            summaryItem(value: "\(Int(store.totalProteinToday))g", label: "Protein", color: FlatColors.ocean)
            flatDivider
            summaryItem(value: "\(Int(store.totalCarbsToday))g", label: "Carbs", color: FlatColors.tangerine)
            flatDivider
            summaryItem(value: "\(Int(store.totalFatToday))g", label: "Fat", color: FlatColors.rose)
        }
        .padding(.vertical, 14)
        .background(FlatColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func summaryItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FlatFont.heading(16))
                .foregroundStyle(color)
            Text(label)
                .font(FlatFont.caption(10))
                .foregroundStyle(FlatColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var flatDivider: some View {
        Rectangle()
            .fill(FlatColors.divider)
            .frame(width: 1, height: 30)
    }

    // MARK: - Meal Category Section

    private func mealCategorySection(_ type: MealType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                FlatIconCircle(icon: type.icon, color: type.flatColor, size: 32)

                Text(type.rawValue)
                    .font(FlatFont.heading(17))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                let cals = store.caloriesForType(type)
                if cals > 0 {
                    Text("\(cals) cal")
                        .font(FlatFont.mono(13))
                        .foregroundStyle(FlatColors.textSecondary)
                }
            }

            let meals = store.mealsForType(type)
            if meals.isEmpty {
                Button {
                    onAddMeal(type)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(type.flatColor)
                        Text("Add \(type.rawValue)")
                            .font(FlatFont.body(14))
                            .foregroundStyle(FlatColors.textSecondary)
                        Spacer()
                    }
                    .padding(14)
                    .background(FlatColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(FlatScaleButtonStyle())
            } else {
                ForEach(meals) { meal in
                    logMealRow(meal, type: type)
                }

                Button {
                    onAddMeal(type)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Add More")
                            .font(FlatFont.label(13))
                    }
                    .foregroundStyle(type.flatColor)
                    .padding(.vertical, 8)
                }
                .buttonStyle(FlatScaleButtonStyle())
            }
        }
        .flatCard(cornerRadius: 14, padding: 16)
    }

    private func logMealRow(_ meal: Meal, type: MealType) -> some View {
        Button {
            onMealTap(meal)
        } label: {
            HStack(spacing: 12) {
                Group {
                    if let image = meal.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(type.flatColor.opacity(0.1))
                            Image(systemName: "fork.knife")
                                .font(.system(size: 14))
                                .foregroundStyle(type.flatColor.opacity(0.5))
                        }
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    Text(meal.name)
                        .font(FlatFont.body(14))
                        .fontWeight(.semibold)
                        .foregroundStyle(FlatColors.textPrimary)
                        .lineLimit(1)
                    Text(meal.timeString)
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(meal.calories) cal")
                        .font(FlatFont.heading(14))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text("P:\(Int(meal.protein))g")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(FlatColors.textTertiary)
            }
            .padding(10)
            .background(FlatColors.inputBg.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(FlatScaleButtonStyle())
    }

    // MARK: - Date Picker Sheet

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(FlatColors.primary)
            .padding()
            .navigationTitle("Choose Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(FlatColors.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    LogView(onAddMeal: { _ in }, onMealTap: { _ in })
        .environment(MealStore())
}
