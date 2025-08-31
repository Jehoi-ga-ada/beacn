//
//  CameraCaptureView.swift
//  BEACN
//
//  Created by Jehoiada Wong on 30/08/25.
//

import SwiftUI

struct CameraCaptureView: View {
    @State private var isShowingCamera = true
    @State private var capturedImage: UIImage? = nil
    @Environment(\.dismiss) var dismiss
    
    let onPhotoCapture: ((UIImage) -> Void)?
    let onNavigateNext: (() -> Void)?
    
    init(onPhotoCapture: ((UIImage) -> Void)? = nil, onNavigateNext: (() -> Void)? = nil) {
        self.onPhotoCapture = onPhotoCapture
        self.onNavigateNext = onNavigateNext
    }
    
    var body: some View {
        ZStack {
            if let image = capturedImage {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                    
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            } else {
                if isShowingCamera {
                    Color.black.ignoresSafeArea()
                } else {
                    Color.clear
                        .onAppear {
                            dismiss()
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            ImagePickerView(
                image: $capturedImage,
                isPresented: $isShowingCamera,
                onPhotoCapture: onPhotoCapture,
                onNavigateNext: onNavigateNext
            )
            .ignoresSafeArea()
        }
    }
}
