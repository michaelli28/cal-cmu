import SwiftUI

struct WaterTrackerView: View {
    @Environment(MealStore.self) private var store
    @State private var showCustomInput = false
    @State private var customValue: String = ""
    @FocusState private var isInputFocused: Bool

    private let quickAmounts = [1, 2, 4]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(alignment: .top) {
                FlatIconCircle(icon: "drop.fill", color: FlatColors.sky, size: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Water Intake")
                        .font(FlatFont.heading(16))
                        .foregroundStyle(FlatColors.textPrimary)
                    Text("glasses (8 oz each)")
                        .font(FlatFont.caption(12))
                        .foregroundStyle(FlatColors.textTertiary)
                }
                Spacer()
            }

            // Large number display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if showCustomInput {
                    TextField("0", text: $customValue)
                        .font(FlatFont.title(32))
                        .foregroundStyle(FlatColors.sky)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 60)
                        .focused($isInputFocused)
                        .onSubmit { commitCustomValue() }
                        .onChange(of: isInputFocused) { _, focused in
                            if !focused { commitCustomValue() }
                        }
                } else {
                    Text("\(store.waterIntake)")
                        .font(FlatFont.title(32))
                        .foregroundStyle(FlatColors.sky)
                        .onTapGesture {
                            customValue = "\(store.waterIntake)"
                            showCustomInput = true
                            isInputFocused = true
                        }
                }

                Text("/ \(store.waterGoal)")
                    .font(FlatFont.body(18))
                    .foregroundStyle(FlatColors.textTertiary)

                Spacer()

                // Approximate oz display
                VStack(alignment: .trailing, spacing: 2) {
                    Text("≈ \(store.waterIntake * 8) oz")
                        .font(FlatFont.mono(14))
                        .foregroundStyle(FlatColors.textSecondary)
                    Text("of \(store.waterGoal * 8) oz goal")
                        .font(FlatFont.caption(11))
                        .foregroundStyle(FlatColors.textTertiary)
                }
            }

            // Progress bar
            FlatProgressBar(
                progress: Double(store.waterIntake) / Double(max(store.waterGoal, 1)),
                color: FlatColors.sky,
                height: 8
            )

            FlatDivider()

            // Quick-add buttons
            HStack(spacing: 10) {
                // Minus button
                Button {
                    store.removeWater()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("1")
                            .font(FlatFont.label(13))
                    }
                    .foregroundStyle(FlatColors.textSecondary)
                    .frame(height: 36)
                    .frame(maxWidth: .infinity)
                    .background(FlatColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Quick-add amounts
                ForEach(quickAmounts, id: \.self) { amount in
                    Button {
                        addGlasses(amount)
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .semibold))
                            Text("\(amount)")
                                .font(FlatFont.label(13))
                        }
                        .foregroundStyle(.white)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(amount == 1 ? FlatColors.sky : FlatColors.sky.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            // Tap-to-edit hint
            if !showCustomInput {
                Text("Tap the number to type a custom value")
                    .font(FlatFont.caption(11))
                    .foregroundStyle(FlatColors.textTertiary)
            }
        }
        .flatCard(cornerRadius: 12, padding: 18)
    }

    private func addGlasses(_ count: Int) {
        withAnimation(.easeOut(duration: 0.2)) {
            store.waterIntake = min(store.waterIntake + count, 99)
        }
        Task { await store.saveWaterLogManually() }
    }

    private func commitCustomValue() {
        showCustomInput = false
        guard let value = Int(customValue) else { return }
        let clamped = max(0, min(value, 99))
        withAnimation(.easeOut(duration: 0.2)) {
            store.waterIntake = clamped
        }
        Task { await store.saveWaterLogManually() }
    }
}

#Preview {
    WaterTrackerView()
        .padding()
        .background(FlatColors.background)
        .environment(MealStore())
}
