//
//  AuthService.swift
//  Runways App
//

import Foundation
import Auth
import Supabase

@Observable
final class AuthService {
    private(set) var currentUser: User?
    private(set) var session: Session?
    private(set) var authError: String?

    private let client = SupabaseClient.shared
    private var authStateTask: Task<Void, Never>?

    init() {
        currentUser = nil
        session = nil
        authError = nil
        authStateTask = Task { [weak self] in
            await self?.observeAuthState()
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    private func observeAuthState() async {
        for await (_, session) in client.auth.authStateChanges {
            await MainActor.run {
                self.session = session
                self.currentUser = session?.user
                self.authError = nil
            }
        }
    }

    var isSignedIn: Bool {
        currentUser != nil
    }

    func signUp(email: String, password: String) async {
        authError = nil
        do {
            _ = try await client.auth.signUp(email: email, password: password)
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
        }
    }

    func signIn(email: String, password: String) async {
        authError = nil
        do {
            _ = try await client.auth.signIn(email: email, password: password)
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
        }
    }

    func signOut() async {
        authError = nil
        do {
            try await client.auth.signOut()
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
        }
    }

    func clearError() {
        authError = nil
    }
}
