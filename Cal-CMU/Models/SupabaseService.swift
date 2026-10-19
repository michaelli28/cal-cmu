import Foundation
import Supabase
import UIKit

// MARK: - Database Row Types (Codable DTOs)

struct MealRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let name: String
    let mealType: String
    let scanSource: String
    let timestamp: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    let vitaminC: Double
    let vitaminB6: Double
    let vitaminB12: Double
    let vitaminD: Double
    let vitaminA: Double
    let potassium: Double
    let iron: Double
    let calcium: Double
    let magnesium: Double
    let zinc: Double
    let receiptItems: [String]
    let restaurantName: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case mealType = "meal_type"
        case scanSource = "scan_source"
        case timestamp
        case calories, protein, carbs, fat
        case fiber, sugar, sodium
        case vitaminC = "vitamin_c"
        case vitaminB6 = "vitamin_b6"
        case vitaminB12 = "vitamin_b12"
        case vitaminD = "vitamin_d"
        case vitaminA = "vitamin_a"
        case potassium, iron, calcium, magnesium, zinc
        case receiptItems = "receipt_items"
        case restaurantName = "restaurant_name"
        case imageUrl = "image_url"
    }
}

struct UserProfileRow: Codable, Sendable {
    let id: UUID
    var userName: String
    var userAge: Int
    var userWeight: Double
    var userHeight: Double
    var userGender: String?
    var dailyCalorieGoal: Int
    var dailyProteinGoal: Double
    var dailyCarbsGoal: Double
    var dailyFatGoal: Double
    var streakDays: Int
    var showNotifications: Bool
    var useDarkMode: Bool
    var hasCompletedOnboarding: Bool?
    // Weekend plan
    var useWeekendPlan: Bool
    var weekendCalorieGoal: Int
    var weekendProteinGoal: Double
    var weekendCarbsGoal: Double
    var weekendFatGoal: Double
    // Weight goal
    var targetWeight: Double?
    var weightGoalType: String
    var weightGoalPace: Double?
    var weightGoalTimeframe: String?
    // Units
    var unitSystem: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case userAge = "user_age"
        case userWeight = "user_weight"
        case userHeight = "user_height"
        case userGender = "user_gender"
        case dailyCalorieGoal = "daily_calorie_goal"
        case dailyProteinGoal = "daily_protein_goal"
        case dailyCarbsGoal = "daily_carbs_goal"
        case dailyFatGoal = "daily_fat_goal"
        case streakDays = "streak_days"
        case showNotifications = "show_notifications"
        case useDarkMode = "use_dark_mode"
        case hasCompletedOnboarding = "has_completed_onboarding"
        case useWeekendPlan = "use_weekend_plan"
        case weekendCalorieGoal = "weekend_calorie_goal"
        case weekendProteinGoal = "weekend_protein_goal"
        case weekendCarbsGoal = "weekend_carbs_goal"
        case weekendFatGoal = "weekend_fat_goal"
        case targetWeight = "target_weight"
        case weightGoalType = "weight_goal_type"
        case weightGoalPace = "weight_goal_pace"
        case weightGoalTimeframe = "weight_goal_timeframe"
        case unitSystem = "unit_system"
    }
}

