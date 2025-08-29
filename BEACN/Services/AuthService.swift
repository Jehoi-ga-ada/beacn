//
//  AuthService.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import Foundation
import Supabase

// MARK: - Protocol
protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> Session
    func signUp(email: String, password: String) async throws -> Session
    func signOut() async throws
    func getCurrentUser() -> User?
    func getCurrentSession() async throws -> Session?
}

// MARK: - Service
final class AuthService: AuthServiceProtocol {
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws -> Session {
        return try await supabase.auth.signIn(
            email: email,
            password: password
        )
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) async throws -> Session {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        guard let session = response.session else {
            throw AuthError.noSession
        }
        return session
    }

    // MARK: - Sign Out
    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    // MARK: - Current User
    func getCurrentUser() -> User? {
        return supabase.auth.currentUser
    }

    // MARK: - Current Session
    func getCurrentSession() async throws -> Session? {
        return try await supabase.auth.session
    }
}

// MARK: - Custom Errors
enum AuthError: LocalizedError {
    case noSession
    case noUser

    var errorDescription: String? {
        switch self {
        case .noSession:
            return "No valid session returned."
        case .noUser:
            return "No user found in session."
        }
    }
}
