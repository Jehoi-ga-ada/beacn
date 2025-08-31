//
//  EditPlaceOverlayView.swift
//  BEACN
//
//  Created by Jessica Lynn on 31/08/25.
//

import SwiftUI

struct EditPlaceOverlayView: View {
    @ObservedObject var viewModel: MapVM
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isEmojiFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                VStack (){
                    HStack {
                        Text("Add to Saved Place")
                            .font(.footnote)
                            .fontWeight(.regular)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    HStack {
                        Text(viewModel.editingPlace?.name ?? viewModel.pendingPlace?.name ?? "New Place")
                            .font(.title)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                HStack{
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Icon")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        
                        TextField("📍", text: $viewModel.selectedEmoji)
                            .focused($isEmojiFieldFocused)
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                            .frame(width: 80, height: 38)
                            .background(Color.clear)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isEmojiFieldFocused ? Color.blue : Color.gray, lineWidth: 2)
                            )
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Label")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        TextField("ex. Home, Work, Sam's School", text: $viewModel.editPlaceName)
                            .focused($isTextFieldFocused)
                            .multilineTextAlignment(.center)
                            .frame(width: 200, height: 38)
                            .background(Color.clear)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isTextFieldFocused ? Color.blue : Color.gray, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Button("Cancel") {
                        dismissOverlay()
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40)
                    .background(Color.white)
                    .fontWeight(.medium)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                    Button("Save") {
                        savePlace()
//                        viewModel.saveEditedPlace(pending)
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 50)
                    .background(Color(hex: "005DAD"))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .disabled(viewModel.editPlaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
            .background(Color.white)
            .cornerRadius(30)
            .padding(.horizontal, 16)
            .shadow(radius: 10)
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight * 0.3 : 0)
            .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .transition(.move(edge: .bottom))
        .zIndex(5)
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isTextFieldFocused = false
            isEmojiFieldFocused = false
        }
    }
    
    private func dismissOverlay() {
        isTextFieldFocused = false
        isEmojiFieldFocused = false
        viewModel.showEditPlaceSheet = false
        viewModel.editingPlace = nil
        viewModel.editPlaceName = ""
        viewModel.selectedEmoji = "📍"
    }
    
    private func savePlace() {
        guard !viewModel.editPlaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if viewModel.selectedEmoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewModel.selectedEmoji = "📍"
        }
        
        viewModel.saveEditedPlace()
        isTextFieldFocused = false
        isEmojiFieldFocused = false
    }
}

struct EditPlaceOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        EditPlaceOverlayView(viewModel: MapVM(coordinator: AppCoordinator()))
            .background(Color.gray.opacity(0.3))
    }
}
