//
//  PoseEstimator.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import Vision
import CoreImage

/// Service responsible for detecting human poses in video frames
class PoseEstimator {
    
    // MARK: - Properties
    
    private var request: VNDetectHumanBodyPoseRequest
    
    // MARK: - Initialization
    
    init() {
        self.request = VNDetectHumanBodyPoseRequest()
        self.request.revision = VNDetectHumanBodyPoseRequestRevision1
    }
    
    // MARK: - Public Methods
    
    /// Detects human pose in a given pixel buffer
    /// - Parameter pixelBuffer: The video frame to process
    /// - Returns: Detected pose model or nil if no pose found
    func detectPose(in pixelBuffer: CVPixelBuffer) async throws -> PoseModel? {
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            do {
                try handler.perform([request])
                
                guard let observation = request.results?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let poseModel = parsePose(from: observation)
                continuation.resume(returning: poseModel)
            } catch {
                continuation.resume(throwing: PoseEstimationError.frameProcessingFailed)
            }
        }
    }
    
    /// Detects human pose in a CIImage
    /// - Parameter image: The image to process
    /// - Returns: Detected pose model or nil if no pose found
    func detectPose(in image: CIImage) async throws -> PoseModel? {
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            
            do {
                try handler.perform([request])
                
                guard let observation = request.results?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let poseModel = parsePose(from: observation)
                continuation.resume(returning: poseModel)
            } catch {
                continuation.resume(throwing: PoseEstimationError.frameProcessingFailed)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Parses a Vision observation into our PoseModel structure
    private func parsePose(from observation: VNHumanBodyPoseObservation) -> PoseModel {
        var keypoints: [VNHumanBodyPoseObservation.JointName: Keypoint] = [:]
        
        // Extract all available joints
        for jointName in VNHumanBodyPoseObservation.JointName.allJoints {
            guard let recognizedPoint = try? observation.recognizedPoint(jointName) else {
                continue
            }
            
            let keypoint = Keypoint(
                id: jointName,
                point: recognizedPoint.location,
                confidence: recognizedPoint.confidence
            )
            
            keypoints[jointName] = keypoint
        }
        
        return PoseModel(keypoints: keypoints)
    }
}

