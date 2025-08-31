//
//  SampleLoginView.swift
//  BEACN
//
//  Created by Jehoiada Wong on 28/08/25.
//

import SwiftUI
import Foundation

struct SampleLoginView: View {
    @StateObject private var vm = AuthViewModel()

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $vm.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)

            Button("Sign In") {
                Task { await vm.signIn() }
            }

            Button("Sign Up") {
                Task { await vm.signUp() }
            }

            if let error = vm.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}
