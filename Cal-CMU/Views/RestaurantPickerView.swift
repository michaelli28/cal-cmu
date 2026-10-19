import SwiftUI

struct RestaurantPickerView: View {
    let mealType: MealType
    let onItemSelected: (Meal) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var restaurants: [String] = []
    @State private var selectedRestaurant: String?
    @State private var menuItems: [RestaurantMenuItemRow] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let service = SupabaseService.shared

    private var filteredItems: [RestaurantMenuItemRow] {
        guard !searchText.isEmpty else { return menuItems }
        return menuItems.filter {
            $0.itemName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedItems: [(String, [RestaurantMenuItemRow])] {
        let dict = Dictionary(grouping: filteredItems, by: \.category)
        let order = ["breakfast", "entree", "sandwich", "salad", "side"]
        return dict.sorted { a, b in
            let ia = order.firstIndex(of: a.key) ?? order.count
            let ib = order.firstIndex(of: b.key) ?? order.count
            return ia < ib
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlatColors.background.ignoresSafeArea()

                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if selectedRestaurant == nil {
                    restaurantListView
                } else {
                    menuItemsView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if selectedRestaurant != nil {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedRestaurant = nil
                                menuItems = []
                                searchText = ""
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: selectedRestaurant != nil ? "chevron.left" : "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(FlatColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(FlatColors.inputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(selectedRestaurant ?? "CMU Dining")
                            .font(FlatFont.heading(17))
                            .foregroundStyle(FlatColors.textPrimary)
                        if selectedRestaurant != nil {
                            Text("Select an item")
                                .font(FlatFont.caption(11))
                                .foregroundStyle(FlatColors.textTertiary)
                        }
                    }
                }
            }
        }
        .task {
            await loadRestaurants()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(FlatColors.primary)
            Text("Loading dining halls...")
                .font(FlatFont.body(14))
                .foregroundStyle(FlatColors.textTertiary)
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            FlatIconCircle(icon: "exclamationmark.triangle", color: FlatColors.coral, size: 48)
            Text(message)
                .font(FlatFont.body(14))
                .foregroundStyle(FlatColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                Task { await loadRestaurants() }
            }
            .buttonStyle(FlatPrimaryButton())
        }
    }

    // MARK: - Restaurant List

    private var restaurantListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    FlatIconCircle(icon: "fork.knife", color: FlatColors.primary, size: 56)
                    Text("Choose a dining location")
                        .font(FlatFont.heading(18))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text("Select where you're eating to browse the menu")
                        .font(FlatFont.body(13))
                        .foregroundStyle(FlatColors.textTertiary)
                }
                .padding(.top, 24)
                .padding(.bottom, 8)

