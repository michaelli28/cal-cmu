import SwiftUI

struct CameraView: View {
    let mealType: MealType
    let onMealCaptured: (UIImage, ScanSource) -> Void
    let onMenuItemSelected: ((Meal) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var showRestaurantPicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera
    @State private var activeScanSource: ScanSource = .receipt

    var body: some View {
        NavigationStack {
            ZStack {
                FlatColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Hero area
                    VStack(spacing: 18) {
                        FlatIconCircle(icon: "doc.text.viewfinder", color: FlatColors.ocean, size: 80)

                        VStack(spacing: 6) {
                            Text("Scan your receipt")
                                .font(FlatFont.heading(18))
                                .foregroundStyle(FlatColors.textPrimary)

                            Text("Snap a receipt or upload a screenshot for exact ingredient tracking")
                                .font(FlatFont.body(13))
                                .foregroundStyle(FlatColors.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }

                        FlatBadge(text: mealType.rawValue, color: mealType.flatColor, icon: mealType.icon)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(FlatColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 28)

                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            activeScanSource = .receipt
                            pickerSource = .camera
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Scan Receipt")
                                    .font(FlatFont.heading(17))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(FlatColors.ocean)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(FlatScaleButtonStyle())

                        Button {
                            activeScanSource = .screenshot
                            pickerSource = .photoLibrary
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.on.rectangle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Upload Receipt Screenshot")
                                    .font(FlatFont.heading(17))
                            }
                            .foregroundStyle(FlatColors.amethyst)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(FlatColors.amethyst.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(FlatColors.amethyst.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(FlatScaleButtonStyle())

                        Button {
                            activeScanSource = .photo
                            pickerSource = .camera
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Take Food Photo")
                                    .font(FlatFont.heading(17))
                            }
                            .foregroundStyle(FlatColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(FlatColors.inputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(FlatScaleButtonStyle())

                        // CMU Dining divider
                        HStack(spacing: 12) {
                            FlatDivider()
                            Text("or")
                                .font(FlatFont.caption(12))
                                .foregroundStyle(FlatColors.textTertiary)
                            FlatDivider()
                        }
                        .padding(.vertical, 4)

                        Button {
                            showRestaurantPicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Browse CMU Dining")
                                    .font(FlatFont.heading(17))
                            }
                            .foregroundStyle(FlatColors.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(FlatColors.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(FlatColors.primary.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(FlatScaleButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 36)
                }
            }
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
                    Text("Log Meal")
                        .font(FlatFont.heading(17))
                        .foregroundStyle(FlatColors.textPrimary)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSource) { image in
                    onMealCaptured(image, activeScanSource)
                    dismiss()
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showRestaurantPicker) {
                RestaurantPickerView(mealType: mealType) { meal in
                    onMenuItemSelected?(meal)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CameraView(mealType: .lunch, onMealCaptured: { _, _ in }, onMenuItemSelected: nil)
}
