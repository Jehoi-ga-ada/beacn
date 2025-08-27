//
//  MapVM.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI

class MapVM: ObservableObject {
    let coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
