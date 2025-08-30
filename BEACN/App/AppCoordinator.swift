//
//  AppCoordinator.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .onboarding
    
    // Optional reference to AuthViewModel - will be set from outside (tdk paham)
    private var authVM: AuthViewModel?
    
    init() {
        // We'll set authVM after initialization (tdk paham jga)
    }
    
    func setAuthVM(_ authVM: AuthViewModel) {
        self.authVM = authVM
        checkAuthState()
    }
    
    private func checkAuthState() {
        // If there's already a session (from previous app launch), go to map
        if authVM?.session != nil {
            currentView = .map
        }
    }
    
    func start() -> some View {
        switch currentView {
        case .onboarding:
            return AnyView(
                OnboardingView()
                    .onChange(of: authVM?.session) { session in
                        if session != nil {
                            // Login success - navigate to map
                            self.currentView = .map
                        }
                    }
            )
        case .map:
            return AnyView(MapView(viewModel: MapVM(coordinator: self)))
        case .notifications:
            return AnyView(NotificationListView(viewModel: NotificationVM(coordinator: self)))
        case .sampleLogin:
            return AnyView(SampleLoginView())
        }
    }
    
    func navigateToMap() {
        currentView = .map
    }
    
    func navigateToNotifications() {
        currentView = .notifications
    }
    
    func navigateToOnboarding() {
        currentView = .onboarding
    }
    
    func signOut() {
        Task {
            await authVM?.signOut()
            await MainActor.run {
                currentView = .onboarding
            }
        }
    }
}

enum AppView {
    case onboarding, map, notifications, sampleLogin
}
