//
//  MyProfileView.swift
//  BEACN
//
//  Created by Jehoiada Wong on 30/08/25.
//

import SwiftUI
import Foundation

struct MyProfileView: View {
    @StateObject var vm: MyProfileViewModel = MyProfileViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Profile Header Section
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        // Profile Picture Placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                        
                        // User Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(vm.user?.email?.split(separator: "@").first ?? "Username")")
                                .font(.headline)
                                .fontWeight(.medium)
                            Text("Free Plan")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Upgrade Button
                        Button(action: {
                            // Handle upgrade action
                        }) {
                            Text("Upgrade")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Settings Section
                VStack(spacing: 0) {
                    // Settings Header
                    HStack {
                        Text("Settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 8)
                    
                    // Notifications Row
                    NavigationLink(destination: NotificationsView()) {
                        HStack {
                            Text("Notifications")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Account Section
                VStack(spacing: 0) {
                    // Account Header
                    HStack {
                        Text("Account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 8)
                    
                    // Log Out Button
                    Button(action: {
                        Task {
                            try await coordinator.signOut()
                        }
                    }) {
                        HStack {
                            Text("Log Out")
                                .font(.body)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// Placeholder for NotificationsView
struct NotificationsView: View {
    var body: some View {
        VStack {
            Text("Notifications Settings")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MyProfileView()
}
