import SwiftUI

struct OnboardingView: View {
    @Environment(MealStore.self) private var store
    var onComplete: () -> Void

    @State private var currentStep = 0
    @State private var direction: Edge = .trailing

    // Collected data
    @State private var name: String = ""
    @State private var age: Int = 22
    @State private var gender: String = "male"
    @State private var unitSystem: String = "imperial"
    @State private var weight: Double = 165
    @State private var height: Double = 70
    @State private var weightGoalType: String = "maintain"
    @State private var activityLevel: String = "moderate"
    @State private var weightPace: Double = 1.0
    @State private var weightTimeframe: String = "weekly"
    @State private var targetWeight: Double = 155

    // Calculated macros
    @State private var calculatedCalories: Int = 2000
    @State private var calculatedProtein: Double = 150
    @State private var calculatedCarbs: Double = 250
    @State private var calculatedFat: Double = 65

    private let totalSteps = 6

    private var isMetric: Bool { unitSystem == "metric" }
    private var wUnit: String { isMetric ? "kg" : "lbs" }
    private var hUnit: String { isMetric ? "cm" : "in" }

    var body: some View {
        ZStack {
            FlatColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // Step content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    nameStep.tag(1)
                    unitsStep.tag(2)
                    bodyStatsStep.tag(3)
                    genderStep.tag(4)
                    goalsStep.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(FlatColors.inputBg)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(FlatColors.primary)
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 6)
                    .animation(.easeOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button {
                    withAnimation { currentStep -= 1 }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(FlatFont.heading(15))
                    }
                    .foregroundStyle(FlatColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FlatColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            Button {
                if currentStep == totalSteps - 1 {
                    finishOnboarding()
                } else {
                    if currentStep == 4 {
                        calculateMacros()
                    }
                    withAnimation { currentStep += 1 }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentStep == totalSteps - 1 ? "Get Started" : "Continue")
                        .font(FlatFont.heading(15))
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(continueButtonDisabled ? FlatColors.primary.opacity(0.4) : FlatColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(continueButtonDisabled)
        }
    }

    private var continueButtonDisabled: Bool {
        if currentStep == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        return false
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            RoundedRectangle(cornerRadius: 28)
                .fill(FlatColors.primary)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.white)
                )

            VStack(spacing: 12) {
                Text("Welcome to Cal-CMU")
                    .font(FlatFont.title(28))
                    .foregroundStyle(FlatColors.textPrimary)

                Text("Let's set up your profile so we can\npersonalize your nutrition tracking.")
                    .font(FlatFont.body(16))
                    .foregroundStyle(FlatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                featureRow(icon: "camera.fill", color: FlatColors.ocean, title: "AI-Powered Scanning", desc: "Snap a photo to log meals instantly")
                featureRow(icon: "chart.line.uptrend.xyaxis", color: FlatColors.primary, title: "Smart Tracking", desc: "Track calories, macros, and weight goals")
                featureRow(icon: "fork.knife", color: FlatColors.tangerine, title: "CMU Dining", desc: "Browse campus restaurant menus")
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            FlatIconCircle(icon: icon, color: color, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)
                Text(desc)
                    .font(FlatFont.caption(13))
                    .foregroundStyle(FlatColors.textTertiary)
            }

            Spacer()
        }
        .padding(14)
        .background(FlatColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Step 1: Name

    private var nameStep: some View {
        VStack(spacing: 24) {
            Spacer()

            stepHeader(
                icon: "person.fill",
                color: FlatColors.ocean,
                title: "What's your name?",
                subtitle: "We'll use this to personalize your experience."
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textSecondary)

                TextField("Enter your name", text: $name)
                    .font(FlatFont.body(18))
                    .padding(16)
                    .background(FlatColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Step 2: Units

    private var unitsStep: some View {
        VStack(spacing: 24) {
            Spacer()

            stepHeader(
                icon: "ruler",
                color: FlatColors.amethyst,
                title: "Choose your units",
                subtitle: "You can always change this later in settings."
            )

            VStack(spacing: 12) {
                unitCard("imperial", label: "Imperial", detail: "lbs, ft/in", icon: "flag.fill")
                unitCard("metric", label: "Metric", detail: "kg, cm", icon: "globe")
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func unitCard(_ value: String, label: String, detail: String, icon: String) -> some View {
        Button {
            let wasMetric = isMetric
            withAnimation(.easeOut(duration: 0.2)) {
                unitSystem = value
            }
            let nowMetric = value == "metric"
            if wasMetric != nowMetric {
                if nowMetric {
                    weight = weight * 0.453592
                    height = height * 2.54
                } else {
                    weight = weight / 0.453592
                    height = height / 2.54
                }
            }
        } label: {
            HStack(spacing: 14) {
                FlatIconCircle(icon: icon, color: unitSystem == value ? FlatColors.amethyst : FlatColors.textTertiary, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(FlatFont.heading(17))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text(detail)
                        .font(FlatFont.caption(13))
                        .foregroundStyle(FlatColors.textTertiary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(unitSystem == value ? FlatColors.amethyst : FlatColors.textTertiary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if unitSystem == value {
                        Circle()
                            .fill(FlatColors.amethyst)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(18)
            .background(unitSystem == value ? FlatColors.amethyst.opacity(0.08) : FlatColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(unitSystem == value ? FlatColors.amethyst : Color.clear, lineWidth: 1.5)
            )
        }
    }

    // MARK: - Step 3: Body Stats

    private var bodyStatsStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                stepHeader(
                    icon: "figure.stand",
                    color: FlatColors.primary,
                    title: "Your body stats",
                    subtitle: "Used to calculate your daily calorie and macro targets."
                )

                VStack(spacing: 20) {
                    // Age
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Age")
                                .font(FlatFont.label(14))
                                .foregroundStyle(FlatColors.textSecondary)
                            Spacer()
                            Text("\(age) years")
                                .font(FlatFont.heading(16))
                                .foregroundStyle(FlatColors.primary)
                                .contentTransition(.numericText())
                        }

                        Slider(value: Binding(
                            get: { Double(age) },
                            set: { age = Int($0) }
                        ), in: 14...80, step: 1)
                        .tint(FlatColors.primary)
                    }

                    FlatDivider()

                    // Weight
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Weight")
                                .font(FlatFont.label(14))
                                .foregroundStyle(FlatColors.textSecondary)
                            Spacer()
                            Text(String(format: "%.1f %@", weight, wUnit))
                                .font(FlatFont.heading(16))
                                .foregroundStyle(FlatColors.ocean)
                                .contentTransition(.numericText())
                        }

                        Slider(value: $weight, in: isMetric ? 35.0...180.0 : 80.0...400.0, step: 0.5)
                            .tint(FlatColors.ocean)
                    }

                    FlatDivider()

                    // Height
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Height")
                                .font(FlatFont.label(14))
                                .foregroundStyle(FlatColors.textSecondary)
                            Spacer()
                            if isMetric {
                                Text("\(Int(height)) cm")
                                    .font(FlatFont.heading(16))
                                    .foregroundStyle(FlatColors.amethyst)
                                    .contentTransition(.numericText())
                            } else {
                                let feet = Int(height) / 12
                                let inches = Int(height) % 12
                                Text("\(feet)'\(inches)\"")
                                    .font(FlatFont.heading(16))
                                    .foregroundStyle(FlatColors.amethyst)
                                    .contentTransition(.numericText())
                            }
                        }

                        Slider(value: $height, in: isMetric ? 120.0...220.0 : 48.0...84.0, step: 1)
                            .tint(FlatColors.amethyst)
                    }
                }
                .flatCard(cornerRadius: 14, padding: 20)
                .padding(.horizontal, 24)

                Spacer().frame(height: 60)
            }
        }
    }

    // MARK: - Step 4: Gender

    private var genderStep: some View {
        VStack(spacing: 24) {
            Spacer()

            stepHeader(
                icon: "person.2.fill",
                color: FlatColors.rose,
                title: "What's your gender?",
                subtitle: "This helps us calculate your basal metabolic rate more accurately."
            )

            VStack(spacing: 12) {
                genderCard("male", icon: "figure.stand", label: "Male")
                genderCard("female", icon: "figure.stand.dress", label: "Female")
                genderCard("other", icon: "person.fill.questionmark", label: "Other")
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func genderCard(_ value: String, icon: String, label: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                gender = value
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(gender == value ? .white : FlatColors.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(gender == value ? FlatColors.rose : FlatColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(label)
                    .font(FlatFont.heading(17))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(gender == value ? FlatColors.rose : FlatColors.textTertiary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if gender == value {
                        Circle()
                            .fill(FlatColors.rose)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(gender == value ? FlatColors.rose.opacity(0.08) : FlatColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(gender == value ? FlatColors.rose : Color.clear, lineWidth: 1.5)
            )
        }
    }

    // MARK: - Step 5: Goals + Summary

    private var goalsStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                stepHeader(
                    icon: "target",
                    color: FlatColors.tangerine,
                    title: "Your goal",
                    subtitle: "We've calculated recommended macros based on your stats."
                )

                // Goal type picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your primary goal?")
                        .font(FlatFont.heading(15))
                        .foregroundStyle(FlatColors.textPrimary)

                    VStack(spacing: 10) {
                        goalTypeCard("lose", icon: "arrow.down.right", color: FlatColors.tangerine, label: "Lose Weight", desc: "Calorie deficit for fat loss")
                        goalTypeCard("maintain", icon: "equal", color: FlatColors.primary, label: "Maintain Weight", desc: "Stay at your current weight")
                        goalTypeCard("gain", icon: "arrow.up.right", color: FlatColors.ocean, label: "Gain Weight", desc: "Calorie surplus for muscle gain")
                    }
                }
                .flatCard(cornerRadius: 14, padding: 18)
                .padding(.horizontal, 24)

                // Weight pace (only if lose or gain)
                if weightGoalType != "maintain" {
                    weightPaceSection
                        .padding(.horizontal, 24)
                }

                // Activity level
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
                .padding(.horizontal, 24)
                .onChange(of: activityLevel) { _, _ in calculateMacros() }
                .onChange(of: weightGoalType) { _, _ in calculateMacros() }
                .onChange(of: weightPace) { _, _ in calculateMacros() }
                .onChange(of: weightTimeframe) { _, _ in calculateMacros() }

                // Calculated results
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        FlatIconCircle(icon: "sparkles", color: FlatColors.primary, size: 28)
                        Text("Your Recommended Plan")
                            .font(FlatFont.heading(15))
                            .foregroundStyle(FlatColors.textPrimary)
                    }

                    HStack(spacing: 10) {
                        macroCard("Calories", value: "\(calculatedCalories)", unit: "cal", color: FlatColors.tangerine)
                        macroCard("Protein", value: "\(Int(calculatedProtein))", unit: "g", color: FlatColors.ocean)
                        macroCard("Carbs", value: "\(Int(calculatedCarbs))", unit: "g", color: FlatColors.sunflower)
                        macroCard("Fat", value: "\(Int(calculatedFat))", unit: "g", color: FlatColors.rose)
                    }

                    Text("You can adjust these anytime in Goal Settings.")
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .flatCard(cornerRadius: 14, padding: 18)
                .padding(.horizontal, 24)

                Spacer().frame(height: 60)
            }
        }
    }

    private func goalTypeCard(_ value: String, icon: String, color: Color, label: String, desc: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                weightGoalType = value
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(weightGoalType == value ? .white : color)
                    .frame(width: 36, height: 36)
                    .background(weightGoalType == value ? color : color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(FlatFont.heading(15))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text(desc)
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textTertiary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(weightGoalType == value ? color : FlatColors.textTertiary.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if weightGoalType == value {
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(12)
            .background(weightGoalType == value ? color.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func activityOption(_ value: String, label: String, desc: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                activityLevel = value
            }
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(activityLevel == value ? FlatColors.sunflower : FlatColors.inputBg)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: activityLevel == value ? "checkmark" : "")
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
            .padding(10)
            .background(activityLevel == value ? FlatColors.sunflower.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func macroCard(_ title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FlatFont.title(18))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(unit)
                .font(FlatFont.caption(10))
                .foregroundStyle(color.opacity(0.7))
            Text(title)
                .font(FlatFont.caption(10))
                .foregroundStyle(FlatColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Weight Pace Section

    private var weightPaceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                FlatIconCircle(icon: "gauge.with.dots.needle.50percent", color: FlatColors.primary, size: 28)
                Text("Rate of \(weightGoalType == "lose" ? "Loss" : "Gain")")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)
            }

            // Timeframe picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Timeframe")
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textSecondary)

                Picker("Timeframe", selection: $weightTimeframe) {
                    Text("Per Week").tag("weekly")
                    Text("Per Month").tag("monthly")
                }
                .pickerStyle(.segmented)
            }

            // Pace slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Pace")
                        .font(FlatFont.label(13))
                        .foregroundStyle(FlatColors.textSecondary)
                    Spacer()
                    let timeLabel = weightTimeframe == "weekly" ? "week" : "month"
                    Text("\(formatPace(weightPace)) \(wUnit)/\(timeLabel)")
                        .font(FlatFont.heading(16))
                        .foregroundStyle(FlatColors.primary)
                        .contentTransition(.numericText())
                }

                Slider(value: $weightPace, in: paceSliderRange, step: paceSliderStep)
                    .tint(FlatColors.primary)

                // Fine adjustment
                HStack(spacing: 8) {
                    paceAdjust(delta: -0.5, label: "-\u{00BD}")
                    paceAdjust(delta: -0.25, label: "-\u{00BC}")
                    Spacer()
                    paceAdjust(delta: 0.25, label: "+\u{00BC}")
                    paceAdjust(delta: 0.5, label: "+\u{00BD}")
                }
            }

            // Target weight
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Target Weight")
                        .font(FlatFont.label(13))
                        .foregroundStyle(FlatColors.textSecondary)
                    Spacer()
                    Text("\(formatPace(targetWeight)) \(wUnit)")
                        .font(FlatFont.heading(16))
                        .foregroundStyle(FlatColors.ocean)
                        .contentTransition(.numericText())
                }

                Slider(value: $targetWeight, in: isMetric ? 35.0...180.0 : 80.0...400.0, step: 0.5)
                    .tint(FlatColors.ocean)

                let diff = targetWeight - weight
                if abs(diff) > 0.1 && weightPace > 0 {
                    let pacePerWeek: Double = weightTimeframe == "weekly" ? weightPace : weightPace / 4.33
                    let weeksNeeded = abs(diff) / pacePerWeek
                    let months = Int(weeksNeeded / 4.33)
                    let weeks = Int(weeksNeeded) % 4
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(FlatColors.primary)
                        let estimate = months > 0 ? "\(months)mo \(weeks)wk" : "\(Int(weeksNeeded))wk"
                        Text("\(formatPace(abs(diff))) \(wUnit) to \(weightGoalType == "lose" ? "lose" : "gain") \u{2022} ~\(estimate)")
                            .font(FlatFont.caption(12))
                            .foregroundStyle(FlatColors.textSecondary)
                    }
                }
            }

            // Calorie impact info
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(weightGoalType == "lose" ? FlatColors.tangerine : FlatColors.ocean)
                let dailyDelta = Int(dailyCalorieAdjustment)
                Text(weightGoalType == "lose" ? "\(dailyDelta) cal/day deficit" : "+\(dailyDelta) cal/day surplus")
                    .font(FlatFont.caption(12))
                    .foregroundStyle(FlatColors.textSecondary)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private var paceSliderRange: ClosedRange<Double> {
        if weightTimeframe == "weekly" {
            return isMetric ? 0.1...1.5 : 0.25...3.0
        }
        return isMetric ? 0.5...6.0 : 1.0...12.0
    }

    private var paceSliderStep: Double {
        isMetric ? 0.1 : 0.25
    }

    private var dailyCalorieAdjustment: Double {
        let pacePerWeekLbs: Double
        if isMetric {
            let pacePerWeekKg = weightTimeframe == "weekly" ? weightPace : weightPace / 4.33
            pacePerWeekLbs = pacePerWeekKg / 0.453592
        } else {
            pacePerWeekLbs = weightTimeframe == "weekly" ? weightPace : weightPace / 4.33
        }
        return pacePerWeekLbs * 500.0
    }

    private func formatPace(_ value: Double) -> String {
        if value == value.rounded() {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func paceAdjust(delta: Double, label: String) -> some View {
        Button {
            let new = weightPace + delta
            if paceSliderRange.contains(new) {
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

    // MARK: - Helpers

    private func stepHeader(icon: String, color: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            FlatIconCircle(icon: icon, color: color, size: 48)

            Text(title)
                .font(FlatFont.title(24))
                .foregroundStyle(FlatColors.textPrimary)

            Text(subtitle)
                .font(FlatFont.body(15))
                .foregroundStyle(FlatColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Macro Calculation (Mifflin-St Jeor)

    private func calculateMacros() {
        let weightKg = isMetric ? weight : weight * 0.453592
        let heightCm = isMetric ? height : height * 2.54

        let bmr: Double
        if gender == "female" {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        } else {
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        }

        let multiplier: Double
        switch activityLevel {
        case "sedentary": multiplier = 1.2
        case "light": multiplier = 1.375
        case "moderate": multiplier = 1.55
        case "active": multiplier = 1.725
        case "very_active": multiplier = 1.9
        default: multiplier = 1.55
        }

        let tdee = bmr * multiplier

        let adjustment = dailyCalorieAdjustment
        switch weightGoalType {
        case "lose": calculatedCalories = max(Int(tdee - adjustment), 1200)
        case "gain": calculatedCalories = Int(tdee + adjustment * 0.6)
        default: calculatedCalories = Int(tdee)
        }

        switch weightGoalType {
        case "lose": calculatedProtein = (weightKg * 2.2).rounded()
        case "gain": calculatedProtein = (weightKg * 2.0).rounded()
        default: calculatedProtein = (weightKg * 1.8).rounded()
        }

        calculatedFat = (Double(calculatedCalories) * 0.25 / 9.0).rounded()
        let remainingCals = Double(calculatedCalories) - (calculatedProtein * 4) - (calculatedFat * 9)
        calculatedCarbs = max((remainingCals / 4.0).rounded(), 50)
    }

    // MARK: - Finish

    private func finishOnboarding() {
        let storedWeight = isMetric ? weight / 0.453592 : weight
        let storedHeight = isMetric ? height / 2.54 : height

        store.userName = name.trimmingCharacters(in: .whitespaces)
        store.userAge = age
        store.userWeight = storedWeight
        store.userHeight = storedHeight
        store.userGender = gender
        store.unitSystem = unitSystem
        store.weightGoalType = weightGoalType
        store.weightGoalPace = isMetric ? weightPace / 0.453592 : weightPace
        store.weightGoalTimeframe = weightTimeframe
        store.targetWeight = weightGoalType != "maintain" ? (isMetric ? targetWeight / 0.453592 : targetWeight) : nil
        store.dailyCalorieGoal = calculatedCalories
        store.dailyProteinGoal = calculatedProtein
        store.dailyCarbsGoal = calculatedCarbs
        store.dailyFatGoal = calculatedFat
        store.hasCompletedOnboarding = true

        Task {
            await store.saveProfile()
            await store.saveGoals()
        }

        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .environment(MealStore())
}