                ForEach(restaurants, id: \.self) { restaurant in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedRestaurant = restaurant
                        }
                        Task { await loadMenuItems(restaurant: restaurant) }
                    } label: {
                        HStack(spacing: 14) {
                            FlatIconCircle(icon: restaurantIcon(for: restaurant), color: FlatColors.ocean, size: 40)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(restaurant)
                                    .font(FlatFont.heading(16))
                                    .foregroundStyle(FlatColors.textPrimary)
                                Text("Tap to browse menu")
                                    .font(FlatFont.caption(12))
                                    .foregroundStyle(FlatColors.textTertiary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(FlatColors.textTertiary)
                        }
                        .padding(16)
                        .background(FlatColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(FlatScaleButtonStyle())
                }

                // Logging for a meal type
                FlatBadge(text: "Logging as \(mealType.rawValue)", color: mealType.flatColor, icon: mealType.icon)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Menu Items

    private var menuItemsView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(FlatColors.textTertiary)

                TextField("Search menu items...", text: $searchText)
                    .font(FlatFont.body(15))
                    .foregroundStyle(FlatColors.textPrimary)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(FlatColors.textTertiary)
                    }
                }
            }
            .padding(12)
            .background(FlatColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if filteredItems.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(FlatColors.textTertiary)
                    Text("No items found")
                        .font(FlatFont.body(15))
                        .foregroundStyle(FlatColors.textSecondary)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                        ForEach(groupedItems, id: \.0) { category, items in
                            Section {
                                ForEach(items) { item in
                                    MenuItemCard(item: item) {
                                        let meal = item.toMeal(mealType: mealType)
                                        onItemSelected(meal)
                                        dismiss()
                                    }
                                }
                            } header: {
                                categoryHeader(category)
                            }
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private func categoryHeader(_ category: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(FlatColors.primary)

            Text(category.capitalized)
                .font(FlatFont.label(13))
                .foregroundStyle(FlatColors.textSecondary)

            FlatDivider()
        }
        .padding(.vertical, 6)
        .background(FlatColors.background)
    }

    // MARK: - Data Loading

    private func loadRestaurants() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.fetchRestaurants()
            await MainActor.run {
                restaurants = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Couldn't load restaurants. Check your connection and try again."
                isLoading = false
            }
        }
    }

    private func loadMenuItems(restaurant: String) async {
        do {
            let result = try await service.fetchMenuItems(restaurant: restaurant)
            await MainActor.run {
                menuItems = result
            }
        } catch {
            await MainActor.run {
                errorMessage = "Couldn't load menu items."
            }
        }
    }

    // MARK: - Helpers

    private func restaurantIcon(for name: String) -> String {
        switch name.lowercased() {
        case let n where n.contains("exchange"): return "building.2"
        case let n where n.contains("resnik"): return "cup.and.saucer"
        case let n where n.contains("schatz"): return "storefront"
        case let n where n.contains("entropy"): return "mug"
        default: return "fork.knife"
        }
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "breakfast": return "sunrise"
        case "entree": return "flame"
        case "sandwich": return "rectangle.split.2x1"
        case "salad": return "leaf"
        case "side": return "square.grid.2x2"
        default: return "circle"
        }
    }
}

// MARK: - Menu Item Card

struct MenuItemCard: View {
    let item: RestaurantMenuItemRow
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                // Name + calories
                HStack(alignment: .top) {
                    Text(item.itemName)
                        .font(FlatFont.heading(15))
                        .foregroundStyle(FlatColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(item.calories)")
                            .font(FlatFont.title(20))
                            .foregroundStyle(FlatColors.primary)
                        Text("cal")
                            .font(FlatFont.caption(11))
                            .foregroundStyle(FlatColors.textTertiary)
                    }
                }

                // Macro row
                HStack(spacing: 16) {
                    macroChip(label: "Protein", value: item.proteinG, unit: "g", color: FlatColors.ocean)
                    macroChip(label: "Carbs", value: item.carbsG, unit: "g", color: FlatColors.sunflower)
                    macroChip(label: "Fat", value: item.totalFatG, unit: "g", color: FlatColors.coral)
                    Spacer()
                    macroChip(label: "Sodium", value: item.sodiumMg, unit: "mg", color: FlatColors.textTertiary)
                }

                // Category badge
                FlatBadge(text: item.category.capitalized, color: categoryColor(item.category))
            }
            .padding(14)
            .background(FlatColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(FlatScaleButtonStyle())
    }

    private func macroChip(label: String, value: Double, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(FlatFont.caption(10))
                .foregroundStyle(FlatColors.textTertiary)

            HStack(spacing: 1) {
                Text(value < 10 ? String(format: "%.1f", value) : "\(Int(value))")
                    .font(FlatFont.mono(13))
                    .foregroundStyle(color)
                Text(unit)
                    .font(FlatFont.caption(10))
                    .foregroundStyle(color.opacity(0.7))
            }
        }
    }

    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "breakfast": return FlatColors.tangerine
        case "entree": return FlatColors.coral
        case "sandwich": return FlatColors.ocean
        case "salad": return FlatColors.primary
        case "side": return FlatColors.amethyst
        default: return FlatColors.textTertiary
        }
    }
}

#Preview {
    RestaurantPickerView(mealType: .lunch) { meal in
        print("Selected: \(meal.name)")
    }
}