struct UserProfileUpdate: Codable, Sendable {
    var userName: String?
    var userAge: Int?
    var userWeight: Double?
    var userHeight: Double?
    var userGender: String?
    var dailyCalorieGoal: Int?
    var dailyProteinGoal: Double?
    var dailyCarbsGoal: Double?
    var dailyFatGoal: Double?
    var streakDays: Int?
    var showNotifications: Bool?
    var useDarkMode: Bool?
    var hasCompletedOnboarding: Bool?
    // Weekend plan
    var useWeekendPlan: Bool?
    var weekendCalorieGoal: Int?
    var weekendProteinGoal: Double?
    var weekendCarbsGoal: Double?
    var weekendFatGoal: Double?
    // Weight goal
    var targetWeight: Double?
    var weightGoalType: String?
    var weightGoalPace: Double?
    var weightGoalTimeframe: String?
    // Units
    var unitSystem: String?

    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case userAge = "user_age"
        case userWeight = "user_weight"
        case userHeight = "user_height"
        case userGender = "user_gender"
        case dailyCalorieGoal = "daily_calorie_goal"
        case dailyProteinGoal = "daily_protein_goal"
        case dailyCarbsGoal = "daily_carbs_goal"
        case dailyFatGoal = "daily_fat_goal"
        case streakDays = "streak_days"
        case showNotifications = "show_notifications"
        case useDarkMode = "use_dark_mode"
        case hasCompletedOnboarding = "has_completed_onboarding"
        case useWeekendPlan = "use_weekend_plan"
        case weekendCalorieGoal = "weekend_calorie_goal"
        case weekendProteinGoal = "weekend_protein_goal"
        case weekendCarbsGoal = "weekend_carbs_goal"
        case weekendFatGoal = "weekend_fat_goal"
        case targetWeight = "target_weight"
        case weightGoalType = "weight_goal_type"
        case weightGoalPace = "weight_goal_pace"
        case weightGoalTimeframe = "weight_goal_timeframe"
        case unitSystem = "unit_system"
    }
}

struct WaterLogRow: Codable, Sendable {
    let id: UUID?
    let userId: UUID
    let date: String      // "YYYY-MM-DD"
    var intake: Int
    var goal: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case intake
        case goal
    }
}

// MARK: - Insert DTOs (without server-generated fields)

struct MealInsert: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let name: String
    let mealType: String
    let scanSource: String
    let timestamp: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    let vitaminC: Double
    let vitaminB6: Double
    let vitaminB12: Double
    let vitaminD: Double
    let vitaminA: Double
    let potassium: Double
    let iron: Double
    let calcium: Double
    let magnesium: Double
    let zinc: Double
    let receiptItems: [String]
    let restaurantName: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case mealType = "meal_type"
        case scanSource = "scan_source"
        case timestamp
        case calories, protein, carbs, fat
        case fiber, sugar, sodium
        case vitaminC = "vitamin_c"
        case vitaminB6 = "vitamin_b6"
        case vitaminB12 = "vitamin_b12"
        case vitaminD = "vitamin_d"
        case vitaminA = "vitamin_a"
        case potassium, iron, calcium, magnesium, zinc
        case receiptItems = "receipt_items"
        case restaurantName = "restaurant_name"
        case imageUrl = "image_url"
    }
}

struct WaterLogUpsert: Codable, Sendable {
    let userId: UUID
    let date: String
    let intake: Int
    let goal: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case date
        case intake
        case goal
    }
}

// MARK: - Weight Log DTOs

struct WeightLogRow: Codable, Sendable {
    let id: UUID?
    let userId: UUID
    let date: String
    let weight: Double

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case weight
    }
}

struct WeightLogInsert: Codable, Sendable {
    let userId: UUID
    let date: String
    let weight: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case date
        case weight
    }
}

// MARK: - Restaurant Menu Item DTO

struct RestaurantMenuItemRow: Codable, Sendable, Identifiable {
    let id: UUID
    let restaurant: String
    let itemName: String
    let category: String
    let calories: Int
    let caloriesFromFat: Int
    let totalFatG: Double
    let satFatG: Double
    let transFatG: Double
    let cholesterolMg: Double
    let sodiumMg: Double
    let carbsG: Double
    let fiberG: Double
    let sugarsG: Double
    let proteinG: Double
    let vitaminAPct: Int
    let vitaminCPct: Int
    let calciumPct: Int
    let ironPct: Int

    enum CodingKeys: String, CodingKey {
        case id, restaurant, category, calories
        case itemName = "item_name"
        case caloriesFromFat = "calories_from_fat"
        case totalFatG = "total_fat_g"
        case satFatG = "sat_fat_g"
        case transFatG = "trans_fat_g"
        case cholesterolMg = "cholesterol_mg"
        case sodiumMg = "sodium_mg"
        case carbsG = "carbs_g"
        case fiberG = "fiber_g"
        case sugarsG = "sugars_g"
        case proteinG = "protein_g"
        case vitaminAPct = "vitamin_a_pct"
        case vitaminCPct = "vitamin_c_pct"
        case calciumPct = "calcium_pct"
        case ironPct = "iron_pct"
    }

