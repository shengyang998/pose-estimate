//
//  VideoPlayerManager.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import AVFoundation
import Combine
import CoreImage

/// Manages video playback and frame extraction
class VideoPlayerManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: CMTime = .zero
    @Published var duration: CMTime = .zero
    @Published var videoOrientation: VideoOrientation = .portrait
    
    // MARK: - Private Properties
    
    private var timeObserver: Any?
    private var videoOutput: AVPlayerItemVideoOutput?
    private let videoOutputQueue = DispatchQueue(label: "com.poseestimate.video.output")
    
    // MARK: - Public Methods
    
    /// Load a video from URL
    func loadVideo(from url: URL) async throws {
        let asset = AVAsset(url: url)
        
        // Check if video is playable
        let isPlayable = try await asset.load(.isPlayable)
        guard isPlayable else {
            throw PoseEstimationError.videoLoadFailed
        }
        
        // Load duration
        let loadedDuration = try await asset.load(.duration)
        
        // Load video tracks to get orientation
        let tracks = try await asset.load(.tracks)
        var detectedOrientation: VideoOrientation = .portrait
        
        // Find video track and get orientation
        for track in tracks {
            if track.mediaType == .video {
                let transform = try await track.load(.preferredTransform)
                detectedOrientation = VideoOrientation.from(transform: transform)
                print("VideoPlayerManager: Detected orientation - \(detectedOrientation)")
                break
            }
        }
        
        // Create player item
        let playerItem = AVPlayerItem(asset: asset)
        
        // Set up video output for frame extraction
        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: outputSettings)
        if let videoOutput = videoOutput {
            playerItem.add(videoOutput)
        }
        
        // Create player
        await MainActor.run {
            player = AVPlayer(playerItem: playerItem)
            duration = loadedDuration
            videoOrientation = detectedOrientation
            setupTimeObserver()
        }
    }
    
    /// Play the video
    func play() {
        player?.play()
        isPlaying = true
    }
    
    /// Pause the video
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    /// Seek to a specific time
    func seek(to time: CMTime) async {
        await player?.seek(to: time)
        currentTime = time
    }
    
    /// Get the current video frame as a pixel buffer
    func getCurrentFrame() -> CVPixelBuffer? {
        guard let videoOutput = videoOutput,
              let player = player,
              let currentItem = player.currentItem else {
            return nil
        }
        
        let currentTime = currentItem.currentTime()
        
        guard videoOutput.hasNewPixelBuffer(forItemTime: currentTime) else {
            return nil
        }
        
        return videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil)
    }
    
    /// Clean up resources
    func cleanup() {
        print("VideoPlayerManager: Cleaning up resources")
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        player?.pause()
        player = nil
        videoOutput = nil
        currentTime = .zero
        duration = .zero
        isPlaying = false
        videoOrientation = .portrait
    }
    
    // MARK: - Private Methods
    
    private func setupTimeObserver() {
        // Update current time periodically
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time
        }
    }
    
    deinit {
        cleanup()
    }
}

