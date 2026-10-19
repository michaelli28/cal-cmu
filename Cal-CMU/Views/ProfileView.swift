import SwiftUI

struct ProfileView: View {
    @Environment(MealStore.self) private var store
    @Environment(AuthManager.self) private var auth
    @State private var showGoalEditor = false
    @State private var showProfileEditor = false
    @State private var showAbout = false
    @State private var showSignOutConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeader
                    dailyGoalsCard
                    personalInfoCard
                    settingsCard
                    aboutButton
                    signOutButton
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(FlatColors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showGoalEditor) {
                GoalSettingView()
            }
            .sheet(isPresented: $showProfileEditor) {
                ProfileEditView()
            }
            .alert("Cal-CMU", isPresented: $showAbout) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Version 1.0\nYour AI-powered meal tracking companion.\nBuilt with SwiftUI.")
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 20)
                .fill(FlatColors.primary)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(store.userName.prefix(1)).uppercased())
                        .font(FlatFont.title(32))
                        .foregroundStyle(.white)
                )

            Text(store.userName)
                .font(FlatFont.title(22))
                .foregroundStyle(FlatColors.textPrimary)

            HStack(spacing: 24) {
                statItem(value: "\(store.streakDays)", label: "Day Streak")
                statDivider
                statItem(value: "\(store.meals.count)", label: "Total Meals")
                statDivider
                statItem(value: "\(store.nutritionScore)", label: "Score")
            }
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .flatCard(cornerRadius: 16, padding: 20)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FlatFont.heading(18))
                .foregroundStyle(FlatColors.primary)
            Text(label)
                .font(FlatFont.caption(11))
                .foregroundStyle(FlatColors.textSecondary)
        }
    }

    private var statDivider: some View {
        Rectangle()
            .fill(FlatColors.divider)
            .frame(width: 1, height: 32)
    }

    // MARK: - Daily Goals

    private var dailyGoalsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily Goals")
                    .font(FlatFont.heading(17))
                    .foregroundStyle(FlatColors.textPrimary)
                Spacer()
                Button {
                    showGoalEditor = true
                } label: {
                    Text("Edit")
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.primary)
                }
            }

            if store.useWeekendPlan {
                HStack {
                    Text(store.activePlanLabel)
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(FlatColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Spacer()
                }
            }

            goalRow(icon: "flame.fill", color: FlatColors.tangerine, label: "Calories", value: "\(store.activeCalorieGoal) cal")
            FlatDivider()
            goalRow(icon: "circle.hexagongrid.fill", color: FlatColors.ocean, label: "Protein", value: "\(Int(store.activeProteinGoal))g")
            FlatDivider()
            goalRow(icon: "bolt.fill", color: FlatColors.sunflower, label: "Carbs", value: "\(Int(store.activeCarbsGoal))g")
            FlatDivider()
            goalRow(icon: "drop.triangle.fill", color: FlatColors.rose, label: "Fat", value: "\(Int(store.activeFatGoal))g")

            if let target = store.targetWeight {
                FlatDivider()
                let displayTarget = store.displayWeightInt(target)
                goalRow(icon: "scalemass.fill", color: FlatColors.primary, label: "Weight Goal", value: "\(displayTarget) \(store.weightUnit) (\(store.weightGoalType))")
                if store.weightGoalType != "maintain" {
                    goalRow(icon: "clock.fill", color: FlatColors.primary, label: "Pace", value: store.weightGoalPaceLabel)
                }
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func goalRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            FlatIconCircle(icon: icon, color: color, size: 28)

            Text(label)
                .font(FlatFont.body(15))
                .foregroundStyle(FlatColors.textPrimary)

            Spacer()

            Text(value)
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textSecondary)
        }
    }

    // MARK: - Personal Info

    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Personal Info")
                    .font(FlatFont.heading(17))
                    .foregroundStyle(FlatColors.textPrimary)
                Spacer()
                Button {
                    showProfileEditor = true
                } label: {
                    Text("Edit")
                        .font(FlatFont.label(14))
                        .foregroundStyle(FlatColors.primary)
                }
            }

            infoRow(icon: "person.fill", color: FlatColors.amethyst, label: "Name", value: store.userName.isEmpty ? "Not set" : store.userName)
            FlatDivider()
            infoRow(icon: "birthday.cake.fill", color: FlatColors.tangerine, label: "Age", value: "\(store.userAge) years")
            FlatDivider()
            infoRow(icon: "scalemass.fill", color: FlatColors.primary, label: "Weight", value: store.formattedWeight)
            FlatDivider()
            infoRow(icon: "ruler.fill", color: FlatColors.amethyst, label: "Height", value: store.formattedHeight)
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    private func infoRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            FlatIconCircle(icon: icon, color: color, size: 28)

            Text(label)
                .font(FlatFont.body(15))
                .foregroundStyle(FlatColors.textPrimary)

            Spacer()

            Text(value)
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textSecondary)
        }
    }

    // MARK: - Settings

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(FlatFont.heading(17))
                .foregroundStyle(FlatColors.textPrimary)

            HStack {
                FlatIconCircle(icon: "bell.fill", color: FlatColors.coral, size: 28)

                Text("Notifications")
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Toggle("", isOn: Bindable(store).showNotifications)
                    .tint(FlatColors.primary)
                    .labelsHidden()
            }

            FlatDivider()

            HStack {
                FlatIconCircle(icon: "moon.fill", color: FlatColors.amethyst, size: 28)

                Text("Dark Mode")
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Toggle("", isOn: Bindable(store).useDarkMode)
                    .tint(FlatColors.primary)
                    .labelsHidden()
            }

            FlatDivider()

            HStack {
                FlatIconCircle(icon: "ruler", color: FlatColors.sky, size: 28)

                Text("Units")
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Picker("", selection: Bindable(store).unitSystem) {
                    Text("Imperial").tag("imperial")
                    Text("Metric").tag("metric")
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    // MARK: - About

    private var aboutButton: some View {
        Button {
            showAbout = true
        } label: {
            HStack {
                FlatIconCircle(icon: "info.circle.fill", color: FlatColors.textSecondary, size: 28)

                Text("About")
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Text("v1.0")
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textTertiary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(FlatColors.textTertiary)
            }
            .flatCard(cornerRadius: 14, padding: 18)
        }
        .buttonStyle(FlatScaleButtonStyle())
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            HStack {
                FlatIconCircle(icon: "rectangle.portrait.and.arrow.right", color: FlatColors.coral, size: 28)

                Text("Sign Out")
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.coral)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(FlatColors.textTertiary)
            }
            .flatCard(cornerRadius: 14, padding: 18)
        }
        .buttonStyle(FlatScaleButtonStyle())
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                Task { await auth.signOut(mealStore: store) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: store.showNotifications) { _, _ in
            Task { await store.saveSettings() }
        }
        .onChange(of: store.useDarkMode) { _, _ in
            Task { await store.saveSettings() }
        }
        .onChange(of: store.unitSystem) { _, _ in
            Task { await store.saveProfile() }
        }
    }
}

