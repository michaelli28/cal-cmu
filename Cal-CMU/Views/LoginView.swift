import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var auth
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                FlatColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 40)

                        // Logo / Header
                        VStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(FlatColors.primary)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundStyle(.white)
                                )

                            Text("Cal-CMU")
                                .font(FlatFont.title(28))
                                .foregroundStyle(FlatColors.textPrimary)

                            Text("Track your meals with AI")
                                .font(FlatFont.body(15))
                                .foregroundStyle(FlatColors.textSecondary)
                        }

                        // Form Card
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

                                SecureField("••••••••", text: $password)
                                    .textContentType(.password)
                                    .font(FlatFont.body(16))
                                    .padding(14)
                                    .background(FlatColors.inputBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            if let error = auth.errorMessage {
                                Text(error)
                                    .font(FlatFont.caption(13))
                                    .foregroundStyle(FlatColors.coral)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }

                            Button {
                                Task { await auth.signIn(email: email, password: password) }
                            } label: {
                                HStack(spacing: 8) {
                                    if auth.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Sign In")
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

                        // Sign Up Link
                        HStack(spacing: 4) {
                            Text("Don\'t have an account?")
                                .font(FlatFont.body(14))
                                .foregroundStyle(FlatColors.textSecondary)

                            Button("Sign Up") {
                                showSignUp = true
                            }
                            .font(FlatFont.heading(14))
                            .foregroundStyle(FlatColors.primary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
