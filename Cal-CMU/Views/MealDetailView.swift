import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    let capturedImage: UIImage?
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    mealPhotoSection
                    scanSourceBadge
                    calorieSummarySection
                    if !meal.receiptItems.isEmpty {
                        receiptItemsSection
                    }
                    macroRingsSection
                    nutrientListSection
                    saveButton
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
            .background(FlatColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(FlatColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(FlatColors.inputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Meal Analysis")
                        .font(FlatFont.heading(17))
                        .foregroundStyle(FlatColors.textPrimary)
                }
            }
        }
    }

    // MARK: - Photo

    private var mealPhotoSection: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(meal.mealType.flatColor.opacity(0.1))
                        Image(systemName: "fork.knife")
                            .font(.system(size: 48))
                            .foregroundStyle(meal.mealType.flatColor.opacity(0.25))
                    }
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            FlatBadge(text: meal.mealType.rawValue, color: meal.mealType.flatColor, icon: meal.mealType.icon)
                .padding(16)
        }
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Calorie Summary

    private var calorieSummarySection: some View {
        VStack(spacing: 8) {
            Text(meal.name)
                .font(FlatFont.title(24))
                .foregroundStyle(FlatColors.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(FlatColors.tangerine)
                    .font(.system(size: 18))
                Text("\(meal.calories)")
                    .font(FlatFont.title(28))
                    .foregroundStyle(FlatColors.textPrimary)
                    .contentTransition(.numericText())
                Text("calories")
                    .font(FlatFont.body(16))
                    .foregroundStyle(FlatColors.textSecondary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    // MARK: - Scan Source Badge

    private var scanSourceBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: meal.scanSource.icon)
                .font(.system(size: 12, weight: .semibold))
            Text(meal.scanSource.label)
                .font(FlatFont.label(13))
            if let restaurant = meal.restaurantName {
                Text("\u{00B7}")
                    .foregroundStyle(FlatColors.textTertiary)
                Text(restaurant)
                    .font(FlatFont.body(13))
                    .foregroundStyle(FlatColors.textSecondary)
            }
        }
        .foregroundStyle(meal.scanSource.flatColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(meal.scanSource.flatColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Receipt Items

    private var receiptItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                FlatIconCircle(icon: "list.bullet.rectangle", color: FlatColors.ocean, size: 28)
                Text("Items from Receipt")
                    .font(FlatFont.heading(17))
                    .foregroundStyle(FlatColors.textPrimary)
                Spacer()
                Text("\(meal.receiptItems.count) items")
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textSecondary)
            }

            ForEach(Array(meal.receiptItems.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(FlatFont.caption(12))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(FlatColors.ocean)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Text(item)
                        .font(FlatFont.body(15))
                        .foregroundStyle(FlatColors.textPrimary)

                    Spacer()
                }
                if index < meal.receiptItems.count - 1 {
                    FlatDivider()
                }
            }
        }
        .flatCard(cornerRadius: 14, padding: 20)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    // MARK: - Macro Rings

    private var macroRingsSection: some View {
        HStack(spacing: 16) {
            macroRing(label: "Protein", value: meal.protein, color: FlatColors.ocean)
            macroRing(label: "Carbs", value: meal.carbs, color: FlatColors.tangerine)
            macroRing(label: "Fat", value: meal.fat, color: FlatColors.rose)
        }
        .flatCard(cornerRadius: 14, padding: 20)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
    }

    private func macroRing(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.12), lineWidth: 10)
                    .frame(width: 76, height: 76)

                Circle()
                    .trim(from: 0, to: appeared ? min(value / 100, 1.0) : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)

                Text("\(Int(value))g")
                    .font(FlatFont.heading(15))
                    .foregroundStyle(color)
            }

            Text(label)
                .font(FlatFont.caption(12))
                .foregroundStyle(FlatColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Nutrients

    private var nutrientListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Detailed Nutrients")
                .font(FlatFont.heading(17))
                .foregroundStyle(FlatColors.textPrimary)
                .padding(.bottom, 14)

            nutrientRow(name: "Protein", value: "\(Int(meal.protein))g", icon: "circle.hexagongrid.fill", color: FlatColors.ocean)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Carbohydrates", value: "\(Int(meal.carbs))g", icon: "bolt.fill", color: FlatColors.tangerine)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Total Fat", value: "\(Int(meal.fat))g", icon: "drop.triangle.fill", color: FlatColors.rose)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Fiber", value: "\(Int(meal.fiber))g", icon: "leaf.fill", color: FlatColors.primary)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Sugar", value: "\(Int(meal.sugar))g", icon: "cube.fill", color: FlatColors.amethyst)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Sodium", value: "\(Int(meal.sodium))mg", icon: "drop.fill", color: FlatColors.sky)

            Text("Vitamins")
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textPrimary)
                .padding(.top, 16)
                .padding(.bottom, 6)

            nutrientRow(name: "Vitamin A", value: "\(Int(meal.vitaminA)) mcg", icon: "eye.fill", color: FlatColors.tangerine)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin C", value: "\(Int(meal.vitaminC)) mg", icon: "pills.fill", color: FlatColors.sunflower)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin D", value: String(format: "%.1f mcg", meal.vitaminD), icon: "sun.max.fill", color: FlatColors.tangerine)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin B6", value: String(format: "%.1f mg", meal.vitaminB6), icon: "bolt.heart.fill", color: FlatColors.sky)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Vitamin B12", value: String(format: "%.1f mcg", meal.vitaminB12), icon: "heart.fill", color: FlatColors.coral)

            Text("Minerals")
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textPrimary)
                .padding(.top, 16)
                .padding(.bottom, 6)

            nutrientRow(name: "Potassium", value: "\(Int(meal.potassium)) mg", icon: "battery.75percent", color: FlatColors.tangerine)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Iron", value: String(format: "%.1f mg", meal.iron), icon: "cross.vial.fill", color: FlatColors.coral)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Calcium", value: "\(Int(meal.calcium)) mg", icon: "bone.fill", color: FlatColors.textSecondary)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Magnesium", value: "\(Int(meal.magnesium)) mg", icon: "sparkles", color: FlatColors.amethyst)
            FlatDivider().padding(.vertical, 10)
            nutrientRow(name: "Zinc", value: String(format: "%.1f mg", meal.zinc), icon: "shield.fill", color: FlatColors.mint)
        }
        .flatCard(cornerRadius: 14, padding: 20)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.4), value: appeared)
    }

    private func nutrientRow(name: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            FlatIconCircle(icon: icon, color: color, size: 30)

            Text(name)
                .font(FlatFont.body(15))
                .foregroundStyle(FlatColors.textPrimary)

            Spacer()

            Text(value)
                .font(FlatFont.heading(15))
                .foregroundStyle(FlatColors.textSecondary)
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            onSave()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                Text("Save Meal")
                    .font(FlatFont.heading(17))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(FlatColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(FlatScaleButtonStyle())
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
    }
}

#Preview {
    MealDetailView(
        meal: Meal.sampleMeals[0],
        capturedImage: nil,
        onSave: {}
    )
}
