//
//  Keypoint.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation
import Vision

/// Represents a single body keypoint detected by the pose estimation model
struct Keypoint: Identifiable {
    let id: VNHumanBodyPoseObservation.JointName
    let point: CGPoint
    let confidence: Float
    
    /// Whether this keypoint should be considered reliable for rendering
    var isReliable: Bool {
        confidence > 0.1
    }
}

/// Names for all body joints detected by Vision framework
extension VNHumanBodyPoseObservation.JointName {
    static let allJoints: [VNHumanBodyPoseObservation.JointName] = [
        .nose,
        .leftEye, .rightEye,
        .leftEar, .rightEar,
        .neck,
        .leftShoulder, .rightShoulder,
        .leftElbow, .rightElbow,
        .leftWrist, .rightWrist,
        .root,
        .leftHip, .rightHip,
        .leftKnee, .rightKnee,
        .leftAnkle, .rightAnkle
    ]
}

