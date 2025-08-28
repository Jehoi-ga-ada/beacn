//
//  BeaconSearchBar.swift
//  BEACN
//
//  Created by Jessica Lynn on 28/08/25.
//
import SwiftUI

struct BeaconSearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @FocusState<Bool>.Binding var searchFieldFocused: Bool
    var showsCancel: Bool = false
    var onCancel: (() -> Void)?
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search places…", text: $text, onEditingChanged: { editing in
                    if editing {
                        withAnimation {
                            isSearching = true
                        }
                    }
                })
                .focused($searchFieldFocused)
                .foregroundColor(.primary)
                .accentColor(.blue)
                .padding(.vertical, 8)
                .onSubmit {
                    onSubmit?()   // trigger callback on Return
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.85))
            .cornerRadius(30)
            .shadow(radius: 3)
            
            if showsCancel {
                Button("Cancel") {
                    onCancel?()
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: showsCancel)
    }
}