#Preview {
    ProfileView()
        .environment(MealStore())
        .environment(AuthManager())
}

// MARK: - Profile Edit View

struct ProfileEditView: View {
    @Environment(MealStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var age: Double = 22
    @State private var weight: Double = 165
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 0
    @State private var heightCm: Double = 170
    @State private var hasInitialized = false

    private var isMetric: Bool { store.isMetric }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Name
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            FlatIconCircle(icon: "person.fill", color: FlatColors.amethyst, size: 28)
                            Text("Name")
                                .font(FlatFont.heading(15))
                                .foregroundStyle(FlatColors.textPrimary)
                        }

                        TextField("Your name", text: $name)
                            .font(FlatFont.body(16))
                            .padding(12)
                            .background(FlatColors.inputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .flatCard(cornerRadius: 14, padding: 18)

                    // Age
                    profileSlider(
                        title: "Age", icon: "birthday.cake.fill", color: FlatColors.tangerine,
                        value: $age, range: 13...100, step: 1, unit: "years"
                    )

                    // Weight
                    profileSlider(
                        title: "Weight", icon: "scalemass.fill", color: FlatColors.primary,
                        value: $weight, range: isMetric ? 35...180 : 80...400,
                        step: 1, unit: store.weightUnit
                    )

                    // Height
                    if isMetric {
                        metricHeightEditor
                    } else {
                        imperialHeightEditor
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(FlatColors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FlatColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(FlatColors.primary)
                }
            }
            .onAppear {
                if !hasInitialized {
                    name = store.userName
                    age = Double(store.userAge)
                    weight = store.displayWeight(store.userWeight)
                    let totalInches = Int(store.userHeight)
                    heightFeet = totalInches / 12
                    heightInches = totalInches % 12
                    heightCm = store.displayHeight(store.userHeight)
                    hasInitialized = true
                }
            }
        }
    }

    // MARK: - Imperial Height

    private var imperialHeightEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FlatIconCircle(icon: "ruler.fill", color: FlatColors.amethyst, size: 28)

                Text("Height")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.textPrimary)

                Spacer()

                Text("\(heightFeet)'\(heightInches)\"")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(FlatColors.amethyst)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Feet")
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textSecondary)
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(3...8, id: \.self) { ft in
                            Text("\(ft)").tag(ft)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("Inches")
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textSecondary)
                    Picker("Inches", selection: $heightInches) {
                        ForEach(0...11, id: \.self) { inch in
                            Text("\(inch)").tag(inch)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .flatCard(cornerRadius: 14, padding: 18)
    }

    // MARK: - Metric Height

    private var metricHeightEditor: some View {
        profileSlider(
            title: "Height", icon: "ruler.fill", color: FlatColors.amethyst,
            value: $heightCm, range: 100...250, step: 1, unit: "cm"
        )
    }

    // MARK: - Slider

    private func profileSlider(
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

    private func saveProfile() {
        store.userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        store.userAge = Int(age)
        store.userWeight = store.weightFromDisplay(weight)
        if isMetric {
            store.userHeight = store.heightFromDisplay(heightCm)
        } else {
            store.userHeight = Double(heightFeet * 12 + heightInches)
        }
        Task { await store.saveProfile() }
    }
}
