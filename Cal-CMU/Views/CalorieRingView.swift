import SwiftUI

struct CalorieRingView: View {
    let consumed: Int
    let goal: Int

    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(consumed) / Double(goal), 1.0)
    }

    private var remaining: Int {
        max(goal - consumed, 0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FlatColors.primary.opacity(0.12), lineWidth: 20)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(FlatColors.primary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(consumed)")
                    .font(FlatFont.title(38))
                    .foregroundStyle(FlatColors.textPrimary)
                    .contentTransition(.numericText())

                Text("of \(goal) cal")
                    .font(FlatFont.label(14))
                    .foregroundStyle(FlatColors.textSecondary)

                Text("\(remaining) left")
                    .font(FlatFont.caption(12))
                    .foregroundStyle(FlatColors.textTertiary)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: consumed) { _, _ in
            withAnimation(.easeOut(duration: 0.4)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    CalorieRingView(consumed: 1210, goal: 2000)
        .padding()
}
