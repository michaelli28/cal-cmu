import Foundation
import Supabase
import SwiftUI

@Observable
class AuthManager {
    var session: Session?
    var isLoading = true
    var errorMessage: String?

    var isAuthenticated: Bool { session != nil }

    var userEmail: String {
        session?.user.email ?? ""
    }

    var userId: UUID? {
        session?.user.id
    }

    // MARK: - Restore Session

    func restoreSession() async {
        isLoading = true
        defer { isLoading = false }
        do {
            session = try await SupabaseConfig.client.auth.session
        } catch {
            session = nil
        }
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        do {
            let response = try await SupabaseConfig.client.auth.signUp(
                email: email,
                password: password
            )
            session = response.session
            // Profile is auto-created by DB trigger
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        do {
            session = try await SupabaseConfig.client.auth.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign Out

    func signOut(mealStore: MealStore) async {
        do {
            try await SupabaseConfig.client.auth.signOut()
            await MainActor.run {
                withAnimation(.spring(response: 0.4)) {
                    session = nil
                }
                mealStore.reset()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
