import SwiftUI

struct StreakBadgeView: View {
    let streakDays: Int

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(FlatColors.tangerine.opacity(0.12))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(FlatColors.tangerine)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakDays) Day Streak")
                    .font(FlatFont.heading(16))
                    .foregroundStyle(FlatColors.textPrimary)

                Text("Keep it going!")
                    .font(FlatFont.caption(12))
                    .foregroundStyle(FlatColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(day < streakDays % 7 || streakDays >= 7
                              ? FlatColors.tangerine
                              : FlatColors.divider)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .flatCard(cornerRadius: 12, padding: 16)
    }
}

#Preview {
    StreakBadgeView(streakDays: 7)
        .padding()
}
