import SwiftUI

@main
struct Cal_CMUApp: App {
    @State private var mealStore = MealStore()
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    ZStack {
                        FlatColors.background.ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                } else if authManager.isAuthenticated {
                    if mealStore.hasCompletedOnboarding {
                        MainTabView()
                            .environment(mealStore)
                            .environment(authManager)
                            .preferredColorScheme(mealStore.useDarkMode ? .dark : .light)
                    } else {
                        OnboardingView {
                            withAnimation(.easeOut(duration: 0.3)) {
                                mealStore.hasCompletedOnboarding = true
                            }
                        }
                        .environment(mealStore)
                        .environment(authManager)
                    }
                } else {
                    LoginView()
                        .environment(authManager)
                }
            }
            .task {
                await authManager.restoreSession()
                if let userId = authManager.userId {
                    await mealStore.loadAllData(userId: userId)
                }
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated, let userId = authManager.userId {
                    Task {
                        await mealStore.loadAllData(userId: userId)
                    }
                }
            }
        }
    }
}
