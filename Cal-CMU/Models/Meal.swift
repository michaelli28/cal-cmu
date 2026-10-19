import Foundation
import SwiftUI

// MARK: - Meal Type

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .indigo
        case .snack: return .mint
        }
    }

    var gradient: [Color] {
        switch self {
        case .breakfast: return [.orange, .yellow]
        case .lunch: return [.yellow, .orange]
        case .dinner: return [.indigo, .purple]
        case .snack: return [.mint, .green]
        }
    }

    var flatColor: Color {
        switch self {
        case .breakfast: return FlatColors.tangerine
        case .lunch: return FlatColors.sunflower
        case .dinner: return FlatColors.amethyst
        case .snack: return FlatColors.mint
        }
    }
}

// MARK: - Scan Source

enum ScanSource: String, Codable {
    case receipt = "Receipt"
    case screenshot = "Screenshot"
    case photo = "Photo"

    var icon: String {
        switch self {
        case .receipt: return "doc.text.viewfinder"
        case .screenshot: return "rectangle.on.rectangle"
        case .photo: return "camera.fill"
        }
    }

    var label: String {
        switch self {
        case .receipt: return "Receipt Scan"
        case .screenshot: return "Screenshot"
        case .photo: return "Food Photo"
        }
    }

    var color: Color {
        switch self {
        case .receipt: return .blue
        case .screenshot: return .purple
        case .photo: return .green
        }
    }

    var flatColor: Color {
        switch self {
        case .receipt: return FlatColors.ocean
        case .screenshot: return FlatColors.amethyst
        case .photo: return FlatColors.primary
        }
    }
}

// MARK: - Meal

