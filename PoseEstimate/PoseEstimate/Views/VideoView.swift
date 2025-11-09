//
//  VideoView.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import SwiftUI
import PhotosUI

/// Main video view with pose overlay
struct VideoView: View {
    @StateObject private var viewModel = VideoViewModel()
    
    var body: some View {
        ZStack {
            if let player = viewModel.videoPlayerManager.player {
                // Video player
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
                
                // Skeleton overlay with video orientation (only show after processing)
                if viewModel.poseProcessor.isComplete {
                    SkeletonOverlayView(
                        pose: viewModel.detectedPose,
                        orientation: viewModel.videoPlayerManager.videoOrientation
                    )
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                }
                
                // Video selection button overlay
                VStack {
                    HStack {
                        Spacer()
                        PhotosPicker(
                            selection: $viewModel.selectedItem,
                            matching: .videos
                        ) {
                            Image(systemName: "video.badge.plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            } else {
                // Video selection view
                VStack(spacing: 20) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Select a Video")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Choose a video from your photo library to analyze human poses.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    PhotosPicker(
                        selection: $viewModel.selectedItem,
                        matching: .videos
                    ) {
                        Label("Choose Video", systemImage: "video.badge.plus")
                            .font(.headline)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .loading(
            viewModel.isLoadingVideo,
            message: "加载视频中..."
        )
        .loading(
            viewModel.poseProcessor.isProcessing,
            message: "处理视频中...",
            progress: viewModel.poseProcessor.processingProgress
        )
        .onChange(of: viewModel.selectedItem) { _, _ in
            Task {
                await viewModel.handleVideoSelection()
            }
        }
        .onDisappear {
            viewModel.cleanup()
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

#Preview {
    VideoView()
}

