//
//  ParentView.swift
//  BEACN
//
//  Created by Jehoiada Wong on 30/08/25.
//

import SwiftUI
struct ParentView: View {
    @State private var savedPhoto: UIImage?
    @State private var showingCamera = false
    @State private var navigateToNextView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("BEACN Camera Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Photo display area
                Group {
                    if let photo = savedPhoto {
                        VStack(spacing: 10) {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text("Photo captured successfully!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 250)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No photo captured yet")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            )
                    }
                }
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    if savedPhoto != nil {
                        Button(action: {
                            navigateToNextView = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Process Photo")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationDestination(isPresented: $navigateToNextView) {
                NextPageView(capturedPhoto: savedPhoto)
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraCaptureView(
                onPhotoCapture: { capturedImage in
                    // Save the captured image to parent view's state
                    savedPhoto = capturedImage
                    savePhotoToUserDefaults(capturedImage)
                    print("📸 Photo captured and saved!")
                },
                onNavigateNext: {
                    // Navigate to next page
                    print("🚀 Navigating to next view...")
                    showingCamera = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navigateToNextView = true
                    }
                }
            )
        }
    }
    
    private func savePhotoToUserDefaults(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "savedPhoto")
            print("💾 Photo saved to UserDefaults")
        }
    }
}

struct NextPageView: View {
    let capturedPhoto: UIImage?
    @Environment(\.dismiss) var dismiss
    @State private var analysisResult: String?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 25) {
            Text("Photo Processing")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            if let photo = capturedPhoto {
                VStack(spacing: 15) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)

                    if isLoading {
                        ProgressView("Analyzing photo…")
                    } else if let analysisResult = analysisResult {
                        Text("Detected Disaster:")
                            .font(.headline)
                        Text(analysisResult)
                            .font(.body)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

            HStack(spacing: 20) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(minWidth: 100)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }

                Button(action: {
                    Task { await analyzePhoto() }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Process")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(minWidth: 100)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func analyzePhoto() async {
        guard let photo = capturedPhoto else {
            errorMessage = "No photo provided"
            return
        }

        isLoading = true
        errorMessage = nil
        analysisResult = nil

        do {
            let result = try await OllamaService.shared.analyzeImage(photo)
            await MainActor.run {
                self.analysisResult = result
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }
}