    /// Convert to a Meal for display / saving
    func toMeal(mealType: MealType) -> Meal {
        Meal(
            name: itemName,
            mealType: mealType,
            scanSource: .receipt,
            calories: calories,
            protein: proteinG,
            carbs: carbsG,
            fat: totalFatG,
            fiber: fiberG,
            sugar: sugarsG,
            sodium: sodiumMg,
            vitaminC: Double(vitaminCPct),
            iron: Double(ironPct),
            calcium: Double(calciumPct),
            restaurantName: restaurant
        )
    }
}

// MARK: - SupabaseService

actor SupabaseService {
    static let shared = SupabaseService()

    private var client: SupabaseClient { SupabaseConfig.client }

    // MARK: - User Profile

    func fetchProfile(userId: UUID) async throws -> UserProfileRow {
        try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
    }

    func upsertProfile(_ profile: UserProfileRow) async throws {
        try await client
            .from("user_profiles")
            .upsert(profile)
            .execute()
    }

    func updateProfile(userId: UUID, updates: UserProfileUpdate) async throws {
        try await client
            .from("user_profiles")
            .update(updates)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Meals

    func fetchMeals(userId: UUID) async throws -> [MealRow] {
        try await client
            .from("meals")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("timestamp", ascending: false)
            .execute()
            .value
    }

    func fetchTodaysMeals(userId: UUID) async throws -> [MealRow] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return try await client
            .from("meals")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("timestamp", value: iso.string(from: startOfDay))
            .order("timestamp", ascending: false)
            .execute()
            .value
    }

    func insertMeal(_ meal: MealInsert) async throws -> MealRow {
        try await client
            .from("meals")
            .insert(meal)
            .select()
            .single()
            .execute()
            .value
    }

    func deleteMeal(id: UUID) async throws {
        try await client
            .from("meals")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Water Logs

    func fetchTodayWaterLog(userId: UUID) async throws -> WaterLogRow? {
        let today = Self.todayDateString()
        let rows: [WaterLogRow] = try await client
            .from("water_logs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("date", value: today)
            .execute()
            .value

        return rows.first
    }

    func upsertWaterLog(_ log: WaterLogUpsert) async throws {
        try await client
            .from("water_logs")
            .upsert(log, onConflict: "user_id,date")
            .execute()
    }

    // MARK: - Image Storage

    func uploadMealImage(userId: UUID, mealId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString)/\(mealId.uuidString).jpg"

        try await client.storage
            .from("meal-images")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))

        let publicURL = try client.storage
            .from("meal-images")
            .getPublicURL(path: path)

        return publicURL.absoluteString
    }

    func deleteMealImage(userId: UUID, mealId: UUID) async throws {
        let path = "\(userId.uuidString)/\(mealId.uuidString).jpg"
        try await client.storage
            .from("meal-images")
            .remove(paths: [path])
    }

    // MARK: - Weight Logs

    func fetchWeightLogs(userId: UUID, limit: Int = 30) async throws -> [WeightLogRow] {
        try await client
            .from("weight_logs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("date", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func upsertWeightLog(_ log: WeightLogInsert) async throws {
        try await client
            .from("weight_logs")
            .upsert(log, onConflict: "user_id,date")
            .execute()
    }

    func deleteWeightLog(id: UUID) async throws {
        try await client
            .from("weight_logs")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Restaurant Menu Items

    func fetchRestaurants() async throws -> [String] {
        let items: [RestaurantMenuItemRow] = try await client
            .from("restaurant_menu_items")
            .select()
            .execute()
            .value

        let unique = Set(items.map(\.restaurant))
        return Array(unique).sorted()
    }

    func fetchMenuItems(restaurant: String) async throws -> [RestaurantMenuItemRow] {
        try await client
            .from("restaurant_menu_items")
            .select()
            .eq("restaurant", value: restaurant)
            .order("category")
            .order("item_name")
            .execute()
            .value
    }

    func fetchAllMenuItems() async throws -> [RestaurantMenuItemRow] {
        try await client
            .from("restaurant_menu_items")
            .select()
            .order("restaurant")
            .order("item_name")
            .execute()
            .value
    }

    // MARK: - Helpers

    private static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: Date())
    }
}
