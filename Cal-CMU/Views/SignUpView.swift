import SwiftUI

struct SignUpView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                FlatColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(FlatFont.title(26))
                                .foregroundStyle(FlatColors.textPrimary)

                            Text("Start tracking your nutrition today")
                                .font(FlatFont.body(15))
                                .foregroundStyle(FlatColors.textSecondary)
                        }

                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(FlatFont.label(13))
                                    .foregroundStyle(FlatColors.textSecondary)

                                TextField("you@example.com", text: $email)
                                    .textContentType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .font(FlatFont.body(16))
                                    .padding(14)
                                    .background(FlatColors.inputBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(FlatFont.label(13))
                                    .foregroundStyle(FlatColors.textSecondary)

                                SecureField("At least 6 characters", text: $password)
                                    .textContentType(.newPassword)
                                    .font(FlatFont.body(16))
                                    .padding(14)
                                    .background(FlatColors.inputBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirm Password")
                                    .font(FlatFont.label(13))
                                    .foregroundStyle(FlatColors.textSecondary)

                                SecureField("Re-enter password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .font(FlatFont.body(16))
                                    .padding(14)
                                    .background(FlatColors.inputBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            if let error = localError ?? auth.errorMessage {
                                Text(error)
                                    .font(FlatFont.caption(13))
                                    .foregroundStyle(FlatColors.coral)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }

                            Button {
                                attemptSignUp()
                            } label: {
                                HStack(spacing: 8) {
                                    if auth.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Create Account")
                                        .font(FlatFont.heading(16))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(FlatColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(auth.isLoading)
                            .padding(.top, 8)
                        }
                        .flatCard(cornerRadius: 16, padding: 20)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(FlatFont.body(15))
                        .foregroundStyle(FlatColors.textSecondary)
                }
            }
        }
    }

    private func attemptSignUp() {
        localError = nil

        guard password == confirmPassword else {
            localError = "Passwords do not match."
            return
        }

        Task {
            await auth.signUp(email: email, password: password)
            if auth.isAuthenticated {
                dismiss()
            }
        }
    }
}

#Preview {
    SignUpView()
        .environment(AuthManager())
}
