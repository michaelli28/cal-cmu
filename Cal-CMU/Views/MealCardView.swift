import SwiftUI

struct MealCardView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if let image = meal.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(meal.mealType.flatColor.opacity(0.12))
                        Image(systemName: "fork.knife")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(meal.mealType.flatColor.opacity(0.5))
                    }
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(FlatFont.body(15))
                    .fontWeight(.semibold)
                    .foregroundStyle(FlatColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    FlatBadge(text: meal.mealType.rawValue, color: meal.mealType.flatColor, icon: meal.mealType.icon)
                    FlatBadge(text: meal.scanSource == .photo ? "Photo" : "Receipt", color: meal.scanSource.flatColor, icon: meal.scanSource.icon)

                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                        Text("\(meal.calories) cal")
                            .font(FlatFont.caption())
                    }
                    .foregroundStyle(FlatColors.textSecondary)
                    .fixedSize()
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                macroPill("P", value: Int(meal.protein), color: FlatColors.ocean)
                macroPill("C", value: Int(meal.carbs), color: FlatColors.tangerine)
                macroPill("F", value: Int(meal.fat), color: FlatColors.rose)
            }
        }
        .flatCard(cornerRadius: 12, padding: 14)
    }

    private func macroPill(_ letter: String, value: Int, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(letter)
                .font(FlatFont.caption(10))
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text("\(value)g")
                .font(FlatFont.caption(10))
                .foregroundStyle(FlatColors.textSecondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .fixedSize()
    }
}

#Preview {
    MealCardView(meal: Meal.sampleMeals[0])
        .padding()
        .background(FlatColors.background)
}
