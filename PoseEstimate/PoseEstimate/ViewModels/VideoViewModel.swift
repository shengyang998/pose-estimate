//
//  VideoViewModel.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import AVFoundation
import PhotosUI
import SwiftUI
import Combine

/// ViewModel for video-based pose estimation
@MainActor
class VideoViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var detectedPose: PoseModel?
    @Published var error: PoseEstimationError?
    @Published var videoPlayerManager = VideoPlayerManager()
    @Published var selectedItem: PhotosPickerItem?
    @Published var poseProcessor = VideoPoseProcessor()
    @Published var isLoadingVideo = false
    
    // MARK: - Private Properties
    
    private var currentAsset: AVAsset?
    private var frameUpdateTimer: Timer?
    
    // MARK: - Initialization
    
    init() {
        // Initialization
    }
    
    // MARK: - Public Methods
    
    /// Handle video selection from photo picker
    func handleVideoSelection() async {
        guard let selectedItem = selectedItem else { return }
        
        // Show loading indicator
        isLoadingVideo = true
        
        // Clean up previous video state
        stopFrameUpdates()
        poseProcessor.cancel()
        poseProcessor.clear()
        videoPlayerManager.cleanup()
        detectedPose = nil
        
        do {
            print("VideoViewModel: Loading transferable...")
            guard let movie = try await selectedItem.loadTransferable(type: VideoTransferable.self) else {
                error = .videoLoadFailed
                isLoadingVideo = false
                return
            }
            
            print("VideoViewModel: Loading video from \(movie.url)")
            
            // Load video
            try await videoPlayerManager.loadVideo(from: movie.url)
            
            // Hide loading indicator
            isLoadingVideo = false
            
            // Load asset for processing
            currentAsset = AVAsset(url: movie.url)
            
            // Start background processing
            if let asset = currentAsset {
                Task.detached { [weak self] in
                    do {
                        try await self?.poseProcessor.processVideo(asset: asset)
                        
                        // Start frame updates after processing completes
                        await MainActor.run {
                            self?.startFrameUpdates()
                        }
                    } catch {
                        print("Video processing failed: \(error)")
                    }
                }
            }
        } catch {
            self.error = .videoLoadFailed
            isLoadingVideo = false
        }
    }
    
    /// Start updating pose from cached frames
    func startFrameUpdates() {
        stopFrameUpdates()
        
        // Update pose from cache at 10 Hz
        frameUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePoseFromCache()
        }
    }
    
    /// Stop frame updates
    func stopFrameUpdates() {
        frameUpdateTimer?.invalidate()
        frameUpdateTimer = nil
    }
    
    /// Clean up resources
    func cleanup() {
        stopFrameUpdates()
        poseProcessor.cancel()
        poseProcessor.clear()
        videoPlayerManager.cleanup()
        currentAsset = nil
    }
    
    // MARK: - Private Methods
    
    private func updatePoseFromCache() {
        let currentTime = videoPlayerManager.currentTime
        detectedPose = poseProcessor.getPose(at: currentTime)
    }
}

/// Transferable type for video files
struct VideoTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = URL.temporaryDirectory.appending(path: "video.mov")
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}

