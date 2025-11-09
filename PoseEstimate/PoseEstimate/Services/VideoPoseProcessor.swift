//
//  VideoPoseProcessor.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import AVFoundation
import CoreMedia
import Combine

/// Result of processing a single video frame
struct ProcessedFrame {
    let time: CMTime
    let pose: PoseModel?
}

/// Processes all frames in a video and caches pose results
class VideoPoseProcessor: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var processingProgress: Double = 0.0
    @Published var isProcessing = false
    @Published var isComplete = false
    
    // MARK: - Private Properties
    
    private var processedFrames: [ProcessedFrame] = []
    private var processingTask: Task<Void, Error>?
    private let poseEstimator = PoseEstimator()
    
    // MARK: - Public Methods
    
    /// Process all frames in video asset
    func processVideo(asset: AVAsset) async throws {
        await MainActor.run {
            isProcessing = true
            isComplete = false
            processingProgress = 0.0
            processedFrames.removeAll()
        }
        
        // Get video track
        let tracks = try await asset.load(.tracks)
        var videoTrack: AVAssetTrack?
        
        for track in tracks {
            if track.mediaType == .video {
                videoTrack = track
                break
            }
        }
        
        guard let videoTrack = videoTrack else {
            throw PoseEstimationError.videoLoadFailed
        }
        
        let duration = try await asset.load(.duration)
        let frameRate: Float = 10.0 // Process 10 frames per second
        let totalFrames = Int(CMTimeGetSeconds(duration) * Double(frameRate))
        
        print("VideoPoseProcessor: Processing \(totalFrames) frames...")
        
        // Create asset reader
        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
        reader.add(readerOutput)
        reader.startReading()
        
        var processedCount = 0
        var lastProcessTime = CMTime.zero
        let frameDuration = CMTime(seconds: 1.0 / Double(frameRate), preferredTimescale: 600)
        
        // Process frames
        while reader.status == .reading {
            // Check if task is cancelled
            try Task.checkCancellation()
            
            guard let sampleBuffer = readerOutput.copyNextSampleBuffer() else {
                break
            }
            
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            
            // Skip frames to match desired frame rate
            if CMTimeCompare(presentationTime, CMTimeAdd(lastProcessTime, frameDuration)) < 0 {
                continue
            }
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                continue
            }
            
            // Detect pose
            let pose = try? await poseEstimator.detectPose(in: pixelBuffer)
            
            let frame = ProcessedFrame(time: presentationTime, pose: pose)
            processedFrames.append(frame)
            
            lastProcessTime = presentationTime
            processedCount += 1
            
            // Update progress
            let progress = min(Double(processedCount) / Double(totalFrames), 1.0)
            await MainActor.run {
                processingProgress = progress
            }
        }
        
        reader.cancelReading()
        
        print("VideoPoseProcessor: Completed processing \(processedCount) frames")
        
        await MainActor.run {
            isProcessing = false
            isComplete = true
            processingProgress = 1.0
        }
    }
    
    /// Get the closest processed pose for a given time
    func getPose(at time: CMTime) -> PoseModel? {
        guard !processedFrames.isEmpty else { return nil }
        
        // Binary search for closest frame
        var closestFrame: ProcessedFrame?
        var minDiff = CMTime.positiveInfinity
        
        for frame in processedFrames {
            let diff = CMTimeAbsoluteValue(CMTimeSubtract(frame.time, time))
            if CMTimeCompare(diff, minDiff) < 0 {
                minDiff = diff
                closestFrame = frame
            }
        }
        
        return closestFrame?.pose
    }
    
    /// Cancel processing
    func cancel() {
        print("VideoPoseProcessor: Cancelling processing")
        processingTask?.cancel()
        processingTask = nil
        
        Task { @MainActor in
            isProcessing = false
        }
    }
    
    /// Clear cached frames
    func clear() {
        print("VideoPoseProcessor: Clearing cached frames")
        processedFrames.removeAll()
        
        Task { @MainActor in
            processingProgress = 0.0
            isComplete = false
        }
    }
}

