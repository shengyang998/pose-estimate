//
//  CameraView.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI

/// Main camera view with real-time pose detection
struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.permissionGranted {
                // Camera preview
                CameraPreviewView(session: viewModel.getCaptureSession())
                    .ignoresSafeArea()
                
                // Skeleton overlay
                // Camera uses landscapeRight (no rotation) because AVCaptureSession
                // outputs portrait-oriented frames already
                SkeletonOverlayView(
                    pose: viewModel.detectedPose,
                    orientation: .landscapeRight
                )
                .ignoresSafeArea()
                
                // Processing indicator
                if viewModel.isProcessing {
                    VStack {
                        Spacer()
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Processing...")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .padding()
                        .background(.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding()
                    }
                }
            } else {
                // Permission request view
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("This app needs camera access to detect and display human poses in real-time.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button("Grant Camera Access") {
                        Task {
                            await viewModel.requestPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            }
        }
        .task {
            await viewModel.requestPermission()
            // Start capture after permission is granted and setup is complete
            if viewModel.permissionGranted {
                viewModel.startCapture()
            }
        }
        .onAppear {
            // Only start if already configured and permission granted
            if viewModel.permissionGranted {
                viewModel.startCapture()
            }
        }
        .onDisappear {
            viewModel.stopCapture()
        }
        .alert(item: Binding(
            get: { viewModel.error.map { ErrorWrapper(error: $0) } },
            set: { _ in viewModel.error = nil }
        )) { wrapper in
            Alert(
                title: Text("Error"),
                message: Text(wrapper.error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Wrapper to make PoseEstimationError identifiable for alerts
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: PoseEstimationError
}

#Preview {
    CameraView()
}
