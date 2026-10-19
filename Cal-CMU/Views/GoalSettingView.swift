import SwiftUI

struct GoalSettingView: View {
    @Environment(MealStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    // Macro goals
    @State private var calories: Double = 2000
    @State private var protein: Double = 150
    @State private var carbs: Double = 250
    @State private var fat: Double = 65

    // Weekend plan
    @State private var useWeekendPlan: Bool = false
    @State private var wkndCalories: Double = 2200
    @State private var wkndProtein: Double = 130
    @State private var wkndCarbs: Double = 280
    @State private var wkndFat: Double = 75

    // Weight goal
    @State private var weightGoalType: String = "maintain"
    @State private var targetWeight: Double = 165
    @State private var hasTarget: Bool = false
    @State private var weightPace: Double = 1.0
    @State private var weightTimeframe: String = "weekly"

    // Personal info for calculator
    @State private var calcAge: Int = 22
    @State private var calcWeight: Double = 165
    @State private var calcHeight: Double = 72
    @State private var calcGender: String = "male"
    @State private var calcActivity: String = "moderate"
    @State private var showCalculator: Bool = false

    // Unit system
    @State private var localUnitSystem: String = "imperial"

    @State private var hasInitialized = false
    @State private var selectedTab = 0

    private var isMetric: Bool { localUnitSystem == "metric" }
    private var wUnit: String { isMetric ? "kg" : "lbs" }
    private var hUnit: String { isMetric ? "cm" : "" }

    private var weightSliderRange: ClosedRange<Double> {
        isMetric ? 35.0...180.0 : 80.0...400.0
    }
    private var weightSliderStep: Double {
        isMetric ? 0.25 : 0.25
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    unitToggleSection
                    planTypePicker

                    if selectedTab == 0 {
                        weekdayGoals
                    } else {
                        weekendGoals
                    }

                    calorieBreakdown(
                        cals: selectedTab == 0 ? calories : wkndCalories,
                        prot: selectedTab == 0 ? protein : wkndProtein,
                        carb: selectedTab == 0 ? carbs : wkndCarbs,
                        f: selectedTab == 0 ? fat : wkndFat
                    )

                    macroCalculatorButton

                    weightGoalSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(FlatColors.background)
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FlatColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoals()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(FlatColors.primary)
                }
            }
            .sheet(isPresented: $showCalculator) {
                MacroCalculatorSheet(
                    age: $calcAge,
                    weight: $calcWeight,
                    height: $calcHeight,
                    gender: $calcGender,
                    activity: $calcActivity,
                    isMetric: isMetric,
                    weightGoalType: weightGoalType,
                    onApply: { cal, prot, carb, f in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if selectedTab == 0 {
                                calories = Double(cal)
                                protein = prot
                                carbs = carb
                                fat = f
                            } else {
                                wkndCalories = Double(cal)
                                wkndProtein = prot
                                wkndCarbs = carb
                                wkndFat = f
                            }
                        }
                    }
                )
            }
            .onAppear {
                if !hasInitialized {
                    localUnitSystem = store.unitSystem
                    calories = Double(store.dailyCalorieGoal)
                    protein = store.dailyProteinGoal
                    carbs = store.dailyCarbsGoal
                    fat = store.dailyFatGoal
                    useWeekendPlan = store.useWeekendPlan
                    wkndCalories = Double(store.weekendCalorieGoal)
                    wkndProtein = store.weekendProteinGoal
                    wkndCarbs = store.weekendCarbsGoal
                    wkndFat = store.weekendFatGoal
                    weightGoalType = store.weightGoalType
                    hasTarget = store.targetWeight != nil
                    let storedTarget = store.targetWeight ?? store.userWeight
                    targetWeight = displayW(storedTarget)
                    weightPace = isMetric ? store.weightGoalPace * 0.453592 : store.weightGoalPace
                    weightTimeframe = store.weightGoalTimeframe
                    calcAge = store.userAge
                    calcWeight = displayW(store.userWeight)
                    calcHeight = displayH(store.userHeight)
                    calcGender = store.userGender
                    hasInitialized = true
                }
            }
        }
    }

    // MARK: - Unit Helpers

    private func displayW(_ lbs: Double) -> Double {
        isMetric ? lbs * 0.453592 : lbs
    }

    private func displayH(_ inches: Double) -> Double {
        isMetric ? inches * 2.54 : inches
    }

    private func toStorageLbs(_ display: Double) -> Double {
        isMetric ? display / 0.453592 : display
    }

    private func toStorageInches(_ display: Double) -> Double {
        isMetric ? display / 2.54 : display
    }

    // MARK: - Unit Toggle

    private var unitToggleSection: some View {
        HStack {
            FlatIconCircle(icon: "ruler", color: FlatColors.amethyst, size: 28)

            Text("Units")
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textPrimary)

            Spacer()

            Picker("Units", selection: $localUnitSystem) {
                Text("Imperial").tag("imperial")
                Text("Metric").tag("metric")
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
        }
        .flatCard(cornerRadius: 14, padding: 18)
        .onChange(of: localUnitSystem) { oldVal, newVal in
            convertUnits(from: oldVal, to: newVal)
        }
    }

    private func convertUnits(from oldSystem: String, to newSystem: String) {
        let wasMetric = oldSystem == "metric"
        let nowMetric = newSystem == "metric"
        guard wasMetric != nowMetric else { return }

        withAnimation(.easeOut(duration: 0.2)) {
            if nowMetric {
                targetWeight = targetWeight * 0.453592
                weightPace = weightPace * 0.453592
                calcWeight = calcWeight * 0.453592
                calcHeight = calcHeight * 2.54
            } else {
                targetWeight = targetWeight / 0.453592
                weightPace = weightPace / 0.453592
                calcWeight = calcWeight / 0.453592
                calcHeight = calcHeight / 2.54
            }
        }
    }

    // MARK: - Plan Type Picker

    private var planTypePicker: some View {
        VStack(spacing: 12) {
            HStack {
                FlatIconCircle(icon: "calendar", color: FlatColors.primary, size: 28)

                Text("Separate Weekend Plan")
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Toggle("", isOn: $useWeekendPlan.animation(.easeOut(duration: 0.2)))
                    .tint(FlatColors.primary)
                    .labelsHidden()
            }

            if useWeekendPlan {
                Picker("Plan", selection: $selectedTab) {
                    Text("Weekday").tag(0)
                    Text("Weekend").tag(1)
                }
                .pickerStyle(.segmented)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    // MARK: - Weekday Goals

    private var weekdayGoals: some View {
        VStack(spacing: 20) {
            goalSlider(title: "Calories", icon: "flame.fill", color: FlatColors.tangerine, value: $calories, range: 1200...4000, step: 50, unit: "cal")
            goalSlider(title: "Protein", icon: "circle.hexagongrid.fill", color: FlatColors.ocean, value: $protein, range: 50...300, step: 5, unit: "g")
            goalSlider(title: "Carbs", icon: "bolt.fill", color: FlatColors.sunflower, value: $carbs, range: 100...500, step: 10, unit: "g")
            goalSlider(title: "Fat", icon: "drop.triangle.fill", color: FlatColors.rose, value: $fat, range: 30...150, step: 5, unit: "g")
        }
    }

    // MARK: - Weekend Goals

    private var weekendGoals: some View {
        VStack(spacing: 20) {
            goalSlider(title: "Calories", icon: "flame.fill", color: FlatColors.tangerine, value: $wkndCalories, range: 1200...4000, step: 50, unit: "cal")
            goalSlider(title: "Protein", icon: "circle.hexagongrid.fill", color: FlatColors.ocean, value: $wkndProtein, range: 50...300, step: 5, unit: "g")
            goalSlider(title: "Carbs", icon: "bolt.fill", color: FlatColors.sunflower, value: $wkndCarbs, range: 100...500, step: 10, unit: "g")
            goalSlider(title: "Fat", icon: "drop.triangle.fill", color: FlatColors.rose, value: $wkndFat, range: 30...150, step: 5, unit: "g")
        }
    }

    // MARK: - Macro Calculator Button

    private var macroCalculatorButton: some View {
        Button {
            showCalculator = true
        } label: {
            HStack(spacing: 10) {
                FlatIconCircle(icon: "function", color: FlatColors.ocean, size: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Macro Calculator")
                        .font(FlatFont.heading(15))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text("Calculate macros from your body stats & goals")
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FlatColors.textTertiary)
            }
            .padding(18)
            .background(FlatColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(FlatScaleButtonStyle())
    }

    // MARK: - Weight Goal

    private var weightGoalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                FlatIconCircle(icon: "scalemass.fill", color: FlatColors.primary, size: 28)

                Text("Weight Goal")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Toggle("", isOn: $hasTarget.animation(.easeOut(duration: 0.2)))
                    .tint(FlatColors.primary)
                    .labelsHidden()
            }

            if hasTarget {
                Picker("Goal Type", selection: $weightGoalType) {
                    Text("Lose").tag("lose")
                    Text("Maintain").tag("maintain")
                    Text("Gain").tag("gain")
                }
                .pickerStyle(.segmented)

                // Target weight with fine control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Target")
                            .font(FlatFont.label(14))
                            .foregroundStyle(FlatColors.textSecondary)
                        Spacer()
                        Text(formatWeight(targetWeight))
                            .font(FlatFont.heading(15))
                            .foregroundStyle(FlatColors.primary)
                            .contentTransition(.numericText())
                    }

                    Slider(value: $targetWeight, in: weightSliderRange, step: weightSliderStep)
                        .tint(FlatColors.primary)

                    // Fine adjustment buttons
                    HStack(spacing: 8) {
                        weightAdjustButton(delta: -1.0, label: "-1")
                        weightAdjustButton(delta: -0.5, label: "-½")
                        weightAdjustButton(delta: -0.25, label: "-¼")
                        Spacer()
                        weightAdjustButton(delta: 0.25, label: "+¼")
                        weightAdjustButton(delta: 0.5, label: "+½")
                        weightAdjustButton(delta: 1.0, label: "+1")
                    }

                    HStack {
                        let currentDisplay = displayW(store.userWeight)
                        Text("Current: \(formatWeight(currentDisplay))")
                            .font(FlatFont.caption(11))
                            .foregroundStyle(FlatColors.textTertiary)
                        Spacer()
                        let diff = targetWeight - currentDisplay
                        Text(diff >= 0 ? "+\(formatWeight(abs(diff)))" : "-\(formatWeight(abs(diff)))")
                            .font(FlatFont.caption(11))
                            .fontWeight(.bold)
                            .foregroundColor(abs(diff) < 0.1 ? FlatColors.textSecondary : (diff > 0 ? FlatColors.primary : FlatColors.tangerine))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Timeframe")
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.textSecondary)

                    Picker("Timeframe", selection: $weightTimeframe) {
                        Text("Per Week").tag("weekly")
                        Text("Per Month").tag("monthly")
                    }
                    .pickerStyle(.segmented)
                }

                if weightGoalType != "maintain" {
                    let paceRange = paceRangeForDisplay
                    let paceStep: Double = isMetric ? 0.1 : 0.25
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Pace")
                                .font(FlatFont.label(14))
                                .foregroundStyle(FlatColors.textSecondary)
                            Spacer()
                            let timeLabel = weightTimeframe == "weekly" ? "week" : "month"
                            Text("\(formatWeight(weightPace))/\(timeLabel)")
                                .font(FlatFont.heading(15))
                                .foregroundStyle(FlatColors.primary)
                                .contentTransition(.numericText())
                        }

                        Slider(value: $weightPace, in: paceRange, step: paceStep)
                            .tint(FlatColors.primary)

                        // Pace fine adjustment
                        HStack(spacing: 8) {
                            paceAdjustButton(delta: -0.5, label: "-½")
                            paceAdjustButton(delta: -0.25, label: "-¼")
                            Spacer()
                            paceAdjustButton(delta: 0.25, label: "+¼")
                            paceAdjustButton(delta: 0.5, label: "+½")
                        }

                        let currentDisplay = displayW(store.userWeight)
                        let totalDiff = abs(targetWeight - currentDisplay)
                        if weightPace > 0 && totalDiff > 0 {
                            let multiplier: Double = weightTimeframe == "weekly" ? 1.0 : (1.0 / 4.33)
                            let weeksNeeded = totalDiff / (weightPace * multiplier)
                            let months = Int(weeksNeeded / 4.33)
                            let weeks = Int(weeksNeeded) % 4
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(FlatColors.primary)
                                let estimate = months > 0 ? "\(months)mo \(weeks)wk" : "\(Int(weeksNeeded))wk"
                                Text("Estimated: \(estimate)")
                                    .font(FlatFont.caption(12))
                                    .foregroundStyle(FlatColors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func weightAdjustButton(delta: Double, label: String) -> some View {
        Button {
            let new = targetWeight + delta
            if weightSliderRange.contains(new) {
                withAnimation(.easeOut(duration: 0.15)) {
                    targetWeight = new
                }
            }
        } label: {
            Text(label)
                .font(FlatFont.mono(12))
                .foregroundStyle(delta < 0 ? FlatColors.tangerine : FlatColors.primary)
                .frame(width: 36, height: 30)
                .background(delta < 0 ? FlatColors.tangerine.opacity(0.1) : FlatColors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }

    private func paceAdjustButton(delta: Double, label: String) -> some View {
        Button {
            let new = weightPace + delta
            if paceRangeForDisplay.contains(new) {
                withAnimation(.easeOut(duration: 0.15)) {
                    weightPace = new
                }
            }
        } label: {
            Text(label)
                .font(FlatFont.mono(12))
                .foregroundStyle(delta < 0 ? FlatColors.tangerine : FlatColors.primary)
                .frame(width: 36, height: 30)
                .background(delta < 0 ? FlatColors.tangerine.opacity(0.1) : FlatColors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }

    private func formatWeight(_ value: Double) -> String {
        if value == value.rounded() {
            return "\(Int(value)) \(wUnit)"
        }
        return String(format: "%.1f \(wUnit)", value)
    }

    private var paceRangeForDisplay: ClosedRange<Double> {
        if weightTimeframe == "weekly" {
            return isMetric ? 0.1...1.5 : 0.25...3.0
        }
        return isMetric ? 0.5...6.0 : 1.0...12.0
    }

    // MARK: - Reusable Slider

    private func goalSlider(
        title: String, icon: String, color: Color,
        value: Binding<Double>, range: ClosedRange<Double>,
        step: Double, unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FlatIconCircle(icon: icon, color: color, size: 28)

                Text(title)
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Text("\(Int(value.wrappedValue)) \(unit)")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }

            Slider(value: value, in: range, step: step)
                .tint(color)

            HStack {
                Text("\(Int(range.lowerBound))")
                    .font(FlatFont.caption(10))
                    .foregroundStyle(FlatColors.textTertiary)
                Spacer()
                Text("\(Int(range.upperBound))")
                    .font(FlatFont.caption(10))
                    .foregroundStyle(FlatColors.textTertiary)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    // MARK: - Calorie Breakdown

    private func calorieBreakdown(cals: Double, prot: Double, carb: Double, f: Double) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calorie Breakdown")
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textPrimary)

            let proteinCals = prot * 4
            let carbsCals = carb * 4
            let fatCals = f * 9
            let total = proteinCals + carbsCals + fatCals

            HStack(spacing: 16) {
                breakdownItem("Protein", cals: Int(proteinCals), pct: total > 0 ? proteinCals / total * 100 : 0, color: FlatColors.ocean)
                breakdownItem("Carbs", cals: Int(carbsCals), pct: total > 0 ? carbsCals / total * 100 : 0, color: FlatColors.sunflower)
                breakdownItem("Fat", cals: Int(fatCals), pct: total > 0 ? fatCals / total * 100 : 0, color: FlatColors.rose)
            }

            if abs(total - cals) > 100 {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(FlatColors.sunflower)
                    Text("Macro total (\(Int(total)) cal) differs from calorie goal (\(Int(cals)) cal)")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textSecondary)
                }
                .padding(.top, 4)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func breakdownItem(_ label: String, cals: Int, pct: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(pct))%")
                .font(FlatFont.heading(16))
                .foregroundStyle(color)
            Text(label)
                .font(FlatFont.caption(11))
                .foregroundStyle(FlatColors.textSecondary)
            Text("\(cals) cal")
                .font(FlatFont.caption(10))
                .foregroundStyle(FlatColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Save

    private func saveGoals() {
        store.dailyCalorieGoal = Int(calories)
        store.dailyProteinGoal = protein
        store.dailyCarbsGoal = carbs
        store.dailyFatGoal = fat
        store.useWeekendPlan = useWeekendPlan
        store.weekendCalorieGoal = Int(wkndCalories)
        store.weekendProteinGoal = wkndProtein
        store.weekendCarbsGoal = wkndCarbs
        store.weekendFatGoal = wkndFat
        store.weightGoalType = hasTarget ? weightGoalType : "maintain"
        store.targetWeight = hasTarget ? toStorageLbs(targetWeight) : nil
        store.weightGoalPace = isMetric ? weightPace / 0.453592 : weightPace
        store.weightGoalTimeframe = weightTimeframe
        store.unitSystem = localUnitSystem
        store.userGender = calcGender
        store.userAge = calcAge
        store.userWeight = toStorageLbs(calcWeight)
        store.userHeight = toStorageInches(calcHeight)
        Task { await store.saveGoals() }
        Task { await store.saveProfile() }
    }
}

// MARK: - Macro Calculator Sheet

struct MacroCalculatorSheet: View {
    @Binding var age: Int
    @Binding var weight: Double
    @Binding var height: Double
    @Binding var gender: String
    @Binding var activity: String

    let isMetric: Bool
    let weightGoalType: String
    let onApply: (Int, Double, Double, Double) -> Void

    @Environment(\.dismiss) private var dismiss

    private var wUnit: String { isMetric ? "kg" : "lbs" }
    private var hUnit: String { isMetric ? "cm" : "in" }

    // Mifflin-St Jeor BMR
    private var bmr: Double {
        let weightKg = isMetric ? weight : weight * 0.453592
        let heightCm = isMetric ? height : height * 2.54

        if gender == "female" {
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        }
        // male & other use male formula
        return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
    }

    private var activityMultiplier: Double {
        switch activity {
        case "sedentary": return 1.2
        case "light": return 1.375
        case "moderate": return 1.55
        case "active": return 1.725
        case "very_active": return 1.9
        default: return 1.55
        }
    }

    private var tdee: Double {
        bmr * activityMultiplier
    }

    private var adjustedCalories: Int {
        switch weightGoalType {
        case "lose": return Int(tdee - 500)
        case "gain": return Int(tdee + 300)
        default: return Int(tdee)
        }
    }

    // Standard macro split
    private var calculatedProtein: Double {
        let weightKg = isMetric ? weight : weight * 0.453592
        switch weightGoalType {
        case "lose": return weightKg * 2.2  // higher protein for cutting
        case "gain": return weightKg * 2.0
        default: return weightKg * 1.8
        }
    }

    private var calculatedFat: Double {
        Double(adjustedCalories) * 0.25 / 9.0
    }

    private var calculatedCarbs: Double {
        let remaining = Double(adjustedCalories) - (calculatedProtein * 4) - (calculatedFat * 9)
        return max(remaining / 4.0, 50)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    bodyStatsSection
                    genderSection
                    activitySection
                    resultsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(FlatColors.background)
            .navigationTitle("Macro Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FlatColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(adjustedCalories, calculatedProtein.rounded(), calculatedCarbs.rounded(), calculatedFat.rounded())
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(FlatColors.primary)
                }
            }
        }
    }

    // MARK: - Body Stats

    private var bodyStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                FlatIconCircle(icon: "figure.stand", color: FlatColors.primary, size: 28)
                Text("Body Stats")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)
            }

            // Age
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Age")
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.textSecondary)
                    Spacer()
                    Text("\(age) years")
                        .font(FlatFont.heading(15))
                        .foregroundStyle(FlatColors.primary)
                        .contentTransition(.numericText())
                }
                Slider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0) }
                ), in: 14...80, step: 1)
                .tint(FlatColors.primary)
            }

            // Weight
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Weight")
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.textSecondary)
                    Spacer()
                    Text(String(format: "%.1f %@", weight, wUnit))
                        .font(FlatFont.heading(15))
                        .foregroundStyle(FlatColors.ocean)
                        .contentTransition(.numericText())
                }
                Slider(value: $weight, in: isMetric ? 35.0...180.0 : 80.0...400.0, step: 0.5)
                    .tint(FlatColors.ocean)
            }

            // Height
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Height")
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.textSecondary)
                    Spacer()
                    if isMetric {
                        Text("\(Int(height)) cm")
                            .font(FlatFont.heading(15))
                            .foregroundStyle(FlatColors.amethyst)
                            .contentTransition(.numericText())
                    } else {
                        let feet = Int(height) / 12
                        let inches = Int(height) % 12
                        Text("\(feet)'\(inches)\"")
                            .font(FlatFont.heading(15))
                            .foregroundStyle(FlatColors.amethyst)
                            .contentTransition(.numericText())
                    }
                }
                Slider(value: $height, in: isMetric ? 120.0...220.0 : 48.0...84.0, step: 1)
                    .tint(FlatColors.amethyst)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    // MARK: - Gender

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FlatIconCircle(icon: "person.fill", color: FlatColors.rose, size: 28)
                Text("Gender")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)
            }

            Text("Used for BMR calculation (Mifflin-St Jeor formula)")
                .font(FlatFont.caption(12))
                .foregroundStyle(FlatColors.textTertiary)

            HStack(spacing: 10) {
                genderOption("male", icon: "figure.stand", label: "Male")
                genderOption("female", icon: "figure.stand.dress", label: "Female")
                genderOption("other", icon: "person.fill.questionmark", label: "Other")
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func genderOption(_ value: String, icon: String, label: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                gender = value
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(gender == value ? .white : FlatColors.textSecondary)
                Text(label)
                    .font(FlatFont.label(12))
                    .foregroundStyle(gender == value ? .white : FlatColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(gender == value ? FlatColors.rose : FlatColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Activity Level

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FlatIconCircle(icon: "figure.run", color: FlatColors.sunflower, size: 28)
                Text("Activity Level")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)
            }

            VStack(spacing: 8) {
                activityOption("sedentary", label: "Sedentary", desc: "Little to no exercise")
                activityOption("light", label: "Light", desc: "1-3 days/week")
                activityOption("moderate", label: "Moderate", desc: "3-5 days/week")
                activityOption("active", label: "Active", desc: "6-7 days/week")
                activityOption("very_active", label: "Very Active", desc: "Intense daily training")
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func activityOption(_ value: String, label: String, desc: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                activity = value
            }
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(activity == value ? FlatColors.primary : FlatColors.inputBg)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: activity == value ? "checkmark" : "")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text(desc)
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textTertiary)
                }

                Spacer()
            }
            .padding(12)
            .background(activity == value ? FlatColors.primary.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                FlatIconCircle(icon: "chart.bar.fill", color: FlatColors.primary, size: 28)
                Text("Calculated Macros")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)
            }

            // BMR & TDEE info
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("BMR")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textTertiary)
                    Text("\(Int(bmr))")
                        .font(FlatFont.heading(18))
                        .foregroundStyle(FlatColors.textSecondary)
                    Text("cal/day")
                        .font(FlatFont.caption(10))
                        .foregroundStyle(FlatColors.textTertiary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("TDEE")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textTertiary)
                    Text("\(Int(tdee))")
                        .font(FlatFont.heading(18))
                        .foregroundStyle(FlatColors.textSecondary)
                    Text("cal/day")
                        .font(FlatFont.caption(10))
                        .foregroundStyle(FlatColors.textTertiary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("Goal")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textTertiary)
                    Text("\(adjustedCalories)")
                        .font(FlatFont.heading(18))
                        .foregroundStyle(FlatColors.primary)
                    Text("cal/day")
                        .font(FlatFont.caption(10))
                        .foregroundStyle(FlatColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .background(FlatColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if weightGoalType == "lose" {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(FlatColors.tangerine)
                    Text("500 cal deficit applied for ~1 lb/week loss")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textSecondary)
                }
            } else if weightGoalType == "gain" {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(FlatColors.primary)
                    Text("300 cal surplus applied for lean gain")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textSecondary)
                }
            }

            FlatDivider()

            // Macro results
            HStack(spacing: 12) {
                macroResultCard("Calories", value: "\(adjustedCalories)", unit: "cal", color: FlatColors.tangerine)
                macroResultCard("Protein", value: "\(Int(calculatedProtein))", unit: "g", color: FlatColors.ocean)
                macroResultCard("Carbs", value: "\(Int(calculatedCarbs))", unit: "g", color: FlatColors.sunflower)
                macroResultCard("Fat", value: "\(Int(calculatedFat))", unit: "g", color: FlatColors.rose)
            }

            Text("Tap \"Apply\" to use these values as your goals")
                .font(FlatFont.caption(11))
                .foregroundStyle(FlatColors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func macroResultCard(_ title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FlatFont.title(20))
                .foregroundStyle(color)
            Text(unit)
                .font(FlatFont.caption(10))
                .foregroundStyle(color.opacity(0.7))
            Text(title)
                .font(FlatFont.caption(10))
                .foregroundStyle(FlatColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    GoalSettingView()
        .environment(MealStore())
}