struct Meal: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let mealType: MealType
    let scanSource: ScanSource
    let timestamp: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    // Vitamins
    let vitaminC: Double
    let vitaminB6: Double
    let vitaminB12: Double
    let vitaminD: Double
    let vitaminA: Double
    // Minerals
    let potassium: Double
    let iron: Double
    let calcium: Double
    let magnesium: Double
    let zinc: Double
    // Receipt data
    let receiptItems: [String]
    let restaurantName: String?
    var imageData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType = .lunch,
        scanSource: ScanSource = .photo,
        timestamp: Date = Date(),
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        sodium: Double = 0,
        vitaminC: Double = 0,
        vitaminB6: Double = 0,
        vitaminB12: Double = 0,
        vitaminD: Double = 0,
        vitaminA: Double = 0,
        potassium: Double = 0,
        iron: Double = 0,
        calcium: Double = 0,
        magnesium: Double = 0,
        zinc: Double = 0,
        receiptItems: [String] = [],
        restaurantName: String? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.scanSource = scanSource
        self.timestamp = timestamp
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.vitaminC = vitaminC
        self.vitaminB6 = vitaminB6
        self.vitaminB12 = vitaminB12
        self.vitaminD = vitaminD
        self.vitaminA = vitaminA
        self.potassium = potassium
        self.iron = iron
        self.calcium = calcium
        self.magnesium = magnesium
        self.zinc = zinc
        self.receiptItems = receiptItems
        self.restaurantName = restaurantName
        self.imageData = imageData
    }

    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    static func == (lhs: Meal, rhs: Meal) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // MARK: - Supabase Conversions

    static func from(row: MealRow) -> Meal {
        Meal(
            id: row.id,
            name: row.name,
            mealType: MealType(rawValue: row.mealType) ?? .lunch,
            scanSource: ScanSource(rawValue: row.scanSource) ?? .photo,
            timestamp: row.timestamp,
            calories: row.calories,
            protein: row.protein,
            carbs: row.carbs,
            fat: row.fat,
            fiber: row.fiber,
            sugar: row.sugar,
            sodium: row.sodium,
            vitaminC: row.vitaminC,
            vitaminB6: row.vitaminB6,
            vitaminB12: row.vitaminB12,
            vitaminD: row.vitaminD,
            vitaminA: row.vitaminA,
            potassium: row.potassium,
            iron: row.iron,
            calcium: row.calcium,
            magnesium: row.magnesium,
            zinc: row.zinc,
            receiptItems: row.receiptItems,
            restaurantName: row.restaurantName,
            imageData: nil  // loaded lazily from URL
        )
    }

    var imageURL: URL? {
        guard let urlString = _imageUrlString else { return nil }
        return URL(string: urlString)
    }

    /// Stored image URL from Supabase Storage (not persisted in imageData)
    var _imageUrlString: String?

    func toInsert(userId: UUID, imageUrl: String? = nil) -> MealInsert {
        MealInsert(
            id: id,
            userId: userId,
            name: name,
            mealType: mealType.rawValue,
            scanSource: scanSource.rawValue,
            timestamp: timestamp,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium,
            vitaminC: vitaminC,
            vitaminB6: vitaminB6,
            vitaminB12: vitaminB12,
            vitaminD: vitaminD,
            vitaminA: vitaminA,
            potassium: potassium,
            iron: iron,
            calcium: calcium,
            magnesium: magnesium,
            zinc: zinc,
            receiptItems: receiptItems,
            restaurantName: restaurantName,
            imageUrl: imageUrl
        )
    }

    static let sampleMeals: [Meal] = [
        Meal(
            name: "Grilled Chicken Salad",
            mealType: .lunch,
            scanSource: .receipt,
            timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            calories: 420, protein: 35, carbs: 28, fat: 18,
            fiber: 6, sugar: 4, sodium: 580,
            vitaminC: 28, vitaminB6: 0.6, vitaminB12: 0.3, vitaminD: 1.2, vitaminA: 180,
            potassium: 520, iron: 2.8, calcium: 85, magnesium: 42, zinc: 3.1,
            receiptItems: ["Grilled Chicken Breast", "Mixed Greens", "Cherry Tomatoes", "Balsamic Vinaigrette"],
            restaurantName: "Sweetgreen"
        ),
        Meal(
            name: "Oatmeal with Berries",
            mealType: .breakfast,
            scanSource: .photo,
            timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
            calories: 310, protein: 12, carbs: 52, fat: 8,
            fiber: 7, sugar: 14, sodium: 120,
            vitaminC: 15, vitaminB6: 0.2, vitaminB12: 0.0, vitaminD: 0.5, vitaminA: 45,
            potassium: 280, iron: 3.4, calcium: 110, magnesium: 56, zinc: 1.8
        ),
        Meal(
            name: "Turkey Club Combo",
            mealType: .dinner,
            scanSource: .receipt,
            timestamp: Calendar.current.date(byAdding: .hour, value: -9, to: Date()) ?? Date(),
            calories: 480, protein: 28, carbs: 42, fat: 20,
            fiber: 3, sugar: 6, sodium: 720,
            vitaminC: 12, vitaminB6: 0.5, vitaminB12: 1.2, vitaminD: 0.8, vitaminA: 95,
            potassium: 340, iron: 2.1, calcium: 65, magnesium: 32, zinc: 2.8,
            receiptItems: ["Turkey Club Sandwich", "Side Salad", "Iced Tea"],
            restaurantName: "Panera Bread"
        ),
        Meal(
            name: "Mixed Nuts",
            mealType: .snack,
            scanSource: .screenshot,
            timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
            calories: 170, protein: 5, carbs: 8, fat: 14,
            fiber: 2, sugar: 1, sodium: 95,
            vitaminC: 0.5, vitaminB6: 0.1, vitaminB12: 0.0, vitaminD: 0.0, vitaminA: 2,
            potassium: 210, iron: 1.6, calcium: 38, magnesium: 68, zinc: 1.5,
            receiptItems: ["Trail Mix - Large"]
        ),
    ]
}

// MARK: - MealStore

@Observable
class MealStore {
    var meals: [Meal] = []
    var isLoadingMeals = false
    var syncError: String?

    // Weekday Goals
    var dailyCalorieGoal: Int = 2000
    var dailyProteinGoal: Double = 150
    var dailyCarbsGoal: Double = 250
    var dailyFatGoal: Double = 65

    // Weekend Goals
    var useWeekendPlan: Bool = false
    var weekendCalorieGoal: Int = 2200
    var weekendProteinGoal: Double = 130
    var weekendCarbsGoal: Double = 280
    var weekendFatGoal: Double = 75

    // Weight Goal
    var targetWeight: Double? = nil
    var weightGoalType: String = "maintain"  // "lose", "gain", "maintain"
    var weightGoalPace: Double = 1.0         // lbs (or kg) per timeframe
    var weightGoalTimeframe: String = "weekly" // "weekly" or "monthly"
    var weightLogs: [(date: String, weight: Double)] = []

    // Units — "imperial" or "metric"
    var unitSystem: String = "imperial"

    // Streak
    var streakDays: Int = 0

    // Profile
    var userName: String = ""
    var userAge: Int = 22
    var userWeight: Double = 165
    var userHeight: Double = 72
    var userGender: String = "male"  // "male", "female", "other"
    var showNotifications: Bool = true
    var useDarkMode: Bool = false
    var hasCompletedOnboarding: Bool = false

