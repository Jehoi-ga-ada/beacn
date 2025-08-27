//
//  NotificationVM.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI

class NotificationVM: ObservableObject {
    let coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
