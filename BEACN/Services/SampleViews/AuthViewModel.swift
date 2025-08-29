//
//  AuthViewModel.swift
//  BEACN
//
//  Created by Jehoiada Wong on 28/08/25.
//


//
//  AuthViewModel.swift
//  YourApp
//

import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var session: Session?
    @Published var errorMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func signIn() async {
        do {
            let loggedInUser = try await authService.signIn(email: email, password: password)
            self.session = loggedInUser
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signUp() async {
        do {
            let newUser = try await authService.signUp(email: email, password: password)
            self.session = newUser
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            self.session = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