    // Water Tracking
    var waterIntake: Int = 0
    var waterGoal: Int = 8

    // The currently authenticated user id
    var currentUserId: UUID?

    private let service = SupabaseService.shared

    // MARK: - Active Goals (weekday vs weekend)

    private var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
    }

    var activeCalorieGoal: Int {
        useWeekendPlan && isWeekend ? weekendCalorieGoal : dailyCalorieGoal
    }

    var activeProteinGoal: Double {
        useWeekendPlan && isWeekend ? weekendProteinGoal : dailyProteinGoal
    }

    var activeCarbsGoal: Double {
        useWeekendPlan && isWeekend ? weekendCarbsGoal : dailyCarbsGoal
    }

    var activeFatGoal: Double {
        useWeekendPlan && isWeekend ? weekendFatGoal : dailyFatGoal
    }

    var activePlanLabel: String {
        if !useWeekendPlan { return "Daily" }
        return isWeekend ? "Weekend" : "Weekday"
    }

    // MARK: - Unit Helpers

    var isMetric: Bool { unitSystem == "metric" }

    var weightUnit: String { isMetric ? "kg" : "lbs" }
    var heightUnit: String { isMetric ? "cm" : "" }

    func displayWeight(_ lbs: Double) -> Double {
        isMetric ? lbs * 0.453592 : lbs
    }

    func displayWeightInt(_ lbs: Double) -> Int {
        Int(displayWeight(lbs))
    }

    func weightFromDisplay(_ display: Double) -> Double {
        isMetric ? display / 0.453592 : display
    }

    func displayHeight(_ inches: Double) -> Double {
        isMetric ? inches * 2.54 : inches
    }

    func heightFromDisplay(_ display: Double) -> Double {
        isMetric ? display / 2.54 : display
    }

    var formattedHeight: String {
        if isMetric {
            return "\(Int(displayHeight(userHeight))) cm"
        }
        let feet = Int(userHeight) / 12
        let inches = Int(userHeight) % 12
        return "\(feet)'\(inches)\""
    }

    var formattedWeight: String {
        "\(displayWeightInt(userWeight)) \(weightUnit)"
    }

    var weightGoalPaceLabel: String {
        let paceInUnit = isMetric ? weightGoalPace * 0.453592 : weightGoalPace
        let timeLabel = weightGoalTimeframe == "weekly" ? "week" : "month"
        return "\(String(format: "%.1f", paceInUnit)) \(weightUnit)/\(timeLabel)"
    }

    var weightSliderRange: ClosedRange<Double> {
        isMetric ? 35.0...180.0 : 80.0...400.0
    }

    var weightPaceRange: ClosedRange<Double> {
        if weightGoalTimeframe == "weekly" {
            return isMetric ? 0.2...1.5 : 0.5...3.0
        }
        return isMetric ? 0.5...6.0 : 1.0...12.0
    }

    var weightPaceStep: Double {
        isMetric ? 0.1 : 0.5
    }

    // MARK: - Nudges

    struct Nudge: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let message: String
        let color: String
        let priority: Int

        var swiftUIColor: Color {
            switch color {
            case "orange": return .orange
            case "blue": return .blue
            case "yellow": return .yellow
            case "red": return .red
            case "green": return .green
            case "indigo": return .indigo
            case "mint": return .mint
            case "cyan": return .cyan
            default: return .secondary
            }
        }
    }

    var nudges: [Nudge] {
        var result: [Nudge] = []

        let calRatio = Double(totalCaloriesToday) / Double(activeCalorieGoal)
        let protRatio = totalProteinToday / activeProteinGoal
        let hour = Calendar.current.component(.hour, from: Date())

        // No meals yet — morning reminder
        if todaysMeals.isEmpty && hour >= 8 {
            result.append(Nudge(
                icon: "sunrise.fill",
                title: "Good Morning",
                message: "Start your day! Log your first meal to stay on track.",
                color: "orange",
                priority: 1
            ))
        }

        // Mid-day protein check
        if hour >= 13 && hour < 18 && protRatio < 0.4 {
            result.append(Nudge(
                icon: "figure.strengthtraining.traditional",
                title: "Protein Check",
                message: "You're at \(Int(protRatio * 100))% of your protein goal — consider a protein-rich snack.",
                color: "blue",
                priority: 2
            ))
        }

        // Calorie pacing
        if hour >= 12 && hour < 20 {
            let expectedPace = Double(hour - 6) / 14.0  // 6am–8pm window
            if calRatio < expectedPace * 0.5 && !todaysMeals.isEmpty {
                result.append(Nudge(
                    icon: "gauge.with.dots.needle.33percent",
                    title: "Under-Pacing",
                    message: "You're under-pacing — \(totalCaloriesToday) of \(activeCalorieGoal) cal by \(hour > 12 ? "\(hour - 12) PM" : "12 PM").",
                    color: "yellow",
                    priority: 3
                ))
            }
        }

        // Over budget warning
        if calRatio > 1.0 {
            let over = totalCaloriesToday - activeCalorieGoal
            result.append(Nudge(
                icon: "exclamationmark.triangle.fill",
                title: "Over Budget",
                message: "You're \(over) cal over your \(activePlanLabel.lowercased()) goal. Consider lighter options.",
                color: "red",
                priority: 1
            ))
        }

        // Approaching goal
        if calRatio >= 0.85 && calRatio <= 1.0 {
            let remaining = activeCalorieGoal - totalCaloriesToday
            result.append(Nudge(
                icon: "checkmark.circle.fill",
                title: "Almost There",
                message: "Almost there! Only \(remaining) cal left for today.",
                color: "green",
                priority: 2
            ))
        }

        // Weekend plan reminder
        if useWeekendPlan && isWeekend && todaysMeals.isEmpty && hour >= 9 {
            result.append(Nudge(
                icon: "calendar.badge.clock",
                title: "Weekend Plan",
                message: "Weekend plan active — \(weekendCalorieGoal) cal target today.",
                color: "indigo",
                priority: 3
            ))
        }

        // Weight trend nudge
        if let target = targetWeight, weightLogs.count >= 2 {
            let latest = weightLogs.first?.weight ?? userWeight
            let diff = latest - target
            let diffDisplay = String(format: "%.1f", abs(displayWeight(diff)))
            if weightGoalType == "lose" && diff > 0 {
                result.append(Nudge(
                    icon: "arrow.down.right",
                    title: "Weight Progress",
                    message: "\(diffDisplay) \(weightUnit) to go — you're trending in the right direction!",
                    color: "mint",
                    priority: 4
                ))
            } else if weightGoalType == "gain" && diff < 0 {
                result.append(Nudge(
                    icon: "arrow.up.right",
                    title: "Weight Progress",
                    message: "\(diffDisplay) \(weightUnit) to your target — keep fueling up!",
                    color: "cyan",
                    priority: 4
                ))
            } else if weightGoalType != "maintain" && ((weightGoalType == "lose" && diff <= 0) || (weightGoalType == "gain" && diff >= 0)) {
                result.append(Nudge(
                    icon: "trophy.fill",
                    title: "Goal Reached!",
                    message: "You've reached your weight goal! Consider setting a new target.",
                    color: "yellow",
                    priority: 1
                ))
            }
        }

        // Water reminder
        if waterIntake < waterGoal / 2 && hour >= 14 {
            result.append(Nudge(
                icon: "drop.fill",
                title: "Hydration",
                message: "Stay hydrated — only \(waterIntake)/\(waterGoal) glasses so far.",
                color: "cyan",
                priority: 5
            ))
        }

        return result.sorted { $0.priority < $1.priority }
    }

    // MARK: - Weight Trend

    var weightTrendDirection: String {
        guard weightLogs.count >= 2 else { return "stable" }
        let recent = weightLogs.prefix(7).map(\.weight)
        let avg = recent.reduce(0, +) / Double(recent.count)
        let latest = recent.first ?? avg
        let diff = latest - avg
        if diff < -0.5 { return "losing" }
        if diff > 0.5 { return "gaining" }
        return "stable"
    }

    var weeklyWeightChange: Double {
        guard weightLogs.count >= 2 else { return 0 }
        let latest = weightLogs.first?.weight ?? userWeight
        let weekAgo = weightLogs.count >= 7 ? (weightLogs[min(6, weightLogs.count - 1)].weight) : weightLogs.last!.weight
        return latest - weekAgo
    }

    // MARK: - Load All Data

    func loadAllData(userId: UUID) async {
        currentUserId = userId
        async let profileTask: () = loadProfile(userId: userId)
        async let mealsTask: () = loadMeals(userId: userId)
        async let waterTask: () = loadWaterLog(userId: userId)
        async let weightTask: () = loadWeightLogs(userId: userId)
        _ = await (profileTask, mealsTask, waterTask, weightTask)
    }

    // MARK: - Profile

    func loadProfile(userId: UUID) async {
        do {
            let profile = try await service.fetchProfile(userId: userId)
            await MainActor.run {
                self.userName = profile.userName
                self.userAge = profile.userAge
                self.userWeight = profile.userWeight
                self.userHeight = profile.userHeight
                self.userGender = profile.userGender ?? "male"
                self.dailyCalorieGoal = profile.dailyCalorieGoal
                self.dailyProteinGoal = profile.dailyProteinGoal
                self.dailyCarbsGoal = profile.dailyCarbsGoal
                self.dailyFatGoal = profile.dailyFatGoal
                self.streakDays = profile.streakDays
                self.showNotifications = profile.showNotifications
                self.useDarkMode = profile.useDarkMode
                self.hasCompletedOnboarding = profile.hasCompletedOnboarding ?? false
                // Weekend plan
                self.useWeekendPlan = profile.useWeekendPlan
                self.weekendCalorieGoal = profile.weekendCalorieGoal
                self.weekendProteinGoal = profile.weekendProteinGoal
                self.weekendCarbsGoal = profile.weekendCarbsGoal
                self.weekendFatGoal = profile.weekendFatGoal
                // Weight goal
                self.targetWeight = profile.targetWeight
                self.weightGoalType = profile.weightGoalType
                self.weightGoalPace = profile.weightGoalPace ?? 1.0
                self.weightGoalTimeframe = profile.weightGoalTimeframe ?? "weekly"
                // Units
                self.unitSystem = profile.unitSystem ?? "imperial"
            }
        } catch {
            print("[MealStore] Failed to load profile: \(error)")
        }
    }

    func saveProfile() async {
        guard let userId = currentUserId else { return }
        let updates = UserProfileUpdate(
            userName: userName,
            userAge: userAge,
            userWeight: userWeight,
            userHeight: userHeight,
            userGender: userGender,
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            dailyCarbsGoal: dailyCarbsGoal,
            dailyFatGoal: dailyFatGoal,
            streakDays: streakDays,
            showNotifications: showNotifications,
            useDarkMode: useDarkMode,
            hasCompletedOnboarding: hasCompletedOnboarding,
            unitSystem: unitSystem
        )
        do {
            try await service.updateProfile(userId: userId, updates: updates)
        } catch {
            print("[MealStore] Failed to save profile: \(error)")
        }
    }

    func saveGoals() async {
        guard let userId = currentUserId else { return }
        let updates = UserProfileUpdate(
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            dailyCarbsGoal: dailyCarbsGoal,
            dailyFatGoal: dailyFatGoal,
            useWeekendPlan: useWeekendPlan,
            weekendCalorieGoal: weekendCalorieGoal,
            weekendProteinGoal: weekendProteinGoal,
            weekendCarbsGoal: weekendCarbsGoal,
            weekendFatGoal: weekendFatGoal,
            targetWeight: targetWeight,
            weightGoalType: weightGoalType,
            weightGoalPace: weightGoalPace,
            weightGoalTimeframe: weightGoalTimeframe
        )
        do {
            try await service.updateProfile(userId: userId, updates: updates)
        } catch {
            print("[MealStore] Failed to save goals: \(error)")
        }
    }

    func saveSettings() async {
        guard let userId = currentUserId else { return }
        let updates = UserProfileUpdate(
            showNotifications: showNotifications,
            useDarkMode: useDarkMode
        )
        do {
            try await service.updateProfile(userId: userId, updates: updates)
        } catch {
            print("[MealStore] Failed to save settings: \(error)")
        }
    }

    // MARK: - Meals

    func loadMeals(userId: UUID) async {
        isLoadingMeals = true
        defer { isLoadingMeals = false }
        do {
            let rows = try await service.fetchMeals(userId: userId)
            await MainActor.run {
                self.meals = rows.map { row in
                    var meal = Meal.from(row: row)
                    meal._imageUrlString = row.imageUrl
                    return meal
                }
            }
        } catch {
            print("[MealStore] Failed to load meals: \(error)")
            syncError = error.localizedDescription
        }
    }

    // MARK: - Water

    func loadWaterLog(userId: UUID) async {
        do {
            if let log = try await service.fetchTodayWaterLog(userId: userId) {
                await MainActor.run {
                    self.waterIntake = log.intake
                    self.waterGoal = log.goal
                }
            }
        } catch {
            print("[MealStore] Failed to load water log: \(error)")
        }
    }

    private func saveWaterLog() async {
        guard let userId = currentUserId else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let log = WaterLogUpsert(
            userId: userId,
            date: formatter.string(from: Date()),
            intake: waterIntake,
            goal: waterGoal
        )
        do {
            try await service.upsertWaterLog(log)
        } catch {
            print("[MealStore] Failed to save water log: \(error)")
        }
    }

    /// Public entry point for views that directly mutate waterIntake
    func saveWaterLogManually() async {
        await saveWaterLog()
    }

    // MARK: - Weight Logs

    func loadWeightLogs(userId: UUID) async {
        do {
            let rows = try await service.fetchWeightLogs(userId: userId, limit: 30)
            await MainActor.run {
                self.weightLogs = rows.map { (date: $0.date, weight: $0.weight) }
            }
        } catch {
            print("[MealStore] Failed to load weight logs: \(error)")
        }
    }

    func logWeight(_ weight: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let today = formatter.string(from: Date())

        // Update local state
        if let index = weightLogs.firstIndex(where: { $0.date == today }) {
            weightLogs[index] = (date: today, weight: weight)
        } else {
            weightLogs.insert((date: today, weight: weight), at: 0)
        }
        userWeight = weight

        // Persist
        Task {
            guard let userId = currentUserId else { return }
            do {
                try await service.upsertWeightLog(WeightLogInsert(
                    userId: userId,
                    date: today,
                    weight: weight
                ))
                try await service.updateProfile(userId: userId, updates: UserProfileUpdate(userWeight: weight))
            } catch {
                print("[MealStore] Failed to save weight log: \(error)")
            }
        }
    }

    // MARK: - Today's Data

    var todaysMeals: [Meal] {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var totalCaloriesToday: Int {
        todaysMeals.reduce(0) { $0 + $1.calories }
    }

    var totalProteinToday: Double {
        todaysMeals.reduce(0) { $0 + $1.protein }
    }

    var totalCarbsToday: Double {
        todaysMeals.reduce(0) { $0 + $1.carbs }
    }

    var totalFatToday: Double {
        todaysMeals.reduce(0) { $0 + $1.fat }
    }

    // Vitamin & Mineral Totals
    var totalVitaminCToday: Double { todaysMeals.reduce(0) { $0 + $1.vitaminC } }
    var totalVitaminB6Today: Double { todaysMeals.reduce(0) { $0 + $1.vitaminB6 } }
    var totalVitaminB12Today: Double { todaysMeals.reduce(0) { $0 + $1.vitaminB12 } }
    var totalVitaminDToday: Double { todaysMeals.reduce(0) { $0 + $1.vitaminD } }
    var totalVitaminAToday: Double { todaysMeals.reduce(0) { $0 + $1.vitaminA } }
    var totalPotassiumToday: Double { todaysMeals.reduce(0) { $0 + $1.potassium } }
    var totalIronToday: Double { todaysMeals.reduce(0) { $0 + $1.iron } }
    var totalCalciumToday: Double { todaysMeals.reduce(0) { $0 + $1.calcium } }
    var totalMagnesiumToday: Double { todaysMeals.reduce(0) { $0 + $1.magnesium } }
    var totalZincToday: Double { todaysMeals.reduce(0) { $0 + $1.zinc } }

    func mealsForType(_ type: MealType) -> [Meal] {
        todaysMeals.filter { $0.mealType == type }
    }

    func caloriesForType(_ type: MealType) -> Int {
        mealsForType(type).reduce(0) { $0 + $1.calories }
    }

    // MARK: - Weekly Data

    var weeklyCalories: [(day: String, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
        let todayWeekday = (calendar.component(.weekday, from: today) + 5) % 7

        return (0..<7).map { offset in
            let dayIndex = offset
            if dayIndex < todayWeekday {
                // For past days, compute from stored meals
                guard let targetDate = calendar.date(byAdding: .day, value: dayIndex - todayWeekday, to: today) else {
                    return (dayLabels[dayIndex], 0)
                }
                let dayCals = meals
                    .filter { calendar.isDate($0.timestamp, inSameDayAs: targetDate) }
                    .reduce(0) { $0 + $1.calories }
                return (dayLabels[dayIndex], dayCals)
            } else if dayIndex == todayWeekday {
                return (dayLabels[dayIndex], totalCaloriesToday)
            } else {
                return (dayLabels[dayIndex], 0)
            }
        }
    }

    var averageWeeklyCalories: Int {
        let nonZero = weeklyCalories.filter { $0.calories > 0 }
        guard !nonZero.isEmpty else { return 0 }
        return nonZero.reduce(0) { $0 + $1.calories } / nonZero.count
    }

    // MARK: - Macro Percentages

    var macroPercentages: (protein: Double, carbs: Double, fat: Double) {
        let totalP = totalProteinToday * 4
        let totalC = totalCarbsToday * 4
        let totalF = totalFatToday * 9
        let total = totalP + totalC + totalF
        guard total > 0 else { return (33, 34, 33) }
        return (
            protein: (totalP / total) * 100,
            carbs: (totalC / total) * 100,
            fat: (totalF / total) * 100
        )
    }

    var nutritionScore: Int {
        var score = 50
        let calRatio = Double(totalCaloriesToday) / Double(activeCalorieGoal)
        if calRatio > 0.7 && calRatio < 1.1 { score += 20 }
        else if calRatio > 0.5 { score += 10 }
        let protRatio = totalProteinToday / activeProteinGoal
        if protRatio > 0.7 { score += 15 }
        let carbRatio = totalCarbsToday / activeCarbsGoal
        if carbRatio > 0.7 && carbRatio < 1.2 { score += 10 }
        let fatRatio = totalFatToday / activeFatGoal
        if fatRatio > 0.5 && fatRatio < 1.2 { score += 5 }
        return min(score, 100)
    }

    // MARK: - Actions

    func addMeal(_ meal: Meal) {
        withAnimation(.spring(response: 0.4)) {
            meals.insert(meal, at: 0)
        }
        // Persist to Supabase in background
        Task {
            guard let userId = currentUserId else { return }
            do {
                var imageUrl: String?
                if let imageData = meal.imageData {
                    imageUrl = try await service.uploadMealImage(
                        userId: userId,
                        mealId: meal.id,
                        imageData: imageData
                    )
                }
                _ = try await service.insertMeal(meal.toInsert(userId: userId, imageUrl: imageUrl))
            } catch {
                print("[MealStore] Failed to save meal: \(error)")
                syncError = "Failed to save meal. It will be synced later."
            }
        }
    }

    func deleteMeal(_ meal: Meal) {
        withAnimation(.spring(response: 0.3)) {
            meals.removeAll { $0.id == meal.id }
        }
        // Delete from Supabase in background
        Task {
            guard let userId = currentUserId else { return }
            do {
                try await service.deleteMeal(id: meal.id)
                try await service.deleteMealImage(userId: userId, mealId: meal.id)
            } catch {
                print("[MealStore] Failed to delete meal: \(error)")
            }
        }
    }

    func addWater() {
        withAnimation(.spring(response: 0.3)) {
            waterIntake = min(waterIntake + 1, 99)
        }
        Task { await saveWaterLog() }
    }

    func removeWater() {
        withAnimation(.spring(response: 0.3)) {
            waterIntake = max(waterIntake - 1, 0)
        }
        Task { await saveWaterLog() }
    }

    // MARK: - Reset on Sign Out

    func reset() {
        meals = []
        currentUserId = nil
        userName = ""
        userAge = 22
        userWeight = 165
        userHeight = 72
        dailyCalorieGoal = 2000
        dailyProteinGoal = 150
        dailyCarbsGoal = 250
        dailyFatGoal = 65
        useWeekendPlan = false
        weekendCalorieGoal = 2200
        weekendProteinGoal = 130
        weekendCarbsGoal = 280
        weekendFatGoal = 75
        targetWeight = nil
        weightGoalType = "maintain"
        weightGoalPace = 1.0
        weightGoalTimeframe = "weekly"
        weightLogs = []
        unitSystem = "imperial"
        streakDays = 0
        showNotifications = true
        useDarkMode = false
        waterIntake = 0
        waterGoal = 8
        syncError = nil
    }

    // MARK: - Mock Analysis

    func generateMockAnalysis(from image: UIImage, mealType: MealType, scanSource: ScanSource) -> Meal {
        if scanSource == .receipt || scanSource == .screenshot {
            return generateReceiptAnalysis(from: image, mealType: mealType, scanSource: scanSource)
        } else {
            return generatePhotoAnalysis(from: image, mealType: mealType)
        }
    }

    private func generateReceiptAnalysis(from image: UIImage, mealType: MealType, scanSource: ScanSource) -> Meal {
        let options: [(name: String, restaurant: String, items: [String], cal: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, sugar: Double, sodium: Double, vitC: Double, b6: Double, b12: Double, vitD: Double, vitA: Double, potassium: Double, iron: Double, calcium: Double, magnesium: Double, zinc: Double)] = [
            ("Chipotle Burrito Bowl", "Chipotle", ["Chicken", "White Rice", "Black Beans", "Fajita Veggies", "Tomato Salsa", "Cheese", "Lettuce"], 740, 45, 68, 28, 12, 4, 1680, 18, 0.6, 0.4, 0.0, 165, 620, 4.5, 280, 78, 4.2),
            ("Big Mac Combo", "McDonald's", ["Big Mac", "Medium Fries", "Medium Coke"], 1080, 28, 138, 48, 6, 52, 1340, 4, 0.3, 2.4, 0.0, 45, 680, 4.8, 220, 42, 3.8),
            ("Spicy Chicken Sandwich", "Chick-fil-A", ["Spicy Chicken Sandwich", "Waffle Fries", "Lemonade"], 920, 34, 108, 38, 4, 42, 1820, 12, 0.4, 0.2, 0.0, 28, 520, 2.8, 65, 36, 2.1),
            ("Poke Bowl - Regular", "Pokeworks", ["Salmon", "Tuna", "Sushi Rice", "Edamame", "Seaweed Salad", "Sriracha Aioli"], 620, 38, 58, 22, 5, 8, 890, 8, 0.9, 5.2, 8.5, 310, 580, 2.2, 48, 62, 1.8),
            ("Veggie Delight Sub", "Subway", ["6-inch Wheat Bread", "Lettuce", "Tomato", "Cucumber", "Green Peppers", "Onions", "Provolone"], 340, 16, 42, 12, 6, 5, 680, 22, 0.2, 0.6, 0.0, 95, 260, 2.8, 180, 32, 1.6),
            ("Acai Supergreens Bowl", "Jamba Juice", ["Acai", "Banana", "Blueberries", "Granola", "Honey", "Chia Seeds"], 470, 10, 82, 14, 11, 38, 45, 42, 0.4, 0.0, 0.0, 65, 420, 2.4, 120, 48, 1.2),
        ]

        let c = options.randomElement()!
        return Meal(
            name: c.name, mealType: mealType, scanSource: scanSource,
            calories: c.cal, protein: c.protein, carbs: c.carbs, fat: c.fat,
            fiber: c.fiber, sugar: c.sugar, sodium: c.sodium,
            vitaminC: c.vitC, vitaminB6: c.b6, vitaminB12: c.b12,
            vitaminD: c.vitD, vitaminA: c.vitA,
            potassium: c.potassium, iron: c.iron, calcium: c.calcium,
            magnesium: c.magnesium, zinc: c.zinc,
            receiptItems: c.items, restaurantName: c.restaurant,
            imageData: image.jpegData(compressionQuality: 0.6)
        )
    }

    private func generatePhotoAnalysis(from image: UIImage, mealType: MealType) -> Meal {
        let options: [(String, Int, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double, Double)] = [
            ("Grilled Chicken Salad", 420, 35, 28, 18, 6, 4, 580, 28, 0.6, 0.3, 1.2, 180, 520, 2.8, 85, 42, 3.1),
            ("Pasta Bolognese", 650, 28, 72, 24, 4, 8, 890, 10, 0.4, 1.8, 0.3, 120, 610, 4.2, 52, 38, 4.5),
            ("Avocado Toast", 380, 14, 36, 22, 8, 3, 440, 12, 0.3, 0.0, 0.0, 45, 480, 1.8, 28, 58, 1.2),
            ("Salmon Rice Bowl", 520, 32, 48, 20, 3, 5, 620, 6, 0.8, 4.9, 14.2, 280, 690, 1.2, 22, 52, 1.0),
            ("Greek Yogurt Parfait", 290, 18, 38, 8, 4, 22, 95, 18, 0.2, 1.1, 0.0, 35, 380, 0.6, 220, 28, 1.4),
            ("Steak and Vegetables", 560, 42, 18, 34, 5, 4, 720, 22, 0.7, 2.8, 0.5, 65, 580, 3.8, 32, 45, 6.2),
            ("Acai Bowl", 340, 8, 52, 12, 9, 28, 45, 32, 0.3, 0.0, 0.0, 55, 310, 1.4, 48, 34, 0.8),
            ("Caesar Wrap", 460, 24, 38, 22, 3, 4, 820, 14, 0.4, 0.5, 0.2, 110, 290, 2.2, 95, 26, 2.4),
        ]

        let c = options.randomElement()!
        return Meal(
            name: c.0, mealType: mealType, scanSource: .photo,
            calories: c.1, protein: c.2, carbs: c.3, fat: c.4,
            fiber: c.5, sugar: c.6, sodium: c.7,
            vitaminC: c.8, vitaminB6: c.9, vitaminB12: c.10,
            vitaminD: c.11, vitaminA: c.12,
            potassium: c.13, iron: c.14, calcium: c.15,
            magnesium: c.16, zinc: c.17,
            imageData: image.jpegData(compressionQuality: 0.6)
        )
    }
}
