import SwiftUI

struct MacroBarView: View {
    let label: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color

    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(FlatFont.label(13))
                    .foregroundStyle(FlatColors.textSecondary)

                Spacer()

                Text("\(Int(current))\(unit)")
                    .font(FlatFont.label(13))
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                +
                Text(" / \(Int(goal))\(unit)")
                    .font(FlatFont.caption(11))
                    .foregroundStyle(FlatColors.textTertiary)
            }

            FlatProgressBar(progress: animatedProgress, color: color, height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: current) { _, _ in
            withAnimation(.easeOut(duration: 0.3)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MacroBarView(label: "Protein", current: 75, goal: 150, unit: "g", color: FlatColors.ocean)
        MacroBarView(label: "Carbs", current: 122, goal: 250, unit: "g", color: FlatColors.tangerine)
        MacroBarView(label: "Fat", current: 46, goal: 65, unit: "g", color: FlatColors.rose)
    }
    .padding()
}
