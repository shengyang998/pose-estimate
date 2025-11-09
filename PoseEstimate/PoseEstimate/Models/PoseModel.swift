//
//  PoseModel.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import Vision

/// Represents a complete detected human pose with all keypoints
struct PoseModel: Identifiable {
    let id = UUID()
    let keypoints: [VNHumanBodyPoseObservation.JointName: Keypoint]
    let timestamp: Date
    
    init(keypoints: [VNHumanBodyPoseObservation.JointName: Keypoint]) {
        self.keypoints = keypoints
        self.timestamp = Date()
    }
    
    /// Get a specific keypoint by joint name
    func keypoint(for joint: VNHumanBodyPoseObservation.JointName) -> Keypoint? {
        return keypoints[joint]
    }
    
    /// Check if a specific joint is available and reliable
    func hasReliableKeypoint(for joint: VNHumanBodyPoseObservation.JointName) -> Bool {
        guard let keypoint = keypoints[joint] else { return false }
        return keypoint.isReliable
    }
}

/// Defines connections between body joints for skeleton rendering
struct SkeletonConnection {
    let from: VNHumanBodyPoseObservation.JointName
    let to: VNHumanBodyPoseObservation.JointName
    
    static let allConnections: [SkeletonConnection] = [
        // Head connections
        SkeletonConnection(from: .nose, to: .neck),
        SkeletonConnection(from: .leftEye, to: .nose),
        SkeletonConnection(from: .rightEye, to: .nose),
        SkeletonConnection(from: .leftEar, to: .leftEye),
        SkeletonConnection(from: .rightEar, to: .rightEye),
        
        // Torso connections
        SkeletonConnection(from: .neck, to: .leftShoulder),
        SkeletonConnection(from: .neck, to: .rightShoulder),
        SkeletonConnection(from: .leftShoulder, to: .leftHip),
        SkeletonConnection(from: .rightShoulder, to: .rightHip),
        SkeletonConnection(from: .leftHip, to: .rightHip),
        
        // Left arm
        SkeletonConnection(from: .leftShoulder, to: .leftElbow),
        SkeletonConnection(from: .leftElbow, to: .leftWrist),
        
        // Right arm
        SkeletonConnection(from: .rightShoulder, to: .rightElbow),
        SkeletonConnection(from: .rightElbow, to: .rightWrist),
        
        // Left leg
        SkeletonConnection(from: .leftHip, to: .leftKnee),
        SkeletonConnection(from: .leftKnee, to: .leftAnkle),
        
        // Right leg
        SkeletonConnection(from: .rightHip, to: .rightKnee),
        SkeletonConnection(from: .rightKnee, to: .rightAnkle)
    ]
}

