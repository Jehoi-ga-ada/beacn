//
//  AppCoordinator.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .onboarding
    
    func start() -> some View {
        switch currentView {
        case .onboarding:
            return AnyView(OnboardingView(viewModel: OnboardingVM(coordinator: self)))
        case .map:
            return AnyView(MapView(viewModel: MapVM(coordinator: self)))
        case .notifications:
            return AnyView(NotificationListView(viewModel: NotificationVM(coordinator: self)))
        }
    }
}

enum AppView {
    case onboarding, map, notifications
}

