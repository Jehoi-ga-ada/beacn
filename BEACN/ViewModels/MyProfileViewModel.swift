//
//  MyProfileViewModel.swift
//  BEACN
//
//  Created by Jehoiada Wong on 30/08/25.
//

import Foundation
import Supabase

class MyProfileViewModel: ObservableObject {
    let authService: AuthService = AuthService()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var user: User?
    
    init() {
        user = authService.getCurrentUser()
    }
    
    func logOut() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signOut()
                user = nil
                isLoading = false
                // Navigation back to login screen should be handled by the parent view
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
