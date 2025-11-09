//
//  PoseEstimationError.swift
//  PoseEstimate
//
//  Created by Soleil Yu on 2025/11/9.
//

import Foundation

enum PoseEstimationError: Error, LocalizedError {
    case cameraPermissionDenied
    case cameraConfigurationFailed
    case videoLoadFailed
    case modelInitializationFailed
    case frameProcessingFailed
    case noPoseDetected
    
    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission was denied. Please enable camera access in Settings."
        case .cameraConfigurationFailed:
            return "Failed to configure camera. Please try again."
        case .videoLoadFailed:
            return "Failed to load video file."
        case .modelInitializationFailed:
            return "Failed to initialize pose estimation model."
        case .frameProcessingFailed:
            return "Failed to process video frame."
        case .noPoseDetected:
            return "No human pose detected in frame."
        }
    }
}

